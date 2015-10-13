//
//  modelAssociateDB.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "modelAssociateDB.h"
#import "valueTransform.h"
#import "WWDBValueAdapter.h"
#import "WWExceptionAndError.h"
@implementation modelAssociateDB

#pragma mark - init methods;
- (instancetype)init
{
    if (self = [super init]) {
        _dbInstance = [[WWDatabase alloc]init];
    }
    return self;
}

- (instancetype)initWithDBName:(NSString *)name
{
    if (self = [super init]) {
        _dbInstance = [[WWDatabase alloc]initWithName:name];
    }
    return self;
}

- (instancetype)initWithDBPath:(NSString *)path
{
    if (self = [super init]) {
        _dbInstance = [[WWDatabase alloc]initWithPath:path];
    }
    return self;
}

#pragma mark - sql methods for model
- (BOOL)saveModel:(id<JsonModelProtocol>)model
{
    if (isNull(model)) {
        WWExceptionLog(@"you can't svae a nil model object");
        return NO;
    }
    
    [self createTableUseModel:model];
    
    jsonModel * JMTemp = (jsonModel *)model;
    
    if (JMTemp.existInDB) {
        //already exist in database,update record;
        [self updateToNewModel:model];
        return NO;
    }
    else
    {
        //bulid insert sql and then execute it;
        NSArray * properties = allPropertyNames(model);
        
        NSMutableArray * valueDescripte = [NSMutableArray array];
        for ( int i = 0; i<properties.count; i++) {
            [valueDescripte addObject:@"?"];
        }
        
        NSString * tableName =[NSString stringWithCString:object_getClassName(model) encoding:NSUTF8StringEncoding];
        
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) values(%@)", tableName , [properties componentsJoinedByString:@","], [valueDescripte componentsJoinedByString:@","]];
        
        NSArray * values = allPropertyValues(model);
        NSArray * paramters = [WWDBValueAdapter buildSqlParamWithDictionary:values];
        [_dbInstance executeSql:sql paramters:paramters];
    }
    
    [JMTemp setPrimaryKey:[_dbInstance lastInsertRowID]];
    [JMTemp setExistInDB:YES];
    return YES;
}


- (NSArray *)selectAll:(Class)modelClass
{
    NSString * sql =  [NSString stringWithFormat:@"SELECT * FROM %@", NSStringFromClass(modelClass)];
    NSArray * sqlResult = [_dbInstance  executeSql:sql];
    
    NSMutableArray * models = [[NSMutableArray alloc]initWithCapacity:sqlResult.count];
    
    for (NSDictionary * dictionary in sqlResult) {
        
        NSDictionary * modelDict = [WWDBValueAdapter extractSQLDictionary:dictionary forModelClass:modelClass];
        id model = [[modelClass alloc]initWithDictionary:modelDict];
        jsonModel *JMTemp = (jsonModel *)model;
        [JMTemp setPrimaryKey:[dictionary[@"primaryKey"] integerValue]];
        [JMTemp setExistInDB:YES];
        
        [models addObject:model];
    }
    
    return models;
}

#pragma mark - private method

- (void)createTableUseModel:(id<JsonModelProtocol>) model;
{
    //check table already exist?
    NSString * tableName =[NSString stringWithCString:object_getClassName(model) encoding:NSUTF8StringEncoding] ;
    NSArray * alltable = [_dbInstance allTable];
    
    for (NSDictionary * dict in alltable) {
        if ([dict[@"name"] isEqualToString:tableName]) {
            return;
        }
    }
    
    //execute create table sql
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (primaryKey integer primary key autoincrement, %@)", tableName , [allPropertyNames(model) componentsJoinedByString:@","]];
    [_dbInstance executeSql:sql];
}

- (NSArray *) bulidTableSQLProperty:(id<JsonModelProtocol>) model
{
    NSMutableArray * tableProperty = [NSMutableArray array];
    
    unsigned int propertyCount = 0;
    
    objc_property_t * propertiesTemp = class_copyPropertyList([model class], &propertyCount);
    
    for (unsigned int i = 0; i<propertyCount; i++) {
        
        objc_property_t  property = propertiesTemp[i];
        
        NSDictionary * dict =  [valueTransform propertyInfoFromProperty:property];
        
        NSString * propertySQLType = [WWDBValueAdapter sqliteTypeByProperty:[dict[constant_propertyType] integerValue]];
        
        const char * propertyName = property_getName(property);
        
        NSString * bulidStr = [NSString stringWithFormat:@"%@ %@",[NSString stringWithUTF8String:propertyName],propertySQLType];
        
        [tableProperty addObject:bulidStr];
    }
    
    free(propertiesTemp);
    
    return tableProperty;
}
@end

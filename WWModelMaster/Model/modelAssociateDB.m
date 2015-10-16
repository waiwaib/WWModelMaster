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
        WWExceptionLog(@"you can't save a nil model object");
        return NO;
    }
    
    [self createTableUseModel:model];
    
    jsonModel * JMTemp = (jsonModel *)model;
    
    if (JMTemp.existInDB) {
        //already exist in database,update record;
        [self updateModel:model];
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
        NSArray * paramters = [WWDBValueAdapter buildSqlParamWithSoruce:values];
        [_dbInstance executeSql:sql paramters:paramters];
    }
    
    [JMTemp setPrimaryKey:[_dbInstance lastInsertRowID]];
    [JMTemp setExistInDB:YES];
    return YES;
}


- (NSArray *)selectAll:(NSString *)tableName
{
    return [self selectWithModelTable:tableName where:nil groupBy:nil];
}

- (id<JsonModelProtocol>)findWithModelTable:(NSString *)tableName withPrimary:(NSUInteger)primary
{
    NSArray * models = [self selectWithModelTable:tableName where:@{defualtPrimayKey:[NSNumber numberWithUnsignedInteger:primary]} groupBy:nil];
    return models.count ? [models firstObject] : nil;
}

- (NSArray *)selectWithModelTable:(NSString *)tableName where:(NSDictionary *)where groupBy:(NSString *)group
{
    //bulid sql and execute sql
    NSString * whereSql = [self bulidWhereString:where];
    NSString * groupSql = isNull(group) ? @"": [NSString stringWithFormat:@"GROUP BY %@",group];
    
    NSString * sql =  [NSString stringWithFormat:@"SELECT * FROM %@ %@ %@", tableName,whereSql,groupSql];
    NSArray * sqlResult = [_dbInstance  executeSql:sql];
    
    //tranfer dictionary objects to models;
    NSMutableArray * models = [[NSMutableArray alloc]initWithCapacity:sqlResult.count];
    
    for (NSDictionary * dictionary in sqlResult) {
        
        NSDictionary * modelDict = [WWDBValueAdapter extractSQLDictionary:dictionary forModelClass:NSClassFromString(tableName)];
        id model = [[NSClassFromString(tableName) alloc]initWithDictionary:modelDict];
        jsonModel *JMTemp = (jsonModel *)model;
        [JMTemp setPrimaryKey:[dictionary[defualtPrimayKey] integerValue]];
        [JMTemp setExistInDB:YES];
        
        [models addObject:model];
    }
    
    return models;
}

- (BOOL)deleteModel:(id<JsonModelProtocol>)model
{
    jsonModel * JM = (jsonModel *)model;
    if (!JM.existInDB) {
        WWExceptionLog(@"the model object you delete is not exist in DB");
        return NO;
    }
    
    return [self deleteWithModelTable:JM.tableName where:@{defualtPrimayKey:[NSNumber numberWithUnsignedInteger:JM.primaryKey]}];
}

- (BOOL) deleteWithModelTable:(NSString *)tableName where:(NSDictionary *)where
{
    //bulid sql and execute sql
    NSString * whereSql = [self bulidWhereString:where];
    NSString * sql =  [NSString stringWithFormat:@"DELETE FROM %@ %@", tableName,whereSql];
    
    [_dbInstance executeSql:sql];
    return YES;
}

- (BOOL)updateModel:(id<JsonModelProtocol>)newModel
{
    if (isNull(newModel)) {
        WWExceptionLog(@"you can't update a nil model object");
        return NO;
    }
    jsonModel * JM = (jsonModel *)newModel;
    if (!JM.existInDB) {
        WWExceptionLog(@"the model object you want update is not exist in DB,now try to store it to database");
        return [self saveModel:newModel];
    }
    else
    {
        return [self updateWithModelTable:JM.tableName Content:[newModel toDictionary] where:@{defualtPrimayKey:[NSNumber numberWithInteger:JM.primaryKey]}];
    }
}

- (BOOL)updateWithModelTable:(NSString *) tableName Content:(NSDictionary *)updateContent where:(NSDictionary *)where
{
    if (isNull(updateContent)) {
        WWExceptionLog(@"you can't use update content with  nil NSDictionary");
        return NO;
    }
    //get sql param names and values
    NSArray * paramNames = [updateContent allKeys];
    NSArray * paramValues = [WWDBValueAdapter buildSqlParamWithSoruce:[updateContent allValues]];
    
    NSString * setContent = [[paramNames componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
    
    NSString * whereSql = [self bulidWhereString:where];
    
    if (isNull(whereSql)) {
        WWExceptionLog(@"you can't execute the sql with a illegal where clauses");
        return NO;
    }
    
    NSString * sql =  [NSString stringWithFormat:@"UPDATE %@ SET %@ %@", tableName,setContent,whereSql];
    
    [_dbInstance executeSql:sql paramters:paramValues];
    
    return YES;
}

#pragma mark - private method
/**
 *  根据model创建表
 *
 *  @param model
 */
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

/**
 *  根据model构建表的创建类型描叙 array
 *
 *  @param model
 *
 *  @return
 */
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

/**
 *  将where判断dictionary转为string描述,这里支持 NSNumber,NSString 类型的where条件;
 *
 *  @param where
 *
 *  @return 结果;
 */
- (NSString *) bulidWhereString:(NSDictionary *)where
{
    if (isNull(where)) {
        return @"";
    }
    
    NSMutableString * result = [NSMutableString string];
    
    __block BOOL firstItemAdd;
    
    [where enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            
            [result appendString:firstItemAdd ? [NSString stringWithFormat:@"AND %@ = '%@'",key,obj] : [NSString stringWithFormat:@"WHERE %@ = '%@'",key,obj]];
            firstItemAdd = YES;
        }
        else if ([obj isKindOfClass:[NSNumber class]])
        {
            [result appendString:firstItemAdd ? [NSString stringWithFormat:@"AND %@ = %f",key,[obj doubleValue]] : [NSString stringWithFormat:@"WHERE %@ = %f",key,[obj doubleValue]]];
            firstItemAdd = YES;
        }
        else
        {
            WWErrorLog(@"you had provide a error format 'where' dictionary");
            return;
        }
    }];
    return result;
}
@end

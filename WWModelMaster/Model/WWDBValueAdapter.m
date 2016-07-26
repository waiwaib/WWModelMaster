//
//  WWDBValueAdapter.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "WWDBValueAdapter.h"
#import "WWExceptionAndError.h"
@implementation WWDBValueAdapter

+ (NSString *)sqliteTypeByProperty:(propertyType)type
{
    switch (type) {
        case propertyTypeString:
        {
            return @"TEXT";
        }
        case propertyTypeInt:
        {
            return @"INTEGER";
        }
        case propertyTypeBool:
        {
            return @"INTEGER";
        }
        case propertyTypeDictionary:
        {
            return @"BLOB";
        }
        case propertyTypeArrray:
        {
            return @"BLOB";
        }
        case propertyTypeModel:
        {
            return @"BLOB";
        }
        case propertyTypeNumber:
        {
            return @"REAL";
        }
        default:
            return @"NULL";
            break;
    }
    return @"TEXT";
}

+ (NSArray *)buildSqlParamWithSoruce:(NSArray *)source
{
    NSMutableArray * paramters = [[NSMutableArray alloc]initWithArray:source copyItems:YES];
    for (int i = 0; i<paramters.count; i++) {
        id obj = [paramters objectAtIndex:i];
        //经常遇到需要做处理的几个类型
        
        @try {
            NSError * err;
            if ([obj isKindOfClass:[NSDictionary class]]) {
                NSData * objData;
                objData = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:&err];
                if (err) {
                    throwException(@"exception", err.description);
                }
                else
                {
                    [paramters replaceObjectAtIndex:i withObject:objData];
                }
            }
            else if ([obj isKindOfClass:[NSArray class]])
            {
                NSData * objData;
                objData = [NSKeyedArchiver archivedDataWithRootObject:obj];
                [paramters replaceObjectAtIndex:i withObject:objData];
            }
            else if ([obj isKindOfClass:[NSDate class]])
            {
                NSNumber * dateNum = [NSNumber numberWithDouble:[obj timeIntervalSince1970]];
                [paramters replaceObjectAtIndex:i withObject:dateNum];
            }
            else if ([obj isKindOfClass:[jsonModel class]])
            {
                NSData * objData;
                objData = [NSJSONSerialization dataWithJSONObject:[obj toDictionary] options:kNilOptions error:&err];
                if (err) {
                    throwException(@"exception", err.description);
                }
                else
                {
                    [paramters replaceObjectAtIndex:i withObject:objData];
                }
            }
            else
            {
                
            }
        }
        @catch (NSException *exception) {
            WWExceptionLog(exception.description);
        }
        @finally {
            
        }
        
    }
    return paramters;
}
+ (NSDictionary *)extractSQLDictionary:(NSDictionary *)soruce forModelClass:(Class)modelClass
{
    NSMutableDictionary * modelDict = [[NSMutableDictionary alloc]initWithDictionary:soruce copyItems:YES];
    
    [soruce enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        objc_property_t property = class_getProperty(modelClass , [key cStringUsingEncoding:NSUTF8StringEncoding]);
        
        NSDictionary * propertyInfo = [valueTransform propertyInfoFromProperty:property];
        
        switch ([[propertyInfo objectForKey:constant_propertyType]integerValue]) {
            case propertyTypeDictionary:
            {
                
                if (isNull(obj)) {
                    WWExceptionLog(@"data can't be nil");
                    break;
                }
                
                NSError * serialErr;
                
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingMutableContainers error:&serialErr];
                
                if(serialErr) {
                    WWErrorLog(serialErr.description);
                }
                else
                {
                    [modelDict setObject:dict forKey:key];
                }
                break;
            }
            case propertyTypeArrray:
            {
                if (isNull(obj)) {
                    WWExceptionLog(@"data can't be nil");
                    break;
                }
                NSArray * array = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
                if (array) {
                    [modelDict setObject:array forKey:key];
                }
                else
                {
                    WWExceptionLog(@"sqlite data transform to array appear a exception");
                }
                break;
            }
            case propertyTypeModel:
            {
                NSString * modelName=  propertyInfo[constant_propertyClassName];
                id <JsonModelProtocol> model = [[NSClassFromString(modelName) alloc]initWithData:obj];
                if (model) {
                    [modelDict setObject:model forKey:key];
                }
                else
                {
                    WWExceptionLog(@"sqlite data transform to model object appear a exception");
                }
                break;
            }
            case propertyTypeDate:
            {
                NSDate * date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
                [modelDict setObject:date forKey:key];
                break;
            }
                
            default:
                break;
        }
    }];
    return modelDict;
}

+ (NSDictionary *)transferNormarlDictionaryToSqlDictionary:(NSDictionary *)soruce
{
    return nil;
}
@end

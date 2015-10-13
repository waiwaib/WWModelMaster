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

+ (NSArray *)buildSqlParamWithDictionary:(NSArray *)source
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
//                NSMutableData * data = [[NSMutableData alloc] init];
//                NSKeyedArchiver * archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//                [archiver encodeObject:obj forKey:@"Some Key Value"];
//                [archiver finishEncoding];
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
@end

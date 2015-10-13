//
//  WWDBValueAdapter.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "valueTransform.h"
#import "jsonModel.h"
/**
 *  一个用来适配sqlite Value与Model Value的工具类
 */
@interface WWDBValueAdapter : NSObject

/**
 *  根据model propertyType给出正确的数据库存储形式
 *
 *  @param  type
 *
 *  @return 数据库存放形式
 */
+ (NSString *)sqliteTypeByProperty:(propertyType) type;

/**
 *  将source转为提供给sqlite的NSArray;
 *
 *  @param source 待转化NSArray
 *
 *  @return 提供给sqlite的paramters
 */
+ (NSArray *)buildSqlParamWithDictionary:(NSArray *)source;

/**
 *  将sqlite查询出来的dictionary转化为可以对model对象进行赋值的dictionary;
 *
 *  @param soruce     查询出来的dictionary
 *  @param modelClass model类型class
 *
 *  @return 结果dictionary
 */
+ (NSDictionary *)extractSQLDictionary:(NSDictionary *)soruce forModelClass:(Class) modelClass;
@end

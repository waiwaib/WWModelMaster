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
@end

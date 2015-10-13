//
//  modelAssociateDB.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WWDatabase.h"
#import "jsonModel.h"

/**
 *  提供了简单基本的几个model类型在 sqlite中的使用方法,包括增加,删除,更新,查询;如果需要自我执行更多的sql类型,请自己声明WWDatabase对象,open数据库,执行sql语句;
 */
@interface modelAssociateDB : NSObject
/** WWDatabase instance */
@property (nonatomic , retain) WWDatabase * dbInstance;

- (instancetype)init;

- (instancetype)initWithDBName:(NSString *) name;

- (instancetype)initWithDBPath:(NSString *) path;


- (BOOL)saveModel:(id<JsonModelProtocol>) model;

- (BOOL)deleteModel:(id<JsonModelProtocol>) model;

- (BOOL)updateToNewModel:(id<JsonModelProtocol>) newModel;

- (NSArray *)selectAll:(Class) modelClass;

- (id)findWithPrimary:(NSUInteger) primary;
@end

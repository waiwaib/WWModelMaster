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
 *  连接WWDatabase 与 Model 的类,提供了简单基本的几个model类型在 sqlite中的使用方法,包括增加,删除,更新,查询;如果需要自我执行更多的sql类型,请自己声明WWDatabase对象,执行sql语句;
 */
@interface modelAssociateDB : NSObject

/** WWDatabase instance */
@property (nonatomic , retain) WWDatabase * dbInstance;

/**
 *  初始化model-database连接对象,连接默认数据库
 */
- (instancetype)init;

/**
 *  根据需要连接到的 database 名字初始化model-database连接对象;
 *
 *  @param name database名字
 */
- (instancetype)initWithDBName:(NSString *) name;

/**
 *  根据需要连接到的 database 路径初始化model-database连接对象;
 *
 *  @param name database路径
 */
- (instancetype)initWithDBPath:(NSString *) path;

/************************ model sql method ************************/
 
/**
 *  保存一个model对象到数据库;(已存在即更新)
 *
 *  @param model 待存储model对象
 *
 *  @return 成功与否
 */
- (BOOL)saveModel:(id<JsonModelProtocol>) model;

/**
 *  从数据库删除一个model对象;
 *
 *  @param model 待删除对象
 *
 *  @return 成功与否
 */
- (BOOL)deleteModel:(id<JsonModelProtocol>) model;

/**
 *  更新一个在数据库中存在的model对象;(不存在即保存)
 *
 *  @param newModel
 *
 *  @return 成功与否
 */
- (BOOL)updateModel:(id<JsonModelProtocol>) newModel;

/**
 *  根据查询where从句来更新数据库记录,
 *
 *  @param tableName     要更新的model类tableName
 *  @param updateContent 更新内容模块
 *  @param where         sql where条件dictionary
 *
 *  @return 成功与否
 */
- (BOOL)updateWithModelTable:(NSString *) tableName Content:(NSDictionary *) updateContent where:(NSDictionary *) where;

/**
 *  根据model tableNmae找出数据库中的所有该类记录;
 *
 *  @param modelClass 要查询的model类tableName
 *
 *  @return 结果model数组
 */
- (NSArray *)selectAll:(NSString *) tableName;

/**
 *  根据主键rowId和model类查询精确目标model对象
 *
 *  @param modelClass model查询目标class
 *  @param primary    主键
 *
 *  @return 结果model
 */
- (id<JsonModelProtocol>)findModel:(Class) modelClass  withPrimary:(NSUInteger) primary;
@end

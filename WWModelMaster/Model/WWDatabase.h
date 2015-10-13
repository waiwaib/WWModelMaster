//
//  WWDatabase.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface WWDatabase : NSObject
{
    sqlite3 * dataBase;
    NSString * dbPath;
    NSString * dbName;
}
/** 使用默认初始方法,DB名称为"DB" */
- (instancetype)init;

/** 初始化DB,提供DB名字 */
- (instancetype)initWithName:(NSString *)name;

/** 初始化DB,提供DB路径 */
- (instancetype)initWithPath:(NSString *)path;

/** 打开DB,建立连接 */
- (void)open;

/** 关闭连接 */
- (void)close;

/** 获取最后一个插入的rowID */
- (NSUInteger)lastInsertRowID;

/** 执行sql */
- (NSArray *)executeSql:(NSString *)sql;

/** 执行带参数sql */
- (NSArray *)executeSql:(NSString *)sql paramters:(NSArray *)param;

/** 获取所有table */
- (NSArray *)allTable;
@end

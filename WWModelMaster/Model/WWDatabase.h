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
}
/** 初始化DB,提供DB名字 */
- (instancetype)initWithName:(NSString *)dbName;

/** 初始化DB,提供DB路径 */
- (instancetype)initwithPath:(NSString *)path;

/** 打开DB,建立连接 */
- (void)open;

/** 关闭连接 */
- (void)close;
@end

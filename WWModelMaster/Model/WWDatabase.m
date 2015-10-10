
//
//  WWDatabase.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "WWDatabase.h"

@implementation WWDatabase
- (instancetype)initWithName:(NSString *)dbName
{
    if (self = [super init]) {
        NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
        dbPath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",dbName]];
        [self open];
    }
    return self;
}

- (void)open
{
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    if (![fileMgr isExecutableFileAtPath:dbPath]) {
        
        @try {
            NSException *exception = [NSException exceptionWithName:@"HotTeaException" reason:@"The tea is too hot" userInfo:nil];
            @throw exception;
        }
        @catch (NSException *exception) {
            
        }
        
        if (sqlite3_open([dbPath UTF8String], &dataBase) != SQLITE_OK) {
            sqlite3_close(dataBase);
            NSLog(@"filed to open database");
        }
    }
}

- (void)close
{
    
}


@end

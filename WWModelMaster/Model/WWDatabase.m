
//
//  WWDatabase.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//
#define defualtDB  @"DB"

#import "WWDatabase.h"
#import "WWExceptionAndError.h"
@implementation WWDatabase

#pragma mark - init methods
- (instancetype) init
{
    return [self initWithName:defualtDB];
}

- (instancetype)initWithName:(NSString *)name
{
    
    NSString * docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0 ];
    NSString * path = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.db",name]];
    
    return [self initWithPath:path];
}

- (instancetype)initWithPath:(NSString *)path
{
    if (self = [super init]) {
        dbPath = [path copy];
        [self open];
    }
    return self;
}
#pragma mark - life cycle
-(void) dealloc
{
    [self close];
}

#pragma mark - sql methods
- (void)open
{
    //try to open database connection
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    if (![fileMgr isExecutableFileAtPath:dbPath]) {
        
        @try {
            if (sqlite3_open([dbPath UTF8String], &dataBase) != SQLITE_OK) {
                sqlite3_close(dataBase);
                throwException(@"openDBException", @"filed to open database");
            }
        }
        @catch (NSException *exception) {
            WWExceptionLog(exception.description);
        }
    }
}

- (void)close
{
    @try {
        if (sqlite3_close(dataBase) != SQLITE_OK) {
            throwException(@"closeDBException", @"filed to close database");
        }
    }
    @catch (NSException *exception) {
        WWExceptionLog(exception.description);
    }
    
}

- (NSUInteger)lastInsertRowID
{
    return (NSUInteger) sqlite3_last_insert_rowid(dataBase);
}

- (NSArray *)executeSql:(NSString *)sql
{
    return [self executeSql:sql paramters:nil];
}

- (NSArray *)executeSql:(NSString *)sql paramters:(NSArray *)param
{
    NSMutableArray * result = [[NSMutableArray alloc]init];
    
    sqlite3_stmt * stmt;
    
    NSArray * columnTypes;
    NSArray * columnNames;
    
    BOOL existColumnInfo = NO;
    if(sqlite3_prepare_v2(dataBase, [sql UTF8String], -1, &stmt, NULL) == SQLITE_OK)
    {
        [self bindStmt:stmt paramters:param];
        
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            if (!existColumnInfo) {
                columnTypes = [self  columnTypesByStmt:stmt];
                columnNames = [self columnNamesByStmt:stmt];
                existColumnInfo = YES;
            }
            [result addObject:[self copyValuesFromStatement:stmt columnTypes:columnTypes columnNames:columnNames]];
        }
    }
    else
    {
        NSString * sqliteErr = [NSString stringWithCString:sqlite3_errmsg(dataBase) encoding:NSUTF8StringEncoding];
        NSString * dbErrorDes =[NSString stringWithFormat:@"sqlite execute error:%@",sqliteErr] ;
        WWErrorLog(dbErrorDes);
    }
    sqlite3_finalize(stmt);//release  sqlite3 resoures;
    
    return result;
}

- (NSArray *)allTable
{
    NSString * sql = @"SELECT * FROM sqlite_master WHERE type = 'table'";
    return [self executeSql:sql];
}

#pragma mark - private method

- (NSArray *)columnTypesByStmt:(sqlite3_stmt *) stmt
{
    int columnCount = sqlite3_column_count(stmt);
    NSMutableArray *columnTypes = [[NSMutableArray alloc]init];
    for (int i=0; i < columnCount; i++) {
        [columnTypes addObject:[self typeForStatement:stmt atColumn:i]];
    }
    return columnTypes;
}
- (NSArray *)columnNamesByStmt:(sqlite3_stmt *) stmt
{
    int columnCount = sqlite3_column_count(stmt);
    NSMutableArray *columnNames = [[NSMutableArray alloc]init];
    for (int i=0; i < columnCount; i++) {
        [columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(stmt, i)]];
    }
    return columnNames;
}

-(NSNumber *)typeForStatement:(sqlite3_stmt *)statement atColumn:(int)column {
    const char* columnType = sqlite3_column_decltype(statement, column);
    
    if (columnType != NULL) {
        return [self columnTypeToNumber:[[NSString stringWithUTF8String:columnType] uppercaseString]];
    }
    
    return [NSNumber numberWithInt:sqlite3_column_type(statement, column)];
}

- (NSNumber *)columnTypeToNumber:(NSString *)columnType {
    NSDictionary * clumnTypeDic = @{@"INTEGER":@SQLITE_INTEGER,@"REAL":@SQLITE_FLOAT,@"TEXT":@SQLITE_TEXT,@"BLOB":@SQLITE_BLOB,@"NULL":@SQLITE_NULL};
    
    //defualt is @SQLITE_TEXT
    NSNumber * typeNum = @SQLITE_TEXT;
    
    if ([[clumnTypeDic allKeys]containsObject:columnType]) {
        typeNum = clumnTypeDic[columnType];
    }
    return typeNum;
}

-(NSDictionary *)copyValuesFromStatement:(sqlite3_stmt *)statement
                   columnTypes:(NSArray *)columnTypes
                   columnNames:(NSArray *)columnNames {
    
    int columnCount = sqlite3_column_count(statement);
    
    NSMutableDictionary * rowContent = [[NSMutableDictionary alloc]init];
    
    for (int i=0; i<columnCount; i++) {
        id value = [self valueFromStatement:statement column:i columnTypes:columnTypes];
        
        if (value != nil) {
            [rowContent setValue:value forKey:[columnNames objectAtIndex:i]];
        }
    }
    
    return rowContent;
}

-(id)valueFromStatement:(sqlite3_stmt *)statement column:(int)column columnTypes:(NSArray *)columnTypes {
    int columnType = [[columnTypes objectAtIndex:column] intValue];
    
    if (columnType == SQLITE_INTEGER) {
        return [NSNumber numberWithInt:sqlite3_column_int(statement, column)];
    } else if (columnType == SQLITE_FLOAT) {
        return [NSNumber numberWithDouble:sqlite3_column_double(statement, column)];
    } else if (columnType == SQLITE_TEXT) {
        const char* text = (const char *) sqlite3_column_text(statement, column);
        if (text != nil) {
            return [NSString stringWithUTF8String:text];
        } else {
            return @"";
        }
    } else if (columnType == SQLITE_BLOB) {
        // create an NSData object with the same size as the blob
        return [NSData dataWithBytes:sqlite3_column_blob(statement, column) length:sqlite3_column_bytes(statement, column)];
    } else if (columnType == SQLITE_NULL) {
        return nil;
    }
    
    return nil;
}

-(BOOL) bindStmt:(sqlite3_stmt *)stmt paramters:(NSArray *) paramters
{
    int expectBindNum = sqlite3_bind_parameter_count(stmt);
    if (expectBindNum != paramters.count) {
        WWExceptionLog(@"provide paramters not match expected bind number");
        return NO;
    }
    
    for (int i=1; i<=expectBindNum; i++) {
        id paramObj = [paramters objectAtIndex:i-1];
        if([paramObj isKindOfClass:[NSString class]])
            sqlite3_bind_text(stmt, i, [paramObj UTF8String], -1, SQLITE_TRANSIENT);
        else if([paramObj isKindOfClass:[NSData class]])
            sqlite3_bind_blob(stmt, i, [paramObj bytes], (int)[paramObj length], SQLITE_TRANSIENT);
        else if([paramObj isKindOfClass:[NSDate class]])
            sqlite3_bind_double(stmt, i, [paramObj timeIntervalSince1970]);
        else if([paramObj isKindOfClass:[NSNumber class]])
            sqlite3_bind_double(stmt, i, [paramObj doubleValue]);
        else if([paramObj isKindOfClass:[NSNull class]])
            sqlite3_bind_null(stmt, i);
        else {
            sqlite3_finalize(stmt);
            NSString * exceStr = [NSString stringWithFormat:@"Unrecognized object type at index %d",i];
            WWExceptionLog(exceStr);
            return NO;
        }
    }
    return YES;
}
@end

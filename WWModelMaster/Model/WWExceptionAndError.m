
//
//  WWExceptionAndError.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "WWExceptionAndError.h"

@implementation WWExceptionAndError

extern void throwException(NSString * name,NSString * des)
{
    NSException *exception = [NSException exceptionWithName:name reason:des userInfo:nil];
    @throw exception;
}
@end

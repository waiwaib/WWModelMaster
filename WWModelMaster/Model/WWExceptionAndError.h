//
//  WWExceptionAndError.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/10.
//  Copyright © 2015年 歪歪. All rights reserved.
//


#define WWErrorLog(errDsp) NSLog(@"method:%@ error -->%@",[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSASCIIStringEncoding],errDsp);
#define WWExceptionLog(expDsp) NSLog(@"method:%@ Exception -->%@",[NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSASCIIStringEncoding],expDsp);


#import <Foundation/Foundation.h>
/**
 *  this class design for deal exception and error,contains build object and print it;
 */
@interface WWExceptionAndError : NSObject

extern void throwException(NSString * name,NSString * des);

@end

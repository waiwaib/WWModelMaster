//
//  Model.m
//  WWModelTest
//
//  Created by 歪歪 on 15/9/23.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "Model.h"
#import <objc/runtime.h>

@implementation Model
-(id) init
{
    if (self = [super init]) {
        [self loadModel];
    }
    return self;
}

-(void) loadModel
{
    
}
@end

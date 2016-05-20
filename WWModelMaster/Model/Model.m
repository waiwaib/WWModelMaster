//
//  Model.m
//  WWModelTest
//
//  Created by 歪歪 on 15/9/23.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "Model.h"

@implementation Model
- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}
/**
 *  如果需要在model生成前设置一些内容,请在子类重写该函数
 */
- (void)beforeLoad
{
    
}
@end

//
//  Model.h
//  WWModelTest
//
//  Created by 歪歪 on 15/9/23.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "jsonModel.h"
/****************	Model	****************/

/**
 *  model类,提供了一个轻量级的Model基类实现;其他model请继承自该model
 */
@interface Model : jsonModel


/**
 *  该函数将在init返回前执行;
 */
-(void) loadModel;

@end

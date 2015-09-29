//
//  superModel.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/9/29.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "Model.h"
#import "testModel.h"
@interface superModel : Model

@property (nonatomic , retain) testModel * userInfo;
@property (nonatomic , retain) NSString * work;

@end

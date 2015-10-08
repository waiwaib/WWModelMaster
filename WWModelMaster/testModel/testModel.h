//
//  testModel.h
//  WWModelTest
//
//  Created by 歪歪 on 15/9/23.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "Model.h"
/**
 *  用户信息model
 */
@interface testModel : Model
@property (nonatomic , retain) NSString * name;
@property (nonatomic , retain) NSNumber * age;
@property (nonatomic , retain) NSString * livePlace;
@end

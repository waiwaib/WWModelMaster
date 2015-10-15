//
//  contactPersonModel.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/15.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "Model.h"
/**
 *  演示model,电话联系人列表
 */
@interface contactPersonModel : Model
/** 名字  */
@property (nonatomic , copy) NSString * name;
/** 电话号码  */
@property (nonatomic , copy) NSString * phone;
/** 所在城市  */
@property (nonatomic , copy) NSString * city;
/** 生日  */
@property (nonatomic , copy) NSDate * birthday;
@end

//
//  contactPersonModel.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/15.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "contactPersonModel.h"

@implementation contactPersonModel

- (NSString *)birthdayStr
{
    NSDateFormatter *dateInvFtr = [[NSDateFormatter alloc] init];
    [dateInvFtr setDateFormat:@"YYYY-MM-dd"];
    return [dateInvFtr  stringFromDate:self.birthday];
}
@end

//
//  contactDetailCtl.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/15.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "contactPersonModel.h"
@interface contactDetailCtl : UIViewController<UIAlertViewDelegate>
@property (nonatomic , retain) contactPersonModel * model;

@property (nonatomic , assign) BOOL modifyRecord;
@end

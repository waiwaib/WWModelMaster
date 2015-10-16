//
//  ViewController.h
//  WWModelMaster
//
//  Created by 歪歪 on 15/9/29.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "modelAssociateDB.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic , retain) NSMutableArray * contacts;

@property (nonatomic , retain , getter=associate) modelAssociateDB * associate;

- (IBAction)addNewContact:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *contactTable;
@end


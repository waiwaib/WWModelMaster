
//
//  contactDetailCtl.m
//  WWModelMaster
//
//  Created by 歪歪 on 15/10/15.
//  Copyright © 2015年 歪歪. All rights reserved.
//

#import "contactDetailCtl.h"
#import "TimeCustomActionSheet.h"
#import "valueTransform.h"
#import "modelAssociateDB.h"
@interface contactDetailCtl ()

@end

@implementation contactDetailCtl

#pragma mrak - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    
    [self configUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mrak - init data and ui
- (void) initData
{
    if (!_modifyRecord) {
        _model = [[contactPersonModel alloc]init];
    }
}

- (void) configUI
{
    self.navigationItem.title=_modifyRecord ? @"详情" : @"新增";
    //navigation Item
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0 , 70, 40)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    rightBtn.backgroundColor = [UIColor clearColor];
    [rightBtn setTitle:_modifyRecord ? @"完成修改" : @"完成添加" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000]  forState:UIControlStateNormal];
    //rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    
    [rightBtn addTarget:self action:@selector(rightButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    //
    NSArray * itemTitle = @[@"名字",@"号码",@"所在地",@"生日"];
    NSArray * itemPlaceholder = @[@"请填写名字",@"请填写号码",@"请填写所在地",@"请选择生日时间"];
    
    NSString * name = isNull(_model.name) ? @"" : _model.name;
    NSString * phone = isNull(_model.phone) ? @"" : _model.phone;
    NSString * city = isNull(_model.city) ? @"" : _model.city;
    NSString * birthday = isNull([_model birthdayStr]) ? @"" : [_model birthdayStr];
    
    NSArray * itemContent  = @[name,phone,city,birthday];
    for (int i = 0 ; i<4; i++) {
        CGFloat YHeight = 70 + i * 35;
        UILabel * lab  = [[UILabel alloc]initWithFrame:CGRectMake(20, YHeight , 80, 30)];
        lab.text = itemTitle[i];
        lab.textColor = [UIColor darkTextColor];
        lab.font = [UIFont systemFontOfSize:14];
        
        [self.view addSubview:lab];
        
        NSInteger itemTag = 700+i;
        
        if (i<3) {
            UITextField * textFiled = [[UITextField alloc]initWithFrame:CGRectMake(105, YHeight, SCREEN_WIDTH - 110, 30)];
            textFiled.tag = itemTag;
            textFiled.borderStyle = UITextBorderStyleRoundedRect;
            textFiled.placeholder = itemPlaceholder[i];
            textFiled.text = itemContent[i];
            [self.view addSubview:textFiled];
        }
        else
        {
            UIButton * btn = [[UIButton alloc]initWithFrame:CGRectMake(105, YHeight, SCREEN_WIDTH - 110, 30)];
            [btn addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:itemContent[i] forState:UIControlStateNormal];
            btn.tag = itemTag;
            [btn setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            
            btn.layer.cornerRadius = 5;
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            [self.view addSubview:btn];
        }
    }
}

#pragma mrak - action

- (void)rightButtonTouch
{
    [self.view endEditing:YES];
    
    NSString * alertTitle = _modifyRecord ? @"确认修改?" : @"确认保存?";
    
    UIAlertView * alert =[[UIAlertView alloc]initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void) selectTime:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    TimeCustomActionSheet * actionsheet = [[TimeCustomActionSheet alloc]initWithBirthday:_model.birthday];
    
    __block contactDetailCtl * selfBlock = self;
    __block UIButton * blockSender = sender;
    [actionsheet selectResultWithBolock:^(NSDate *date) {
        selfBlock.model.birthday = date;
        [blockSender setTitle:[selfBlock.model birthdayStr] forState:UIControlStateNormal];
    }];
    
    [actionsheet showInView:self.view];
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //采集model信息
    _model.name = [(UITextField *)[self.view viewWithTag:700] text];
    _model.phone = [(UITextField *)[self.view viewWithTag:701] text];
    _model.city = [(UITextField *)[self.view viewWithTag:702] text];
    if (buttonIndex) {
        modelAssociateDB * associate = [[modelAssociateDB alloc]init];
        if (_modifyRecord) {
            [associate updateModel:self.model];
        }
        else
        {
            [associate saveModel:self.model];
        }
    }
}


#pragma mark - touch
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end

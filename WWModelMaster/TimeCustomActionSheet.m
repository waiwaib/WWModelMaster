//
//  TimeCustomActionSheet.m
//  VenadaOA
//
//  Created by hejingzhi on 15/2/12.
//  Copyright (c) 2015年 waiwai. All rights reserved.
//
#import "TimeCustomActionSheet.h"
#import "valueTransform.h"
#define ANIMATE_DURATION                        0.25f
#define ACTIONSHEET_BACKGROUNDCOLOR             [UIColor colorWithRed:106/255.00f green:106/255.00f blue:106/255.00f alpha:0.8]


#define WINDOW_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]

@implementation TimeCustomActionSheet
@synthesize datePicker;
- (id)initWithBirthday:(NSDate *)birthday{
    self = [super init];
    if (self) {
        CGFloat height = 300;
        birthday = isNull(birthday) ? [NSDate date] : birthday;
        //初始化背景视图，添加手势
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor = WINDOW_COLOR;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        [self addGestureRecognizer:tapGesture];
        
        //生成ActionSheetView
        self.backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.height - 200), SCREEN_WIDTH, height)];
        self.backGroundView.backgroundColor = [UIColor whiteColor];
        
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        toolBar.barStyle = UIBarStyleDefault;
        
        
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style: UIBarButtonItemStyleDone target: self action: @selector(timeActionDone:)];
        UIBarButtonItem *leftButton  = [[UIBarButtonItem alloc] initWithTitle:@"取消" style: UIBarButtonItemStylePlain target: self action: @selector(docancel)];
        UIBarButtonItem *fixedButton  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemFlexibleSpace target: nil action: nil];
        NSArray *array = [[NSArray alloc] initWithObjects: leftButton,fixedButton,rightButton, nil];
        [toolBar setItems: array];		

        //给ActionSheetView添加响应事件(如果不加响应事件则传过来的view不显示)
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBackGroundView)];
        [self.backGroundView addGestureRecognizer:tapGesture1];
        
        
        [self addSubview:self.backGroundView];
        [self.backGroundView addSubview:toolBar];
        
        datePicker = [[UIDatePicker alloc]init];
        datePicker.frame = CGRectMake(20, 44,  SCREEN_WIDTH-40, height - 44);
        [datePicker setDatePickerMode:UIDatePickerModeDate];
        
        [datePicker setDate:birthday];
    
        [self.backGroundView addSubview:datePicker];
        
        
        [UIView animateWithDuration:ANIMATE_DURATION animations:^{
            [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-height, [UIScreen mainScreen].bounds.size.width, height)];
            
        } completion:^(BOOL finished) {
            
        }];
    }
    return self;
}

- (void)tappedCancel
{
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)showInView:(UIView *)view{
    if (view) {
        [view addSubview:self];
    }
    else
    {
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:self];
    }
    
}

- (void)tappedBackGroundView
{
    //
}

- (void)timeActionDone:(id) alertView{
    self.complteSelect(datePicker.date);
    [self tappedCancel];
}

- (void)docancel
{
    [self tappedCancel];
}

- (void)selectResultWithBolock:(timeSelectedBlock)doneHander
{
    _complteSelect = doneHander;
}
@end

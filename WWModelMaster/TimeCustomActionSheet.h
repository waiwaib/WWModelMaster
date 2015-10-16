//
//  TimeCustomActionSheet.h
//  VenadaOA
//
//  Created by hejingzhi on 15/2/12.
//  Copyright (c) 2015年 waiwai. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

typedef void(^timeSelectedBlock)(NSDate * date);

@interface TimeCustomActionSheet : UIView
{
    UIToolbar* toolBar;
}

- (id)initWithBirthday:(NSDate *)birthday;

- (void)showInView:(UIView *)view;

@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, assign) CGFloat LXActionSheetHeight;
@property (nonatomic, retain) UIDatePicker * datePicker;
@property(nonatomic, copy) timeSelectedBlock complteSelect;

- (void) selectResultWithBolock:(timeSelectedBlock) doneHander;
@end

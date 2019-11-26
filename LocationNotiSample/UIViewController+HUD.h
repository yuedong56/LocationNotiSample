//
//  UIViewController+HUD.h
//  TodayTodo
//
//  Created by yuedongkui on 2018/4/26.
//  Copyright © 2018年 LYue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIViewController (HUD)

@property (nonatomic, strong) MBProgressHUD *progressHUD;

- (void)showProgressHUDWithText:(NSString *)text; //基本显示，菊花+文字
- (void)showHudOnlyText:(NSString *)text; //无菊花，仅文字
- (void)hideProgressHUD;
- (void)showToastViewWithText:(NSString *)text isOnWindow:(BOOL)isOnWindow; //仅展示文字，然后自动消失
- (void)showToastViewWithText:(NSString *)text
                   guideImage:(UIImage *)image
                   isOnWindow:(BOOL)isOnWindow
                     showtime:(CGFloat)time;

- (void)showToastViewWithText:(NSString *)text isOnWindow:(BOOL)isOnWindow showtime:(CGFloat)time;

#pragma mark -
- (void)startDownloadHUDWithText:(NSString *)text;
- (void)updateDownloadProgress:(CGFloat)progress text:(NSString *)text;
- (void)finishDownloadProgressWithText:(NSString *)text;

@end

//
//  UIViewController+HUD.m
//  TodayTodo
//
//  Created by yuedongkui on 2018/4/26.
//  Copyright © 2018年 LYue. All rights reserved.
//

#import "UIViewController+HUD.h"
#import <objc/runtime.h>

static NSString *kProgressHUD = @"kProgressHUD";

@implementation UIViewController (HUD)

- (void)setProgressHUD:(MBProgressHUD *)progressHUD
{
    objc_setAssociatedObject(self, &kProgressHUD, progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)progressHUD
{
    return objc_getAssociatedObject(self, &kProgressHUD);
}

#pragma mark - ProgressHUD
- (void)showProgressHUDWithText:(NSString *)text
{
    if (self.progressHUD) {
        [self.progressHUD hideAnimated:YES];
        self.progressHUD = nil;
    }
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.label.text = text;
    self.progressHUD.userInteractionEnabled = NO;
    [self.view addSubview:self.progressHUD];
    [self.progressHUD showAnimated:YES];
}

- (void)showHudOnlyText:(NSString *)text; //无菊花，仅文字
{
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.userInteractionEnabled = NO;
    self.progressHUD.mode = MBProgressHUDModeText;
    self.progressHUD.detailsLabel.text = text;
    self.progressHUD.detailsLabel.font =  [UIFont systemFontOfSize:14];
    self.progressHUD.center = self.view.center;
}

- (void)hideProgressHUD
{
    [self.progressHUD hideAnimated:YES];
    [self.progressHUD removeFromSuperview];
    self.progressHUD = nil;
}

- (void)showToastViewWithText:(NSString *)text isOnWindow:(BOOL)isOnWindow
{
    UIView *view = isOnWindow ? ([UIApplication sharedApplication].keyWindow) : self.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.detailsLabel.font =  [UIFont systemFontOfSize:14];
//    hud.label.text = text;
    hud.center = view.center;
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)showToastViewWithText:(NSString *)text isOnWindow:(BOOL)isOnWindow showtime:(CGFloat)time {
    UIView *view = isOnWindow ? ([UIApplication sharedApplication].keyWindow) : self.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.detailsLabel.font =  [UIFont systemFontOfSize:14];
    //    hud.label.text = text;
    hud.center = view.center;
    [hud hideAnimated:YES afterDelay:time];
}

- (void)showToastViewWithText:(NSString *)text
                   guideImage:(UIImage *)image
                   isOnWindow:(BOOL)isOnWindow
                     showtime:(CGFloat)time {
    
    UIView *view = isOnWindow ? ([UIApplication sharedApplication].keyWindow) : self.view;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeCustomView;
    hud.center = view.center;
    hud.bezelView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    
//    YRGuideView *guideView = [[YRGuideView alloc]initWithFrame:CGRectZero];

    UIImageView *imageV = [[UIImageView alloc]initWithImage:image];
    hud.customView = imageV;
    
    hud.label.text = text;
    hud.label.font =  [UIFont systemFontOfSize:14];
    hud.label.numberOfLines = 0;
    hud.label.textAlignment = NSTextAlignmentCenter;

    [hud hideAnimated:YES afterDelay:time];
    
}


#pragma mark -
- (void)startDownloadHUDWithText:(NSString *)text
{
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
    self.progressHUD.minSize = CGSizeMake(140.f, 114.f);
    self.progressHUD.label.text = text;
}

- (void)updateDownloadProgress:(CGFloat)progress text:(NSString *)text;
{
    self.progressHUD.progress = progress;
    if (text.length > 0) {
        self.progressHUD.label.text = text;
    }
}

- (void)finishDownloadProgressWithText:(NSString *)text
{
    UIImage *image = [[UIImage imageNamed:@"save_complete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    self.progressHUD.customView = imageView;
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    self.progressHUD.label.text = text;
    [self.progressHUD hideAnimated:YES afterDelay:1];
}


@end

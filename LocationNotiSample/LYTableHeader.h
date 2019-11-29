//
//  LYTableFooter.h
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/11/28.
//  Copyright © 2019 LY. All rights reserved.
//

#define LYTableFooter_Height  150

#import <UIKit/UIKit.h>

@protocol LYTableFooterDelegete;
@interface LYTableHeader : UIView <UITextFieldDelegate>

@property (nonatomic, weak) id<LYTableFooterDelegete>delegate;

@property (nonatomic, strong) UITextField *field1;
@property (nonatomic, strong) UITextField *field2;
@property (nonatomic, strong) UIButton *addButton;

@end



@protocol LYTableFooterDelegete <NSObject>

- (void)footerDidAddLoction:(LYTableHeader *)footer;

@end

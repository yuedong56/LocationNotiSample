//
//  LYTableFooter.m
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/11/28.
//  Copyright © 2019 LY. All rights reserved.
//

#import "LYTableHeader.h"
#import <CoreLocation/CoreLocation.h>

@interface LYTableHeader ()

@property (nonatomic, strong) CLGeocoder *geocoder;

@end



@implementation LYTableHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
//        self.backgroundColor = [UIColor redColor];
        //根据坐标取得地名
        self.geocoder = [[CLGeocoder alloc] init];
        
        self.field1 = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth-20, 40)];
        self.field1.placeholder = @"输入经度";
        self.field1.borderStyle = UITextBorderStyleRoundedRect;
        self.field1.returnKeyType = UIReturnKeyDone;
        self.field1.clearButtonMode = UITextFieldViewModeAlways;
        self.field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.field1.delegate = self;
        [self addSubview:self.field1];
        
        self.field2 = [[UITextField alloc] initWithFrame:CGRectMake(10, self.field1.frame.origin.y+self.field1.frame.size.height+2, kScreenWidth-20, 40)];
        self.field2.placeholder = @"输入纬度";
        self.field2.borderStyle = UITextBorderStyleRoundedRect;
        self.field2.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.field2.clearButtonMode = UITextFieldViewModeAlways;
        self.field2.returnKeyType = UIReturnKeyDone;
        self.field2.delegate = self;
        [self addSubview:self.field2];
        
        self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.addButton setTitle:@"点击增加经纬度" forState:UIControlStateNormal];
        [self addSubview:self.addButton];
        self.addButton.frame = CGRectMake(0, self.field2.frame.origin.y+self.field2.frame.size.height+2, kScreenWidth/2-20, 40);
        [self.addButton addTarget:self action:@selector(addArrayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        self.radiusField = [[UITextField alloc] initWithFrame:CGRectMake(kScreenWidth/2, _addButton.frame.origin.y, kScreenWidth/2-10, _addButton.frame.size.height)];
        self.radiusField.placeholder = @"输入范围半径（米）";
        self.radiusField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.radiusField.borderStyle = UITextBorderStyleRoundedRect;
        self.radiusField.returnKeyType = UIReturnKeyDone;
        self.radiusField.clearButtonMode = UITextFieldViewModeAlways;
        self.radiusField.delegate = self;
        [self addSubview:self.radiusField];
    }
    return self;
}

#pragma mark - UIButton Events
//增加位置经纬度
- (void)addArrayButtonAction:(UIButton *)button
{
    NSMutableArray *mLocations = [[[NSUserDefaults standardUserDefaults] objectForKey:kAllLocations_Key] mutableCopy];
    if (mLocations == nil) {
        mLocations = [NSMutableArray array];
    }
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.field2.text.doubleValue longitude:self.field1.text.doubleValue];
    NSLog(@"location ===== %@", location);
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
        NSString *localInfo = [NSString stringWithFormat:@"%@, %@, %@", placemark.locality, placemark.subLocality, placemark.name];
        
        NSLog(@"localInfo = %@", localInfo);
        [mLocations addObject:@[self.field1.text, self.field2.text, localInfo]]; //
        [[NSUserDefaults standardUserDefaults] setObject:mLocations forKey:kAllLocations_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.delegate footerDidAddLoction:self];
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    return YES;
}

@end

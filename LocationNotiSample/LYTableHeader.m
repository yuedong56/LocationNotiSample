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
    if (self) {
        //根据坐标取得地名
        self.geocoder = [[CLGeocoder alloc] init];
        
        self.field1 = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth-20, 44)];
        self.field1.placeholder = @"输入经度";
        self.field1.borderStyle = UITextBorderStyleRoundedRect;
        self.field1.returnKeyType = UIReturnKeyDone;
        self.field1.delegate = self;
        [self addSubview:self.field1];
        
        self.field2 = [[UITextField alloc] initWithFrame:CGRectMake(10, self.field1.frame.origin.y+self.field1.frame.size.height, kScreenWidth-20, 44)];
        self.field2.placeholder = @"输入纬度";
        self.field2.borderStyle = UITextBorderStyleRoundedRect;
        self.field2.returnKeyType = UIReturnKeyDone;
        self.field2.delegate = self;
        [self addSubview:self.field2];
        
        self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.addButton setTitle:@"点击增加经纬度" forState:UIControlStateNormal];
        [self addSubview:self.addButton];
        self.addButton.frame = CGRectMake(0, LYTableFooter_Height-44, kScreenWidth, 44);
        [self.addButton addTarget:self action:@selector(addArrayButtonAction:) forControlEvents:UIControlEventTouchUpInside];
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
        
        self.field1.text = nil;
        self.field2.text = nil;
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    return YES;
}

@end

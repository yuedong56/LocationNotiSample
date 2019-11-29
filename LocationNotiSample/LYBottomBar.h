//
//  LYBottomBar.h
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/11/28.
//  Copyright © 2019 LY. All rights reserved.
//

#define kLYBottomBar_Height  50

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface LYBottomBar : UIView <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) UIButton *rightButton;

@end

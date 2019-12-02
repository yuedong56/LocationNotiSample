//
//  LYBottomBar.m
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/11/28.
//  Copyright © 2019 LY. All rights reserved.
//

#import "LYBottomBar.h"

@implementation LYBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, (kScreenWidth-20), kLYBottomBar_Height)];
        self.locationLabel.font = [UIFont systemFontOfSize:12];
        self.locationLabel.textAlignment = NSTextAlignmentCenter;
        self.locationLabel.text = @"当前位置：null";
        if (@available(iOS 13.0, *)) {
            self.locationLabel.textColor = [UIColor systemGray3Color];
        } else {
            self.locationLabel.textColor = [UIColor blackColor];
        }
        [self addSubview:self.locationLabel];

        //
        self.leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.leftButton.frame = CGRectMake(0, 0, 60, kLYBottomBar_Height);
        [self.leftButton setImage:ImageNamed(@"location_l") forState:UIControlStateNormal];
        [self.leftButton  addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.leftButton];
        
        self.rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.rightButton.frame = CGRectMake(kScreenWidth-60, 0, 60, kLYBottomBar_Height);
        [self.rightButton setImage:ImageNamed(@"reload") forState:UIControlStateNormal];
        [self addSubview:self.rightButton];
    }
    return self;
}


- (void)locationButtonAction:(UIButton *)button
{
    //定位管理器
    self.locationManager = [[CLLocationManager alloc] init];
    
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"定位服务当前可能尚未打开，请设置打开！");
        return;
    }
    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        //设置代理
        _locationManager.delegate = self;
        //设置定位精度
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance = 10.0;//十米定位一次
        _locationManager.distanceFilter = distance;
        
        //启动跟踪定位
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations firstObject];//取出第一个位置
    CLLocationCoordinate2D coordinate = location.coordinate;//位置坐标
    
    NSLog(@"经度：%f,纬度：%f,海拔：%f", coordinate.longitude, coordinate.latitude, location.altitude);
    
    //如果不需要实时定位，使用完即使关闭定位服务
    [_locationManager stopUpdatingLocation];
    
    //根据坐标取得地名
    self.geocoder = [[CLGeocoder alloc] init];

    //CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
        NSLog(@"详细信息:%@", placemark.addressDictionary);
        
        NSString *localInfo = [NSString stringWithFormat:@"%@, %@, %@", placemark.locality, placemark.subLocality, placemark.name];
        self.locationLabel.text = @"";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.locationLabel.text = localInfo;
        });
    }];
}

@end

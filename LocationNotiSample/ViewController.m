//
//  ViewController.m
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/11/26.
//  Copyright © 2019 LY. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Notification.h"


#define kAllNotis_Indentifer @"kAllNotis_Indentifer"

@interface ViewController ()<CLLocationManagerDelegate>
{
    
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) UIButton *updateButton;

@end




@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
      
    //
    self.locationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.locationButton setTitle:@"点击获取定位" forState:UIControlStateNormal];
    [self.locationButton  addTarget:self action:@selector(locationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.locationButton];

    self.locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.locationLabel.font = [UIFont systemFontOfSize:12];
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    self.locationLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.locationLabel];
    
    //
    self.updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.updateButton setTitle:@"点击更新位置推送" forState:UIControlStateNormal];
    [self.view addSubview:self.updateButton];
    [self.updateButton addTarget:self action:@selector(updateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    [self locationButtonAction:self.locationButton];
    [self updateButtonAction:self.updateButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.locationLabel.frame = CGRectMake(10, 100, (kScreenWidth-20), 50);
    self.locationButton.frame = CGRectMake((kScreenWidth-160)/2, 140, 160, 44);
    self.updateButton.frame = CGRectMake((kScreenWidth-160)/2, 200, 160, 44);
}

#pragma mark -
- (void)locationButtonAction:(UIButton *)button
{
    //定位管理器
    self.locationManager = [[CLLocationManager alloc]init];
    
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

- (void)updateButtonAction:(UIButton *)button
{
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert|UNAuthorizationOptionSound
                                                                        completionHandler:^(BOOL granted, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self p_updateNotifications];
        });
    }];
}

- (void)p_updateNotifications
{
    [self showProgressHUDWithText:@"正在更新位置推送..."];
    
    NSString *url = @"http://b612-beta.kajicam.com/ts/api/push/demo/get";
    [[AFHTTPSessionManager manager] GET:url
                             parameters:nil
                               progress:nil
                                success:^(NSURLSessionDataTask *task, NSArray *responseObject) {
        NSLog(@"responseObject == %@", responseObject);
        
        // 1. 先移除所有推送
        NSArray *allNotiIds = [[NSUserDefaults standardUserDefaults] objectForKey:kAllNotis_Indentifer];
        [allNotiIds enumerateObjectsUsingBlock:^(NSString *indentifer, NSUInteger idx, BOOL *stop) {
            [NSObject removeNotificationWithIndentifier:indentifer];
        }];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAllNotis_Indentifer];
        
        // 2. 根据地理位置更新推送
        [responseObject enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
            NSString *addr_name = dic[@"addr_name"];
            NSString *latitude = dic[@"latitude"];
            NSString *longitude = dic[@"longitude"];
            [self addToNotificationWithTitle:addr_name atitude:latitude longitude:longitude];
            
//            CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
//            [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//                CLPlacemark *placemark = [placemarks firstObject];
//                NSLog(@"推送地址 == %@", placemark);
//            }];
        }];
        
        NSString *info = [NSString stringWithFormat:@"已成功设置 %ld 个位置推送", responseObject.count];
        [self showAlertWithTitle:info];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideProgressHUD];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideProgressHUD];
        });
        NSString *errorInfo = [NSString stringWithFormat:@"更新失败：%@", error.localizedDescription];
        [self showAlertWithTitle:errorInfo];
    }];
}

- (void)showAlertWithTitle:(NSString *)title
{
    NSLog(@"%@", title);

    UIAlertController *vc = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)addToNotificationWithTitle:(NSString *)title
                           atitude:(NSString *)latitude
                            longitude:(NSString *)longitude
{
    NSString *indentifier = [NSString stringWithFormat:@"%@_%@_%@", title, latitude, longitude];
    [NSObject sendNotificationWithTitle:title
                                   body:@"测试提醒body"
                               latitude:[latitude doubleValue]
                              longitude:[longitude doubleValue]
                                 radius:500
                                 repeat:YES
                         notiIdentifier:indentifier];
    
    NSMutableArray *mArr = [[[NSUserDefaults standardUserDefaults] objectForKey:kAllNotis_Indentifer] mutableCopy];
    if (mArr == nil) {
        mArr = [NSMutableArray array];
    }
    [mArr addObject:indentifier];
    [[NSUserDefaults standardUserDefaults] setObject:mArr forKey:kAllNotis_Indentifer];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

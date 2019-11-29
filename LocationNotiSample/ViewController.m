//
//  ViewController.m
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/11/26.
//  Copyright © 2019 LY. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Notification.h"
#import "LYBottomBar.h"
#import "LYTableHeader.h"

#define kAllNotis_Indentifer @"kAllNotis_Indentifer"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, LYTableFooterDelegete>
{
    
}
@property (nonatomic, strong) UIButton *updateButton;
@property (nonatomic, strong) LYBottomBar *bottomBar;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LYTableHeader *header;

@end




@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
          
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate =  self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.header = [[LYTableHeader alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, LYTableFooter_Height)];
    self.header.delegate = self;
    self.tableView.tableHeaderView = self.header;
    
    //
    self.updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.updateButton setTitle:@"点击添加位置推送" forState:UIControlStateNormal];
    [self.view addSubview:self.updateButton];
    [self.updateButton addTarget:self action:@selector(updateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    self.bottomBar = [[LYBottomBar alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.bottomBar];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.bottomBar.frame = CGRectMake(0, kScreenHeight-self.view.safeAreaInsets.bottom-kLYBottomBar_Height, kScreenWidth, kLYBottomBar_Height);
    self.updateButton.frame = CGRectMake((kScreenWidth-160)/2, self.bottomBar.frame.origin.y-44, 160, 44);
    
    self.tableView.frame = CGRectMake(0, self.view.safeAreaInsets.top, kScreenWidth, kScreenHeight-self.view.safeAreaInsets.bottom-self.view.safeAreaInsets.top-kLYBottomBar_Height-100);
}

#pragma mark -
//更新推送
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
    NSArray *locations = nil;
    
    // 1. 先移除所有推送
    NSArray *allNotiIds = [[NSUserDefaults standardUserDefaults] objectForKey:kAllNotis_Indentifer];
    [allNotiIds enumerateObjectsUsingBlock:^(NSString *indentifer, NSUInteger idx, BOOL *stop) {
        [NSObject removeNotificationWithIndentifier:indentifer];
    }];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAllNotis_Indentifer];
    
    // 2. 根据地理位置更新推送
    [locations enumerateObjectsUsingBlock:^(NSDictionary *dic, NSUInteger idx, BOOL *stop) {
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
    
    NSString *info = [NSString stringWithFormat:@"已成功设置 %ld 个位置推送", locations.count];
    [self showAlertWithTitle:info];
}

- (void)addToNotificationWithTitle:(NSString *)title atitude:(NSString *)latitude longitude:(NSString *)longitude
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

#pragma mark - LYTableFooterDelegete
- (void)footerDidAddLoction:(LYTableHeader *)footer
{
    [self.tableView reloadData];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *locations = [[NSUserDefaults standardUserDefaults] objectForKey:kAllLocations_Key];
    
    return locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    
    NSArray *locations = [[NSUserDefaults standardUserDefaults] objectForKey:kAllLocations_Key];
    NSArray *subLocations = locations[indexPath.row];
    cell.textLabel.text = subLocations[2];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"经度：%@, 纬度：%@", subLocations[0], subLocations[1]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

@end

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
#import "SearchViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, LYTableFooterDelegete, SearchViewControllerDelegate>
{
    NSMutableArray *models;
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
    
    [self reloadData];
    
    //
    self.updateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.updateButton setTitle:@"点击添加位置推送" forState:UIControlStateNormal];
    [self.view addSubview:self.updateButton];
    [self.updateButton addTarget:self action:@selector(updateButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchButtonAction:)];
    self.navigationItem.leftBarButtonItem = searchItem;
    
    //
    self.bottomBar = [[LYBottomBar alloc] initWithFrame:CGRectZero];
    [self.bottomBar.rightButton addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventTouchUpInside];
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

- (void)searchButtonAction:(UIButton *)button
{
    SearchViewController *vc = [[SearchViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)p_updateNotifications
{
    // 1. 先移除所有推送
    [NSObject removeAllNotification];

    // 2. 根据地理位置更新推送
    __block int selectedCount = 0;
    [models enumerateObjectsUsingBlock:^(LocationModel *model, NSUInteger idx, BOOL *stop) {
        if (model.isSelected) {
            [self addToNotificationWithTitle:model.locationDes latitude:model.latitude longitude:model.longitude];
            selectedCount ++;
        }
    }];
    
    NSString *info = [NSString stringWithFormat:@"已成功设置 %d 个位置推送", selectedCount];
    if (selectedCount == 0) {
        [self showAlertWithTitle:@"尚未选中任何地址，点击列表可选中对应地址后重试！"];
    } else {
        [self showToastViewWithText:info isOnWindow:YES];
    }
}

- (void)addToNotificationWithTitle:(NSString *)title latitude:(NSString *)latitude longitude:(NSString *)longitude
{
    NSString *indentifier = [NSString stringWithFormat:@"%@_%@_%@", title, latitude, longitude];
    [NSObject sendNotificationWithTitle:title
                                   body:@"测试提醒body"
                               latitude:[latitude doubleValue]
                              longitude:[longitude doubleValue]
                                 radius:_header.radiusField.text.length>0 ? _header.radiusField.text.doubleValue : 500
                                 repeat:YES
                         notiIdentifier:indentifier];
}

- (void)reloadData
{
    NSArray *locations = [[NSUserDefaults standardUserDefaults] objectForKey:kAllLocations_Key];

    models = [NSMutableArray array];
    [locations enumerateObjectsUsingBlock:^(NSArray *subLocs, NSUInteger idx, BOOL *stop) {
        LocationModel *model = [[LocationModel alloc] init];
        model.longitude = subLocs[0];
        model.latitude = subLocs[1];
        model.locationDes = subLocs[2];
        [models addObject:model];
    }];
    [self.tableView reloadData];
}

#pragma mark - LYTableFooterDelegete
- (void)footerDidAddLoction:(LYTableHeader *)footer
{
    [self reloadData];
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indentifier];
    }
    LocationModel *model = models[indexPath.row];
    cell.textLabel.text = model.locationDes;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"经度：%@, 纬度：%@", model.longitude, model.latitude];
    cell.accessoryType = model.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    LocationModel *model = models[indexPath.row];
    model.isSelected = !model.isSelected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - 左滑删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction *action, UIView *sourceView, void (^completionHandler)(BOOL))
    {
        completionHandler(YES);
//        [self p_deleteWithIndex:indexPath.row];
        NSMutableArray *locations = [[[NSUserDefaults standardUserDefaults] objectForKey:kAllLocations_Key] mutableCopy];
        [locations removeObjectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setObject:locations forKey:kAllLocations_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self->models removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    //deleteRowAction.image = [UIImage imageNamed:@"delete_today"];
    deleteRowAction.backgroundColor = [UIColor redColor];
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - SearchViewControllerDelegate
- (void)searchController:(SearchViewController *)vc didSelectPlacemark:(CLPlacemark *)placemark
{
    [self reloadData];
}

@end

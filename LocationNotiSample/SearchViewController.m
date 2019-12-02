//
//  SearchViewController.m
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/12/2.
//  Copyright © 2019 LY. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()<UITextFieldDelegate>
{
    NSMutableArray <CLPlacemark *>*models;
}
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CLGeocoder *geocoder;

@end




@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.geocoder = [[CLGeocoder alloc] init];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeySearch;
    self.textField.placeholder = @"输入地名搜索";
    [self.view addSubview:self.textField];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate =  self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.textField.frame = CGRectMake(10, self.view.safeAreaInsets.top, kScreenWidth-20, 40);
    CGFloat table_Y = _textField.frame.size.height+_textField.frame.origin.y;
    self.tableView.frame = CGRectMake(0, table_Y, kScreenWidth, kScreenHeight-self.view.safeAreaInsets.bottom-table_Y);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
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
    CLPlacemark *placemark = models[indexPath.row];
    cell.textLabel.text = placemark.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"经度：%f, 纬度：%f", placemark.location.coordinate.longitude, placemark.location.coordinate.latitude];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *mLocations = [[[NSUserDefaults standardUserDefaults] objectForKey:kAllLocations_Key] mutableCopy];
    if (mLocations == nil) {
        mLocations = [NSMutableArray array];
    }

    CLPlacemark *placemark = models[indexPath.row];
    CLLocation *location = placemark.location;
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
        NSString *localInfo = [NSString stringWithFormat:@"%@, %@, %@", placemark.locality, placemark.subLocality, placemark.name];
        
        NSLog(@"localInfo = %@", localInfo);
        [mLocations addObject:@[@(placemark.location.coordinate.longitude).stringValue,
                                @(placemark.location.coordinate.latitude).stringValue,
                                localInfo]]; //
        [[NSUserDefaults standardUserDefaults] setObject:mLocations forKey:kAllLocations_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.delegate searchController:self didSelectPlacemark:placemark];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.geocoder geocodeAddressString:textField.text completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        [placemarks enumerateObjectsUsingBlock:^(CLPlacemark *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"====%@", obj.name);
        }];
        self->models = [placemarks copy];
        [self.tableView reloadData];
    }];
    return YES;
}

@end

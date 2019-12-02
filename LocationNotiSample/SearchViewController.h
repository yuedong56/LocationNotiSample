//
//  SearchViewController.h
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/12/2.
//  Copyright © 2019 LY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol SearchViewControllerDelegate;
@interface SearchViewController : UIViewController

@property (nonatomic, weak) id <SearchViewControllerDelegate> delegate;

@end




@protocol SearchViewControllerDelegate <NSObject>

- (void)searchController:(SearchViewController *)vc didSelectPlacemark:(CLPlacemark *)placemark;

@end

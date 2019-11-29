//
//  NSObject+Notification.h
//  TodayTodo
//
//  Created by yuedongkui on 2019/2/11.
//  Copyright © 2019年 LYue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>


@interface NSObject (Notification)


+ (void)sendNotificationWithTitle:(NSString *)title
                             body:(NSString *)body
                         latitude:(CLLocationDegrees)latitude
                        longitude:(CLLocationDegrees)longitude
                           radius:(CGFloat)radius
                           repeat:(BOOL)isRepeat
                   notiIdentifier:(NSString *)notiIdentifier;

+ (void)removeNotificationWithIndentifier:(NSString *)indentifer;

+ (void)removeAllNotification;


@end

//
//  NSObject+Notification.m
//  TodayTodo
//
//  Created by yuedongkui on 2019/2/11.
//  Copyright © 2019年 LYue. All rights reserved.
//

#import "NSObject+Notification.h"


@implementation NSObject (Notification)

+ (void)sendNotificationWithTitle:(NSString *)title
                             body:(NSString *)body
                         latitude:(CLLocationDegrees)latitude
                        longitude:(CLLocationDegrees)longitude
                           radius:(CGFloat)radius
                           repeat:(BOOL)isRepeat
                   notiIdentifier:(NSString *)notiIdentifier;
{
    // 1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    //[content setValue:@(YES) forKeyPath:@"shouldAlwaysAlertWhileAppIsForeground"];
    content.title = title;
    //content.subtitle = @"";
    content.body = body;
    //content.badge = @(1);
    //content.userInfo = nil;
    
    // 2.设置声音
    content.sound = [UNNotificationSound defaultSound]; //[UNNotificationSound soundNamed:@"sound01.wav"]
    
    // 3.触发模式
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:coordinate
                                                                 radius:radius
                                                             identifier:notiIdentifier];
    NSLog(@"设置推送信息：region === %@ (%f, %f, %f)", region, coordinate.latitude, coordinate.longitude, radius);
    UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:region
                                                                                      repeats:isRepeat];
    
    // 4.设置UNNotificationRequest
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:notiIdentifier content:content trigger:trigger];
    
    // 5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
}

+ (void)removeNotificationWithIndentifier:(NSString *)indentifer;
{
    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[indentifer]];
}

+ (void)removeAllNotification;
{
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
}

@end

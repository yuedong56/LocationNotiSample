//
//  LocationModel.h
//  LocationNotiSample
//
//  Created by yuedongkui on 2019/11/29.
//  Copyright © 2019 LY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationModel : NSObject

@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *locationDes;
@property (nonatomic, assign) BOOL isSelected;

@end

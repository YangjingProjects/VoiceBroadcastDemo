//
//  JPushTool.h
//  VoiceBroadcastDemo
//
//  Created by Yang on 2019/1/28.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JPushTool : NSObject

+ (JPushTool *)shareTool;

/*初始化JPush SDK*/
- (void)registerJPUSH:(NSDictionary *)launchOptions;

/*未读消息数角标*/
- (void)setBadge:(NSInteger)badge;

/*注册设备*/
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

@end

NS_ASSUME_NONNULL_END

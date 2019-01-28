//
//  AppDelegate.m
//  PopOnChatPalAUserSDK
//
//  Created by Yang on 2019/1/22.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import "AppDelegate.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "YJAudioTool.h"
#import "JPushTool.h"
#import "YJMacro.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (yjIOS10) {
        //通知授权
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // 点击允许
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"yangjing_%@: settings->%@", NSStringFromClass([self class]),settings);
                }];
            } else {
                // 点击不允许
                
            }
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    } else {
        // iOS8-iOS10注册远程通知的方法
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    //初始化JPushSDK
    [[JPushTool shareTool] registerJPUSH:launchOptions];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [[JPushTool shareTool] setBadge:0];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(nonnull UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    
    [application registerForRemoteNotifications];
}

//远程推送注册成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"yangjing_%@: deviceToken->%@", NSStringFromClass([self class]), [deviceToken description]);
    [[JPushTool shareTool] registerForRemoteNotificationsWithDeviceToken:deviceToken];
}

//远程推送注册失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

//ios10之前接收远程推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"yangjing_%@: userInfo->%@ ", NSStringFromClass([self class]), userInfo);
    
    [[YJAudioTool sharedPlayer] playPushInfo:userInfo backModes:NO completed:nil];
}

//ios10之前接收本地推送
- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
}

//ios10之后接收推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    //远程推送
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"yangjing_%@: userInfo->%@ ", NSStringFromClass([self class]), userInfo);
        
        //未经过NotificationService处理
        if (![userInfo.allKeys containsObject:@"hasHandled"]) {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                [[YJAudioTool sharedPlayer] playPushInfo:userInfo backModes:NO completed:nil];
                completionHandler(UNNotificationPresentationOptionAlert);
                
            } else {
                completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionSound);

            }
            
        } else {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                completionHandler(UNNotificationPresentationOptionAlert);
                
            } else {
                completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
                
            }

        }

    }
    
    //远程推送
    else {
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert|UNAuthorizationOptionSound);

    }
}

// iOS10及以上通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) {
    completionHandler();  // 系统要求执行这个方法
}


@end

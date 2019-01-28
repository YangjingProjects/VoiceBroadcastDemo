//
//  NotificationService.m
//  YJNotificationServiceExtension
//
//  Created by Yang on 2019/1/25.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import "NotificationService.h"
#import "YJAudioTool.h"
#import "YJMacro.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    NSLog(@"yangjing_%@: dict->%@", NSStringFromClass([self class]), self.bestAttemptContent.userInfo);
    
    //iOS12.1系统以上语音播报无法使用语音播放器
    self.bestAttemptContent.sound = nil;
    
    __weak typeof(self) weakSelf = self;
    [[YJAudioTool sharedPlayer] playPushInfo:weakSelf.bestAttemptContent.userInfo completed:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            NSMutableDictionary *dict = [strongSelf.bestAttemptContent.userInfo mutableCopy] ;
            [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
            strongSelf.bestAttemptContent.userInfo = dict;
            
            strongSelf.contentHandler(self.bestAttemptContent);
        }
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end

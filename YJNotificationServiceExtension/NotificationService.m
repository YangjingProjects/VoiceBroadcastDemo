//
//  NotificationService.m
//  YJNotificationServiceExtension
//
//  Created by Yang on 2019/1/25.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import "NotificationService.h"
#import "YJAudioTool.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    NSMutableDictionary *dict = [self.bestAttemptContent.userInfo mutableCopy] ;
    [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
    self.bestAttemptContent.userInfo = dict;
//    self.bestAttemptContent.sound = nil;
    NSLog(@"yangjing_%@: dict->%@", NSStringFromClass([self class]), dict);

    [[YJAudioTool sharedPlayer] playPushInfo:dict completed:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentHandler(self.bestAttemptContent);
        });
    }];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end

//
//  NotificationService.m
//  YJNotificationServiceExtension
//
//  Created by Yang on 2019/1/25.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import "NotificationService.h"
#import "YJAudioTool.h"
#import <AVFoundation/AVFoundation.h>

@interface NotificationService ()  <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@property (strong, nonatomic) AVSpeechSynthesizer *synthesizer;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    NSLog(@"yangjing_%@: dict->%@", NSStringFromClass([self class]), self.bestAttemptContent.userInfo);
    self.bestAttemptContent.sound = nil;

    [[YJAudioTool sharedPlayer] playPushInfo:self.bestAttemptContent.userInfo completed:^(BOOL success) {

        NSMutableDictionary *dict = [self.bestAttemptContent.userInfo mutableCopy] ;
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"hasHandled"] ;
        self.bestAttemptContent.userInfo = dict;

        self.contentHandler(self.bestAttemptContent);
    }];
    
//    if (!self.synthesizer) {
//        self.synthesizer = [[AVSpeechSynthesizer alloc] init];
//        self.synthesizer.delegate = self;
//    }
//
//    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc]initWithString:self.bestAttemptContent.userInfo[@"aps"][@"alert"]];
//    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
//    utterance.rate = 0.5f;
//    utterance.pitchMultiplier = 0.8f;
//    utterance.postUtteranceDelay = 0.1f;
//    utterance.preUtteranceDelay = 0.0f;
//    utterance.volume = 1.0f;
//    [self.synthesizer speakUtterance:utterance];

}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

//开始朗读的代理方法
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"yangjing: didStartSpeechUtterance");
}
//结束朗读的代理方法
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"yangjing: didFinishSpeechUtterance");

    self.contentHandler(self.bestAttemptContent);
}
//暂停朗读的代理方法
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"yangjing: didPauseSpeechUtterance");

    self.contentHandler(self.bestAttemptContent);
}
//继续朗读的代理方法
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"yangjing: didContinueSpeechUtterance-");

}
//取消朗读的代理方法
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"yangjing: didCancelSpeechUtterance");

    self.contentHandler(self.bestAttemptContent);
}
//将要播放的语音文字
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance{
    NSLog(@"willSpeakRangeOfSpeechString->characterRange.location = %zd->characterRange.length = %zd->utterance.speechString= %@",characterRange.location,characterRange.length,utterance.speechString);
}

@end

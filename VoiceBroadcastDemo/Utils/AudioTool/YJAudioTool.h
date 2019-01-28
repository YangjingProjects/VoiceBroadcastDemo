//
//  YJAudioTool.h
//  VoiceBroadcastDemo
//
//  Created by Yang on 2019/1/25.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^YJCompleteBlock)(BOOL success) ;

@interface YJAudioTool : NSObject

+ (instancetype)sharedPlayer;

- (void)playPushInfo:(NSDictionary *)userInfo backModes:(BOOL)backModes completed:(YJCompleteBlock)completed;

- (void)stopAudioPlayer;

@end

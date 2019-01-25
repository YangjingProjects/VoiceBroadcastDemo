//
//  YJAudioTool.m
//  VoiceBroadcastDemo
//
//  Created by Yang on 2019/1/25.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import "YJAudioTool.h"
#import <AVFoundation/AVFoundation.h>
#import "NSDictionary+YJDictionary.h"
#import "NSString+YJString.h"

@interface YJAudioTool () <AVAudioPlayerDelegate>

@property(nonatomic, strong) AVAudioPlayer *audioPlayer ;

@property (nonatomic, strong) NSMutableArray *audioFiles;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) NSInteger subIndex;

@end

@implementation YJAudioTool

+ (instancetype)sharedPlayer {
    static YJAudioTool *tool = nil ;
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        tool = [[YJAudioTool alloc] init] ;
    }) ;
    return tool ;
}

- (void)playPushInfo:(NSDictionary *)userInfo completed:(YJCompleteBlock)completed {
    
    NSDictionary *apsDic =  [userInfo nunullValueForKey:@"aps"] ;
    if (!apsDic) {
        if (completed) completed(NO);
        return;
    }
    
    NSLog(@"yangjing_%@: apsDic->%@", NSStringFromClass([self class]), apsDic);
    
    //amount:金额/元
    NSNumber *amountNum = [apsDic nunullValueForKey:@"amount"];
    if(amountNum) {
        double amount = [amountNum doubleValue];
        [self playMoneyReceived:amount completed:completed] ;
        
    } else {
        if (completed) completed(NO);
    }
}


- (void)playMoneyReceived:(double)amount completed:(YJCompleteBlock)completed {
    // 将金额转换为对应的文字
    NSString *amountString = [NSString stringFromNumber:amount] ;
    NSLog(@"yangjing_%@: amountString->%@", NSStringFromClass([self class]), amountString);
    
    // 分解成mp3数组
    NSMutableArray *subAudioFiles = [[NSMutableArray alloc] init];
    [subAudioFiles addObject:@"tts_pre.mp3"] ;
    
    for (NSInteger i = 0, count = amountString.length; i < count; i++) {
        NSString *subString = [amountString substringWithRange:NSMakeRange(i, 1)] ;
        NSString *fileName = [self audioFileWithString:subString];
        if (!fileName) {
            [subAudioFiles removeAllObjects];
            [subAudioFiles addObject:@"tts_default.mp3"];
            
        } else {
            [subAudioFiles addObject:fileName];
        }
    }
    [subAudioFiles addObject:@"tts_yuan.mp3"];

    [self.audioFiles addObject:subAudioFiles];
    
    if (self.subIndex > 0) return;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    [[AVAudioSession sharedInstance] setActive:YES error:NULL];
    
    [self playAudioFiles];
}

// 播放声音文件
- (void)playAudioFiles {
    
    if (self.currentIndex >= self.audioFiles.count) return;
    
    NSMutableArray *subAudioFiles = [self.audioFiles objectAtIndex:self.currentIndex];
    
    if (self.subIndex >= subAudioFiles.count) return;

    NSString *fileName = [subAudioFiles objectAtIndex:self.subIndex] ;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    if (self.audioPlayer.isPlaying) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfURL:fileURL];
    if (!data) {
        NSLog(@"yangjing_%@: data is nil", NSStringFromClass([self class]));

    }
    
    NSLog(@"yangjing_%@: filePath->%@", NSStringFromClass([self class]), filePath);
    
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    if (error) {
        NSLog(@"yangjing_audio: 音频播放器初始化失败");
        [self audioPlayerPlayNextFile];
        return;
    }
    self.audioPlayer.currentTime = 0;
    self.audioPlayer.numberOfLoops = 0 ;
    self.audioPlayer.delegate = self;
    BOOL ret = [self.audioPlayer prepareToPlay];
    if (!ret) {
        NSLog(@"yangjing_audio: 音频播放器准备失败");
        [self audioPlayerPlayNextFile];
        return;
    };
    
    BOOL ret2 = [self.audioPlayer play];
    if (!ret2) {
        NSLog(@"yangjing_audio: 音频播放器播放失败");
        [self audioPlayerPlayNextFile];
        return;
    }
    NSLog(@"yangjing_audio: 播放成功");
}

- (void)stopAudioPlayer {
    [self.audioPlayer stop];

    self.subIndex = 0;
    self.currentIndex = 0;
    [self.audioFiles removeAllObjects];
}

- (void)audioPlayerPlayNextFile {
    if (self.currentIndex >= self.audioFiles.count) return;
    NSMutableArray *subAudioFiles = [self.audioFiles objectAtIndex:self.currentIndex];
    
    if (self.subIndex < subAudioFiles.count-1) {
        self.subIndex += 1;
        [self playAudioFiles];
        
    } else if (self.subIndex == subAudioFiles.count-1) {
        self.subIndex = 0;
        self.currentIndex += 1;
        [self playAudioFiles];
        
    } else {
        self.subIndex = 0;
        self.currentIndex = 0;
        
        [self.audioFiles removeAllObjects];
    }
}

//MARK: - audioplayer delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self audioPlayerPlayNextFile];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    [self.audioPlayer stop];
    
    [self audioPlayerPlayNextFile];
}

//MARK: -
- (NSString *)audioFileWithString:(NSString *)fileName {
    if([fileName isEqualToString:@"零"]) return @"tts_0.mp3";
    if([fileName isEqualToString:@"一"]) return @"tts_1.mp3";
    if([fileName isEqualToString:@"二"]) return @"tts_2.mp3";
    if([fileName isEqualToString:@"三"]) return @"tts_3.mp3";
    if([fileName isEqualToString:@"四"]) return @"tts_4.mp3";
    if([fileName isEqualToString:@"五"]) return @"tts_5.mp3";
    if([fileName isEqualToString:@"六"]) return @"tts_6.mp3";
    if([fileName isEqualToString:@"七"]) return @"tts_7.mp3";
    if([fileName isEqualToString:@"八"]) return @"tts_8.mp3";
    if([fileName isEqualToString:@"九"]) return @"tts_9.mp3";
    if([fileName isEqualToString:@"十"]) return @"tts_ten.mp3";
    if([fileName isEqualToString:@"百"]) return @"tts_hundred.mp3";
    if([fileName isEqualToString:@"千"]) return @"tts_thousand.mp3";
    if([fileName isEqualToString:@"万"]) return @"tts_ten_thousand.mp3";
    if([fileName isEqualToString:@"点"]) return @"tts_dot.mp3";
    return nil;
}

- (NSMutableArray *)audioFiles {
    if (!_audioFiles) {
        _audioFiles = [[NSMutableArray alloc] init];
    }
    return _audioFiles;
}

@end
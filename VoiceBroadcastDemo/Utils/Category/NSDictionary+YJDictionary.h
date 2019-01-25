//
//  NSDictionary+YJDictionary.h
//  VoiceBroadcastDemo
//
//  Created by Yang on 2019/1/25.
//  Copyright © 2019 YangJing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (YJDictionary)

- (id)nunullValueForKey:(NSString *)key;

- (id)nunullObjectForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

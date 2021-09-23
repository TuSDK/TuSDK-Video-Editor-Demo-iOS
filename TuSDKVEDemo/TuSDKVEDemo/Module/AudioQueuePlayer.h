//
//  AudioQueuePlayer.h
//  TuSDKVEDemo
//
//  Created by 刘鹏程 on 2021/8/17.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
NS_ASSUME_NONNULL_BEGIN

@interface AudioQueuePlayer : NSObject


+ (instancetype)shared;

- (void)playerWithFilePath:(NSString *)filePath;

@end

NS_ASSUME_NONNULL_END

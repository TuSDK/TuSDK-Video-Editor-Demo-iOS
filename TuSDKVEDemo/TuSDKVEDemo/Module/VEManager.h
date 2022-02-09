//
//  VEManager.h
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/12/1.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TuSDKPulseEditor.h"
#import "TuSDKPulseCore.h"
NS_ASSUME_NONNULL_BEGIN

@interface VEManager : NSObject
+ (instancetype)shareManager;

- (NSArray <TuFilterOption *> *)filterGroups;
- (NSArray <TuStickerGroup *>*)tuMVStickerGroup;
- (NSArray <NSString *>*)sceneGroup;
- (NSArray <NSString *>*)particleGroup;
- (NSArray <UIColor *>*)particleColorGroup;
- (NSURL *)audioURLWithStickerIdt:(int64_t)stickerIdt;
- (void)loadThumbWithStickerGroup:(TuStickerGroup *)stickerGroup imageView:(UIImageView *)imageView;
@end

NS_ASSUME_NONNULL_END

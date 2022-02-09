//
//  TUPVEFreezeEffect.h
//  TuSDKPulseEditor
//
//  Created by 言有理 on 2021/5/12.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "TUPVEditorEffect.h"
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const TUPVEFreezeEffect_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEFreezeEffect_VIDEO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEFreezeEffect_CONFIG_FREEZE_POS;
FOUNDATION_EXPORT NSString *const TUPVEFreezeEffect_CONFIG_FREEZE_DURATION;
@interface TUPVEFreezeEffect : TUPVEditorEffect

+ (instancetype)effectWithAudio:(TUPVEditorCtx*)ctx;
+ (instancetype)effectWithVideo:(TUPVEditorCtx*)ctx;
@end

NS_ASSUME_NONNULL_END

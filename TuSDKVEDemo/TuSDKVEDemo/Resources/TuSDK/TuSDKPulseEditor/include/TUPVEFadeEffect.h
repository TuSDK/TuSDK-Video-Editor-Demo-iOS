//
//  TUPVEFadeEffect.h
//  TuSDKPulseEditor
//
//  Created by 言有理 on 2021/8/9.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const TUPVEFadeEffect_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEFadeEffect_CONFIG_FADEIN_DURATION;
FOUNDATION_EXPORT NSString *const TUPVEFadeEffect_CONFIG_FADEOUT_DURATION;

@interface TUPVEFadeEffect : NSObject

+ (TUPVEditorEffect *)effectWithAudio:(TUPVEditorCtx*)ctx;
@end

NS_ASSUME_NONNULL_END

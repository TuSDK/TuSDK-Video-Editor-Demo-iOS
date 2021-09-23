
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN




FOUNDATION_EXPORT NSString *const TUPVERepeatEffectV2_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVERepeatEffectV2_VIDEO_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVERepeatEffectV2_CONFIG_DURATION;

@interface TUPVERepeatEffectV2 : NSObject


+ (TUPVEditorEffect*) makeAudio:(TUPVEditorCtx*) ctx;

+ (TUPVEditorEffect*) makeVideo:(TUPVEditorCtx*) ctx;


@end

NS_ASSUME_NONNULL_END

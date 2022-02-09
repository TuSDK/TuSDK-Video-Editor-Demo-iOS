
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN




FOUNDATION_EXPORT NSString *const TUPVERepeatEffect_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVERepeatEffect_VIDEO_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVERepeatEffect_CONFIG_BEGIN;
FOUNDATION_EXPORT NSString *const TUPVERepeatEffect_CONFIG_END;
FOUNDATION_EXPORT NSString *const TUPVERepeatEffect_CONFIG_REPEAT_COUNT;


@interface TUPVERepeatEffect : NSObject


+ (TUPVEditorEffect*) makeAudio:(TUPVEditorCtx*) ctx;

+ (TUPVEditorEffect*) makeVideo:(TUPVEditorCtx*) ctx;


@end

NS_ASSUME_NONNULL_END

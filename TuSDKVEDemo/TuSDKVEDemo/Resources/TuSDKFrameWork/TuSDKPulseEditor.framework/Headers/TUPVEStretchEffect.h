
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN




FOUNDATION_EXPORT NSString *const TUPVEStretchEffect_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEStretchEffect_VIDEO_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVEStretchEffect_CONFIG_BEGIN;
FOUNDATION_EXPORT NSString *const TUPVEStretchEffect_CONFIG_END;
FOUNDATION_EXPORT NSString *const TUPVEStretchEffect_CONFIG_STRETCH;


@interface TUPVEStretchEffect : NSObject


+ (TUPVEditorEffect*) makeAudio:(TUPVEditorCtx*) ctx;

+ (TUPVEditorEffect*) makeVideo:(TUPVEditorCtx*) ctx;


@end

NS_ASSUME_NONNULL_END

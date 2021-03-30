
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN




FOUNDATION_EXPORT NSString *const TUPVETrimEffect_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVETrimEffect_VIDEO_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVETrimEffect_CONFIG_BEGIN;
FOUNDATION_EXPORT NSString *const TUPVETrimEffect_CONFIG_END;


@interface TUPVETrimEffect : NSObject


+ (TUPVEditorEffect*) makeAudio:(TUPVEditorCtx*) ctx;

+ (TUPVEditorEffect*) makeVideo:(TUPVEditorCtx*) ctx;


@end

NS_ASSUME_NONNULL_END

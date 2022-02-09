
#include "TUPVEditorClip.h"

NS_ASSUME_NONNULL_BEGIN



FOUNDATION_EXPORT NSString *const TUPVESilenceClip_AUDIO_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVESilenceClip_CONFIG_DURATION;


@interface TUPVESilenceClip : NSObject

+ (TUPVEditorClip*) make:(TUPVEditorCtx*) ctx;

@end

NS_ASSUME_NONNULL_END

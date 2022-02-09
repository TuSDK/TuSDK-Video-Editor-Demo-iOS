
//#import "TUPVEClipBase.h"

#include "TUPVEditorClip.h"

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT NSString *const TUPVEFileClip_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEFileClip_VIDEO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEFileClip_VIDEO_REVERSE_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVEFileClip_CONFIG_PATH;
FOUNDATION_EXPORT NSString *const TUPVEFileClip_CONFIG_TRIM_START;
FOUNDATION_EXPORT NSString *const TUPVEFileClip_CONFIG_TRIM_DURATION;
FOUNDATION_EXPORT NSString *const TUPVEFileClip_CONFIG_IS_SYNC;


@interface TUPVEFileClip : NSObject



+ (TUPVEditorClip*) makeAudio:(TUPVEditorCtx*) ctx;

+ (TUPVEditorClip*) makeVideo:(TUPVEditorCtx*) ctx;

+ (TUPVEditorClip*) makeVideoReverse:(TUPVEditorCtx*) ctx;

@end

NS_ASSUME_NONNULL_END

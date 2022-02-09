
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN




FOUNDATION_EXPORT NSString *const TUPVEPitchEffect_AUDIO_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVEPitchEffect_CONFIG_TYPE;


FOUNDATION_EXPORT NSString *const TUPVEPitchEffect_TYPE_Normal;
FOUNDATION_EXPORT NSString *const TUPVEPitchEffect_TYPE_Monster;
FOUNDATION_EXPORT NSString *const TUPVEPitchEffect_TYPE_Uncle;
FOUNDATION_EXPORT NSString *const TUPVEPitchEffect_TYPE_Girl;
FOUNDATION_EXPORT NSString *const TUPVEPitchEffect_TYPE_Lolita;

@interface TUPVEPitchEffect : NSObject


+ (TUPVEditorEffect*) make:(TUPVEditorCtx*) ctx;



@end

NS_ASSUME_NONNULL_END

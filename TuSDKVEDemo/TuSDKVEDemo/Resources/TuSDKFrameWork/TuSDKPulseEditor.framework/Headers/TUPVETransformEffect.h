
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT NSString *const TUPVETransformEffect_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVETransformEffect_CONFIG_MODE;


FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_None;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_K90;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_K180;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_K270;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_VFlip;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_HFlip;


@interface TUPVETransformEffect : NSObject


+ (TUPVEditorEffect*) make:(TUPVEditorCtx*) ctx;


@end

NS_ASSUME_NONNULL_END

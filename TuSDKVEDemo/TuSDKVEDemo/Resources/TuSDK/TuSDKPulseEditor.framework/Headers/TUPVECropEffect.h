
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT NSString *const TUPVECropEffect_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVECropEffect_CONFIG_LEFT;
FOUNDATION_EXPORT NSString *const TUPVECropEffect_CONFIG_TOP;
FOUNDATION_EXPORT NSString *const TUPVECropEffect_CONFIG_RIGHT;
FOUNDATION_EXPORT NSString *const TUPVECropEffect_CONFIG_BOTTOM;



@interface TUPVECropEffect : NSObject


+ (TUPVEditorEffect*) make:(TUPVEditorCtx*) ctx;


@end

NS_ASSUME_NONNULL_END

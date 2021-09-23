
#import <Foundation/Foundation.h>

#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT NSString *const TUPVETransformEffect_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVETransformEffect_CONFIG_MODE;


FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_None;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_90;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_180;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_270;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_HFlip;

FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_VFlip;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_VFlip90;
FOUNDATION_EXPORT NSString *const TUPVETransformEffect_MODE_VFlip270;


@interface TUPVETransformEffect : NSObject


+ (TUPVEditorEffect*) make:(TUPVEditorCtx*) ctx;


@end

@interface TUPVETransformEffect_ModeTransfer : NSObject


- (instancetype) init;
- (instancetype) init:(NSString*) mode;

- (NSString*) applyMirror;
- (NSString*) applyFlip;
- (NSString*) applyRotateCW;
- (NSString*) applyRotateCCW;


@end



NS_ASSUME_NONNULL_END

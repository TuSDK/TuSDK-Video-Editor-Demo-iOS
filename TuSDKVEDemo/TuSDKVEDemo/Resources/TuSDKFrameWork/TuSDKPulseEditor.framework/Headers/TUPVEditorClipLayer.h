
#import <Foundation/Foundation.h>
#import <TuSDKPulse/TUPBase.h>
#import <TuSDKPulse/TUPConfig.h>


#include "TUPVEditorLayer.h"
//#include "TUPVEditorEffect.h"


NS_ASSUME_NONNULL_BEGIN

@class TUPVEditorCtx;
@class TUPVEditorClip;
@class TUPVEditorEffects;




///TUPVEditorClipLayer_Transition::name

FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_Fade;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_FadeColor;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_WipeLeft;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_WipeRight;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_WipeUp;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_WipeDown;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_PullLeft;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_PullRight;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_PullUp;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_PullDown;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_Swap;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_Doorway;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_CrossZoom;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_CrossWarp;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_PinWheel;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_Radial;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_SimpleZoom;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_DreamyZoom;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_Perlin;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_Circle;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_CircleOpen;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_CircleClose;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_LinearBlur;
FOUNDATION_EXPORT NSString *const TUPVEditorClipLayer_Transition_NAME_Heart;


@interface TUPVEditorClipLayer_Transition : NSObject

@property(nonatomic) NSInteger duration;
@property(nonatomic, copy) NSString* name;

- (instancetype) init;

@end


@interface TUPVEditorClipLayer : TUPVEditorLayer {
//
}

- (instancetype) initForAudio:(TUPVEditorCtx*) ctx;
- (instancetype) initForVideo:(TUPVEditorCtx*) ctx;
- (instancetype) init:(TUPVEditorCtx*) ctx forVideo:(BOOL) v;

- (instancetype) init:(TUPVEditorCtx*) ctx withModel:(TUPVEditorModel*) model;
- (instancetype) init:(TUPVEditorCtx*) ctx withImpl:(void*) impl;



- (BOOL) setTransition:(TUPVEditorClipLayer_Transition*) transition at:(NSInteger) idx;
- (TUPVEditorClipLayer_Transition*) getTransition:(NSInteger) idx;
- (BOOL) unsetTransition:(NSInteger) idx;


- (BOOL) addClip:(TUPVEditorClip*) clip at:(NSInteger) idx;

- (BOOL) deleteClip:(NSInteger) idx;

- (void) deleteAllClips;

- (BOOL) swapClips:(NSInteger) idx1 and:(NSInteger) idx2;


- (TUPVEditorClip* _Nullable) getClip:(NSInteger) idx;

- (NSDictionary<NSNumber*, TUPVEditorClip*>*) getAllClips;

- (TUPVEditorEffects*) effects;


@end



NS_ASSUME_NONNULL_END

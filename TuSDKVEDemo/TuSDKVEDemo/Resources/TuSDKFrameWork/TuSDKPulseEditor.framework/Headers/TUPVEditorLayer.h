
#import <Foundation/Foundation.h>
#import <TuSDKPulse/TUPBase.h>
#import <TuSDKPulse/TUPConfig.h>
#import <TuSDKPulse/TUPProperty.h>
#import <TuSDKPulse/TUPStreamInfo.h>

#import "TUPVEditorModel.h"



NS_ASSUME_NONNULL_BEGIN

@class TUPVEditorCtx;
@class TUPVEditorEffect;
@class TUPVEditorEffects;
@class TUPVEditorLayer;
//


FOUNDATION_EXPORT NSString *const TUPVEditorLayer_CONFIG_MAIN_LAYER;
FOUNDATION_EXPORT NSString *const TUPVEditorLayer_CONFIG_START_POS;

///VideoLayer
FOUNDATION_EXPORT NSString *const TUPVEditorLayer_CONFIG_BLEND_MODE;

FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_None;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Default;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Normal;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Overlay;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Add;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Subtract;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Negation;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Average;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Multiply;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Difference;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Screen;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Softlight;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Hardlight;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Linearlight;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Pinlight;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Lighten;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Darken;
//FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Reflect;
FOUNDATION_EXPORT NSString *const TUPVEditorLayerBlendMode_Exclusion;





@interface TUPVEditorLayer_InteractionInfo : NSObject {
    
}

@property(nonatomic) double posX;
@property(nonatomic) double posY;
@property(nonatomic) int width;
@property(nonatomic) int height;
@property(nonatomic) double rotation;

- (instancetype) init;

- (instancetype) init:(TUPProperty*) prop;


@end




@interface TUPVEditorLayer : TUPBase {
    
@package
    void* _impl;
}

@property(nonatomic, readonly) TUPVEditorCtx* context;


- (instancetype) init:(TUPVEditorCtx*) ctx;

//- (instancetype) init:(TUPVEditorCtx*) ctx withImpl:(void*) impl;

//- (instancetype) init:(TUPVEditorCtx*) ctx withType:(NSString*) type;

//- (instancetype) init:(TUPVEditorCtx*) ctx withModel:(TUPVEditorModel*) model;



/// Effects operation root
- (TUPVEditorEffects*) effects;

- (BOOL) setConfig:(TUPConfig*) config;
- (TUPConfig*) getConfig;

- (BOOL) setProperty:(TUPProperty*) prop forKey:(NSString*) key;
- (TUPProperty*  _Nullable) getProperty:(NSString*) key;


- (TUPVEditorModel*) getModel;
- (BOOL) setModel:(TUPVEditorModel*) model;


- (BOOL) activate;
- (void) deactivate;

- (TUPStreamInfo*  _Nullable) getStreamInfo;
//- (TUPStreamInfo*  _Nullable) getOriginStreamInfo;


- (NSString*) getType;


+ (TUPVEditorLayer*) newLayer:(TUPVEditorCtx*) ctx withImpl:(void*) impl;

+ (TUPVEditorLayer*) newLayer:(TUPVEditorCtx*) ctx withModel:(TUPVEditorModel*) model;

@end





///VideoLayer
FOUNDATION_EXPORT NSString *const TUPVEditorLayer_PROP_INTERACTION_INFO;
FOUNDATION_EXPORT NSString *const TUPVEditorLayer_PROP_OVERLAY;


@interface TUPVEditorLayer_OverlayPropertyHolder : NSObject

/// Upper layer's opacity, range [0, 1]
@property(nonatomic) float opacity;
/// Blend strength, range [0, 1]
@property(nonatomic) float blendStrength;

/// Pan x/y, range [0, 1]
@property(nonatomic) float pzrPanX;
@property(nonatomic) float pzrPanY;
/// Zoom/scale, fitin size: 1, range [0, +oo]
@property(nonatomic) float pzrZoom;
/// Rotate, unit: degree
@property(nonatomic) double pzrRotate;




- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end


@interface TUPVEditorLayer_OverlayPropertyBuilder : NSObject

@property(nonatomic) TUPVEditorLayer_OverlayPropertyHolder* holder;


- (instancetype) init;
- (instancetype) initWithHolder:(TUPVEditorLayer_OverlayPropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end





///AudioLayer
FOUNDATION_EXPORT NSString *const TUPVEditorLayer_PROP_MIX;


@interface TUPVEditorLayer_MixPropertyHolder : NSObject

/// Audio mix weight, range [0, +oo]
@property(nonatomic) float weight;

- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end

@interface TUPVEditorLayer_MixPropertyBuilder : NSObject


@property(nonatomic) TUPVEditorLayer_MixPropertyHolder* holder;


- (instancetype) init;
- (instancetype) initWithHolder:(TUPVEditorLayer_MixPropertyHolder*) holder;

- (TUPProperty*) makeProperty;

@end


NS_ASSUME_NONNULL_END

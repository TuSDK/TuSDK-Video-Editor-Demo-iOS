
//#import "TUPVEEffectBase.h"

//#import <CoreGraphics/CGColor.h>
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>

NS_ASSUME_NONNULL_BEGIN





FOUNDATION_EXPORT NSString *const TUPVECanvasResizeEffect_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVECanvasResizeEffect_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVECanvasResizeEffect_PROP_INTERACTION_INFO;



@interface TUPVECanvasResizeEffect_InteractionInfo : NSObject {
    
}

@property(nonatomic) double posX;
@property(nonatomic) double posY;
@property(nonatomic) int width;
@property(nonatomic) int height;
@property(nonatomic) double rotation;

- (instancetype) init;

- (instancetype) init:(TUPProperty*) prop;


@end




typedef NS_ENUM(NSInteger, TUPVECanvasResizeEffect_BackgroundType) {
    TUPVECanvasResizeEffect_BackgroundType_Color,
    TUPVECanvasResizeEffect_BackgroundType_Blur,
    TUPVECanvasResizeEffect_BackgroundType_Image
};


@interface TUPVECanvasResizeEffect_PropertyHolder : NSObject


@property(nonatomic) TUPVECanvasResizeEffect_BackgroundType type;
@property(nonatomic) UIColor* color;
@property(nonatomic) NSString* image;
@property(nonatomic) double blurStrength;
@property(nonatomic) double panX;
@property(nonatomic) double panY;
@property(nonatomic) double zoom;
@property(nonatomic) double rotate;

- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;


@end



@interface TUPVECanvasResizeEffect_PropertyBuilder : NSObject {
    
}


@property(nonatomic) TUPVECanvasResizeEffect_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVECanvasResizeEffect_PropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end


@interface TUPVECanvasResizeEffect : NSObject

@end

NS_ASSUME_NONNULL_END

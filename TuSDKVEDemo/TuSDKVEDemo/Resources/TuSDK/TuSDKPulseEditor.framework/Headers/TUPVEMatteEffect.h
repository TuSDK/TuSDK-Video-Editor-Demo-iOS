
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_PROP_INTERACTION_INFO;

FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_CONFIG_TYPE;
FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_CONFIG_TYPE_LINEAR;
FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_CONFIG_TYPE_MIRROR;
FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_CONFIG_TYPE_CIRCLE;
FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_CONFIG_TYPE_RECTANGLE;
FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_CONFIG_TYPE_LOVE;
FOUNDATION_EXPORT NSString *const TUPVEMatteEffect_CONFIG_TYPE_STAR;

@interface TUPVEMatteEffect_InteractionInfo : NSObject {
    
}
//
//@property(nonatomic) double posX;
//@property(nonatomic) double posY;
//@property(nonatomic) double width;
//@property(nonatomic) double height;
//@property(nonatomic) double rotate;


@property(nonatomic) NSMutableDictionary<NSString*, NSNumber*>* values;

- (instancetype) init;

- (instancetype) init:(TUPProperty*) prop;


@end





@interface TUPVEMatteEffect_PropertyHolder : NSObject

//
//@property(nonatomic) TUPVEMatteEffect_BackgroundType type;
//@property(nonatomic) UIColor* color;
//@property(nonatomic) NSString* image;
//@property(nonatomic) double blurStrength;
//@property(nonatomic) double panX;
//@property(nonatomic) double panY;
//@property(nonatomic) double zoom;
//@property(nonatomic) double rotate;
@property(nonatomic) NSMutableDictionary<NSString*, NSNumber*>* values;


- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;


@end



@interface TUPVEMatteEffect_PropertyBuilder : NSObject {
    
}


@property(nonatomic) TUPVEMatteEffect_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVEMatteEffect_PropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end


@interface TUPVEMatteEffect : NSObject

@end

NS_ASSUME_NONNULL_END

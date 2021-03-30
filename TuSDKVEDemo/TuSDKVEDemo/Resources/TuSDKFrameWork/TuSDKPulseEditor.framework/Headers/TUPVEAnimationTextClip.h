
#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>


NS_ASSUME_NONNULL_BEGIN



FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_CONFIG_DURATION;


FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_PROP_INTERACTION_INFO;


@interface TUPVEAnimationTextClip_InteractionInfo : NSObject {
    
}

@property(nonatomic) double posX;
@property(nonatomic) double posY;
@property(nonatomic) int width;
@property(nonatomic) int height;
@property(nonatomic) int rotation;

- (instancetype) init;

- (instancetype) init:(TUPProperty*) prop;


@end






typedef NS_ENUM(NSInteger, TUPVEAnimationTextClip_AlignmentType) {
    TUPVEAnimationTextClipAlignmentType_LEFT,
    TUPVEAnimationTextClipAlignmentType_CENTER,
    TUPVEAnimationTextClipAlignmentType_RIGHT
};



@interface TUPVEAnimationTextClip_PropertyHolder : NSObject



@property(nonatomic, copy) NSString* font;
@property(nonatomic, copy) NSString* text;

@property(nonatomic) double posX;
@property(nonatomic) double posY;
@property(nonatomic) double fontScale;
@property(nonatomic) int rotation;

@property(nonatomic) double textScaleX;
@property(nonatomic) double textScaleY;

@property(nonatomic) double strokeWidth;
@property(nonatomic) UIColor* strokeColor;

@property(nonatomic) UIColor* fillColor;

@property(nonatomic) int64_t startTs;
@property(nonatomic) int64_t endTs;
@property(nonatomic) int64_t inTs;
@property(nonatomic) int64_t outTs;

@property(nonatomic) TUPVEAnimationTextClip_AlignmentType alignment;
@property(nonatomic) double blurStrength;


- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end


@interface TUPVEAnimationTextClip_PropertyBuilder : NSObject {
    
}


@property(nonatomic) TUPVEAnimationTextClip_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVEAnimationTextClip_PropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end




@interface TUPVEAnimationTextClip : NSObject

@end

NS_ASSUME_NONNULL_END


#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>


NS_ASSUME_NONNULL_BEGIN



FOUNDATION_EXPORT NSString *const TUPVEText2DClip_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVEText2DClip_CONFIG_DURATION;


FOUNDATION_EXPORT NSString *const TUPVEText2DClip_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEText2DClip_PROP_INTERACTION_INFO;


@interface TUPVEText2DClip_InteractionInfo : NSObject {
    
}

@property(nonatomic) double posX;
@property(nonatomic) double posY;
@property(nonatomic) int width;
@property(nonatomic) int height;
@property(nonatomic) int rotation;

- (instancetype) init;

- (instancetype) init:(TUPProperty*) prop;


@end






typedef NS_ENUM(NSInteger, TUPVEText2DClip_AlignmentType) {
    TUPVEText2DClipAlignmentType_LEFT,
    TUPVEText2DClipAlignmentType_CENTER,
    TUPVEText2DClipAlignmentType_RIGHT
};



@interface TUPVEText2DClip_PropertyHolder : NSObject



@property(nonatomic, copy) NSString* font;
@property(nonatomic, copy) NSString* text;

@property(nonatomic) int underline;

@property(nonatomic) double posX;
@property(nonatomic) double posY;
@property(nonatomic) double fontScale;
@property(nonatomic) int rotation;

@property(nonatomic) double textScaleX;
@property(nonatomic) double textScaleY;

@property(nonatomic) double strokeWidth;
@property(nonatomic) UIColor* strokeColor;

@property(nonatomic) UIColor* fillColor;

@property(nonatomic) UIColor* bgColor;




@property(nonatomic) TUPVEText2DClip_AlignmentType alignment;
@property(nonatomic) double blurStrength;


- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end


@interface TUPVEText2DClip_PropertyBuilder : NSObject {
    
}


@property(nonatomic) TUPVEText2DClip_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVEText2DClip_PropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end




@interface TUPVEText2DClip : NSObject

@end

NS_ASSUME_NONNULL_END

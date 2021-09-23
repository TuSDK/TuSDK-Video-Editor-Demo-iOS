
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>

NS_ASSUME_NONNULL_BEGIN





FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_TYPE_NAME;


FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_PARAM;


/// 0:temp:[-1, 1], 1:tint:[0, 1]
FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_TYPE_WhiteBalance;

/// 0:highlight:[0, 1], 1:shadow:[0, 1]
FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_TYPE_HighlightShadow;

/// 0:[-1, 1]
FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_TYPE_Sharpen;

/// 0:[-1, 1]
FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_TYPE_Brightness;

/// 0:[0, 1]
FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_TYPE_Contrast;

/// 0:[-1, 1]
FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_TYPE_Saturation;

/// 0:[-1, 1]
FOUNDATION_EXPORT NSString *const TUPVEColorAdjustEffect_PROP_TYPE_Exposure;


@interface TUPVEColorAdjustEffect_PropertyItem : NSObject

@property(nonatomic, copy) NSString* name;
@property(nonatomic) NSArray<NSNumber*>* values;

- (instancetype) init:(NSString*) name with:(double) v;
- (instancetype) init:(NSString*) name with:(double) v0 and:(double) v1;
- (instancetype) init:(NSString*) name withArray:(NSArray<NSNumber*>*) arr;


@end


@interface TUPVEColorAdjustEffect_PropertyHolder : NSObject


@property(nonatomic) NSMutableArray<TUPVEColorAdjustEffect_PropertyItem*>* items;

- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;


@end


@interface TUPVEColorAdjustEffect_PropertyBuilder : NSObject

@property(nonatomic) TUPVEColorAdjustEffect_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVEColorAdjustEffect_PropertyHolder*) holder;

- (TUPProperty*) makeProperty;

@end


@interface TUPVEColorAdjustEffect : NSObject

@end

NS_ASSUME_NONNULL_END

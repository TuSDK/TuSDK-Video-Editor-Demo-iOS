
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>

NS_ASSUME_NONNULL_BEGIN





FOUNDATION_EXPORT NSString *const TUPVETusdkParticleEffect_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVETusdkParticleEffect_CONFIG_NAME;


FOUNDATION_EXPORT NSString *const TUPVETusdkParticleEffect_PROP_PARTICLE_POS;

FOUNDATION_EXPORT NSString *const TUPVETusdkParticleEffect_PROP_PARAM;




@interface TUPVETusdkParticleEffect_PosPropertyBuilder : NSObject {
    
}


@property(nonatomic) double posX;
@property(nonatomic) double posY;

@property(nonatomic) double scale;
@property(nonatomic) UIColor* tint;


- (instancetype) init;

- (TUPProperty*) makeProperty;

@end



@interface TUPVETusdkParticleEffect_PosInfo : NSObject {
    
}

@property(nonatomic) int64_t timestamp;
@property(nonatomic) double posX;
@property(nonatomic) double posY;

- (instancetype) init:(int64_t) ts withPosX:(double) x andY:(double) y;

@end


@interface TUPVETusdkParticleEffect_PropertyHolder : NSObject



@property(nonatomic) int64_t  begin;
@property(nonatomic) int64_t  end;

@property(nonatomic) double scale;
@property(nonatomic) UIColor* tint;

@property(nonatomic) NSArray<TUPVETusdkParticleEffect_PosInfo*>* trajectory;

- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end

@interface TUPVETusdkParticleEffect_PropertyBuilder : NSObject {
    
}
@property(nonatomic) TUPVETusdkParticleEffect_PropertyHolder* holder;


- (instancetype) init;
- (instancetype) initWithHolder:(TUPVETusdkParticleEffect_PropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end


@interface TUPVETusdkParticleEffect : NSObject

@end

NS_ASSUME_NONNULL_END

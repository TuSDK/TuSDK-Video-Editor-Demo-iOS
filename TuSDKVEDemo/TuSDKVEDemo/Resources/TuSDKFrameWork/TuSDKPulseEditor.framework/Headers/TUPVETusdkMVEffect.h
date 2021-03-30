
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>

NS_ASSUME_NONNULL_BEGIN





FOUNDATION_EXPORT NSString *const TUPVETusdkMVEffect_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVETusdkMVEffect_CONFIG_CODE;

FOUNDATION_EXPORT NSString *const TUPVETusdkMVEffect_PROP_PARAM;





@interface TUPVETusdkMVEffect_PropertyHolder : NSObject



@property(nonatomic) int64_t  begin;
@property(nonatomic) int64_t  end;


- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end




@interface TUPVETusdkMVEffect_PropertyBuilder : NSObject {
    
}


@property(nonatomic) TUPVETusdkMVEffect_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVETusdkMVEffect_PropertyHolder*) holder;

- (TUPProperty*) makeProperty;

@end


@interface TUPVETusdkMVEffect : NSObject

@end

NS_ASSUME_NONNULL_END


#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>

NS_ASSUME_NONNULL_BEGIN





FOUNDATION_EXPORT NSString *const TUPVETusdkFilterEffect_TYPE_NAME;

FOUNDATION_EXPORT NSString *const TUPVETusdkFilterEffect_CONFIG_NAME;

FOUNDATION_EXPORT NSString *const TUPVETusdkFilterEffect_PROP_PARAM;




@interface TUPVETusdkFilterEffect_PropertyHolder : NSObject



@property(nonatomic) int64_t  begin;
@property(nonatomic) int64_t  end;
@property(nonatomic) double  strength;


- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end



@interface TUPVETusdkFilterEffect_PropertyBuilder : NSObject {
    
}



@property(nonatomic) TUPVETusdkFilterEffect_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVETusdkFilterEffect_PropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end


@interface TUPVETusdkFilterEffect : NSObject

@end

NS_ASSUME_NONNULL_END

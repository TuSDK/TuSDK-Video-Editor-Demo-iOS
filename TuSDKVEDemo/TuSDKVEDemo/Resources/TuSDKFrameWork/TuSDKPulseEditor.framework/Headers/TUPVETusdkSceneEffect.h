
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>

NS_ASSUME_NONNULL_BEGIN





FOUNDATION_EXPORT NSString *const TUPVETusdkSceneEffect_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVETusdkSceneEffect_CONFIG_NAME;

FOUNDATION_EXPORT NSString *const TUPVETusdkSceneEffect_PROP_PARAM;





@interface TUPVETusdkSceneEffect_PropertyHolder : NSObject



@property(nonatomic) int64_t  begin;
@property(nonatomic) int64_t  end;


- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;



@end



@interface TUPVETusdkSceneEffect_PropertyBuilder : NSObject {
    
}


@property(nonatomic) TUPVETusdkSceneEffect_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVETusdkSceneEffect_PropertyHolder*) holder;


- (TUPProperty*) makeProperty;

@end


@interface TUPVETusdkSceneEffect : NSObject

@end

NS_ASSUME_NONNULL_END

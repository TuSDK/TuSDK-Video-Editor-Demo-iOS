
#import <Foundation/Foundation.h>
#import <TuSDKPulse/TuSDKPulse.h>
#import <TuSDKPulse/TUPConfig.h>
#import <TuSDKPulse/TUPProperty.h>
#import <TuSDKPulse/TUPStreamInfo.h>

#import "TUPVEditorModel.h"

NS_ASSUME_NONNULL_BEGIN


@class TUPVEditorCtx;
@interface TUPVEditorEffect : TUPBase {
    
@package
    //TUPVEditorEffectImpl
    void* _impl;
    
}

//@property(nonatomic, copy) NSString* name;


- (instancetype) init NS_UNAVAILABLE;

- (instancetype) init:(TUPVEditorCtx*) ctx withImpl:(void*) impl;

- (instancetype) init:(TUPVEditorCtx*) ctx withType:(NSString*) type;

- (instancetype) init:(TUPVEditorCtx*) ctx withModel:(TUPVEditorModel*) model;


- (BOOL) setConfig:(TUPConfig*) config;
- (TUPConfig*) getConfig;

- (BOOL) setProperty:(TUPProperty*) prop forKey:(NSString*) key;
- (TUPProperty*  _Nullable) getProperty:(NSString*) key;


- (TUPVEditorModel*) getModel;
- (BOOL) setModel:(TUPVEditorModel*) model;

- (NSString*) getType;

//- (BOOL) activate;
//- (void) deactivate;
//- (TUPStreamInfo*) getStreamInfo;



@end











@interface TUPVEditorEffects : TUPBase {
    
    
}

- (instancetype) init:(TUPVEditorCtx*) ctx withImpl:(void*) impl;//EffectChain*

- (BOOL) addEffect:(TUPVEditorEffect*) effect at:(NSInteger) idx;

- (TUPVEditorEffect*  _Nullable) getEffect:(NSInteger) idx;

- (BOOL) deleteEffect:(NSInteger) idx;

- (void) deleteAllEffects;

- (NSDictionary<NSNumber*, TUPVEditorEffect*>*) getAllEffects;


@end

NS_ASSUME_NONNULL_END

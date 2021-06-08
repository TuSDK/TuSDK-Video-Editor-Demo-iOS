
#import <Foundation/Foundation.h>
#import <TuSDKPulse/TUPBase.h>
#import <TuSDKPulse/TUPConfig.h>
#import <TuSDKPulse/TUPProperty.h>
#import <TuSDKPulse/TUPStreamInfo.h>
#import "TUPVEditorModel.h"


NS_ASSUME_NONNULL_BEGIN



@class TUPVEditorCtx;
@class TUPVEditorEffect;
@class TUPVEditorEffects;
@class TUPVEditorClip;



@interface TUPVEditorClip : TUPBase {
    
@package
    void* _impl;
    
}

@property(nonatomic, readonly) TUPVEditorCtx* context;
@property(nonatomic, readonly) NSString* mediaType;


- (instancetype) init NS_UNAVAILABLE;

- (instancetype) init:(TUPVEditorCtx*) ctx withImpl:(void*) impl;

- (instancetype) init:(TUPVEditorCtx*) ctx withType:(NSString*) type;

- (instancetype) init:(TUPVEditorCtx*) ctx withModel:(TUPVEditorModel*) model;



/// Effects operation root
- (TUPVEditorEffects*) effects;

- (BOOL) setConfig:(TUPConfig*) config;
- (TUPConfig*) getConfig;

- (BOOL) setProperty:(TUPProperty*) prop forKey:(NSString*) key;
- (TUPProperty*  _Nullable) getProperty:(NSString*) key;


- (TUPVEditorModel*) getModel;
- (BOOL) setModel:(TUPVEditorModel*) model;


- (BOOL) activate;
- (void) deactivate;


- (TUPStreamInfo* _Nullable) getStreamInfo;

- (TUPStreamInfo* _Nullable) getOriginStreamInfo;


- (NSString*) getType;


@end

NS_ASSUME_NONNULL_END

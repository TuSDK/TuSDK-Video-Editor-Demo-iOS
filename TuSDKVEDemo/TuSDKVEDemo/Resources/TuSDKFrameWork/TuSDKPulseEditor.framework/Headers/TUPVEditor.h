
#import <Foundation/Foundation.h>
#import <TuSDKPulse/TUPBase.h>
#import <TuSDKPulse/TUPPlayer.h>
#import <TuSDKPulse/TUPProducer.h>


NS_ASSUME_NONNULL_BEGIN
//
//@class TUPPlayer;
//@class TUPProducer;
//
@class TUPVEditorComposition;
@class TUPVEditorCompositionModel;
@class TUPVEditorEditorModel;

@interface TUPVEditorPlayer : TUPPlayer
- (instancetype) initWithImpl:(void*) impl;
- (BOOL) open;
- (void) lock;
- (void) unlock;
@end


@interface TUPVEditorProducer : TUPProducer
- (instancetype) initWithImpl:(void*) impl;
- (BOOL) open;
@end



@interface TUPVEditor_Config : NSObject {
}

/// initial-duration, if dont's have any layers
@property(nonatomic) NSInteger initialDuration;
/// video output/stream width
@property(nonatomic) NSInteger width;
/// video output/stream height
@property(nonatomic) NSInteger height;
/// video output/stream framerate
@property(nonatomic) double framerate;
/// audio output/stream sample-rate
@property(nonatomic) NSInteger sampleRate;
//@property(nonatomic) NSInteger sampleCount;
/// audio output/stream channels
@property(nonatomic) int channels;


/// TUPVEditor_Config -> pulse::Config
/// @param config input config
- (BOOL) unwrap:(void*) config;

/// pulse::Config -> TUPVEditor_Config
/// @param config output config
- (BOOL) wrap:(void*) config;

@end



@interface TUPVEditorCtx : NSObject {
    @package
    void* _impl;
}

- (instancetype) initWithImpl:(void*)ctx;//pulse::editor::EditorContext

@end


@interface TUPVEditor : TUPBase

/// get Editor Context
- (TUPVEditorCtx*) getContext;

/// get Editor Config
- (TUPVEditor_Config*) getConfig;


/// create Editor
- (BOOL) createWithConfig:(TUPVEditor_Config*) config;
- (BOOL) createWithModel:(TUPVEditorEditorModel*) model;

/// destroy Editor
- (void) destroy;


/// update
- (BOOL) updateWithConfig:(TUPVEditor_Config*) config;





/// create Player from Editor
- (TUPPlayer*) newPlayer;

/// release Player resource
- (void) resetPlayer;


/// create Producer from Editor
- (TUPProducer*) newProducer;

/// release Producer resource
- (void) resetProducer;



- (TUPVEditorComposition*) videoComposition;

- (TUPVEditorComposition*) audioComposition;

//- (TUPVEditorComposition*) resetVideoComposition:(TUPVEditorCompositionModel*) model;
//
//- (TUPVEditorComposition*) resetAudioComposition:(TUPVEditorCompositionModel*) model;

/// build internal streams
- (BOOL) build;

/// deprecated
- (NSInteger) getDuration;

/// dump internal streams
- (void) debugDump;


/// current editor model
- (TUPVEditorEditorModel*) getModel;

@end

NS_ASSUME_NONNULL_END

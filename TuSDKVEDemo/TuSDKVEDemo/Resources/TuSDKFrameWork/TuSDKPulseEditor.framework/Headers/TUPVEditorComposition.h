
#import <Foundation/Foundation.h>

#import <TuSDKPulse/TUPBase.h>

#import "TUPVEditorClip.h"
#import "TUPVEditorModel.h"

NS_ASSUME_NONNULL_BEGIN


@class TUPVEditorCtx;
@class TUPVEditorLayer;
@class TUPVEditorComposition;
//

@interface TUPVEditorCompositionModel : TUPVEditorModel {
    
}

- (instancetype) initWithComposition:(TUPVEditorComposition*) comp;
@end


@interface TUPVEditorComposition : TUPVEditorClip {
}


- (instancetype) init:(TUPVEditorCtx*) ctx withImpl:(void*) impl; // TUPVEditorClipImpl*


- (BOOL) addLayer:(TUPVEditorLayer*) layer at:(NSInteger) idx;

- (BOOL) deleteLayerAt:(NSInteger) idx;

- (BOOL) deleteLayer:(TUPVEditorLayer*) layer;

- (BOOL) moveLayer:(TUPVEditorLayer*) from to:(TUPVEditorLayer*) to;

- (BOOL) swapLayer:(TUPVEditorLayer*) first and:(TUPVEditorLayer*) second;


- (NSDictionary<NSNumber*, TUPVEditorLayer*>*) getAllLayers;

- (TUPVEditorLayer*  _Nullable) getLayer:(NSInteger) idx;
- (NSInteger) getLayerIndex:(TUPVEditorLayer*) layer;


//- (void) debugDump;

- (BOOL) build;


@end

NS_ASSUME_NONNULL_END

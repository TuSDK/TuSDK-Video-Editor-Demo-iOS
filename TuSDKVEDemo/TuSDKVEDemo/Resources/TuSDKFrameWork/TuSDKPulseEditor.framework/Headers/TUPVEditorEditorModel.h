
#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface TUPVEditorEditorModel : NSObject {
    @package
    void* _impl;
}

- (instancetype) initWithImpl:(void*)impl;


/// Create EditorModel from json string
/// @param modestr json string
- (instancetype) initWithString:(NSString*) modestr;


/// Save EditorModel to file,
/// @param path path to model file
- (BOOL) save:(NSString*) path;

- (void) dump;

- (BOOL) unwrap:(void*)impl;


- (TUPVEditorEditorModel*) duplicate;


@end




@protocol TUPVEditorEditorModelEditorDelegate <NSObject>

- (NSString*) onModifyClipPath:(NSString*) path forName:(NSString*) name andType:(NSString*) type;

@end

@interface TUPVEditorEditorModelEditor : NSObject

@property (nonatomic, weak) id<TUPVEditorEditorModelEditorDelegate> delegate;


- (instancetype) init:(TUPVEditorEditorModel*) model;

- (int) modifyClipPath;


@end






NS_ASSUME_NONNULL_END


#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface TUPVEditorModel : NSObject {
    @package
    void* _impl;
}

@property (nonatomic, readonly) NSString* TAG;

- (instancetype) initWithImpl:(void*)impl;
- (BOOL) unwrap:(void*)impl;



//- (void) dump;



@end



NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUPVEditorClip.h"
#import "TUPVEditorEffect.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_CONFIG_POS;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_CONFIG_DURATION;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_PATH_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_RECT_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_PROP_APPEND_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_PROP_EXTEND_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_PROP_DELETE_PARAM;

FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_CODE_FILL;
FOUNDATION_EXPORT NSString *const TUPVEMosaicEffect_CODE_ERASER;


// rect mode --------------------------------------------------
@interface TUPVEMosaicEffect_RectInfo : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double width;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) double rotation;
@property (nonatomic, assign) double scale;
@end

@interface TUPVEMosaicEffect_RectPropertyHolder : NSObject
@property (nonatomic, strong) NSMutableArray <TUPVEMosaicEffect_RectInfo *> *rects;
- (instancetype)initWithProperty:(TUPProperty *)prop;
@end

@interface TUPVEMosaicEffect_RectPropertyBuilder : NSObject
@property (nonatomic, strong) TUPVEMosaicEffect_RectPropertyHolder* holder;

- (instancetype)initWithHolder:(TUPVEMosaicEffect_RectPropertyHolder*)holder;
- (TUPProperty *)makeProperty;
- (TUPProperty *)makeAppendProperty:(double)rectX rectY:(double)rectY rectW:(double)rectW rectH:(double)rectH index:(NSInteger)index;
- (TUPProperty *)makeDeleteProperty:(NSInteger)index;
@end


// path mode --------------------------------------------------
@interface TUPVEMosaicEffect_PathInfo : NSObject
@property (nonatomic, strong) NSString *code;
@property (nonatomic, assign) double thickness;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray <NSValue *> *points;
@end

@interface TUPVEMosaicEffect_PathPropertyHolder : NSObject
@property (nonatomic, strong) NSMutableArray <TUPVEMosaicEffect_PathInfo *> *paths;
- (instancetype)initWithProperty:(TUPProperty *)prop;
@end

@interface TUPVEMosaicEffect_PathPropertyBuilder : NSObject
@property (nonatomic, strong) TUPVEMosaicEffect_PathPropertyHolder* holder;

- (instancetype)initWithHolder:(TUPVEMosaicEffect_PathPropertyHolder*)holder;
- (TUPProperty *)makeProperty;
- (TUPProperty *)makeAppendProperty:(double)posX posY:(double)posY index:(NSInteger)index thickness:(double)thickness code:(NSString *)code;
- (TUPProperty *)makeExtendProperty:(double)posX posY:(double)posY index:(NSInteger)index;
- (TUPProperty *)makeDeleteProperty:(NSInteger)index;
@end



@interface TUPVEMosaicEffect : TUPVEditorEffect
+ (instancetype)effectWithCtx:(TUPVEditorCtx*)ctx;
@end


NS_ASSUME_NONNULL_END

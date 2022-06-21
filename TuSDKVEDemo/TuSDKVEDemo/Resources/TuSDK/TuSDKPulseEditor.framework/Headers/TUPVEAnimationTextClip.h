
#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>

#import <TuSDKPulse/TUPProperty.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TUPVEAnimationTextClip_BoundType) {
    TUPVEAnimationTextClip_BoundTypeAll,
    TUPVEAnimationTextClip_BoundTypeTextAll,
    TUPVEAnimationTextClip_BoundTypeTextLine,
};

FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_CONFIG_DURATION;
FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEAnimationTextClip_PROP_INTERACTION_INFO;

//--------------------------------------------------------------------------------------------

@interface TUPVEAnimationTextClip_InteractionInfo : NSObject {
    
}

@property(nonatomic) double posX;
@property(nonatomic) double posY;
@property(nonatomic) int width;
@property(nonatomic) int height;
@property(nonatomic) int rotation;

- (instancetype) init;

- (instancetype) init:(TUPProperty*) prop;

@end

// 对齐方式
typedef NS_ENUM(NSInteger, TUPVEAnimationTextClip_AlignmentType) {
    TUPVEAnimationTextClipAlignmentType_LEFT,
    TUPVEAnimationTextClipAlignmentType_CENTER,
    TUPVEAnimationTextClipAlignmentType_RIGHT
};

// 排列方式
typedef NS_ENUM(NSInteger, TUPVEAnimationTextClip_OrderType) {
    TUPVEAnimationTextClipOrderType_LEFT2RIGHT, // 从左向右
    TUPVEAnimationTextClipOrderType_RIGHT2LEFT, // 从右向左
    
};

// 背景
@interface TUPVEAnimationTextClip_Background : NSObject
@property(nonatomic, strong) UIColor *color;        // 颜色
@property(nonatomic, assign) double opacity;        // 不透明度 [0-1.0]
@property(nonatomic, assign) TUPVEAnimationTextClip_BoundType boundType;
@end

// 下划线
@interface TUPVEAnimationTextClip_UnderLine : NSObject
@property(nonatomic, strong) UIColor *color;        // 颜色
@property(nonatomic, assign) int size;              // 尺寸 [0-100]
@end

// 描边
@interface TUPVEAnimationTextClip_Stroke : NSObject
@property(nonatomic, strong) UIColor *color;        // 颜色
@property(nonatomic, assign) int size;              // 尺寸 [0-100]
@end

// 阴影
@interface TUPVEAnimationTextClip_Shadow : NSObject
@property(nonatomic, strong) UIColor *color;        // 颜色
@property(nonatomic, assign) double opacity;        // 不透明度 [0-1.0]
@property(nonatomic, assign) double blur;           // 模糊强度 [0-1.0]
@property(nonatomic, assign) int distance;          // 模糊距离 [0-100]
@property(nonatomic, assign) int degree;            // 旋转角度 [0-360]
@end

// 动画器
@interface TUPVEAnimationTextClip_Animator : NSObject
@property(nonatomic, copy) NSString* path;   // 模型路径
@property(nonatomic, assign) double start;   // 开始时间 [0-1.0]
@property(nonatomic, assign) double end;     // 结束时间 [0-1.0]
@end

@interface TUPVEAnimationTextClip_PropertyHolder : NSObject

@property(nonatomic, assign) double posX;                                       // 位置x [0-1.0]
@property(nonatomic, assign) double posY;                                       // 位置y [0-1.0]
@property(nonatomic, assign) int rotation;                                      // 旋转角度
@property(nonatomic, assign) double fontScale;                                  // 缩放

@property(nonatomic, copy) NSString *text;                                      // 文本
@property(nonatomic, strong) UIColor *fillColor;                                // 文字颜色
@property(nonatomic, assign) double opacity;                                    // 文字不透明度 [0-1.0]
@property(nonatomic, assign) TUPVEAnimationTextClip_AlignmentType alignment;    // 对齐方式
@property(nonatomic, assign) TUPVEAnimationTextClip_OrderType order;            // 排列方式
@property(nonatomic, assign) double textScaleX;                                 // 字间距
@property(nonatomic, assign) double textScaleY;                                 // 行间距

@property(nonatomic, strong) NSMutableArray<NSString*>* fonts;            // 字体

@property(nonatomic, strong, nullable) TUPVEAnimationTextClip_Background* background;       // 背景
@property(nonatomic, strong, nullable) TUPVEAnimationTextClip_UnderLine* underline;         // 下划线
@property(nonatomic, assign) int underline2;                                                // 下划线2
@property(nonatomic, strong, nullable) TUPVEAnimationTextClip_Stroke* stroke;               // 描边
@property(nonatomic, strong, nullable) TUPVEAnimationTextClip_Shadow* shadow;               // 阴影

@property(nonatomic, copy) NSString* stylePath;                                             // 样式-模型路径
@property(nonatomic, copy) NSString* bubblePath;                                            // 气泡-模型路径
@property(nonatomic, strong) NSMutableArray<TUPVEAnimationTextClip_Animator*>* animators;   // 动画器

- (instancetype) init;
- (instancetype) initWithProperty:(TUPProperty*) prop;

@end


@interface TUPVEAnimationTextClip_PropertyBuilder : NSObject {
    
}


@property(nonatomic) TUPVEAnimationTextClip_PropertyHolder* holder;

- (instancetype) init;
- (instancetype) initWithHolder:(TUPVEAnimationTextClip_PropertyHolder*) holder;

- (TUPProperty*) makeProperty;

@end

//--------------------------------------------------------------------------------------------

@interface TUPVEAnimationTextClip : NSObject

@end

NS_ASSUME_NONNULL_END

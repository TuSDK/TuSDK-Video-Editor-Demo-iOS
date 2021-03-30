//
//  TuTextItemView.h
//  TuSDKVEDemo
//
//  Created by hecc on 2021/2/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuPanImageView.h"

@class TuTextItemView;

typedef NS_ENUM(NSInteger, TuTextItemView_TransformType) {
    TuTextItemView_TransformType_None       = 0,
    TuTextItemView_TransformType_Translate  = 1,
    TuTextItemView_TransformType_Scale      = 2,
    TuTextItemView_TransformType_Rotate     = 3
};

@interface TuTextItemInfo : NSObject

@property (nonatomic, assign) TuTextItemView_TransformType type;
@property (nonatomic, assign) CGPoint pos;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat rotation;

@end

@protocol TuTextItemViewDelegate <NSObject>

@optional

/**
 *  更新文字属性
 *
 *  @param info 数据
 */
- (void)updatePropBuilder:(NSInteger)vid info:(TuTextItemInfo*)info;

/**
 *  选中贴纸元件
 *
 *  @param view 贴纸元件视图
 */
- (void)onSelectedItemView:(TuTextItemView *)view;

/**
 *  贴纸元件关闭
 *
 *  @param view 贴纸元件视图
 */
- (void)onClosedItemView:(TuTextItemView *)view;

/**
 *  双击贴纸
 *
 *  @param view 贴纸元件视图
 */
- (void)onDoubleClick:(TuTextItemView*)itemView;

@end

@interface TuTextItemView : UIView

#pragma mark - UI

@property (nonatomic) UIImageView *borderView;                  // 边框view
@property (nonatomic) UIButton *closeBtn;                       // 关闭按钮
@property (nonatomic) TuPanImageView *dragBtn;                  // 拖拽按钮
@property (nonatomic, assign, getter=isSelected) BOOL select;   // view是否被选中
@property (nonatomic, assign) NSInteger vid;                    // 唯一标识
@property (nonatomic, assign) CGRect interactionRect;           // 控件view的物理大小
@property (nonatomic, assign) CGFloat interactionRatio;         // 画布view/控件view的比例
@property (nonatomic, assign) CGFloat startTs;                 // view显示时间轴起始点
@property (nonatomic, assign) CGFloat endTs;                   // view显示时间轴结束点

@property (nonatomic, assign) id <TuTextItemViewDelegate> delegate;


+(instancetype) initWithFrame:(CGRect)rect;

/**
 *  绘制view
 *
 *  @param rect 画布的rect
 *  @param rotation 画布的旋转角度
 */
-(void) redraw:(CGRect)rect rotation:(int)rotation;

@end

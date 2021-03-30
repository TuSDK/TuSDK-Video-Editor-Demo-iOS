//
//  TuGIFStickerView.h
//  PLVideoEditor
//
//  Created by suntongmian on 2018/5/24.
//  Copyright © 2018年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuPanImageView.h"

@class TuImageItemView;

typedef NS_ENUM(NSInteger, TuImageItemView_TransformType) {
    TuImageItemView_TransformType_None       = 0,
    TuImageItemView_TransformType_Translate  = 1,
    TuImageItemView_TransformType_Scale      = 2,
    TuImageItemView_TransformType_Rotate     = 3
};

@interface TuImageItemInfo : NSObject

@property (nonatomic, assign) TuImageItemView_TransformType type;
@property (nonatomic, assign) CGPoint pos;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat rotation;

@end

@protocol TuImageItemViewDelegate <NSObject>

@optional

/**
 *  更新文字属性
 *
 *  @param info 数据
 */
- (void)updatePropBuilder:(NSInteger)vid info:(TuImageItemInfo*)info;

/**
 *  选中贴纸元件
 *
 *  @param view 贴纸元件视图
 */
- (void)onSelectedItemView:(TuImageItemView *)view;

/**
 *  贴纸元件关闭
 *
 *  @param view 贴纸元件视图
 */
- (void)onClosedItemView:(TuImageItemView *)view;

@end

@interface TuImageItemView : UIView

#pragma mark - UI

@property (nonatomic) UIImageView *borderView;                  // 边框view
@property (nonatomic) UIButton *closeBtn;                       // 关闭按钮
@property (nonatomic) TuPanImageView *dragBtn;                  // 拖拽按钮
@property (nonatomic, assign, getter=isSelected) BOOL select;   // view是否被选中
@property (nonatomic, assign) NSInteger vid;                    // 唯一标识
@property (nonatomic, assign) CGRect interactionRect;           // 控件view的物理大小
@property (nonatomic, assign) CGFloat interactionRatio;         // 画布view/控件view的比例
@property (nonatomic, assign) NSInteger startTs;                // view显示时间轴起始时间
@property (nonatomic, assign) NSInteger endTs;                  // view显示时间轴结束时间
@property (nonatomic, assign) CGFloat scale;                    // 缩放比例

@property (nonatomic, assign) id <TuImageItemViewDelegate> delegate;


+(instancetype) initWithFrame:(CGRect)rect;

/**
 *  绘制view
 *
 *  @param rect 画布的rect
 *  @param rotation 画布的旋转角度
 */
-(void) redraw:(CGRect)rect rotation:(int)rotation;

@end

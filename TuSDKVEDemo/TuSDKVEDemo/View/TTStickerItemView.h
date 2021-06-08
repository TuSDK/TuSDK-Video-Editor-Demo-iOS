//
//  TTStickerItemView.h
//  Demo
//
//  Created by 言有理 on 2021/4/9.
//  Copyright © 2021 言有理. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TTStickerItemView;
@protocol TTStickerItemDelegate <NSObject>

/// 视图变换回调
/// @param itemView 贴纸视图
/// @param center 偏移量
/// @param scale 缩放比例
/// @param angle 旋转角度
- (void)itemView:(TTStickerItemView *)itemView center:(CGPoint)center scale:(CGFloat)scale angle:(CGFloat)angle;

/// 点击编辑
/// @param itemView 贴纸视图
- (void)didEditItemView:(TTStickerItemView *)itemView;

/// 选中复选框
/// @param itemView 贴纸
/// @param inputIndex 复选框下标
- (void)itemView:(TTStickerItemView *)itemView didSelectInputAtIndex:(NSInteger)inputIndex;
/// 贴纸移除
/// @param itemView 贴纸视图
- (void)didRemoveItemView:(TTStickerItemView *)itemView;
@end

@interface TTStickerItemView : UIView
@property (nonatomic, weak) id<TTStickerItemDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger index; // 索引
@property (nonatomic, assign) CGFloat minScale; // default is 0
@property (nonatomic, assign) CGFloat maxScale; // default is 0
/// 旋转角度 default is 0
@property (nonatomic, assign) CGFloat transformRotation;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign, readonly) BOOL isMulti;
@property (nonatomic, assign) BOOL gestureAutoTransform; // 手势自动形变
@property (nonatomic, assign) BOOL isRemoveUsable; // 删除按钮是否可用 
- (instancetype)initWithFrame:(CGRect)frame multi:(nullable NSArray<NSValue *> *)multis;

/// 设置索引
- (void)setupIndex:(NSInteger)index;
/// 更新复选框坐标
- (void)updateInputViews:(nullable NSArray<NSValue *> *)multis;
@end

@interface TTStickerInputView : UIImageView

@end
NS_ASSUME_NONNULL_END

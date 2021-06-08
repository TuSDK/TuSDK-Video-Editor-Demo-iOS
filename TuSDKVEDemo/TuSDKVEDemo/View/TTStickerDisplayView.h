//
//  TTStickerDisplayView.h
//  Demo
//
//  Created by 言有理 on 2021/4/9.
//  Copyright © 2021 言有理. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TTStickerDisplayView;
@protocol TTStickerDisplayDelegate <NSObject>
@optional
/// 视图变换回调
/// @param displayView 画布
/// @param index 贴纸索引
/// @param position 贴纸中心-[0,1]
/// @param scale 贴纸缩放比例
/// @param rotation 贴纸旋转角度
- (void)displayView:(TTStickerDisplayView *)displayView index:(NSInteger)index position:(CGPoint)position scale:(CGFloat)scale rotation:(CGFloat)rotation;

/// 贴纸选中
/// @param displayView 画布
/// @param index 索引
- (BOOL)displayView:(TTStickerDisplayView *)displayView didSelectItemAtIndex:(NSInteger)index;

/// 贴纸编辑
/// @param displayView 画布
/// @param index 索引
- (void)displayView:(TTStickerDisplayView *)displayView didEditItemAtIndex:(NSInteger)index;

/// 贴纸复选框编辑
/// @param displayView 画布
/// @param index 索引
/// @param inputIndex 复选框下标
- (void)displayView:(TTStickerDisplayView *)displayView didEditItemAtIndex:(NSInteger)index didSelectInputAtIndex:(NSInteger)inputIndex;
/// 贴纸取消选中
/// @param displayView 画布
- (void)displayViewCancelSelect:(TTStickerDisplayView *)displayView;
/// 贴纸移除
/// @param displayView 画布
/// @param index 索引
- (void)displayView:(TTStickerDisplayView *)displayView didRemovedItemAtIndex:(NSInteger)index;

@end
@interface TTStickerDisplayView : UIView
@property(nonatomic, weak) id<TTStickerDisplayDelegate> delegate;
@property (nonatomic, assign) BOOL gestureAutoTransform; // 手势自动形变
@property (nonatomic, assign) BOOL isRemoveUsable; // 删除按钮是否可用                                                                                                   
/// 添加默认贴纸
/// @param index 索引
/// @param size 尺寸
- (void)addItemView:(NSInteger)index size:(CGSize)size;

/// 添加贴纸
/// @param index 索引
/// @param frame 坐标
/// @param isSelected 选中
- (void)addItemView:(NSInteger)index frame:(CGRect)frame isSelected:(BOOL)isSelected;

/// 添加多个复选框贴纸
/// @param index 索引
/// @param frame 坐标
/// @param angle 角度
/// @param multis 复选框坐标
/// @param isSelected isSelected 选中
- (void)addItemView:(NSInteger)index frame:(CGRect)frame angle:(CGFloat)angle multi:(nullable NSArray<NSValue *> *)multis isSelected:(BOOL)isSelected;

/// 更新贴纸坐标
/// @param index 索引
/// @param frame 坐标
/// @param angle 角度
- (void)updateItemView:(NSInteger)index frame:(CGRect)frame angle:(CGFloat)angle;

/// 更新多个复选框贴纸坐标
/// @param index 索引
/// @param frame 坐标
/// @param angle 角度
/// @param multis 多个复选框
- (void)updateItemView:(NSInteger)index frame:(CGRect)frame angle:(CGFloat)angle multi:(nullable NSArray<NSValue *> *)multis;

/// 更新贴纸选中状态
/// @param index 索引
/// @param isSelected 选中
- (void)updateItemView:(NSInteger)index selected:(BOOL)isSelected;

- (void)removeItemView:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END

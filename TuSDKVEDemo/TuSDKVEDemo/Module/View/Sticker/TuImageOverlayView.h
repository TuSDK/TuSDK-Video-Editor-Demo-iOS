//
//  TuImageOverlayView.h
//  TuSDKVEDemo
//
//  Created by hecc on 2021/2/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuImageItemView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TuImageOverlayViewDelegate <NSObject>

/**
 *  设置当前选中item状态
 *
 *  @param vid 数据
 */
- (void)onSelectItem:(NSInteger)vid;


/**
 *  未选中状态
 */
- (void)onUnSelected;

/**
 *  更新文字属性
 *
 *  @param info 数据
 */
- (void)updatePropBuilder:(NSInteger)vid info:(TuImageItemInfo*)info;

/**
 *  获取当前播放进度
 */
-(NSInteger)presentTs;


@end

@interface TuImageOverlayView : UIView

@property(nonatomic, assign) CGRect interactionRect;        // 控件view的物理大小
@property(nonatomic, assign) CGFloat  interactionRatio;     // 画布view/控件view的比例

@property(nonatomic, assign) id <TuImageOverlayViewDelegate> delegate;
@property(nonatomic, copy)void(^editBlock)(void);
@property(nonatomic, copy)void(^closeBlock)(void);

-(instancetype)initWithFrame:(CGRect)frame;

-(void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs scale:(float)scale;

-(void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs scale:(float)scale rect:(CGRect)rect rotation:(int)rotation;

-(void) redraw:(NSInteger)vid rect:(CGRect)rect rotation:(int)rotation;

-(void) presentview:(NSInteger)vid show:(BOOL)show;

/**
 *  设置view显示时间轴
 *
 *  @param vid 唯一标识
 *  @param startTs 起始点
 *  @param endTs 结束点
 */
-(void) setTimeline:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs;


/**
 *  view交换顺序
 *
 *  @param srcvid 起始点
 *  @param destvid 结束点
 */
-(void) swapview:(NSInteger)srcvid dest:(NSInteger)destvid;

@end

NS_ASSUME_NONNULL_END

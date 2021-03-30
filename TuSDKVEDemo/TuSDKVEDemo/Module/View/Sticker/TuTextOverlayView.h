//
//  TuTextOverlayView.h
//  TuSDKVEDemo
//
//  Created by hecc on 2021/2/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TuTextItemView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TuTextOverlayViewDelegate <NSObject>

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
- (void)updatePropBuilder:(NSInteger)vid info:(TuTextItemInfo*)info;
/**
 *  获取当前播放进度
 *
 */
-(NSInteger)presentProgress;

@end

@interface TuTextOverlayView : UIView

@property(nonatomic, assign) CGRect interactionRect;        // 控件view的物理大小
@property(nonatomic, assign) CGFloat  interactionRatio;     // 画布view/控件view的比例

@property(nonatomic, assign) id <TuTextOverlayViewDelegate> delegate;
@property(nonatomic, copy)void(^editBlock)(void);
@property(nonatomic, copy)void(^closeBlock)(void);

-(instancetype)init;

-(void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs;
-(void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs rect:(CGRect)rect rotation:(int)rotation;
-(void) redraw:(NSInteger)vid rect:(CGRect)rect rotation:(int)rotation;

-(void) presentview:(NSInteger)vid show:(BOOL)show;

-(void) setTimeline:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs;

@end

NS_ASSUME_NONNULL_END

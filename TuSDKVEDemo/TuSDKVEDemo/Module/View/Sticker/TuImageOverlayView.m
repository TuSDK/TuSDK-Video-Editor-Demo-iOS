//
//  TuImageOverlayView.m
//  TuSDKVEDemo
//
//  Created by tusdk on 2021/2/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import "TuImageOverlayView.h"
#import <TuSDKPulseCore/TuSDKPulseCore.h>

@interface TuImageOverlayView()<TuImageItemViewDelegate>

@property (nonatomic, strong) NSMutableArray<TuImageItemView *> *imageItemViews;

@end

@implementation TuImageOverlayView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _imageItemViews = [[NSMutableArray alloc]init];
    return self;
}

-(void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs scale:(float)scale {
    
    CGRect rc = self.bounds;
    TuImageItemView *imageItemView = [TuImageItemView initWithFrame:CGRectMake(70, (rc.size.height - 50) / 2, rc.size.width - 70 * 2, 50)];
    imageItemView.delegate = self;
    imageItemView.interactionRect = self.interactionRect;
    imageItemView.interactionRatio = self.interactionRatio;
    imageItemView.vid = vid;
    imageItemView.startTs = startTs;
    imageItemView.endTs = endTs;
    imageItemView.scale = scale;

    [self addSubview:imageItemView];
    [_imageItemViews addObject:imageItemView];
    
    [self onSelectedItemView:imageItemView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TuImageItemInfo *info = [[TuImageItemInfo alloc]init];
        info.type = TuImageItemView_TransformType_None;
        [self updatePropBuilder:vid info:info];
    });
}

-(void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs scale:(float)scale rect:(CGRect)rect rotation:(int)rotation
{
    CGRect rc = self.bounds;
    TuImageItemView *imageItemView = [TuImageItemView initWithFrame:CGRectMake(70, (rc.size.height - 50) / 2, rc.size.width - 70 * 2, 50)];
    imageItemView.delegate = self;
    imageItemView.interactionRect = self.interactionRect;
    imageItemView.interactionRatio = self.interactionRatio;
    imageItemView.vid = vid;
    imageItemView.startTs = startTs;
    imageItemView.endTs = endTs;
    imageItemView.scale = scale;

    [self addSubview:imageItemView];
    [_imageItemViews addObject:imageItemView];
    [imageItemView redraw:rect rotation:rotation];
    imageItemView.select = NO;
    
}

-(void) redraw:(NSInteger)vid rect:(CGRect)rect rotation:(int)rotation {
    [_imageItemViews enumerateObjectsUsingBlock:^(TuImageItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (vid == obj.vid && obj.select) {
            [obj redraw:rect rotation:rotation];
        }
    }];
}

-(void) presentview:(NSInteger)vid show:(BOOL)show {
    [_imageItemViews enumerateObjectsUsingBlock:^(TuImageItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (vid == obj.vid) {
            obj.select = show;
        }
    }];
}

/**
 *  设置view显示时间轴
 *
 *  @param vid 唯一标识
 *  @param startTs 起始点
 *  @param endTs 结束点
 */
-(void) setTimeline:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs {
    [_imageItemViews enumerateObjectsUsingBlock:^(TuImageItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (vid == obj.vid) {
            obj.startTs = startTs;
            obj.endTs = endTs;
        }
    }];
}

/**
 *  view交换顺序
 *
 *  @param srcvid 起始点
 *  @param destvid 结束点
 */
-(void) swapview:(NSInteger)srcvid dest:(NSInteger)destvid {
    NSInteger srcidx = 0;
    NSInteger destidx = 0;
    for (int i = 0; i < _imageItemViews.count; i++) {
        if (srcvid == _imageItemViews[i].vid) {
            srcidx = i;
        }else if(destvid == _imageItemViews[i].vid){
            destidx = i;
        }
    }
    
    [_imageItemViews exchangeObjectAtIndex:srcidx withObjectAtIndex:destidx];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //[super touchesBegan:touches withEvent:event];
    
    //获取点击点的坐标
    CGPoint touchPoint = [[touches  anyObject] locationInView:self];
    // 触摸顶层的item view
    BOOL touchTopView = false;
    
    // 从上往下遍历item view，获取最上层的view
    for (int i = _imageItemViews.count - 1; i >= 0; i--) {
        TuImageItemView *view = _imageItemViews[i];

        // 当前预览进度是否在view显示时间轴内
        BOOL insideTs = FALSE;
        if ([self.delegate respondsToSelector:@selector(presentTs)]) {
            float ts = [self.delegate presentTs];
            insideTs = view.startTs <= ts && view.endTs >= ts;
        }
        
        //判断点是否在view rect范围内
        BOOL insideRect = [view pointInside:[view convertPoint:touchPoint fromView:self] withEvent:nil];

        if (insideRect && insideTs && !touchTopView) {

            view.select = YES;
            touchTopView = YES;
            if (view.select && [self.delegate respondsToSelector:@selector(onSelectItem:)]) {
                [self.delegate onSelectItem:view.vid];
            }
        }else {
            view.select = NO;
        }
    }
    
    // 如果没有触碰到任何item view，则手动设置unselect
    if(!touchTopView){
        [self cancelAllSelected];
        
        if ([self.delegate respondsToSelector:@selector(onUnSelected)]) {
            [self.delegate onUnSelected];
        }
    }
    
}

// 取消所有贴纸选中状态
- (void)cancelAllSelected;
{
    [_imageItemViews enumerateObjectsUsingBlock:^(TuImageItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.select = NO;
    }];
}

/**
 *  更新文字属性
 *
 *  @param info 数据
 */
- (void)updatePropBuilder:(NSInteger)vid info:(TuImageItemInfo*)info {
    if ([self.delegate respondsToSelector:@selector(updatePropBuilder:info:)]) {
        [self.delegate updatePropBuilder:vid info:info];
    }
}

/**
 *  选中贴纸元件
 *
 *  @param view 贴纸元件视图
 */
- (void)onSelectedItemView:(TuImageItemView *)view;
{
    if (!view) return;
    [_imageItemViews enumerateObjectsUsingBlock:^(TuImageItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

        // 当前预览进度是否在view显示时间轴内
        BOOL insideTs = FALSE;
        if ([self.delegate respondsToSelector:@selector(presentTs)]) {
            float ts = [self.delegate presentTs];
            insideTs = view.startTs <= ts && view.endTs >= ts;
        }
        
        obj.select = [obj isEqual:view] && insideTs;
        
        if (obj.select && [self.delegate respondsToSelector:@selector(onSelectItem:)]) {
            [self.delegate onSelectItem:view.vid];
        }
    }];
}

/**
 *  贴纸元件关闭
 *
 *  @param view 贴纸元件视图
 */
- (void)onClosedItemView:(TuImageItemView *)view;
{
    if (!view) return;
    
    [_imageItemViews removeObject:view];
    [view removeFromSuperview];
    
    if (self.closeBlock) {
        self.closeBlock();
    }
}


@end


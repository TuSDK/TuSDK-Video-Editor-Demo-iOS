//
//  TuTextOverlayView.m
//  TuSDKVEDemo
//
//  Created by tusdk on 2021/2/25.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import "TuTextOverlayView.h"
#import <TuSDKPulseCore/TuSDKPulseCore.h>

@interface TuTextOverlayView()<TuTextItemViewDelegate>

@property (nonatomic, strong) NSMutableArray<TuTextItemView *> *textItemViews;

@end

@implementation TuTextOverlayView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _textItemViews = [[NSMutableArray alloc]init];
    return self;
}
- (void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs {
    
    CGRect rc = self.bounds;
    TuTextItemView *textItemView = [TuTextItemView initWithFrame:CGRectMake(70, (rc.size.height - 50) / 2, rc.size.width - 70 * 2, 50)];
    textItemView.delegate = self;
    textItemView.interactionRect = self.interactionRect;
    textItemView.interactionRatio = self.interactionRatio;
    textItemView.vid = vid;
    textItemView.startTs = startTs;
    textItemView.endTs = endTs;
    
    [self addSubview:textItemView];
    [_textItemViews addObject:textItemView];
    [self onSelectedItemView:textItemView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           TuTextItemInfo *info = [[TuTextItemInfo alloc]init];
           info.type = TuTextItemView_TransformType_None;
        [self updatePropBuilder:vid info:info];
    });

    
}
-(void) createView:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs rect:(CGRect)rect rotation:(int)rotation {
    CGRect rc = self.bounds;
    TuTextItemView *textItemView = [TuTextItemView initWithFrame:CGRectMake(70, (rc.size.height - 50) / 2, rc.size.width - 70 * 2, 50)];
    textItemView.delegate = self;
    textItemView.interactionRect = self.interactionRect;
    textItemView.interactionRatio = self.interactionRatio;
    textItemView.vid = vid;
    textItemView.startTs = startTs;
    textItemView.endTs = endTs;
    
    [self addSubview:textItemView];
    [_textItemViews addObject:textItemView];
    [textItemView redraw:rect rotation:rotation];
    textItemView.select = NO;
   
}

-(void) redraw:(NSInteger)vid rect:(CGRect)rect rotation:(int)rotation {
    [_textItemViews enumerateObjectsUsingBlock:^(TuTextItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (vid == obj.vid && obj.select) {
            [obj redraw:rect rotation:rotation];
        }
    }];
}

-(void) presentview:(NSInteger)vid show:(BOOL)show {
    [_textItemViews enumerateObjectsUsingBlock:^(TuTextItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (vid == obj.vid) {
            obj.select = show;
        }
    }];
}

-(void) setTimeline:(NSInteger)vid startTs:(NSInteger)startTs endTs:(NSInteger)endTs {
    [_textItemViews enumerateObjectsUsingBlock:^(TuTextItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (vid == obj.vid) {
            obj.startTs = startTs;
            obj.endTs = endTs;
        }
    }];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //[super touchesBegan:touches withEvent:event];
    
    //获取点击点的坐标
    CGPoint touchPoint = [[touches  anyObject] locationInView:self];
    // 触摸顶层的item view
    BOOL touchTopView = false;
    
    // 从上往下遍历item view，获取最上层的view
    for (int i = _textItemViews.count - 1; i >= 0; i--) {
        TuTextItemView *view = _textItemViews[i];

        // 当前预览进度是否在view显示时间轴内
        BOOL insideProg = FALSE;
        if ([self.delegate respondsToSelector:@selector(presentProgress)]) {
            NSInteger prog = [self.delegate presentProgress];
            insideProg = view.startTs <= prog && view.endTs >= prog;
        }
        
        //判断点是否在view rect范围内
        BOOL insideRect = [view pointInside:[view convertPoint:touchPoint fromView:self] withEvent:nil];

        if (insideRect && insideProg && !touchTopView) {

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
    [_textItemViews enumerateObjectsUsingBlock:^(TuTextItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.select = NO;
    }];
}

/**
 *  更新文字属性
 *
 *  @param info 数据
 */
- (void)updatePropBuilder:(NSInteger)vid info:(TuTextItemInfo*)info  {
    if ([self.delegate respondsToSelector:@selector(updatePropBuilder:info:)]) {
        [self.delegate updatePropBuilder:vid info:info];
    }
}

/**
 *  选中贴纸元件
 *
 *  @param view 贴纸元件视图
 */
- (void)onSelectedItemView:(TuTextItemView *)view;
{
    if (!view) return;
    [_textItemViews enumerateObjectsUsingBlock:^(TuTextItemView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        // 当前预览进度是否在view显示时间轴内
        BOOL insideProg = FALSE;
        if ([self.delegate respondsToSelector:@selector(presentProgress)]) {
            float prog = [self.delegate presentProgress];
            insideProg = obj.startTs <= prog && obj.endTs >= prog;
        }
        
        obj.select = [obj isEqual:view] && insideProg;
        
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
- (void)onClosedItemView:(TuTextItemView *)view;
{
    if (!view) return;
    
    [_textItemViews removeObject:view];
    [view removeFromSuperview];
    
    if (self.closeBlock) {
        self.closeBlock();
    }
}

/**
 *  双击贴纸
 *
 *  @param itemView 文字view
 */
- (void)onDoubleClick:(TuTextItemView*)itemView;
{
    // 当前预览进度是否在view显示时间轴内
    BOOL insideProg = FALSE;
    if ([self.delegate respondsToSelector:@selector(presentProgress)]) {
        float prog = [self.delegate presentProgress];
        insideProg = itemView.startTs <= prog && itemView.endTs >= prog;
    }
    
    if (insideProg && self.editBlock) {
        self.editBlock();
    }
}

@end


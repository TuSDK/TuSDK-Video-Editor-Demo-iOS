//
//  TTStickerDisplayView.m
//  Demo
//
//  Created by 言有理 on 2021/4/9.
//  Copyright © 2021 言有理. All rights reserved.
//

#import "TTStickerDisplayView.h"
#import "TTStickerItemView.h"

@interface TTStickerDisplayView()<TTStickerItemDelegate>
@property (nonatomic, strong) NSMapTable <NSNumber *, TTStickerItemView *> *itemTable;
@property (nonatomic, strong) TTStickerItemView *currentItemView;
@end

@implementation TTStickerDisplayView

- (void)addItemView:(NSInteger)index size:(CGSize)size {
    CGRect itemFrame = CGRectMake((self.frame.size.width - size.width)/2, (self.frame.size.height - size.height)/2, size.width, size.height);
    [self addItemView:index frame:itemFrame isSelected:YES];
}

- (void)addItemView:(NSInteger)index frame:(CGRect)frame isSelected:(BOOL)isSelected {
    [self addItemView:index frame:frame angle:0 multi:nil isSelected:isSelected];
}

- (void)addItemView:(NSInteger)index frame:(CGRect)frame angle:(CGFloat)angle multi:(nullable NSArray<NSValue *> *)multis isSelected:(BOOL)isSelected {
    TTStickerItemView *itemView = [[TTStickerItemView alloc] initWithFrame:frame multi:multis];
    itemView.isRemoveUsable = self.isRemoveUsable;
    [itemView setupIndex:index];
    CGFloat rotation = angle * M_PI / 180;
    itemView.transformRotation = rotation;
    itemView.delegate = self;
    [self addSubview:itemView];
    [self.itemTable setObject:itemView forKey:@(index)];
    if (isSelected) {
        self.currentItemView = itemView;
    } else {
        itemView.isSelected = NO;
    }
    if (angle != 0) {
        itemView.transform = CGAffineTransformMakeRotation(rotation);
    }
    itemView.gestureAutoTransform = self.gestureAutoTransform;
}

- (void)updateItemView:(NSInteger)index frame:(CGRect)frame angle:(CGFloat)angle {
    [self updateItemView:index frame:frame angle:angle multi:nil];
}

- (void)updateItemView:(NSInteger)index frame:(CGRect)frame angle:(CGFloat)angle multi:(nullable NSArray<NSValue *> *)multis {
    TTStickerItemView *itemView = [self itemViewWithIndex:index];
    CGFloat rotation = angle * M_PI / 180;
    itemView.transform = CGAffineTransformMakeRotation(rotation);
    itemView.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    itemView.center = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    [itemView updateInputViews:multis];
}

- (void)updateItemView:(NSInteger)index selected:(BOOL)isSelected {
    TTStickerItemView *itemView = [self itemViewWithIndex:index];
    if (itemView) {
        itemView.isSelected = isSelected;
    }
}
- (void)removeItemView:(NSInteger)index {
    TTStickerItemView *itemView = [self itemViewWithIndex:index];
    [self deleteItemView:itemView];
}
// MARK: - TTStickerItemDelegate
- (void)itemView:(TTStickerItemView *)itemView center:(CGPoint)center scale:(CGFloat)scale angle:(CGFloat)angle {
    if (itemView.index != self.currentItemView.index) {
        return;
    }
    CGPoint position = CGPointMake(center.x/self.frame.size.height, center.y/self.frame.size.height);
    if ([self.delegate respondsToSelector:@selector(displayView:index:position:scale:rotation:)]) {
        [self.delegate displayView:self index:itemView.index position:position scale:scale rotation:angle];
    }
}
- (void)didEditItemView:(TTStickerItemView *)itemView {
    if ([self.delegate respondsToSelector:@selector(displayView:didEditItemAtIndex:)]) {
        [self.delegate displayView:self didEditItemAtIndex:itemView.index];
    }
}
- (void)itemView:(nonnull TTStickerItemView *)itemView didSelectInputAtIndex:(NSInteger)inputIndex {
    if ([self.delegate respondsToSelector:@selector(displayView:didEditItemAtIndex:didSelectInputAtIndex:)]) {
        [self.delegate displayView:self didEditItemAtIndex:itemView.index didSelectInputAtIndex:inputIndex];
    }
}
- (void)didRemoveItemView:(TTStickerItemView *)itemView {
    [self deleteItemView:itemView];

    if ([self.delegate respondsToSelector:@selector(displayView:didRemovedItemAtIndex:)]) {
        [self.delegate displayView:self didRemovedItemAtIndex:itemView.index];
    }
}
- (void)deleteItemView:(nullable TTStickerItemView *)itemView {
    if (itemView == nil) {
        return;
    }
    itemView.hidden = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (itemView.index == self.currentItemView.index) {
            self.currentItemView = nil;
        }
        itemView.delegate = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [itemView removeFromSuperview];
        });
    });
}
// MARK: - 贴纸切换
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 获取点击点的坐标
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    TTStickerItemView *selectedItemView = nil;
    for (UIView *subview in self.subviews) {
        if (![subview isKindOfClass:[TTStickerItemView classForCoder]]) {
            continue;
        }
        TTStickerItemView *itemView = (TTStickerItemView *)subview;
        // 判断点是否在view rect范围内
        BOOL isInside = [itemView pointInside:[itemView convertPoint:touchPoint fromView:self] withEvent:nil];
        if (isInside) {
            selectedItemView = itemView;
        }
    }
    if (selectedItemView) {
        if ([self.delegate respondsToSelector:@selector(displayView:didSelectItemAtIndex:)]) {
            BOOL isSelected = [self.delegate displayView:self didSelectItemAtIndex:selectedItemView.index];
            if (isSelected) {
                self.currentItemView = selectedItemView;
            } else {
                [self cancelSelect];
            }
        }
    } else { // 点击背景
        [self cancelSelect];
    }
}
// 取消选中
- (void)cancelSelect {
    self.currentItemView.isSelected = NO;
    self.currentItemView = nil;
    if ([self.delegate respondsToSelector:@selector(displayViewCancelSelect:)]) {
        [self.delegate displayViewCancelSelect:self];
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isRemoveUsable = YES;
        _gestureAutoTransform = NO;
    }
    return self;
}
// MARK: - setter
- (void)setCurrentItemView:(TTStickerItemView *)currentItemView {
    _currentItemView = currentItemView;
    if (currentItemView == nil) {
        return;
    }
    // 移至最上层
    [self bringSubviewToFront:currentItemView];
    
    // 重置选中状态
    for (NSNumber *key in self.itemTable) {
        TTStickerItemView *itemView = [self.itemTable objectForKey:key];
        if (itemView.index == currentItemView.index) {
            if (!itemView.isSelected) {
                itemView.isSelected = YES;
            }
        } else {
            if (itemView.isSelected) {
                itemView.isSelected = NO;
            }
        }
    }
}

- (NSMapTable <NSNumber *, TTStickerItemView *> *)itemTable {
    if (!_itemTable) {
        _itemTable = [NSMapTable weakToWeakObjectsMapTable];
    }
    return _itemTable;
}

// MARK: - getter
- (nullable TTStickerItemView *)itemViewWithIndex:(NSInteger)index {
    return [self.itemTable objectForKey:@(index)];
}

- (void)dealloc {
    NSLog(@"tutu dealloc: %@", self.class);
}

@end

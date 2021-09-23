//
//  TTMatteDisplayView.m
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import "TTMatteDisplayView.h"
#import "UIView+Hotspot.h"

static CGFloat kDiffSpace = 35;

@interface TTMatteDisplayView()<UIGestureRecognizerDelegate>
@property(nonatomic, assign) CGRect displayRect;
@property(nonatomic, strong) UIView *interactionView;
@property(nonatomic, strong) UIView *itemView;
@property(nonatomic, strong) UIView *diffView;
/// 偏移
@property(nonatomic, assign) CGPoint transformCenter;
@end
@implementation TTMatteDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 旋转手势
        UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGestureAction:)];
        rotationGesture.delegate = self;
        [self addGestureRecognizer:rotationGesture];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
        panGesture.maximumNumberOfTouches = 1;
        //[self addGestureRecognizer:panGesture];
    }
    return self;
}
- (void)setupInteractionView:(CGRect)rect {
    self.displayRect = rect;
    UIView *interactionView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.origin.y, self.frame.size.width, rect.size.height)];
    [self addSubview:interactionView];
    self.interactionView = interactionView;
    
    CGFloat itemWidth = rect.size.width * 2 + self.frame.size.width;
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(-rect.size.width, interactionView.frame.size.height/2, itemWidth,1)];
    itemView.backgroundColor = UIColor.yellowColor;
    [itemView setEnlargeEdgeWithTop:10 left:5 bottom:10 right:5];
    [interactionView addSubview:itemView];
    self.itemView = itemView;
    
    UIView *pointView = [[UIView alloc] initWithFrame:CGRectMake((itemView.frame.size.width - 6)/2, (0 - 6)/2, 6, 6)];
    pointView.backgroundColor = UIColor.yellowColor;
    pointView.layer.cornerRadius = 3;
    pointView.clipsToBounds = YES;
    [itemView addSubview:pointView];
    
    self.diffView = [[UIView alloc] initWithFrame:CGRectMake((interactionView.frame.size.width - 20)/2, CGRectGetMaxY(itemView.frame) + kDiffSpace, 20, 20)];
    self.diffView.backgroundColor = UIColor.greenColor;
    [interactionView addSubview:self.diffView];
    
    // 拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.delegate = self;
    [itemView addGestureRecognizer:panGesture];
    
    self.transformCenter = self.itemView.center;
}

// 两种或多种手势可以一起响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// MARK: - 旋转
- (void)rotationGestureAction:(UIRotationGestureRecognizer *)gesture {
    CGFloat rotation = gesture.rotation;
    self.transformRotation += rotation;
    self.itemView.transform = CGAffineTransformRotate(self.itemView.transform, rotation);
    self.diffView.transform = CGAffineTransformRotate(self.diffView.transform, rotation);
    if ([self.delegate respondsToSelector:@selector(displayView:rotation:)]) {
        [self.delegate displayView:self rotation:self.transformRotation];
    }
    gesture.rotation = 0;
}
// MARK: - 移动
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.view == self.itemView) {
        // 偏移量
        CGPoint translation = [gesture translationInView:self];
        // 移动后 中心点
        CGPoint center = CGPointMake(self.transformCenter.x + translation.x, self.transformCenter.y + translation.y);
        if (center.y >= self.displayRect.origin.y
            && center.y <= (self.displayRect.size.height + self.displayRect.origin.y)
            && center.x >= self.displayRect.origin.x
            && center.x <= (self.displayRect.origin.x + self.displayRect.size.width)) {
            self.itemView.transform = CGAffineTransformTranslate(self.itemView.transform, translation.x, translation.y);
            self.diffView.transform = CGAffineTransformTranslate(self.diffView.transform, 0, translation.y);
            self.transformCenter = center;
            CGPoint position = CGPointMake(center.x/self.frame.size.height, center.y/self.frame.size.height);
            if ([self.delegate respondsToSelector:@selector(displayView:position:)]) {
                [self.delegate displayView:self position:CGPointMake(position.x * 2 - 1, -(position.y * 2 - 1))];
            }
        }
        [gesture setTranslation:CGPointZero inView:self];
    } else {
        // 偏移量
        CGPoint translation = [gesture translationInView:gesture.view];
        CGPoint location = [gesture locationInView:gesture.view];
        
        CGFloat space = self.diffView.frame.origin.y - CGRectGetMaxY(self.itemView.frame) + translation.y;
        if (space >= kDiffSpace
            && space <= kDiffSpace*2
            && location.y > self.itemView.frame.origin.y) {
            self.diffView.transform = CGAffineTransformTranslate(self.diffView.transform, 0, translation.y);
            if ([self.delegate respondsToSelector:@selector(displayView:diff:)]) {
                [self.delegate displayView:self diff:(space - kDiffSpace)/kDiffSpace];
            }
            
        }
        [gesture setTranslation:CGPointZero inView:gesture.view];
        
    }
}

@end

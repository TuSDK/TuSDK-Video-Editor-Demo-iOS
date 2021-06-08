//
//  TTStickerItemView.m
//  Demo
//
//  Created by 言有理 on 2021/4/9.
//  Copyright © 2021 言有理. All rights reserved.
//
#import "TTStickerItemView.h"
static CGFloat const kButtonWidth = 36;
@interface TTStickerItemView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, strong) UIButton *rotationButton;
@property (nonatomic, strong) UILabel *debugLabel;
@property (nonatomic, strong) NSArray<TTStickerInputView *> *multiViews;
@property (nonatomic, assign) BOOL isMulti;
@property (nonatomic, assign) NSInteger index;
/// 偏移
@property (nonatomic, assign) CGPoint transformCenter;
/// 缩放比例 - 相对于开始
@property (nonatomic, assign) CGFloat transformScale;
@property (nonatomic, assign) CGPoint loc_in;
@property (nonatomic, assign) CGFloat rotation_in;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@end

@implementation TTStickerItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame multi:(nullable NSArray<NSValue *> *)multis {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        [self setupInputView:multis];
    }
    return self;
}
- (void)setup {
    _minScale = 0;
    _maxScale = 0;
    _transformScale = 1;
    _transformRotation = 0;
    _isSelected = NO;
    _gestureAutoTransform = NO;
    _isRemoveUsable = YES;
    _transformCenter = self.center;
    _multiViews = [NSMutableArray array];
    _isMulti = NO;
    [self setupGesture];
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    [self addSubview:self.removeButton];
    [self addSubview:self.rotationButton];
    [self setupAutoLayout];
}
// MARK: - 创建复选框
- (void)setupInputView:(nullable NSArray<NSValue *> *)multis {
    if (multis.count <= 0) {
        return;
    }
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < multis.count; i++) {
        CGRect rect = [multis[i] CGRectValue];
        CGRect inputFrame = CGRectMake(rect.origin.x * self.frame.size.width, rect.origin.y * self.frame.size.height, rect.size.width * self.frame.size.width, rect.size.height * self.frame.size.height);
        TTStickerInputView *inputView = [[TTStickerInputView alloc] initWithFrame:inputFrame];
        inputView.image = [[UIImage imageNamed:@"bubble_dotted"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        inputView.userInteractionEnabled = YES;
        inputView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inputViewTapAction:)];
        [inputView addGestureRecognizer:tap];
        [self addSubview:inputView];
        [temp addObject:inputView];
    }
    _multiViews = [temp copy];
    _isMulti = YES;
}
- (void)setupIndex:(NSInteger)index {
    self.index = index;
#ifdef DEBUG
    self.debugLabel.text = [NSString stringWithFormat:@"%ld",(long)index];
#endif
}
- (void)updateInputViews:(nullable NSArray<NSValue *> *)multis {
    if (multis.count <= 0 || multis.count != self.multiViews.count) {
        return;
    }
    for (int i = 0; i < multis.count; i++) {
        CGRect rect = [multis[i] CGRectValue];
        CGRect inputFrame = CGRectMake(rect.origin.x * self.bounds.size.width, rect.origin.y * self.bounds.size.height, rect.size.width * self.bounds.size.width, rect.size.height * self.bounds.size.height);
        self.multiViews[i].frame = inputFrame;
    }
}
- (void)setupGesture {
    // 编辑手势
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    //self.tapGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];
    // 拖动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    // 旋转手势
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotationGestureAction:)];
    rotationGesture.delegate = self;
    [self addGestureRecognizer:rotationGesture];
    // 缩放手势
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureAction:)];
    pinchGesture.delegate = self;
    [self addGestureRecognizer:pinchGesture];
}

// 两种或多种手势可以一起响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch view] == self.rotationButton) { // 缩放按钮不处理panGesture
        return NO;
    }
    return YES;
}

- (void)tapAction:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(didEditItemView:)]) {
        [self.delegate didEditItemView:self];
    }
}
- (void)inputViewTapAction:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(itemView:didSelectInputAtIndex:)]) {
        [self.delegate itemView:self didSelectInputAtIndex:gesture.view.tag];
        NSLog(@"sticker index: %ld inputIndex: %ld",(long)self.index, (long)gesture.view.tag);
    }
}
// MARK: - 移动
- (void)panGestureAction:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        // 偏移量
        CGPoint translation = [gesture translationInView:gesture.view.superview];
        // 移动后 中心点
        self.transformCenter = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        if (self.gestureAutoTransform) {
            self.center = self.transformCenter;
        }
        [gesture setTranslation:CGPointZero inView:self];
        [self fetch];
    }
}
// MARK: - 缩放
- (void)pinchGestureAction:(UIPinchGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = gesture.scale;
        if (![self scaleValid:scale]) {
            return;
        }
        if (self.gestureAutoTransform) {
            self.transform = CGAffineTransformScale(self.transform, scale, scale);
            self.removeButton.transform = CGAffineTransformInvert(self.transform);
            self.rotationButton.transform = CGAffineTransformInvert(self.transform);
        }
        self.transformScale *= scale;
        gesture.scale = 1;
        [self fetch];
    }
}
// MARK: - 旋转
- (void)rotationGestureAction:(UIRotationGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat rotation = gesture.rotation;
        if (self.gestureAutoTransform) {
            self.transform = CGAffineTransformRotate(self.transform, rotation);
        }
        self.transformRotation += rotation;
        gesture.rotation = 0;
        [self fetch];
    }
}
// MARK: - 旋转缩放按钮事件
- (void)rotationButtonPanGestureAction:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _loc_in = location;
        _rotation_in = [self getRadius:location withPointB:self.center];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        // 计算缩放
        CGFloat preDistance = [self getDistance:_loc_in withPointB:self.center];
        CGFloat curDistance = [self getDistance:location withPointB:self.center];
        CGFloat scale = curDistance / preDistance;
        CGAffineTransform transform = CGAffineTransformScale(self.transform, scale, scale);
        if ([self scaleValid:scale]) {
            _loc_in = location;
            self.transformScale *= scale;
        } else {
            transform = self.transform;
        }
        
        // 计算弧度
        CGFloat rotation = [self getRadius:location withPointB:self.center];
        CGFloat movedRotation = rotation - _rotation_in;
        // 经过PI到-PI的区域时，通过x轴来计算正确的转过的角度
        if (rotation < -M_PI_2 && _rotation_in > M_PI_2) {
            movedRotation = (M_PI - _rotation_in) + (rotation + M_PI);
        }else if(rotation > M_PI_2 && _rotation_in < -M_PI_2) {
            movedRotation = (-M_PI - _rotation_in) + (rotation - M_PI);
        }
        self.transformRotation += movedRotation;
        if (self.gestureAutoTransform) {
            self.transform = CGAffineTransformRotate(transform, movedRotation);
            self.removeButton.transform = CGAffineTransformInvert(self.transform);
            self.rotationButton.transform = CGAffineTransformInvert(self.transform);
        }
        _rotation_in = rotation;
        [self fetch];
    }
}

- (void)fetch {
    if ([self.delegate respondsToSelector:@selector(itemView:center:scale:angle:)]) {
        CGFloat angle = [self angleFromRadian:self.transformRotation];
        [self.delegate itemView:self center:self.transformCenter scale:self.transformScale angle:angle];
    }
}

- (void)removeAction {
    if (self.removeButton.isHidden) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didRemoveItemView:)]) {
        [self.delegate didRemoveItemView:self];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.layer.borderWidth = isSelected ? 1 : 0;
        if (self.isRemoveUsable) {
            self.removeButton.hidden = !isSelected;
        }
        self.rotationButton.hidden = !isSelected;
        self.userInteractionEnabled = isSelected;
        for (TTStickerInputView *inputView in self.multiViews) {
            inputView.hidden = !isSelected;
        }
    });
    NSLog(@"sticker index: %ld selected: %@", (long)self.index, isSelected ? @"YES" : @"NO");
}
- (void)setIsRemoveUsable:(BOOL)isRemoveUsable {
    _isRemoveUsable = isRemoveUsable;
    if (!isRemoveUsable) {
        _removeButton.hidden = YES;
    }
}
/// 缩放限制
- (BOOL)scaleValid:(CGFloat)scale {
    CGFloat curScale = self.transformScale * scale;
    if (self.maxScale > 0 && curScale > self.maxScale) {//放大
        return NO;
    }
    if (self.minScale > 0 && curScale < self.minScale) { // 缩小
        return NO;
    }
    return YES;
}
/// 距离
- (CGFloat)getDistance:(CGPoint)pointA withPointB:(CGPoint)pointB {
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    return sqrt(x*x + y*y);
}
/// 弧度
- (CGFloat)getRadius:(CGPoint)pointA withPointB:(CGPoint)pointB {
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    return atan2(y, x);
}

/// 弧度转换为角度
- (CGFloat)angleFromRadian:(CGFloat)radian {
    return radian * 180 / M_PI;
}

// 按钮超出范围响应事件
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in @[self.removeButton,self.rotationButton]) {
            CGPoint p = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, p)) {
                view = subView;
            }
        }
    }
    return view;
}

- (void)setupAutoLayout {
    // 使用Auto Layout约束，禁止将Autoresizing Mask转换为约束
    [self.rotationButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *contraint1 = [NSLayoutConstraint constraintWithItem:self.rotationButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kButtonWidth];
    NSLayoutConstraint *contraint2 = [NSLayoutConstraint constraintWithItem:self.rotationButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:kButtonWidth];
    NSLayoutConstraint *contraint3 = [NSLayoutConstraint constraintWithItem:self.rotationButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kButtonWidth/2];
    NSLayoutConstraint *contraint4 = [NSLayoutConstraint constraintWithItem:self.rotationButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:kButtonWidth/2];
    //把约束添加到父视图上
    [self addConstraints:@[contraint1, contraint2, contraint3, contraint4]];
}
- (UIButton *)removeButton {
    if (!_removeButton) {
        _removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _removeButton.frame = CGRectMake(-kButtonWidth/2, -kButtonWidth/2, kButtonWidth, kButtonWidth);
        [_removeButton setImage:[UIImage imageNamed:@"qn_sticker_delete"] forState:UIControlStateNormal];
        [_removeButton addTarget:self action:@selector(removeAction) forControlEvents:UIControlEventTouchUpInside];
        _removeButton.adjustsImageWhenHighlighted = NO;
        _removeButton.hidden = YES;
    }
    return _removeButton;
}
- (UIButton *)rotationButton {
    if (!_rotationButton) {
        _rotationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rotationButton.frame = CGRectMake(self.frame.size.width - kButtonWidth/2, self.frame.size.height - kButtonWidth/2, kButtonWidth, kButtonWidth);
        [_rotationButton setImage:[UIImage imageNamed:@"qn_sticker_rotate"] forState:UIControlStateNormal];
        _rotationButton.adjustsImageWhenHighlighted = NO;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rotationButtonPanGestureAction:)];
        panGesture.maximumNumberOfTouches = 1;
        [_rotationButton addGestureRecognizer:panGesture];
        _rotationButton.hidden = YES;
    }
    return _rotationButton;
}
- (UILabel *)debugLabel {
    if (!_debugLabel) {
        _debugLabel = [[UILabel alloc] init];
        _debugLabel.frame = CGRectMake(0, 0, 30, 20);
        _debugLabel.textColor = UIColor.redColor;
        _debugLabel.font = [UIFont systemFontOfSize:8];
        _debugLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_debugLabel];
    }
    return _debugLabel;
}

- (void)dealloc {
    NSLog(@"tutu dealloc: %@", self.class);
}
@end

@implementation TTStickerInputView

@end

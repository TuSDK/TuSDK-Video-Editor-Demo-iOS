//
//  TuImageItemView.m
//  PLVideoEditor
//
//  Created by suntongmian on 2018/5/24.
//  Copyright © 2018年 Pili Engineering, Qiniu Inc. All rights reserved.
//

#import "TuImageItemView.h"
#import <TuSDKPulseCore/TuSDKPulseCore.h>

@implementation TuImageItemInfo

-(instancetype) init
{
    self = [super init];

    return self;
}

@end

@interface TuImageItemView ()
{

    // 内容视图边缘距离
    CGSize _mCMargin;
    // 内容对角线长度
    CGFloat _mCHypotenuse;
    // 旋转度数
    CGFloat _mDegree;
    // 是否为旋转缩放动作
    BOOL _isRotatScaleAction;
    // 拖动手势
    UIPanGestureRecognizer *_panGesture;
    // 旋转手势
    UIRotationGestureRecognizer *_rotationGesture;
    // 缩放手势
    UIPinchGestureRecognizer *_pinchGesture;
    // 最后的触摸点
    CGPoint _lastPotion;
}

@end

@implementation TuImageItemView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

+(instancetype) initWithFrame:(CGRect)rect
{
    TuImageItemView *view = [[TuImageItemView alloc]init];
    [view setupUI:rect];
    return view;
}

- (void)setupUI:(CGRect)rect{
    
    _scale = 1.f;
    self.frame = rect;
    _mCHypotenuse = 0;
    _select = YES;
    
    // 边框view
    _borderView = [UIImageView initWithFrame:self.bounds];
    _borderView.contentMode = UIViewContentModeScaleAspectFit;
    // IOS7 边缘抗锯齿
    _borderView.layer.allowsEdgeAntialiasing = YES;
    [self addSubview:_borderView];
    
    // 关闭按钮
    _closeBtn = [[UIButton alloc] init];
    [_closeBtn setImage:[UIImage imageNamed:@"qn_sticker_delete"] forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(handleCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeBtn];
    
    // 拖拽btn
    _dragBtn = [[TuPanImageView alloc] initWithImage:[UIImage imageNamed:@"qn_sticker_rotate"]];
    _dragBtn.userInteractionEnabled = YES;
    [self addSubview:_dragBtn];
    
    // 图片视图边缘距离
    UIEdgeInsets _mImageEdge;
    _mImageEdge.left = ceilf(_closeBtn.lsqGetSizeWidth * 1.0f);
    _mImageEdge.right = ceilf(_dragBtn.lsqGetSizeWidth * 1.0f);
    _mImageEdge.top = ceilf(_closeBtn.lsqGetSizeHeight * 1.0f);
    _mImageEdge.bottom = ceilf(_dragBtn.lsqGetSizeHeight * 1.0f);
    
    // 边框
    _borderView.layer.borderWidth = 2.0;
    _borderView.layer.borderColor = [[UIColor colorWithWhite:1 alpha:.8] CGColor];
    
    // 内容视图边缘距离
    _mCMargin.width = _mImageEdge.left + _mImageEdge.right;
    _mCMargin.height = _mImageEdge.top + _mImageEdge.bottom;
    
    // 添加手势
    [self appendGestureRecognizer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _closeBtn.frame = CGRectMake(-10, -10, 50, 50);
    _dragBtn.frame = CGRectMake(self.bounds.size.width - 35, self.bounds.size.height - 35, 40, 40);
}

// 添加手势
- (void)appendGestureRecognizer;
{
    // 拖动手势
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    _panGesture.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:_panGesture];
    // 旋转手势
    _rotationGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(handleRotationGesture:)];
    _rotationGesture.delegate = self;
    [self addGestureRecognizer:_rotationGesture];

    // 缩放手势
    _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    _pinchGesture.delegate = self;
    [self addGestureRecognizer:_pinchGesture];
}

#pragma mark - PanGesture

// 拖动手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
{
    if (!_select) return;

    CGPoint point = [recognizer locationInView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if (!_dragBtn.hidden) {
            CGPoint selfPoint = [recognizer locationInView:self];
            // 是否为旋转缩放动作
            _isRotatScaleAction = CGRectContainsPoint(_dragBtn.frame, selfPoint);
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (_isRotatScaleAction) {
            [self handlePanGestureRotatScaleAction:point];
        }
        else{
            [self handlePanGestureTransAction:point];
        }
    }
    
    _lastPotion = point;
}

// 旋转手势
- (void)handleRotationGesture:(UIRotationGestureRecognizer *)recognizer;
{
    if (!_select) return;

    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        // 旋转度数
        _mDegree = [TuTSMath numberFloat:_mDegree + 360 + [TuTSMath degreesFromRadian:recognizer.rotation] modulus:360];
        
        // update builder
        TuImageItemInfo *info = [[TuImageItemInfo alloc]init];
        info.type = TuImageItemView_TransformType_Rotate;
        info.rotation = _mDegree;
        if ([self.delegate respondsToSelector:@selector(updatePropBuilder:info:)]) {
            [self.delegate updatePropBuilder:_vid info:info];
        }
    }
    
    recognizer.rotation = 0;
}

// 缩放手势
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer;
{
    if (!_select) return;

    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self computerScaleWithScale:recognizer.scale - 1 center:self.center];
    }
    
    recognizer.scale = 1;
}

#pragma mart - handleTransAction
// 处理移动位置
- (void)handlePanGestureTransAction:(CGPoint)nowPoint;
{
    CGPoint center = self.center;
    center.x += nowPoint.x - _lastPotion.x;
    center.y += nowPoint.y - _lastPotion.y;
    
    // 修复移动范围
    center = [self fixedCenterPoint:center];

    // update builder
    TuImageItemInfo *info = [[TuImageItemInfo alloc]init];
    info.type = TuImageItemView_TransformType_Translate;
    info.pos = CGPointMake((center.x - _interactionRect.origin.x) / _interactionRect.size.width,
                           (center.y - _interactionRect.origin.y) / _interactionRect.size.height);
    if ([self.delegate respondsToSelector:@selector(updatePropBuilder:info:)]) {
        [self.delegate updatePropBuilder:_vid info:info];
    }

}

#pragma mart - handleRotatScaleAction
// 处理旋转和缩放
- (void)handlePanGestureRotatScaleAction:(CGPoint)nowPoint;
{
    // 中心点
    CGPoint cPoint = self.center;
    
    // 计算旋转角度
    [self computerAngleWithPoint:nowPoint lastPoint:_lastPotion center:cPoint];
    
    // 计算缩放
    [self computerScaleWithPoint:nowPoint lastPoint:_lastPotion center:cPoint];
}

/**
 * 计算旋转角度
 *
 * @param point
 *            当前坐标点
 * @param lastPoint
 *            最后坐标点
 * @param cPoint
 *            中心点坐标
 */
- (void)computerAngleWithPoint:(CGPoint)point
                     lastPoint:(CGPoint)lastPoint
                        center:(CGPoint)cPoint;
{
    // 开始角度
    CGFloat sAngle = [TuTSMath degreesWithPoint:lastPoint center:cPoint];
    // 结束角度
    CGFloat eAngle = [TuTSMath degreesWithPoint:point center:cPoint];

    // 旋转度数
    _mDegree = [TuTSMath numberFloat:_mDegree + 360 + (eAngle - sAngle) modulus:360];
    
    // update builder
    TuImageItemInfo *info = [[TuImageItemInfo alloc]init];
    info.type = TuImageItemView_TransformType_Rotate;
    info.rotation = _mDegree;
    if ([self.delegate respondsToSelector:@selector(updatePropBuilder:info:)]) {
        [self.delegate updatePropBuilder:_vid info:info];
    }
}

/**
 * 计算缩放
 *
 * @param point
 *            当前坐标点
 * @param lastPoint
 *            最后坐标点
 * @param cPoint
 *            中心点坐标
 */

- (void)computerScaleWithPoint:(CGPoint)point
                     lastPoint:(CGPoint)lastPoint
                        center:(CGPoint)cPoint;
{
    // 开始距离中心点距离
    CGFloat sDistance = [TuTSMath distanceOfEndPoint:cPoint startPoint:lastPoint];
    
    // 当前距离中心点距离
    CGFloat cDistance = [TuTSMath distanceOfEndPoint:cPoint startPoint:point];
    // 缩放距离
    CGFloat distance = cDistance - sDistance;
    if (distance == 0) return;
    
    // 计算缩放偏移
    [self computerScaleWithScale:distance / _mCHypotenuse center:cPoint];
    
}


/**
 *  计算缩放
 *
 *  @param scale  缩放倍数
 *  @param cPoint 中心点坐标
 */
- (void)computerScaleWithScale:(CGFloat)scale center:(CGPoint)cPoint;
{
    // 计算缩放偏移
    CGFloat offsetScale = scale * 2;
    // 缩放比例
    _scale += offsetScale;
    
    // update builder
    TuImageItemInfo *info = [[TuImageItemInfo alloc]init];
    info.type = TuImageItemView_TransformType_Scale;
    info.scale = _scale;
    if ([self.delegate respondsToSelector:@selector(updatePropBuilder:info:)]) {
        [self.delegate updatePropBuilder:_vid info:info];
    }
}

#pragma mark - rect
/**
 *  修复移动范围
 *
 *  @param center 当前中心点
 *
 *  @return 移动的中心坐标
 */
- (CGPoint)fixedCenterPoint:(CGPoint)center;
{
    if (!self.superview) return center;
    
    if (center.x < 0) {
        center.x = 0;
    }else if (center.x > self.superview.lsqGetSizeWidth){
        center.x = self.superview.lsqGetSizeWidth;
    }
    
    if (center.y < 0) {
        center.y = 0;
    }else if (center.y > self.superview.lsqGetSizeHeight){
        center.y = self.superview.lsqGetSizeHeight;
    }
    return center;
}

/**
 *  关闭事件
 *
 *  @param sender
 *
 */
- (void)handleCancelButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(onClosedItemView:)]) {
        [self.delegate onClosedItemView:self];
    }
}

/**
 *  view是否被选中
 *
 *  @param select
 */
- (void)setSelect:(BOOL)select{
    //if (select == _select) return;
        
    _select = select;
    if (select) {
        //self.layer.borderWidth = 1.0;
        //self.layer.borderColor = [[UIColor colorWithRed:1.0 green:0 blue:0 alpha:.8] CGColor];
        self.hidden = NO;

    }else{
        //self.layer.borderWidth = 0;
        self.hidden = YES;
    }
}

/**
 *  绘制view
 *
 *  @param rect 画布的rect
 *  @param rotation 画布的旋转角度
 */
-(void) redraw:(CGRect)rect rotation:(int)rotation {
            
    CGFloat width = rect.size.width / _interactionRatio;
    CGFloat height = rect.size.height / _interactionRatio;
    
    if (_mCHypotenuse == 0) {
        _mCHypotenuse = [TuTSMath distanceOfPointX1:0 y1:0 pointX2:width y2:height];
    }
    
    [self rotationWithDegrees:rotation];
    
    self.bounds = CGRectMake(0, 0, width + _mCMargin.width, height + _mCMargin.height);
    
    self.center = CGPointMake(_interactionRect.origin.x + _interactionRect.size.width * rect.origin.x,
                                 _interactionRect.origin.y + _interactionRect.size.height * rect.origin.y);
    
    _borderView.bounds = CGRectMake(0, 0, width, height);

    _borderView.center = CGPointMake((width + _mCMargin.width)/2, (height + _mCMargin.height)/2);
    
    return;
}

@end


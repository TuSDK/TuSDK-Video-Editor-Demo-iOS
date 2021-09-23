//
//  UIView+Hotspot.m
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/12.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import "UIView+Hotspot.h"
#import <objc/runtime.h>

@implementation UIView (Hotspot)
static char *leftKey = "left";
static char *rightKey = "right";
static char *topKey = "top";
static char *bottomKey = "bottom";

+ (void)load {
    SEL orignalSelector = @selector(hitTest:withEvent:);
    SEL swizzingSelector = @selector(my_hitTest:withEvent:);
    [self swizzleSelector:orignalSelector withNewSelector:swizzingSelector];
}
+ (void)swizzleSelector:(SEL)origSelector withNewSelector:(SEL)replaceSelector {
    
    Class class = [self class];
    Method origMethod = class_getInstanceMethod(class,
                                                origSelector);
    Method newMethod = class_getInstanceMethod(class,
                                               replaceSelector);
    
    method_exchangeImplementations(origMethod, newMethod);
}
- (UIView *)my_hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect rect = [self enlargedClickRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [self my_hitTest:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) && !self.hidden ? self : nil;
}

- (CGRect)enlargedClickRect {
    return CGRectMake(self.bounds.origin.x - self.leftClickOffset,
                      self.bounds.origin.y - self.topClickOffset,
                      self.bounds.size.width + self.leftClickOffset + self.rightClickOffset,
                      self.bounds.size.height + self.topClickOffset + self.bottomClickOffset);
}

- (CGFloat)leftClickOffset {
    return [objc_getAssociatedObject(self, &leftKey) doubleValue];
}
- (void)setLeftClickOffset:(CGFloat)leftClickOffset {
    objc_setAssociatedObject(self, &leftKey, [NSString stringWithFormat:@"%f",leftClickOffset], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)rightClickOffset {
    return [objc_getAssociatedObject(self, &rightKey) doubleValue];
}
- (void)setRightClickOffset:(CGFloat)rightClickOffset {
    objc_setAssociatedObject(self, &rightKey, [NSString stringWithFormat:@"%f",rightClickOffset], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)topClickOffset {
    return [objc_getAssociatedObject(self, &topKey) doubleValue];
}
- (void)setTopClickOffset:(CGFloat)topClickOffset {
    objc_setAssociatedObject(self, &topKey, [NSString stringWithFormat:@"%f",topClickOffset], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat)bottomClickOffset {
    return [objc_getAssociatedObject(self, &bottomKey) doubleValue];
}
- (void)setBottomClickOffset:(CGFloat)bottomClickOffset {
    objc_setAssociatedObject(self, &bottomKey, [NSString stringWithFormat:@"%f",bottomClickOffset], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right{
    [self setUserInteractionEnabled:YES];
    [self setLeftClickOffset:left];
    [self setRightClickOffset:right];
    [self setTopClickOffset:top];
    [self setBottomClickOffset:bottom];
}
@end

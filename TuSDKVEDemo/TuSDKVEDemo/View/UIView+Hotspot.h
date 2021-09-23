//
//  UIView+Hotspot.h
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/12.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Hotspot)
//扩大view的点击范围
- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
@end

NS_ASSUME_NONNULL_END

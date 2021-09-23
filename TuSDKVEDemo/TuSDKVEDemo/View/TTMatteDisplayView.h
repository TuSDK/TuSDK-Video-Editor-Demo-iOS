//
//  TTMatteDisplayView.h
//  TuSDKVEDemo
//
//  Created by 言有理 on 2021/8/11.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TTMatteDisplayView;
@protocol TTMatteDisplayDelegate <NSObject>
@optional
- (void)displayView:(TTMatteDisplayView *)displayView position:(CGPoint)position;
- (void)displayView:(TTMatteDisplayView *)displayView rotation:(CGFloat)rotation;
- (void)displayView:(TTMatteDisplayView *)displayView diff:(CGFloat)diff;
@end
@interface TTMatteDisplayView : UIView
@property(nonatomic, weak) id<TTMatteDisplayDelegate> delegate;
/// 旋转角度 default is 0
@property (nonatomic, assign) CGFloat transformRotation;

- (void)setupInteractionView:(CGRect)rect;
@end

NS_ASSUME_NONNULL_END

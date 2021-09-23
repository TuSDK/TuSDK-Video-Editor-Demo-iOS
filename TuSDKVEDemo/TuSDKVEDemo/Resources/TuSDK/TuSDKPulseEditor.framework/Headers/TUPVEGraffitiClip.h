//
//  TUPVEGraffitiClip.h
//  TuSDKPulseEditor
//
//  Created by 言有理 on 2021/5/8.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUPVEditorClip.h"
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const TUPVEGraffitiClip_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEGraffitiClip_CONFIG_DURATION;

FOUNDATION_EXPORT NSString *const TUPVEGraffitiClip_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEGraffitiClip_PROP_APPEND_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEGraffitiClip_PROP_EXTEND_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEGraffitiClip_PROP_DELETE_PARAM;

@interface TUPVEGraffitiClip : TUPVEditorClip

@end

@interface TUPVEGraffitiClip_PathInfo : NSObject
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) double width;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSMutableArray <NSValue *> *points;
@end

@interface TUPVEGraffitiClip_PropertyHolder : NSObject
@property (nonatomic, strong) NSMutableArray <TUPVEGraffitiClip_PathInfo *> *paths;
- (instancetype)initWithProperty:(TUPProperty *)prop;
@end

@interface TUPVEGraffitiClip_PropertyBuilder : NSObject
@property (nonatomic, strong) TUPVEGraffitiClip_PropertyHolder* holder;

- (instancetype)initWithHolder:(TUPVEGraffitiClip_PropertyHolder*)holder;
- (TUPProperty *)makeProperty;
- (TUPProperty *)makeAppendProperty:(double)posX posY:(double)posY color:(UIColor *)color width:(double)width index:(int)index;
- (TUPProperty *)makeExtendProperty:(double)posX posY:(double)posY index:(int)index;
- (TUPProperty *)makeDeleteProperty:(int)index;
@end

NS_ASSUME_NONNULL_END

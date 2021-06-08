//
//  TUPVEBubbleTextClip.h
//  TuSDKPulseEditor
//
//  Created by 言有理 on 2021/4/22.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <TuSDKPulse/TUPProperty.h>
#import "TUPVEditorClip.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const TUPVEBubbleTextClip_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVEBubbleTextClip_CONFIG_DURATION;
FOUNDATION_EXPORT NSString *const TUPVEBubbleTextClip_CONFIG_MODEL;
FOUNDATION_EXPORT NSString *const TUPVEBubbleTextClip_CONFIG_FONT_DIR;
FOUNDATION_EXPORT NSString *const TUPVEBubbleTextClip_PROP_PARAM;
FOUNDATION_EXPORT NSString *const TUPVEBubbleTextClip_PROP_INTERACTION_INFO;

@interface TUPVEBubbleTextClip: TUPVEditorClip

@end

@interface TUPVEBubbleTextClip_InteractionInfo_Item : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) CGRect rect;
@end

@interface TUPVEBubbleTextClip_InteractionInfo: NSObject
@property (nonatomic, assign) double posX;
@property (nonatomic, assign) double posY;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int rotation;
@property (nonatomic, assign) double scale;
@property (nonatomic, strong) NSMutableArray<TUPVEBubbleTextClip_InteractionInfo_Item *>* items;
- (instancetype)init;
- (instancetype)initWithProperty:(TUPProperty *)prop;

@end

@interface TUPVEBubbleTextClip_PropertyHolder: NSObject

@property (nonatomic, assign) double posX;
@property (nonatomic, assign) double posY;
@property (nonatomic, assign) double scale;
@property (nonatomic, assign) int rotation;
@property (nonatomic, strong) NSArray <NSString *>*texts;
- (instancetype)init;
- (instancetype)initWithProperty:(TUPProperty *)prop;

@end

@interface TUPVEBubbleTextClip_PropertyBuilder: NSObject
@property (nonatomic, strong) TUPVEBubbleTextClip_PropertyHolder* holder;
- (instancetype)initWithHolder:(TUPVEBubbleTextClip_PropertyHolder*)holder;

- (instancetype)init;
- (TUPProperty *)makeProperty;

@end
NS_ASSUME_NONNULL_END

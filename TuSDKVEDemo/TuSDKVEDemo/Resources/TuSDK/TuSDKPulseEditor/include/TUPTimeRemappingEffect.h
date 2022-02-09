//
//  TUPVideoTimeRemappingEffect.h
//  TuSDKPulseEditor
//
//  Created by 言有理 on 2021/11/4.
//  Copyright © 2021 tusdk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TUPVEditorCtx;
@class TUPVEditorEffect;
@class TUPProperty;
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *const TUPVideoRemappingEffect_VIDEO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPVideoRemappingEffect_AUDIO_TYPE_NAME;
FOUNDATION_EXPORT NSString *const TUPTimeRemappingEffect_CONFIG_DURATION;
FOUNDATION_EXPORT NSString *const TUPTimeRemappingEffect_PROP_PARAM;

typedef NS_ENUM(NSUInteger, TUPTimeRemappingFunctionType) {
    TUPTimeRemappingFunctionTypeLinear,
    TUPTimeRemappingFunctionTypeQuadEaseIn,
    TUPTimeRemappingFunctionTypeQuadEaseOut,
    TUPTimeRemappingFunctionTypeQuadEaseInOut,
    
    TUPTimeRemappingFunctionTypeCubicEaseIn,
    TUPTimeRemappingFunctionTypeCubicEaseOut,
    TUPTimeRemappingFunctionTypeCubicEaseInOut,

    TUPTimeRemappingFunctionTypeSineEaseIn,
    TUPTimeRemappingFunctionTypeSineEaseOut,
    TUPTimeRemappingFunctionTypeSineEaseInOut,

    TUPTimeRemappingFunctionTypeQuinticEaseIn,
    TUPTimeRemappingFunctionTypeQuinticEaseOut,
    TUPTimeRemappingFunctionTypeQuinticEaseInOut

};

@interface TUPTimeRemappingNode : NSObject
@property(nonatomic) double realPos;
@property(nonatomic) double targetPos;
// FunctionType default linear.
@property(nonatomic) TUPTimeRemappingFunctionType type;
@end

@interface TUPTimeRemappingEffect_PropertyHolder : NSObject
@property(nonatomic, strong) NSMutableArray <TUPTimeRemappingNode *> *nodes;
- (instancetype)init;
- (instancetype)initWithProperty:(TUPProperty *)prop;
@end
@interface TUPTimeRemappingEffect_PropertyBuilder : NSObject

@property(nonatomic) TUPTimeRemappingEffect_PropertyHolder* holder;

- (instancetype)init;
- (instancetype)initWithHolder:(TUPTimeRemappingEffect_PropertyHolder *) holder;
- (TUPProperty*)makeProperty;

@end

@interface TUPTimeRemappingEffect : NSObject
+ (TUPVEditorEffect *)effectWithAudio:(TUPVEditorCtx *)ctx;
+ (TUPVEditorEffect *)effectWithVideo:(TUPVEditorCtx *)ctx;
@end

NS_ASSUME_NONNULL_END

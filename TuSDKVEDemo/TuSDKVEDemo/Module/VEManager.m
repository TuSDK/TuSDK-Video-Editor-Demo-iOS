//
//  VEManager.m
//  TuSDKVEDemo
//
//  Created by 言有理 on 2020/12/1.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "VEManager.h"
// MV 配对音频名
#define kMVEffectAudioDictionary @{@(1420):@"sound_cat",\
@(1427):@"sound_crow",\
@(1432):@"sound_tangyuan",\
@(1446):@"sound_children",\
@(1470):@"sound_oldmovie",\
@(1469):@"sound_relieve",\
}

#pragma mark - 场景特效（Array）

// 场景特效code
#define kSceneEffectCodeArray @[@"LiveShake01",@"LiveMegrim01",@"EdgeMagic01",@"LiveFancy01_1",@"LiveSoulOut01",@"LiveSignal01",@"LiveLightning01",@"LiveXRay01",@"LiveHeartbeat01", @"LiveMirrorImage01", @"LiveSlosh01", @"LiveOldTV01"]
// 场景特效颜色
#define kSceneEffectColorArray @[lsqRGBA(250, 118, 82, 0.7), lsqRGBA(244, 161, 26, 0.7), lsqRGBA(255, 253, 80, 0.7),lsqRGBA(91, 242, 84, 0.7), lsqRGBA(22, 206, 252, 0.7), lsqRGBA(110, 160, 242, 0.7), lsqRGBA(110, 160, 17, 0.7), lsqRGBA(255, 155, 224, 0.7), lsqRGBA(110, 17, 242, 0.7), lsqRGBA(153, 225, 17, 0.7), lsqRGBA(255, 239, 255, 0.7), lsqRGBA(110, 254, 238, 0.7)]


#pragma mark - 时间特效（Array）

// 时间特效code
#define kTimeEffectCodeArray @[@"repeat", @"slow", @"reverse"]

// 时间特效code
#define kTimeEffectCodeArray @[@"repeat", @"slow", @"reverse"]

#pragma mark - 魔法特效（Array）

// 粒子特效code
#define kParticleEffectCodeArray @[@"snow01", @"Love", @"Bubbles", @"Music", @"Star", @"Surprise", @"Flower", @"Magic", @"Money", @"Burning", @"Fireball"]
// 粒子特效颜色
#define kParticleEffectColorArray @[\
lsqRGBA(255, 255, 255, 0.7),\
lsqRGBA(254, 15, 15, 0.7),\
lsqRGBA(170, 170, 170, 0.7),\
lsqRGBA(54, 101, 255, 0.7),\
lsqRGBA(95, 250, 197, 0.7),\
lsqRGBA(148, 123, 255, 0.7),\
lsqRGBA(255, 155, 190, 0.7),\
lsqRGBA(100, 253, 253, 0.7),\
lsqRGBA(252, 231, 123, 0.7),\
lsqRGBA(255, 145, 91, 0.7),\
lsqRGBA(255, 203, 91, 0.7)]


// 转场特效
#define kTransitionTypesArray @[@(0),@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12)]

#define kTransitionEffectColorArray @[\
lsqRGBA(250, 118, 82, 0.7),\
lsqRGBA(244, 161, 26, 0.7),\
lsqRGBA(255, 253, 80, 0.7),\
lsqRGBA(91, 242, 84, 0.7), \
lsqRGBA(22, 206, 252, 0.7), \
lsqRGBA(110, 160, 242, 0.7), \
lsqRGBA(110, 160, 17, 0.7), \
lsqRGBA(255, 155, 224, 0.7), \
lsqRGBA(110, 17, 242, 0.7),\
lsqRGBA(255, 145, 91, 0.7),\
lsqRGBA(252, 231, 123, 0.7),\
lsqRGBA(100, 253, 253, 0.7),\
lsqRGBA(255, 203, 91, 0.7)]






/**
 *  魔法效果 - ParticleEffectListView
 *  NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", particleEffectCodes[index]];
    title = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    itemView.titleLabel.text = title;
    // 缩略图
    NSString *imageName = [NSString stringWithFormat:@"lsq_effect_thumb_%@", particleEffectCodes[index]];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    itemView.thumbnailView.image = [UIImage imageWithContentsOfFile:imagePath];
 *
 */

/**
 *  场景效果 - SceneEffectListView
 *  NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", particleEffectCodes[index]];
    NSString *imageName = [NSString stringWithFormat:@"lsq_effect_thumb_%@", sceneEffectCodes[index]];
    TuSDKCPGifImage *image = [TuSDKCPGifImage imageNamed:@"sample_gif_editor"];
 *
 */

/**
 *  时间特效 - TimeEffectListView
 *  NSString *title = [NSString stringWithFormat:@"lsq_filter_%@", timeEffectCodes[index]];
    title = NSLocalizedStringFromTable(title, @"TuSDKConstants", @"无需国际化");
    // GIF 缩略图
    NSString *imageName = [NSString stringWithFormat:@"lsq_effect_thumb_%@", timeEffectCodes[index]];
 *  TuSDKCPGifImage *image = [TuSDKCPGifImage imageNamed:@"sample_gif_editor"];
 *
 */

/**
 *  转场特效 - TransitionEffectListView
 *  NSArray *titles = @[@"FadeIn", @"FlyIn", @"PullInRight", @"PullInLeft", @"PullInTop", @"PullInBottom", @"SpreadIn", @"FlashLight", @"Flip", @"FocusOut", @"FocusIn", @"StackUp" , @"Zoom"];
 
    NSArray *imageNames = @[@"z_ic_fadein",@"z_ic_flyin", @"z_ic_pullright",@"z_ic_pullnleft", @"z_ic_pullnbottom", @"z_ic_pullntop", @"z_ic_spreadin",@"z_ic_flashlight", @"z_ic_flip",@"z_ic_focusout", @"z_ic_focusin",@"z_ic_stackup", @"z_ic_zoom"];
 *
 */

@interface VEManager()

@end
static VEManager *manager = nil;
@implementation VEManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
/**
 *  获取短视频滤镜组
 *
 *  @return 短视频滤镜组
 */
- (NSArray<TuFilterOption *> *)filterGroups {
    NSMutableArray *list = [NSMutableArray array];

    NSArray *filterGroups = [TuFilterLocalPackage package].groups;
    NSMutableArray *options = [NSMutableArray array];
    for (TuFilterGroup *filterGroup in filterGroups){
        if (filterGroup.groupFilterType == 0) {
            //获取所有的短视频滤镜组，demo 中只展示制定滤镜组。所以增加了如下判断
            NSArray *appointArray = @[@"298", @"297", @"296", @"295"];
            if ([appointArray containsObject:[NSString stringWithFormat:@"%u", filterGroup.groupId]])
            {
                NSArray* items = [[TuFilterLocalPackage package] optionsWithGroup:filterGroup];
                [options addObject:items];
            }
//            NSArray* items = [[TuFilterLocalPackage package] optionsWithGroup:filterGroup];
//            [options addObject:items];
        }
    }
    
    for (NSMutableArray *items in [options mutableCopy]){
        for (TuFilterOption *option in [[items reverseObjectEnumerator] allObjects]) {
            NSString *filterName = NSLocalizedStringFromTable(option.name, @"TuSDKConstants", @"无需国际化");
            NSLog(@"filterNameBB: %@: %@",filterName, option);
            [list addObject:option];
        }
    }
    
    return [[[list reverseObjectEnumerator] allObjects] copy];
}
/**
 * 获取mv贴纸组
 * @return 本地MV贴纸组包
 */
- (NSArray <TuStickerGroup *>*)tuMVStickerGroup {
    NSMutableArray *mvDataSet = [NSMutableArray array];
    NSArray<TuStickerGroup *> *stickers = [[TuStickerLocalPackage package] getSmartStickerGroupsWithFaceFeature:NO];
    for (TuStickerGroup *sticker in stickers)
    {
        NSURL *audioURL = [self audioURLWithStickerIdt:sticker.idt];
        //过滤录制相机中的动态贴纸，与音乐文件不匹配的动态贴纸都不是MV
        if(!audioURL) continue;
        [mvDataSet addObject:sticker];
    }
    /**
     name : 贴纸名称
     //展示 MV 缩略图
     //点击展示
     sticker.idt
     [_controller.sticker setGroup:1420];
     */
    return mvDataSet;
}
/**
 * 获取场景组
 */
- (NSArray <NSString *>*)sceneGroup {
    return @[@"LiveShake01",@"LiveMegrim01",@"EdgeMagic01",@"LiveFancy01_1",@"LiveSoulOut01",@"LiveSignal01",@"LiveLightning01",@"LiveXRay01",@"LiveHeartbeat01", @"LiveMirrorImage01", @"LiveSlosh01", @"LiveOldTV01"];
}
- (NSArray <NSString *>*)particleGroup {
    return @[@"snow01", @"Music", @"Star", @"Love", @"Bubbles", @"Surprise", @"Fireball", @"Flower", @"Magic", @"Money", @"Burning"];
}
- (NSArray <UIColor *>*)particleColorGroup {
    return @[\
        lsqRGBA(255, 255, 255, 0.7),
        lsqRGBA(254, 15, 15, 0.7),
        lsqRGBA(170, 170, 170, 0.7),
        lsqRGBA(54, 101, 255, 0.7),
        lsqRGBA(95, 250, 197, 0.7),
        lsqRGBA(148, 123, 255, 0.7),
        lsqRGBA(255, 155, 190, 0.7),
        lsqRGBA(100, 253, 253, 0.7),
        lsqRGBA(252, 231, 123, 0.7),
        lsqRGBA(255, 145, 91, 0.7),
        lsqRGBA(255, 203, 91, 0.7)];
}

- (void)loadThumbWithStickerGroup:(TuStickerGroup *)stickerGroup imageView:(UIImageView *)imageView {
    [[TuStickerLocalPackage package] loadThumbWithStickerGroup:stickerGroup imageView:imageView];
}

- (NSURL *)audioURLWithStickerIdt:(int64_t)stickerIdt {
    NSString *audioName = kMVEffectAudioDictionary[@(stickerIdt)];
    if (!audioName) return nil;
    
    return [[NSBundle mainBundle] URLForResource:audioName withExtension:@"mp3"];
}

@end

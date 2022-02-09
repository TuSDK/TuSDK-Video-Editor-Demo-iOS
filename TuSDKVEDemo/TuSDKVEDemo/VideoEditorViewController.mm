//
//  VideoEditorViewController.m
//  PulseDemoDev
//
//  Created by tutu on 2020/7/9.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "VideoEditorViewController.h"
#include <string>
//#import <TuSDKPulseVEditor/test_Layer.h>
#import "TuSDKPulseEditor.h"
#import "TuSDKPulseCore.h"
#import "TuSDKpulse.h"

#define ASSERT(b, msg) if (!(b)) {NSLog(@"ASSERT (%s) failure!! \n\t\tFILE:%s:%d // %@", #b, __FILE__, __LINE__, @msg); abort();}



@interface VideoEditorViewController ()<TUPPlayerDelegate> {
    
    __weak UIProgressView* _progressView;
    __weak TUPDisplayView* _displayView;
    __weak UIButton* _playBtn;
    __weak UIButton* _actBtn;

    __weak UISlider* _seekView;
    BOOL _underSeek;
    
    __weak UISlider* _adjustView;
    
    
    TUPVEditor* _editor;
    TUPVEditorPlayer* _player;
    TUPVEditorProducer* _producer;
    
    TUPVEditorEffect* _effect;
    TUPVEditorClip* _clip;

    
    TUPVEditorLayer* _layer;
    TUPVEditorLayer* _layer0;

    
    BOOL _playing;
    
    CGFloat _curts;
    
    //TUPVEditorEffect* _effect;
    
    
}

@end

@implementation VideoEditorViewController

//
//- (void) test;
//{
//
//
//    NSURL* turl = [[NSBundle mainBundle] URLForResource:@"c_re" withExtension:@"mp4"];
//
//    const char* ppp = turl.absoluteString.UTF8String;
//   // test_editor(ppp);
//
//}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

//    [self test];
    
    TUPVEditor_Config* veconfig = [[TUPVEditor_Config alloc] init];
    veconfig.width = 600;
    veconfig.height = 800;
    veconfig.framerate = 25;
    veconfig.sampleRate = 48000;
    veconfig.channels = 2;
    veconfig.initialDuration = 50000;
    
    BOOL ret;
    
    
    _editor = [[TUPVEditor alloc] init];
    
    //ret = [_editor setConfig:veconfig];
    
    ret = [_editor createWithConfig:veconfig];
    
    
    [self editorTest_2];
     
    
    TUPVEditorEditorModel* model = _editor.getModel;
   
    TUPVEditor* neditor = [[TUPVEditor alloc] init];
    ret = [neditor createWithModel:model];
    
    
    TUPVEditor_Config* oconfig = _editor.getConfig;
    oconfig.width = 1000;
    oconfig.height = 1000;
    [neditor updateWithConfig:oconfig];

    _playing = NO;
    
    
    UIProgressView* pv = [[UIProgressView alloc] init];
    pv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pv];
    [pv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [pv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [pv.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    
    _progressView = pv;
    
    _progressView.progress = 0.0;
    
    
    
    TUPDisplayView* displayView = [[TUPDisplayView alloc] init];
    displayView.translatesAutoresizingMaskIntoConstraints = NO;
    //displayView.frame = CGRectMake(0, 60, 300, 300);
    [self.view addSubview:displayView];
    
    [displayView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [displayView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [displayView.topAnchor constraintEqualToAnchor:pv.bottomAnchor constant:2].active = YES;
    [displayView.heightAnchor constraintEqualToAnchor:displayView.widthAnchor constant:80].active = YES;
    //[displayView.heightAnchor constraintEqualToConstant:300].active = YES;
    _displayView = displayView;
    
    
    
    
    
    
    
    UISlider* sv = [[UISlider alloc] init];
    sv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sv];
    _seekView = sv;
    [sv.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:5].active = YES;
    [sv.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
    [sv.topAnchor constraintEqualToAnchor:_displayView.bottomAnchor].active = YES;
    //[sv.bottomAnchor constraintEqualToAnchor:_playBtn.bottomAnchor].active = YES;
    
    
    UIButton *pb = [UIButton buttonWithType:UIButtonTypeCustom];
       [pb addTarget:self
              action:@selector(onPlayOrPause:forEvent:)
    forControlEvents:UIControlEventTouchUpInside];
    [pb setTitle:@"PP" forState:UIControlStateNormal];
    pb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pb];
    _playBtn = pb;
    pb.backgroundColor = UIColor.brownColor;
    
    [pb.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [pb.topAnchor constraintEqualToAnchor:sv.bottomAnchor].active = YES;
    [pb.widthAnchor constraintEqualToConstant:60].active = YES;
    [pb.heightAnchor constraintEqualToAnchor:pb.widthAnchor].active = YES;
    
    
    UIButton *ab = [UIButton buttonWithType:UIButtonTypeCustom];
       [ab addTarget:self
              action:@selector(onAction:forEvent:)
    forControlEvents:UIControlEventTouchUpInside];
    [ab setTitle:@"PP" forState:UIControlStateNormal];
    ab.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ab];
    _actBtn = ab;
    ab.backgroundColor = UIColor.yellowColor;
    
    [ab.leadingAnchor constraintEqualToAnchor:pb.trailingAnchor].active = YES;
    [ab.topAnchor constraintEqualToAnchor:sv.bottomAnchor].active = YES;
    [ab.widthAnchor constraintEqualToConstant:60].active = YES;
    [ab.heightAnchor constraintEqualToAnchor:ab.widthAnchor].active = YES;
    
    
    
    //sv.continuous = NO;
    [sv addTarget:self action:@selector(onSeekViewValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    sv.minimumValue = 0;
    sv.maximumValue = 1;
    _underSeek = NO;
    
    
    
    {
        
        UISlider* sv = [[UISlider alloc] init];
        sv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:sv];
        
        [sv.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:40].active = YES;
        [sv.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-40].active = YES;
        [sv.topAnchor constraintEqualToAnchor:_playBtn.bottomAnchor constant:10].active = YES;
        //[sv.bottomAnchor constraintEqualToAnchor:_playBtn.bottomAnchor].active = YES;
        
        _adjustView = sv;
        [sv addTarget:self action:@selector(onTestValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
        
        sv.minimumValue = 0;
        sv.maximumValue = 1;
        
    }
    
    
    
    
    
    
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"amazon" ofType:@"jpg" inDirectory:@"image"];
    
    //NSString *imagePath = [[NSBundle mainBundle] URLForResource:@"flow" withExtension:@"png"].absoluteString;
//    NSString *imagePath = [[NSBundle mainBundle] URLForResource:@"amazon" withExtension:@"jpg" subdirectory:@"image"].absoluteString;

    NSString *imagePath = [[NSBundle mainBundle] URLForResource:@"amazon" withExtension:@"jpg"].absoluteString;
    //NSString *imagePath = [[NSBundle mainBundle] URLForResource:@"grid" withExtension:@"jpeg"].absoluteString;
    
    NSLog(@"%@", imagePath);
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"tr9" ofType:@"MOV"];
    //    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    //    NSString *resource = [bundle pathForResource:@"fileName" ofType:@"fileType"];
    
    //int a = path.length;
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"Mojito" ofType:@"mp4"];
//
//    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Mojito" withExtension:@"mp4"];
    
    ///const char* ppp = url.absoluteString.UTF8String;
    
    
   
    
    [_displayView setup:nil];
    

    _player = [_editor newPlayer];
         
    ret = [_player open];
    _player.delegate = self;
    
    
    [_displayView attachPlayer:_player];
    //
    
//
//    _producer = [_editor newProducer];
//
//    _producer.savePath = outputPath;
//    _producer.delegate = self;
//    TUPProducer_OutputConfig* pocfg = [[TUPProducer_OutputConfig alloc] init];
//    pocfg.
//
//    _producer setOutputConfig:<#(nonnull TUPProducer_OutputConfig *)#>
//    [_producer open];
//    [_producer start];

    
    
}




- (void) editorTest_1;
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"a_re" withExtension:@"mp4"];
    NSURL* url2 = [[NSBundle mainBundle] URLForResource:@"c_re" withExtension:@"mp4"];
    
    NSURL* imurl = [[NSBundle mainBundle] URLForResource:@"grid" withExtension:@"jpeg"];

    
//    test_editor(url.absoluteString.UTF8String);
//    return;
//
    //TUPVEditorClipLayer* layer0 = nil;
    
    
    BOOL ret = NO;
    NSInteger dur = 0;
    TUPVEditorCtx* ctx = _editor.getContext;
    
    TUPVEditorComposition* videoComp = [_editor videoComposition];
    TUPVEditorComposition* audioComp = [_editor audioComposition];

    TUPStreamInfo* si = videoComp.getStreamInfo;
//    auto ddd = videoComp.getDuration;
//    ASSERT(ddd==50000, "failure");

    
    {
        TUPVEditorClipLayer* alayer =  [[TUPVEditorClipLayer alloc] initForAudio:ctx];
        
        TUPConfig* config = [[TUPConfig alloc] init];
        [config setString:url2.absoluteString forKey:@"path"];
        //[config setNumber:@(50000) forKey:@"duration"];
        [config setNumber:@(20000) forKey:@"trim-duration"];
        
        TUPVEditorClip* clip0 = [[TUPVEditorClip alloc] init:ctx withType:@"a:FILE"];
        clip0.config = config;
        
        //ret = clip0.activate;
        ret = [alayer addClip:clip0 at:30];
        
        
        [config setString:url.absoluteString forKey:@"path"];
        [config setNumber:@(10000) forKey:@"trim-duration"];

        TUPVEditorClip* clip1 = [[TUPVEditorClip alloc] init:ctx withType:@"a:FILE"];
        clip1.config = config;
        //ret = clip1.activate;

        ret = [alayer addClip:clip1 at:40];
        
        //ret = alayer.activate;

        
        TUPVEditorClipLayer_Transition *tt = [[TUPVEditorClipLayer_Transition alloc] init];
        tt.duration = 2000;
        [alayer setTransition:tt at:40];

        ret = [audioComp addLayer:alayer at:100];
    }
    
    
    
    {
        
        TUPVEditorClipLayer* vlayer =  [[TUPVEditorClipLayer alloc] initForVideo:ctx];
        
        TUPConfig* config = [[TUPConfig alloc] init];
        [config setString:url2.absoluteString forKey:@"path"];
        //[config setNumber:@(50000) forKey:@"duration"];
        [config setNumber:@(20000) forKey:@"trim-duration"];
        
        TUPVEditorClip* clip0 = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
        clip0.config = config;
        ret = [vlayer addClip:clip0 at:30];
        
        
        [config setString:url.absoluteString forKey:@"path"];
        [config setNumber:@(10000) forKey:@"trim-duration"];

        TUPVEditorClip* clip1 = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
        clip1.config = config;
        ret = [vlayer addClip:clip1 at:40];
        
        ret = vlayer.activate;
        
//
//        NSString* script_str = [NSString stringWithUTF8String:script4];
//        script_str = [script_str stringByReplacingOccurrencesOfString: @"\"" withString:@"\\\""];
//        script_str = [script_str stringByReplacingOccurrencesOfString: @"\n" withString:@"\\n"];
//
//        NSString * model_str = [NSString stringWithFormat:@(model_fmt), script_str];
        
        TUPVEditorClipLayer_Transition *tt;
        tt.duration = 2000;
        tt.name = @"fade";
        ret = [vlayer setTransition:tt at:40];
        NSAssert(!!ret, @"set transition");
    
        ret = [videoComp addLayer:vlayer at:100];
    }
    
    
    _editor.debugDump;
     
    
     
     [_editor build];
    
}



- (void) editorTest_0;
{
    
    TUPStreamInfo* si = 0;
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"a_re" withExtension:@"mp4"];
    NSURL* url2 = [[NSBundle mainBundle] URLForResource:@"c_re" withExtension:@"mp4"];
    
    NSURL* imurl = [[NSBundle mainBundle] URLForResource:@"grid" withExtension:@"jpeg"];

    
//    test_editor(url.absoluteString.UTF8String);
//    return;
//
    //TUPVEditorClipLayer* layer0 = nil;
    
    
    BOOL ret = NO;
    NSInteger dur = 0;
    TUPVEditorCtx* ctx = _editor.getContext;
    
    TUPVEditorComposition* videoComp = [_editor videoComposition];
    TUPVEditorComposition* audioComp = [_editor audioComposition];

    //auto ddd = videoComp.getDuration;
    si = videoComp.getStreamInfo;
    NSAssert(si.duration==50000, @"failure");

    
    {
        TUPVEditorClipLayer* alayer =  [[TUPVEditorClipLayer alloc] initForAudio:ctx];
        
        TUPConfig* config = [[TUPConfig alloc] init];
        //[config setString:url2.absoluteString forKey:@"path"];
        [config setNumber:@(50000) forKey:@"duration"];
        //[config setNumber:@(10000) forKey:@"trim-duration"];
        
        TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"a:SILENCE"];
        
        clip.config = config;
        ret = clip.activate;
        NSAssert(ret, @"failure");
        
//        dur = clip.getDuration;
        si = audioComp.getStreamInfo;
        dur = si.duration;
        ret = [alayer addClip:clip at:100];
        NSAssert(ret, @"failure");
        
        ret = alayer.activate;
//        dur = alayer.getDuration;
        si = audioComp.getStreamInfo;
        dur = si.duration;
        ret = [audioComp addLayer:alayer at:10];
        NSAssert(ret, @"failure");
        
//        dur = alayer.getDuration;
        si = audioComp.getStreamInfo;
        dur = si.duration;
        NSAssert(dur==49984, @"failure");
        
//        dur = audioComp.getDuration;
//        si = videoComp.getStreamInfo;
//        dur = si.duration;
        //NSAssert(ddd==50000, @"failure");
        
        int a = dur;
        
    }
    
    
    
    
    
    TUPConfig* lconfig = [[TUPConfig alloc] init];

    TUPVEditorClipLayer* layer =  [[TUPVEditorClipLayer alloc] initForVideo:ctx];
    {//clip
        
        {
            TUPConfig* config = [[TUPConfig alloc] init];
            [config setString:url.absoluteString forKey:@"path"];
            //[config setNumber:@(20002) forKey:@"trim-duration"];
            
            // 创建clip, 设置config
            TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
            clip.config = config;
            //激活
            ret = clip.activate;
            NSAssert(ret, @"failure");
            //
            
            //激活后 可以获取长度等信息(宽高帧率)
//            dur = [clip getDuration];
            si = clip.getStreamInfo;
            dur = si.duration;
            NSAssert(dur == 41600, @"failure");

            
            
//            [config setNumber:@(20002) forKey:@"trim-duration"];
//            clip.config = config;
//            clip.active;
            
            //在clip后添加一个Effect, 类型是v:TRIM, 用于截取clip视频中的某一段
            TUPVEditorEffect* trim_e = [[TUPVEditorEffect alloc] init:ctx withType:@"v:TRIM"];
            TUPConfig* econfig = [[TUPConfig alloc] init];
            //设置config, 参数: begin 和 end,
            [econfig setNumber:@(10000) forKey:@"begin"];
            [econfig setNumber:@(24000) forKey:@"end"];
            trim_e.config = econfig;
            
            //将effect 添加至clip
            ret = [clip.effects addEffect:trim_e at:100];
            NSAssert(ret, @"failure");

            
            //ret = clip.activate;
            //NSAssert(ret, @"failure");

//            dur = [clip getDuration];
            si = clip.getStreamInfo;
            dur = si.duration;
            NSAssert(dur == 14000, @"failure");

            //NSAssert(0, @"failure 0");
            
            //effect 更新 config
            [econfig setNumber:@(34000) forKey:@"end"];
            trim_e.config = econfig;
            //trim_e update

//            dur = [clip getDuration];
            si = clip.getStreamInfo;
            dur = si.duration;
            NSAssert(dur == 24000, @"failure");

            //clip里删除某个effect
            ret = [clip.effects deleteEffect:100];
            NSAssert(ret, @"failure");

//            dur = [clip getDuration];
            si = clip.getStreamInfo;
            dur = si.duration;
            NSAssert(dur == 41600, @"failure");
            
            //effect 更新 config
            //将effect 添加至clip
            [econfig setNumber:@(10000) forKey:@"begin"];
            [econfig setNumber:@(40000) forKey:@"end"];
            trim_e.config = econfig;
            
            ret = [clip.effects addEffect:trim_e at:100];
            NSAssert(ret, @"failure");
            
//            dur = [clip getDuration];
            si = clip.getStreamInfo;
            dur = si.duration;
            NSAssert(dur == 30000, @"failure");
           
           
            
            
            
            //将该clip添加到layer上
            ret = [layer addClip:clip at:200];
            NSAssert(ret, @"failure");

          
            
        }
        
        
        [lconfig setNumber:@2000 forKey:TUPVEditorLayer_CONFIG_START_POS];
        layer.config = lconfig;
        //[layer setConfig:lconfig];
       
        //[layer setStart:2000];
        
        
        // 激活layer
        ret = layer.activate;
        NSAssert(ret, @"failure");

        si = layer.getStreamInfo;
        dur = si.duration;
//        dur = layer.getDuration;
        NSAssert(dur == 30000, @"failure");

      
        si = videoComp.getStreamInfo;
        dur = si.duration;
//        dur = videoComp.getDuration;
        NSAssert(dur==50000, @"failure");


        ///
        {
            TUPConfig* config = [[TUPConfig alloc] init];
            [config setString:url2.absoluteString forKey:@"path"];
            [config setNumber:@(10000) forKey:@"trim-start"];
            [config setNumber:@(10000) forKey:@"trim-duration"];

            TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
            
            clip.config = config;
            ret = clip.activate;
            NSAssert(ret, @"failure");

            si = clip.getStreamInfo;
            dur = si.duration;
//            dur = [clip getDuration];
            NSAssert(dur == 10000, @"failure");

            ret = [layer addClip:clip at:300];
            NSAssert(ret, @"failure");
            
        }
        si = layer.getStreamInfo;
        dur = si.duration;
//        dur = layer.getDuration;
        NSAssert(dur == 40000, @"failure");
        
        
        {
            //在layer后添加effect
            TUPVEditorEffect* trim_e = [[TUPVEditorEffect alloc] init:ctx withType:@"v:TRIM"];
            TUPConfig* econfig = [[TUPConfig alloc] init];
            [econfig setNumber:@(10000) forKey:@"begin"];
            [econfig setNumber:@(30000) forKey:@"end"];
            //trim_e.config = econfig;
            
//            ret = [layer.effects addEffect:trim_e at:100];
//            NSAssert(ret, @"failure");
            
        }
        si = layer.getStreamInfo;
        dur = si.duration;
//        dur = layer.getDuration;
        NSAssert(dur == 40000, @"failure");
        

        TUPVEditorModel* lmodel = layer.getModel;
        {
            TUPVEditorClipLayer* layer0 =  [[TUPVEditorClipLayer alloc] init:ctx withModel:lmodel];
            ret = layer0.activate;
            NSAssert(ret, @"failure");

            si = layer0.getStreamInfo;
            dur = si.duration;
//            dur = layer0.getDuration;
            NSAssert(dur == 40000, @"failure");

            NSInteger b = dur;
            b+=1;
            _layer0 = layer0;
            //ret = [videoComp addLayer:layer0 at:30];
            NSAssert(ret, @"failure");
            layer0.deactivate;

        }
    
        ret = [videoComp addLayer:layer at:10];
        NSAssert(ret, @"failure");

        si = videoComp.getStreamInfo;
        dur = si.duration;
//        dur = videoComp.getDuration;

//        ret = [videoComp build];
//        NSAssert(ret, @"failure");

        //
        
        int a = dur;

    }
    
    
    _editor.debugDump;
    
   
    
    [_editor build];
    
    return;
    
}






- (void) editorTest_2;
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"a_re" withExtension:@"mp4"];
    NSURL* url2 = [[NSBundle mainBundle] URLForResource:@"c_re" withExtension:@"mp4"];

    NSURL* imurl = [[NSBundle mainBundle] URLForResource:@"amazon" withExtension:@"jpg"];

    
//    test_editor(url.absoluteString.UTF8String);
//    return;
//
    //TUPVEditorClipLayer* layer0 = nil;
    
    
    BOOL ret = NO;
    NSInteger dur = 0;
    TUPVEditorCtx* ctx = _editor.getContext;
    
    TUPVEditorComposition* videoComp = [_editor videoComposition];
    TUPVEditorComposition* audioComp = [_editor audioComposition];

    TUPStreamInfo* si = videoComp.getStreamInfo;
    auto ddd = si.duration;
//    auto ddd = videoComp.getDuration;
    ASSERT(ddd == 50000, "failure");

//    TUPStreamInfo* si;
    
    {
        
        TUPConfig* config = [[TUPConfig alloc] init];
        [config setString:url2.absoluteString forKey:@"path"];
        //[config setNumber:@(50000) forKey:@"duration"];
        [config setNumber:@(20000) forKey:@"trim-duration"];
        
        TUPVEditorClip* clip0 = [[TUPVEditorClip alloc] init:ctx withType:@"a:FILE"];
        clip0.config = config;
        
        ret = clip0.activate;
        si = clip0.getStreamInfo;
//        dur = clip0.getDuration;
        //ASSERT(dur == 20000, "failure");

        
        TUPVEditorClipLayer* alayer =  [[TUPVEditorClipLayer alloc] initForAudio:ctx];
        TUPConfig* lconfig = [[TUPConfig alloc] init];
        [lconfig setNumber:@(2000) forKey:@"start-pos"];
        alayer.config = lconfig;
        ret = [alayer addClip:clip0 at:30];
        
        
        [config setNumber:@(10000) forKey:@"trim-duration"];
        clip0.config = config;
        //ret = clip0.activate;
        //dur = clip0.getDuration;
        //ASSERT(dur == 10000, "failure");
        
        
        
        
        [config setString:url.absoluteString forKey:@"path"];
        [config setNumber:@(10000) forKey:@"trim-duration"];

        TUPVEditorClip* clip1 = [[TUPVEditorClip alloc] init:ctx withType:@"a:FILE"];
        clip1.config = config;
        //ret = clip1.activate;

        ret = [alayer addClip:clip1 at:40];
        
        //ret = alayer.activate;

        
        TUPVEditorClipLayer_Transition *tt;
        tt.duration = 2000;
        [alayer setTransition:tt at:40];

        ret = [audioComp addLayer:alayer at:100];
    }
    
    
    
    {
        
        TUPVEditorClipLayer* vlayer =  [[TUPVEditorClipLayer alloc] initForVideo:ctx];
        TUPConfig* lconfig = [[TUPConfig alloc] init];
        [lconfig setNumber:@(2000) forKey:@"start-pos"];
        vlayer.config = lconfig;
        
        TUPConfig* config = [[TUPConfig alloc] init];
        [config setString:url2.absoluteString forKey:@"path"];
        //[config setNumber:@(50000) forKey:@"duration"];
        [config setNumber:@(10000) forKey:@"trim-duration"];
        
        TUPVEditorClip* clip0 = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
        clip0.config = config;
        ret = [vlayer addClip:clip0 at:30];
        
        
        [config setString:url.absoluteString forKey:@"path"];
        [config setNumber:@(10000) forKey:@"trim-duration"];

        TUPVEditorClip* clip1 = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
        clip1.config = config;
        ret = [vlayer addClip:clip1 at:40];
        
        ret = vlayer.activate;
        
//        NSString* script_str = [NSString stringWithUTF8String:script4];
//        script_str = [script_str stringByReplacingOccurrencesOfString: @"\"" withString:@"\\\""];
//        script_str = [script_str stringByReplacingOccurrencesOfString: @"\n" withString:@"\\n"];
//        NSString * model_str = [NSString stringWithFormat:@(model_fmt), script_str];
        
        TUPVEditorClipLayer_Transition *tt;
        tt.duration = 2000;
        tt.name = @"fade-color";
        ret = [vlayer setTransition:tt at:40];
        NSAssert(!!ret, @"set transition");
    
        ret = [videoComp addLayer:vlayer at:100];
        
        
        {
            TUPVEditorClipLayer* vlayer0 =  [[TUPVEditorClipLayer alloc] initForVideo:ctx];
            TUPConfig* lconfig0 = [[TUPConfig alloc] init];
            [lconfig0 setNumber:@(2000) forKey:@"start-pos"];
            vlayer0.config = lconfig0;
            
            TUPConfig* configi = [[TUPConfig alloc] init];
            [configi setString:imurl.absoluteString forKey:@"path"];
            [configi setNumber:@20000 forKey:@"duration"];

            TUPVEditorClip* clipi = [[TUPVEditorClip alloc] init:ctx withType:@"v:TEXT2D"];
            clipi.config = configi;
            ret = [vlayer0 addClip:clipi at:30];
            _clip = clipi;
            
//            TUPVEditorEffect* ee = [[TUPVEditorEffect alloc] init:ctx withType:TUPVECanvasResizeEffect_TYPE_NAME];
//            _effect = ee;
//            [clipi.effects addEffect:ee at:111];
            
            ret = [videoComp addLayer:vlayer0 at:200];

        }
        
        
    }
    
    
    _editor.debugDump;
     
    
     
     [_editor build];
    
    {
        
        
//        TUPVECanvasResizePropertyBuilder* propBuilder = [[TUPVECanvasResizePropertyBuilder alloc] init];
//        propBuilder.color = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
//        propBuilder.panX = 0;
//        propBuilder.panY = 0;
//
//        TUPProperty* prop = [propBuilder makeProperty];
//
        
//        [_effect setProperty:prop forKey:TUPVECanvasResizeEffect_PROP_PARAM];
        
        std::string sss = "HelloSkia\n你好";
        
        TUPVEText2DClip_PropertyBuilder* propBuilder = [[TUPVEText2DClip_PropertyBuilder alloc] init];
        propBuilder.holder.text = @(sss.c_str());
        TUPProperty* prop = [propBuilder makeProperty];
        [_clip setProperty:prop forKey:TUPVEText2DClip_PROP_PARAM];

        TUPVEColorAdjustEffect_PropertyBuilder* vpropBuilder = [[TUPVEColorAdjustEffect_PropertyBuilder alloc] init];
        
        TUPVEColorAdjustEffect_PropertyItem* item =[[TUPVEColorAdjustEffect_PropertyItem alloc] init:@"aa" with:0.7 and:11.0];
        [vpropBuilder.holder.items addObject:item];
        TUPVEColorAdjustEffect_PropertyItem* item2 =[[TUPVEColorAdjustEffect_PropertyItem alloc] init:@"bb" with:10.0];
        [vpropBuilder.holder.items addObject:item2];
        TUPProperty* vprop = [vpropBuilder makeProperty];
        
        
        
        int a = 0;
        
    }
    
}



- (void) editorTest_xx;
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"a_re" withExtension:@"mp4"];
    NSURL* url2 = [[NSBundle mainBundle] URLForResource:@"c_re" withExtension:@"mp4"];
    
    NSURL* imurl = [[NSBundle mainBundle] URLForResource:@"grid" withExtension:@"jpeg"];

    
//    test_editor(url.absoluteString.UTF8String);
//    return;
//    
    TUPVEditorClipLayer* layer0 = nil;
    
    
    BOOL ret = NO;
    
    TUPVEditorCtx* ctx = _editor.getContext;
    
    {
        
        TUPVEditorComposition* videoComp = [_editor videoComposition];
        
        
        
        TUPConfig* lconfig = [[TUPConfig alloc] init];
        //[lconfig setNumber:@(2000) forKey:@"start-pos"];
        [lconfig setNumber:@2000 forKey:TUPVEditorLayer_CONFIG_START_POS];

        TUPVEditorClipLayer* layer =  [[TUPVEditorClipLayer alloc] initForVideo:ctx];
        layer.config = lconfig;
        //[layer setConfig:lconfig];
        
        //[layer setStart:2000];
        [videoComp addLayer:layer at:10];
        
       
        layer0 = layer;
        _layer0 = layer;

        {
            TUPConfig* config = [[TUPConfig alloc] init];
            [config setString:url.absoluteString forKey:@"path"];
            [config setNumber:@(20000) forKey:@"trim-duration"];
            TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
            clip.config = config;
            [layer addClip:clip at:10];
            
            ret = [config setNumber:@(10000) forKey:@"trim-duration"];

            clip.config = config;
            
//            TUPVEditorEffect* e = [[TUPVEditorEffect alloc] init:ctx withType:@"v:RESIZE" andConfig:ecfg];
//            _effect = e;
////            veconfig.width = 600;
////            veconfig.height = 800;
//            [clip addEffect:e at:100];
            
        }
        
       
    
        {
            
//            NSString* script_str = [NSString stringWithUTF8String:script4];
//            script_str = [script_str stringByReplacingOccurrencesOfString: @"\"" withString:@"\\\""];
//            script_str = [script_str stringByReplacingOccurrencesOfString: @"\n" withString:@"\\n"];
//
//            NSString * model_str = [NSString stringWithFormat:@(model_fmt), script_str];
            

            TUPConfig* config = [[TUPConfig alloc] init];
            [config setString:url2.absoluteString forKey:@"path"];
            [config setNumber:@(10000) forKey:@"trim-start"];
            [config setNumber:@(30000) forKey:@"trim-duration"];
//            [config setNumber:@(2000) forKey:@"transition-duration"];
//            [config setString: model_str forKey:@"transition-model"];

            TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"v:FILE"];
            clip.config = config;
            [layer addClip:clip at:20];
            TUPVEditorClipLayer_Transition *transition;
            transition.duration = 2000;
            transition.name = @"fade";
            
            [layer setTransition:transition at:20];
            
            TUPConfig* ecfg = [[TUPConfig alloc] init];
            [ecfg setNumber:@(1023) forKey:@"test-cc"];
            TUPVEditorEffect* effect = [[TUPVEditorEffect alloc] init:ctx withType:@"v:COLOR"];
            //_effect = effect;
            [clip.effects addEffect:effect at:100];
            effect.config = ecfg;
            
            TUPProperty* epp = [[TUPProperty alloc] initWithNumber:@(1111)];
            BOOL rrr = [effect setProperty:epp forKey:@"test-key"];
//
//            TUPVEditorClipModel* cm = [[TUPVEditorClipModel alloc] initWithClip:clip];
//
//            int s = cm.index;
//
//            clip updateConfig:<#(nonnull TUPConfig *)#>
//            {
//
//                [layer setProperty:@"transition" forKey:@"param:transition"];
//
//            }
            
        }
       
        
        if (1) {
            TUPConfig* ecfg = [[TUPConfig alloc] init];
//            [ecfg setNumber:@(600) forKey:@"width"];
//            [ecfg setNumber:@(800) forKey:@"height"];
            TUPVEditorEffect* e = [[TUPVEditorEffect alloc] init:ctx withType:@"v:RESIZE"];
            e.config = ecfg;
            _effect = e;
            //            veconfig.width = 600;
            //            veconfig.height = 800;
            [layer.effects addEffect:e at:100];
        }
        
        {
            
            TUPConfig* lconfig = [[TUPConfig alloc] init];
            //[lconfig setNumber:@(3000) forKey:@"start-pos"];
            //[lconfig setString: [NSString stringWithUTF8String:blend_script] forKey:@"blend-script"];
            //[lconfig setString: @"normal" forKey:@"blend-mode"];
            [lconfig setNumber:@2000 forKey:TUPVEditorLayer_CONFIG_START_POS];
            [lconfig setString:TUPVEditorLayerBlendMode_Normal forKey:TUPVEditorLayer_CONFIG_BLEND_MODE];
            
            
            TUPVEditorClipLayer* layer =  [[TUPVEditorClipLayer alloc] initForVideo:ctx];
            layer.config = lconfig;
            //TUPVEditorLayer* layer = [videoop NewLayer:@"11" withIndex:100 andConfig:lconfig];
            //[layer setConfig:lconfig];
            //[layer setStart:3000];
            //[layer setBlendMode:TUPVEditorLayerBlendMode_Darken];
            
            [videoComp addLayer:layer at:20];
            _layer = layer;
            
            {
                
                TUPConfig* config = [[TUPConfig alloc] init];
                [config setString:imurl.absoluteString forKey:@"path"];
                [config setNumber:@(3000) forKey:@"duration"];
                //[config setNumber:@(2000) forKey:@"transition-duration"];
                // [config setString: [NSString stringWithUTF8String:script4] forKey:@"transition-name"];
                
                TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"v:IMG"];
                clip.config = config;
                [layer addClip:clip at:30];
                
            }
            
        }
       
        
       // TUPVEditorClipLayer* layer1 =  [[TUPVEditorClipLayer alloc] initForVideo:ctx withName:@"www"];

        
        
        TUPVEditor_Config* cfg = [_editor getConfig];
        
//        TUPVEditorEffect* effect = [[TUPVEditorEffect alloc] init:ctx withName:@"v:DUMMY" andConfig:nil];
//
//        [clip addEffect:effect at:100];
//
        TUPVEditorModel* vcompM = [videoComp getModel];
        //vcompM.dump;
        
        cfg.width = 800;
        cfg.height = 400;
        
        ///BOOL aa = [_editor updateConfig:cfg];
        
        
        
        
        
    }
    {
        //TUPVEditorAudioLayerOperator* audioop = [_editor Audio];
        TUPVEditorComposition* audioComp = [_editor audioComposition];

        
        TUPVEditorClipLayer* layer =  [[TUPVEditorClipLayer alloc] initForAudio:ctx];

        
        TUPConfig* lconfig = [[TUPConfig alloc] init];
        [lconfig setNumber:@(2000) forKey:@"start-pos"];
        //TUPVEditorLayer* layer = [audioop NewLayer:@"11" withIndex:100 andConfig:lconfig];
        [layer setConfig:lconfig];
        
        [audioComp addLayer:layer at:10];


        {
            TUPConfig* config = [[TUPConfig alloc] init];
            [config setString:url.absoluteString forKey:@"path"];
            [config setNumber:@(10000) forKey:@"trim-duration"];
            TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"a:FILE"];
            clip.config = config;
            [layer addClip:clip at:10];
        
        }
        
        {
            TUPConfig* config = [[TUPConfig alloc] init];
            [config setString:url2.absoluteString forKey:@"path"];
            [config setNumber:@(10000) forKey:@"trim-start"];
            [config setNumber:@(30000) forKey:@"trim-duration"];
            //[config setNumber:@(2000) forKey:@"transition-duration"];
            TUPVEditorClipLayer_Transition *transition;
            transition.duration = 2000;
            //transition.model = model_str;

            TUPVEditorClip* clip = [[TUPVEditorClip alloc] init:ctx withType:@"a:FILE"];
            clip.config = config;
            [layer addClip:clip at:20];
            [layer setTransition:transition at:20];

        }
        


        

        
    }
    
    [_editor build];
    
    
    {
       
    }
    
    
    
    return;
    
}




- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    
    [_displayView setup:nil];
    
    [_displayView attachPlayer:_player];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    NSLog(@"viewDidDisappear");
    [_displayView teardown];
    _displayView = nil;
    
    
    [_player close];
    [_editor resetPlayer];
    
    [_editor destroy];
    _editor = nil;
}







- (void)onPlayOrPause:(id)sender forEvent:(UIEvent*)event {
    
    
    NSLog(@"PPP");
    [self playOrPause];
    //    BOOL res = [_editor play];
    //    if (!res) {
    //        NSLog(@"play failed!");
    //    }
    
}





- (void)onAction:(id)sender forEvent:(UIEvent*)event {
    
    
    NSLog(@"ACT");
    //[self playOrPause];
    //    BOOL res = [_editor play];
    //    if (!res) {
    //        NSLog(@"play failed!");
    //    }
    
}


- (void)onSeekViewValChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseBegan:
            // handle drag began
            NSLog(@"begin..");
            [self pause];
            _underSeek = YES;
            break;
        case UITouchPhaseMoved: {
            // handle drag moved
            
                        CGFloat p = slider.value * [_editor getDuration];
            
                        NSLog(@"move to: %f", p);
                        [_player previewFrame:(NSInteger)p];
            
        }
            break;
        case UITouchPhaseEnded:
            // handle drag ended
            NSLog(@"end..");
            _underSeek = NO;
            //[_editor play];
            break;
        default:
            break;
    }
}



- (void)onTestValChanged:(UISlider*)slider forEvent:(UIEvent*)event {
    UITouch *touchEvent = [[event allTouches] anyObject];
    switch (touchEvent.phase) {
        case UITouchPhaseBegan:
            // handle drag began
//            NSLog(@"begin..");
//            [self pause];
//            _underSeek = YES;
            break;
        case UITouchPhaseMoved: {
            // handle drag moved
            
            CGFloat p = slider.value;
//
//            TUPProperty* prop = [TUPProperty propertyWithNumber:@(p*360)];
//            [_layer setProperty:prop forKey:@"rotate"];

            
            if (0) {
                auto _oljson = R"JSON(
                
                {
                "strength" : %f
                }
                
                
                )JSON";
                
                NSString* json_str = [NSString stringWithFormat:@(_oljson), p];
                TUPProperty* prop = [TUPProperty propertyWithJsonString:json_str];
                
                //TUPProperty* prop = [TUPProperty propertyWithNumber:@(p)];
                [_layer setProperty:prop forKey:@"blend"];
                
                
                NSLog(@"move to: %@  at: %f", @(p*360), _curts);
            }
            
          
            
            if (1) {
                
                auto _oljson = R"JSON(
                
                {
                "pzr" : {
                "p" : [0.5, %f],
                "z" : 1,
                "r" : 0
                },
                "blend" : {
                "strength" : 0.8
                }
                }
                
                
                )JSON";
                
                NSString* json_str = [NSString stringWithFormat:@(_oljson), p];
                
                
                TUPProperty* op = [TUPProperty propertyWithJsonString:json_str];
                BOOL ret =[_layer0 setProperty:op forKey:@"overlay"];
                if (!ret) {
                    NSLog(@"xxxxxxxxxxxxxxxx");
                }
                
            }
            
            if (0) {
                
                auto _oljson = R"JSON(
                [
                    {
                        "n": "contrast",
                        "a": [
                            %f
                            ]
                    },
                    {
                        "n": "white-balance",
                        "a": [
                            0.5,
                            0.2
                            ]
                    }
                ]
                
                )JSON";
                
                NSString* json_str = [NSString stringWithFormat:@(_oljson), p];
                TUPProperty* prop = [TUPProperty propertyWithJsonString:json_str];
                
                [_effect setProperty:prop forKey:@"parameters"];
                
                
            }
            
            if (0) {
                           
               auto _oljson = R"JSON(
               {
                    "t" : "blur",
                    "v" : %f,
                   
                    "pzr" : {
                        "p" : [0.0, 0.0],
                        "z" : 1.0,
                        "r" : 0
                    }
               }
               
               )JSON";
               
               NSString* json_str = [NSString stringWithFormat:@(_oljson), p];
               TUPProperty* prop = [TUPProperty propertyWithJsonString:json_str];
               
               [_effect setProperty:prop forKey:@"parameters"];
               
               
           }
          
            
            
            [_player previewFrame:_curts];
            //  [_editor previewFrame:(NSInteger)p];
            // [_editor testProperty:p];
        }
            break;
        case UITouchPhaseEnded:
//            // handle drag ended
//            NSLog(@"end..");
//            _underSeek = NO;
            //[_editor play];
            break;
        default:
            break;
    }
}


- (void)onPlayerEvent:(TUPPlayerState)state withTimestamp:(NSInteger)ts {
    
    
    if (state == kEOS) {
        
        [_player seekTo:0];
        [self play];
    }
    
    
    
    CGFloat p = (CGFloat)ts / [_player getDuration];
    
    
    
    if (state == kPLAYING) {
        
        _curts = ts;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_progressView setProgress:p];
        if (!_underSeek)
            [_seekView setValue:p];
    });
    } else if (state ==  kDO_PREVIEW) {
        
        _curts = ts;
    }
}



- (void) playOrPause;
{
    if (_playing) {
        [_player pause];
        _playing = NO;
    } else {
        [_player play];
        _playing = YES;
    }
}

- (void) play;
{
    if (!_playing) {
        [_player play];
        _playing = YES;
    }
}


- (void) pause;
{
    if (_playing) {
        [_player pause];
        _playing = NO;
    }
}



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

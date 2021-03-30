//
//  StreamTestViewController.m
//  PulseDemoDev
//
//  Created by Zoeric on 2020/08/16.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "StreamTestViewController.h"


#import <TuSDKPulse/TUPEngine.h>
#import <TuSDKPulse/TUPDisplayView.h>
#import <TuSDKPulse/TUPVideoPlayer.h>



@interface StreamTestViewController ()<TUPPlayerDelegate> {

    __weak UIProgressView* _progressView;
    __weak TUPDisplayView* _displayView;
    __weak UIButton* _playBtn;
    __weak UISlider* _seekView;
    __weak UIButton* _actBtn;

    BOOL _underSeek;
    
    TUPVideoPlayer* _player;
    //TUPEvaPlayer* _player;
    
    
    BOOL _playing;
  
}
@end

@implementation StreamTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"VC : %@", self);
    
    
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
    
    [sv.leadingAnchor constraintEqualToAnchor:super.view.safeAreaLayoutGuide.leadingAnchor].active = YES;
    [sv.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor].active = YES;
    [sv.topAnchor constraintEqualToAnchor:_displayView.bottomAnchor].active = YES;
    _seekView = sv;
    
    UIButton *pb = [UIButton buttonWithType:UIButtonTypeCustom];
    [pb addTarget:self
               action:@selector(onPlayOrPause:forEvent:)
     forControlEvents:UIControlEventTouchUpInside];
    [pb setTitle:@"PP" forState:UIControlStateNormal];
    pb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pb];
    _playBtn = pb;
    pb.backgroundColor = UIColor.greenColor;
   
    
    
   
    
    [pb.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [pb.topAnchor constraintEqualToAnchor:_seekView.bottomAnchor].active = YES;
    [pb.widthAnchor constraintEqualToConstant:60].active = YES;
    [pb.heightAnchor constraintEqualToAnchor:pb.widthAnchor].active = YES;

    
   
    //[sv.bottomAnchor constraintEqualToAnchor:_playBtn.bottomAnchor].active = YES;
    
    
    UIButton *ab = [UIButton buttonWithType:UIButtonTypeCustom];
    [ab addTarget:self
               action:@selector(onAction:forEvent:)
     forControlEvents:UIControlEventTouchUpInside];
    [ab setTitle:@"AC" forState:UIControlStateNormal];
    ab.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:ab];
    _actBtn = ab;
    ab.backgroundColor = UIColor.brownColor;
    [ab.leadingAnchor constraintEqualToAnchor:_playBtn.trailingAnchor].active = YES;
    [ab.topAnchor constraintEqualToAnchor:_playBtn.topAnchor].active = YES;
    [ab.widthAnchor constraintEqualToAnchor:_playBtn.widthAnchor].active = YES;
    [ab.heightAnchor constraintEqualToAnchor:ab.widthAnchor].active = YES;
    
    
    //sv.continuous = NO;
    [sv addTarget:self action:@selector(onSeekViewValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    
    sv.minimumValue = 0;
    sv.maximumValue = 1;
    _underSeek = NO;
    
    
    
    
    //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"d" ofType:@"png" inDirectory:@"images"];

    //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"flow" ofType:@"png"];
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"grid" ofType:@"jpeg"];

    NSLog(@"%@", imagePath);
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"tr9" ofType:@"MOV"];
//    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
//    NSString *resource = [bundle pathForResource:@"fileName" ofType:@"fileType"];
    
    //int a = path.length;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"c_re" ofType:@"mp4"];

    NSURL* url = [[NSBundle mainBundle] URLForResource:@"Mojito" withExtension:@"mp4"];
    
    const char* ppp = url.absoluteString.UTF8String;
    
#if 0
    test_editor(ppp);
    
#endif
    

    [_displayView setup:nil];
    
    //NSString *tmpPath = [[NSBundle mainBundle] pathForResource:@"text2/data" ofType:@"json"];

    NSString *tmpPath = [[NSBundle mainBundle] URLForResource:@"lsq_eva_173" withExtension:@"eva"].absoluteString;

    
    //UIImage* img = [maker generate: tmpPath];
    

    _player = [[TUPVideoPlayer alloc] init];
   

  

    TUPPlayer_OutputConfig* oconfig = [[TUPPlayer_OutputConfig alloc] init];
    //oconfig.rangeStart = 2000;
     //   oconfig.width = 2000;
    //    oconfig.height = 800;
    //    oconfig.watermarkPosition = 0;
    oconfig.watermark = [UIImage imageNamed: @"flow.png"];
    [_player setOutputConfig:oconfig];
    
   
    //NSString *repath = [[NSBundle mainBundle] pathForResource:@"c_re" ofType:@"mp4"];
    
    _player.delegate = self;

    [_player open:path];
    [_displayView attachPlayer:_player];

    
}



- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    
  //  [_displayView setup:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    NSLog(@"viewDidDisappear");
    [_displayView teardown];
    _displayView = nil;
    [_player close];
    _player = nil;
    
   // [_director close];
}







- (void)onPlayOrPause:(id)sender forEvent:(UIEvent*)event {
    
    
    NSLog(@"PPP");
    [self playOrPause];
//    BOOL res = [_player play];
//    if (!res) {
//        NSLog(@"play failed!");
//    }
    
}



- (void)onAction:(id)sender forEvent:(UIEvent*)event {
    
    
    NSLog(@"AAAACCC");
//    BOOL res = [_player play];
//    if (!res) {
//        NSLog(@"play failed!");
//    }
//    TUPEvaReplaceConfig_ImageOrVideo* vconfig = [[TUPEvaReplaceConfig_ImageOrVideo alloc] init];
//    vconfig.start = 000;
//    vconfig.duration = 2000;
//    //vconfig.repeat = 1;
//    vconfig.crop = CGRectMake(0.4, 0.4, 0.5, 0.5);
//    NSString *repath = [[NSBundle mainBundle] pathForResource:@"kawa2_re" ofType:@"mp4"];
//    
//    [_director updateImage:@"image_15" withPath:repath andConfig:vconfig];
    
    [self playOrPause];


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
            
            CGFloat p = slider.value * [_player getDuration];

            NSLog(@"move to: %f", p);
            [_player previewFrame:(NSInteger)p];

        }
            break;
        case UITouchPhaseEnded:
            // handle drag ended
            NSLog(@"end..");
            _underSeek = NO;
            //[_player play];
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
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_progressView setProgress:p];
        if (!_underSeek)
            [_seekView setValue:p];
    });
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
    //if (!_playing) {
        [_player play];
        _playing = YES;
    //}
}


- (void) pause;
{
    //if (_playing) {
        [_player pause];
        _playing = NO;
    //}
}

@end

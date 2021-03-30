//
//  VideoEditorViewController.m
//  PulseDemoDev
//
//  Created by tutu on 2020/7/9.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "VideoEditorViewController.h"



#import <TuSDKPulse/TUPulseEngine.h>
#import <TuSDKPulse/TUPulseDisplayView.h>

//#import <TuSDKEditor/TUPulseVideoEditor.h>


@interface VideoEditorViewController ()<TUPulsePlayerDelegate> {

    __weak UIProgressView* _progressView;
    __weak TUPulseDisplayView* _displayView;
    __weak UIButton* _playBtn;
    __weak UISlider* _seekView;
    BOOL _underSeek;
    
    __weak UISlider* _adjustView;

    
    //TUPulseVideoEditor* _editor;
    //TUPulseEvaPlayer* _editor;

    
    BOOL _playing;
    
    
    
}

@end

@implementation VideoEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
     _playing = NO;
        
        
        UIProgressView* pv = [[UIProgressView alloc] init];
        pv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:pv];
        [pv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [pv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [pv.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        
        _progressView = pv;
        
        _progressView.progress = 0.0;
        
        
        
        TUPulseDisplayView* displayView = [[TUPulseDisplayView alloc] init];
        displayView.translatesAutoresizingMaskIntoConstraints = NO;
        //displayView.frame = CGRectMake(0, 60, 300, 300);
        [self.view addSubview:displayView];
        
        [displayView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [displayView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [displayView.topAnchor constraintEqualToAnchor:pv.bottomAnchor constant:2].active = YES;
        [displayView.heightAnchor constraintEqualToAnchor:displayView.widthAnchor constant:80].active = YES;
        //[displayView.heightAnchor constraintEqualToConstant:300].active = YES;
        _displayView = displayView;
        
        
        
        UIButton *pb = [UIButton buttonWithType:UIButtonTypeCustom];
        [pb addTarget:self
                   action:@selector(onPlayOrPause:forEvent:)
         forControlEvents:UIControlEventTouchUpInside];
        [pb setTitle:@"PP" forState:UIControlStateNormal];
        pb.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:pb];
        _playBtn = pb;
        pb.backgroundColor = UIColor.brownColor;
       
        
        
        UISlider* sv = [[UISlider alloc] init];
        sv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:sv];
        
        [pb.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [pb.topAnchor constraintEqualToAnchor:_displayView.bottomAnchor].active = YES;
        [pb.widthAnchor constraintEqualToConstant:60].active = YES;
        [pb.heightAnchor constraintEqualToAnchor:pb.widthAnchor].active = YES;

        
        [sv.leadingAnchor constraintEqualToAnchor:_playBtn.trailingAnchor constant:5].active = YES;
        [sv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [sv.topAnchor constraintEqualToAnchor:_displayView.bottomAnchor].active = YES;
        [sv.bottomAnchor constraintEqualToAnchor:_playBtn.bottomAnchor].active = YES;

        
        _seekView = sv;
        
        //sv.continuous = NO;
        [sv addTarget:self action:@selector(onSeekViewValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
        
        sv.minimumValue = 0;
        sv.maximumValue = 1;
        _underSeek = NO;
        
    
    
    {
        
        UISlider* sv = [[UISlider alloc] init];
        sv.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:sv];
        
        [pb.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
        [sv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
        [sv.topAnchor constraintEqualToAnchor:_playBtn.bottomAnchor].active = YES;
        //[sv.bottomAnchor constraintEqualToAnchor:_playBtn.bottomAnchor].active = YES;

//        [pb.topAnchor constraintEqualToAnchor:_playBtn.bottomAnchor].active = YES;
//        [pb.widthAnchor constraintEqualToConstant:60].active = YES;
//        [pb.heightAnchor constraintEqualToAnchor:pb.widthAnchor].active = YES;

        
        //[sv.leadingAnchor constraintEqualToAnchor:_playBtn.trailingAnchor constant:5].active = YES;
        

        
        _adjustView = sv;
        [sv addTarget:self action:@selector(onTestValChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
        
        sv.minimumValue = 0;
        sv.maximumValue = 1;
        
    }
    
    
    
        
        
        
        //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"d" ofType:@"png" inDirectory:@"images"];

        //NSString *imagePath = [[NSBundle mainBundle] URLForResource:@"flow" withExtension:@"png"].absoluteString;
        NSString *imagePath = [[NSBundle mainBundle] URLForResource:@"amazon" withExtension:@"jpg"].absoluteString;
        //NSString *imagePath = [[NSBundle mainBundle] URLForResource:@"grid" withExtension:@"jpeg"].absoluteString;

        NSLog(@"%@", imagePath);
        
        //NSString *path = [[NSBundle mainBundle] pathForResource:@"tr9" ofType:@"MOV"];
    //    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    //    NSString *resource = [bundle pathForResource:@"fileName" ofType:@"fileType"];
        
        //int a = path.length;
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Mojito" ofType:@"mp4"];

        NSURL* url = [[NSBundle mainBundle] URLForResource:@"Mojito" withExtension:@"mp4"];
        
        const char* ppp = url.absoluteString.UTF8String;
        
       

        [_displayView setup:nil];
        
   
    
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
    //[_editor close];
    //_editor = nil;
}







- (void)onPlayOrPause:(id)sender forEvent:(UIEvent*)event {
    
    
    NSLog(@"PPP");
    [self playOrPause];
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
            
//            CGFloat p = slider.value * [_editor getDuration];
//
//            NSLog(@"move to: %f", p);
//            [_editor previewFrame:(NSInteger)p];

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
            NSLog(@"begin..");
            [self pause];
            _underSeek = YES;
            break;
        case UITouchPhaseMoved: {
            // handle drag moved
            
            CGFloat p = slider.value;

            //NSLog(@"move to: %f", p);
         //   [_editor previewFrame:(NSInteger)p];
           // [_editor testProperty:p];
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



- (void)onEvent:(TUPulsePlayerState)state withTimestamp:(NSInteger)ts {
    
    
    if (state == kEOS) {
        
 //       [_editor seekTo:0];
        [self play];
    }
    
    
    
 //   CGFloat p = (CGFloat)ts / [_editor getDuration];
    
    
    
    if (state == kPLAYING) {
    
    dispatch_sync(dispatch_get_main_queue(), ^{
     //   [_progressView setProgress:p];
    //    if (!_underSeek)
   //         [_seekView setValue:p];
    });
    }
}


- (void) playOrPause;
{
    if (_playing) {
 //       [_editor pause];
        _playing = NO;
    } else {
 //       [_editor play];
        _playing = YES;
    }
}

- (void) play;
{
    //if (!_playing) {
  //      [_editor play];
        _playing = YES;
    //}
}


- (void) pause;
{
    //if (_playing) {
   //     [_editor pause];
        _playing = NO;
    //}
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

//
//  ProducerViewController.m
//  PulseDemoDev
//
//  Created by tutu on 2020/6/18.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "ProducerViewController.h"

#import <TuSDKPulse/TUPDisplayView.h>
#import <TuSDKPulse/TUPTranscoder.h>


#import <GPUUtilization/GPUUtilization.h>

@interface ProducerViewController ()<TUPProducerDelegate> {

    __weak UIProgressView* _progressView;
    __weak UIButton* _startBtn;
    __weak UIButton* _cancelBtn;
    //__weak UISlider* _seekView;
    BOOL _underSeek;
    //TUPTranscoder* _producer;
    //TUPEvaProducer* _producer;
//    TUPEvaDirectorProducer* _producer;
//    TUPEvaDirector* _director;

    //BOOL _playing;
    __weak TUPDisplayView* _displayView;

}

@end

@implementation ProducerViewController



- (void)dealloc;
{
 
//    [_producer close];
//    [_director close];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
    
    //  [_displayView setup:nil];
    //[_displayView setup:nil];

    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    NSLog(@"viewDidDisappear");
    [_displayView teardown];
//    _displayView = nil;
//    [_player close];
//    _player = nil;
//
//    [_director close];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIProgressView* pv = [[UIProgressView alloc] init];
    pv.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pv];
    [pv.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [pv.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [pv.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = YES;
    
    _progressView = pv;
    
    _progressView.progress = 0.0;
    
    
    
    UIButton *pb = [UIButton buttonWithType:UIButtonTypeCustom];
    [pb addTarget:self
               action:@selector(onStart:forEvent:)
     forControlEvents:UIControlEventTouchUpInside];
    [pb setTitle:@"Start" forState:UIControlStateNormal];
    pb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:pb];
    _startBtn = pb;
    pb.backgroundColor = UIColor.greenColor;
    
    
    [pb.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10].active = YES;
    [pb.topAnchor constraintEqualToAnchor:_progressView.bottomAnchor constant:10].active = YES;
    //[pb.widthAnchor constraintEqualToConstant:50].active = YES;
    //[pb.heightAnchor constraintEqualToAnchor:pb.widthAnchor].active = YES;

    
    UIButton *cb = [UIButton buttonWithType:UIButtonTypeCustom];
    [cb addTarget:self
               action:@selector(onCancel:forEvent:)
     forControlEvents:UIControlEventTouchUpInside];
    [cb setTitle:@"Cancel" forState:UIControlStateNormal];
    cb.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:cb];
    _cancelBtn = cb;
    cb.backgroundColor = UIColor.redColor;
    
    [cb.leadingAnchor constraintEqualToAnchor:_startBtn.trailingAnchor constant:10].active = YES;
    [cb.topAnchor constraintEqualToAnchor:_progressView.bottomAnchor constant:10].active = YES;
    //[pb.widthAnchor constraintEqualToConstant:50].active = YES;
    //[pb.heightAnchor constraintEqualToAnchor:pb.widthAnchor].active = YES;
    
    
    TUPDisplayView* displayView = [[TUPDisplayView alloc] init];
    displayView.translatesAutoresizingMaskIntoConstraints = NO;
    //displayView.frame = CGRectMake(0, 60, 300, 300);
    [self.view addSubview:displayView];
    
    [displayView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [displayView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [displayView.topAnchor constraintEqualToAnchor:pb.bottomAnchor constant:2].active = YES;
    [displayView.heightAnchor constraintEqualToAnchor:displayView.widthAnchor constant:80].active = YES;
    //[displayView.heightAnchor constraintEqualToConstant:300].active = YES;
    _displayView = displayView;
    
    
    
    
    
    //NSURL* savurl = [[NSBundle mainBundle] URLForResource:@"TR" withExtension:@"MOV"];

    NSURL* savurl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0] URLByAppendingPathComponent:@"eva-out-1.MOV"];
    
    
    NSString* savePath = savurl.absoluteString;

#if 0
    _producer = [[TUPTranscoder alloc]init];
    
    
    
    _producer.savePath = savePath;
    _producer.delegate = self;
    
    TUPProducer_OutputConfig* oconfig = [[TUPProducer_OutputConfig alloc] init];
    //oconfig.width = 800;
    //oconfig.height = 800;
    oconfig.watermarkPosition = 0;
    oconfig.watermark = [UIImage imageNamed: @"flow.png"];
   // oconfig.watermark = [UIImage imageNamed: @"icon.jpg"];

    [_producer setOutputConfig:oconfig];
    
    
    NSString *inpath = [[NSBundle mainBundle] pathForResource:@"c_re" ofType:@"mp4"];

    BOOL ret = [_producer open:inpath];

    
    
#else
    
    _director = [[TUPEvaDirector alloc] init];
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"lmz" ofType:@"eva"];

    TUPEvaModel* model = [[TUPEvaModel alloc] init:modelPath];
    //_producer = [[TUPEvaProducer alloc]init];
    
    BOOL ret = [_director openModel:model];

    
     //BOOL ret = [_producer openModel: model];
        NSString *repath = [[NSBundle mainBundle] pathForResource:@"kawa2_re" ofType:@"mp4"];

        TUPEvaReplaceConfig_ImageOrVideo* reconfig = [[TUPEvaReplaceConfig_ImageOrVideo alloc] init];
        //reconfig.crop
    //    vconfig.start = 1000;
    //    vconfig.duration = 3000;
        //NSAssert(ret);
      // [_director updateImage:@"image_14" withPath:repath andConfig:reconfig];
    
    _producer = [_director newProducer];
    
    
    _producer.savePath = savePath;
    _producer.delegate = self;
    
   
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"d" ofType:@"mp4"];
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"hecc3/data" ofType:@"json"];

    
    
    TUPProducer_OutputConfig* oconfig = [[TUPProducer_OutputConfig alloc] init];
//    oconfig.width = 800;
//    oconfig.height = 800;
//    oconfig.watermarkPosition = 0;
    oconfig.watermark = [UIImage imageNamed: @"flow.png"];
    oconfig.scale = 0.5;
    [_producer setOutputConfig:oconfig];
    

    
    ret = [_producer open];

      
    
//    [_producer setRange:10000 andDuration:10000];
//    [_producer setOutputSize:CGSizeMake(-400, 900)];
#endif
    
    //NSURL* logourl = [[NSBundle mainBundle] URLForResource:@"flow" withExtension:@"png"];

   
    {
        
        
        //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UILabel * gpuLabel = [[UILabel alloc] init];
            gpuLabel.backgroundColor = [UIColor whiteColor];
            gpuLabel.font = [UIFont fontWithName:@"Courier" size:14];
            gpuLabel.text = @"GPU:  0%  ";
            gpuLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
            [gpuLabel sizeToFit];
            
            CGRect rect = gpuLabel.frame;
            rect.origin.x = 10.f;
            rect.origin.y = 200;//application.statusBarFrame.size.height;
            gpuLabel.frame = rect;
            [self.view addSubview:gpuLabel];
            
            NSTimer *timer = [NSTimer timerWithTimeInterval:0.5
                                                    repeats:YES
                                                      block:^(NSTimer * timer) {
                                                          [GPUUtilization fetchCurrentUtilization:^(GPUUtilization *current) {
                                                              gpuLabel.text = [NSString stringWithFormat:@"GPU: %2zd%%", current.deviceUtilization];
                                                          }];
                                                      }];
            [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        //});
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







- (void)onStart:(id)sender forEvent:(UIEvent*)event {
    
    
    NSLog(@"Start Produce...");
    //[self playOrPause];
//    BOOL res = [_player play];
//    if (!res) {
//        NSLog(@"play failed!");
//    }
    
    [_producer start];
    
}

- (void)onCancel:(id)sender forEvent:(UIEvent*)event {
    
    
    NSLog(@"Cancel Produce...");
    //[self playOrPause];
//    BOOL res = [_player play];
//    if (!res) {
//        NSLog(@"play failed!");
//    }
    
    [_producer cancel];
    
}





- (void)onProducerEvent:(TUPProducerState)state withTimestamp:(NSInteger)ts {
    
    NSLog(@" ---- %ld : %ld", state, (long)ts);
    
    if (state == kWRITING) {
    
        CGFloat p = (CGFloat)ts / [_producer getDuration];
         
        dispatch_async(dispatch_get_main_queue(), ^{
           [_progressView setProgress:p];
           
       });
    }
}


@end

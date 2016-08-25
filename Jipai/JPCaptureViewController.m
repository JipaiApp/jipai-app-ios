//
//  JPCaptureViewController.m
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "JPCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "JPShareViewController.h"
#import "UIImage+Color.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JPApiManager+Stream.h"
#import "JPQRViewController.h"
#import <PLCameraStreamingKit/PLCameraStreamingKit.h>


@interface JPCaptureViewController ()
<
PLCameraStreamingSessionDelegate,
PLStreamingSendingBufferDelegate
>

@property (nonatomic, strong) JPShareViewController *shareViewController;
@property (nonatomic, strong) JPQRViewController    *qrViewController;

@property (nonatomic, strong) UIView    *coverView;
@property (nonatomic, assign, getter=isCreatingStream) BOOL creatingStream;
@property (nonatomic, strong) UIBarButtonItem   *fpsItem;
@property (nonatomic, strong) UILabel   *fpsLabel;
@property (nonatomic, strong) UIBarButtonItem   *bpsInfoItem;
@property (nonatomic, strong) UILabel   *bpsInfoLabel;
@property (nonatomic, strong) UIView    *dotView;
@property (nonatomic, strong) UILabel   *resolutionLabel;

@property (nonatomic, strong) CALayer   *goLiveCenterLayer;

@property (nonatomic, strong) AVAudioPlayer *startAudioPlayer;
@property (nonatomic, strong) AVAudioPlayer *endAudioPlayer;

@property (nonatomic, strong) PLCameraStreamingSession  *session;
@property (nonatomic, strong) NSDictionary  *urls;
@property (nonatomic, assign) BOOL  needRestoreLive;

@property (nonatomic, strong) NSMutableDictionary   *animateLayerMap;
@property (nonatomic, assign) BOOL  isGoLiveButtonAnimating;
@property (nonatomic, strong) NSTimer   *animateTimer;
@property (nonatomic, strong) NSString  *videoQuality;

@end

@implementation JPCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.needRestoreLive = NO;
    self.isGoLiveButtonAnimating = NO;
    self.animateLayerMap = [@{} mutableCopy];
    
    CGRect goLiveButtonBounds = self.goLiveButton.bounds;
    CALayer *borderLayer = [CALayer layer];
    borderLayer.frame = goLiveButtonBounds;
    borderLayer.cornerRadius = CGRectGetMidX(goLiveButtonBounds);
    borderLayer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    borderLayer.borderWidth = 4;
    borderLayer.masksToBounds = YES;
    [self.goLiveButton.layer addSublayer:borderLayer];
    
    self.goLiveCenterLayer = [CALayer layer];
    self.goLiveCenterLayer.backgroundColor = [UIColor redColor].CGColor;
    self.goLiveCenterLayer.frame = CGRectInset(goLiveButtonBounds, 6, 6);
    self.goLiveCenterLayer.anchorPoint = (CGPoint){.5f, .5f};
    self.goLiveCenterLayer.position = (CGPoint){CGRectGetMidX(goLiveButtonBounds), CGRectGetMidY(goLiveButtonBounds)};
    self.goLiveCenterLayer.cornerRadius = CGRectGetMidX(self.goLiveCenterLayer.bounds);
    self.goLiveCenterLayer.masksToBounds = YES;
    [borderLayer addSublayer:self.goLiveCenterLayer];
    
    CGRect bounds = self.view.bounds;
    if (CGRectGetWidth(bounds) < CGRectGetHeight(bounds)) {
        bounds.size = (CGSize){CGRectGetHeight(bounds), CGRectGetWidth(bounds)};
    }
    self.previewView.frame = bounds;
    
    NSURL *startURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"begin_video_record" ofType:@"caf"]];
    self.startAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:startURL error:nil];
    self.startAudioPlayer.volume = 1.0f;
    [self.startAudioPlayer prepareToPlay];
    
    NSURL *endURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"end_video_record" ofType:@"caf"]];
    self.endAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:endURL error:nil];
    self.endAudioPlayer.volume = 1.0f;
    [self.endAudioPlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notif) {
                                                      if (PLStreamStateConnected == self.session.streamState ||
                                                          PLStreamStateConnecting == self.session.streamState) {
                                                          self.needRestoreLive = YES;
                                                      } else {
                                                          self.needRestoreLive = NO;
                                                      }
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *notif) {
                                                      if (self.needRestoreLive) {
                                                          [self goLiveButtonPressed:self.goLiveButton];
                                                      }
                                                  }];
    
    self.creatingStream = NO;
    
    [self initSession];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.2]]
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    // navigation bar button items
    
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                               target:self
                                                                               action:@selector(shareButtonPressed:)];
    UIBarButtonItem *qrItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_qr.png"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(qrButtonPressed:)];
    self.navigationItem.leftBarButtonItems = @[shareItem, qrItem];
    
    UIView *dotView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, {30, 30}}];
    dotView.backgroundColor = [UIColor clearColor];
    UIView *dot = [[UIView alloc] initWithFrame:(CGRect){{20, 10}, {10, 10}}];
    dot.layer.cornerRadius = 5;
    dot.layer.masksToBounds = YES;
    dot.backgroundColor = [UIColor redColor];
    
    [dotView addSubview:dot];
    UIBarButtonItem *dotItem = [[UIBarButtonItem alloc] initWithCustomView:dotView];
    self.dotView = dotView;
    dotView.hidden = YES;
    
    UIView *fpsView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, {50, 30}}];
    fpsView.backgroundColor = [UIColor clearColor];
    
    UILabel *fpsLabel = [[UILabel alloc] initWithFrame:fpsView.bounds];
    fpsLabel.backgroundColor = [UIColor clearColor];
    fpsLabel.textColor = [UIColor lightTextColor];
    fpsLabel.textAlignment = NSTextAlignmentRight;
    fpsLabel.text = @"0 fps";
    [fpsView addSubview:fpsLabel];
    self.fpsLabel = fpsLabel;
    UIBarButtonItem *fpsItem = [[UIBarButtonItem alloc] initWithCustomView:fpsView];
    
    UIView *bpsInfoView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, {80, 30}}];
    bpsInfoView.backgroundColor = [UIColor clearColor];
    
    UILabel *bpsInfoLabel = [[UILabel alloc] initWithFrame:bpsInfoView.bounds];
    bpsInfoLabel.backgroundColor = [UIColor clearColor];
    bpsInfoLabel.textColor = [UIColor lightTextColor];
    bpsInfoLabel.textAlignment = NSTextAlignmentRight;
    bpsInfoLabel.text = @"1 M bps";
    [bpsInfoView addSubview:bpsInfoLabel];
    self.bpsInfoLabel = bpsInfoLabel;
    UIBarButtonItem *bpsInfoItem = [[UIBarButtonItem alloc] initWithCustomView:bpsInfoView];
    
    self.navigationItem.rightBarButtonItems = @[bpsInfoItem, fpsItem, dotItem];
    self.bpsInfoItem = bpsInfoItem;
}

- (void)initSession {
    void (^permissionBlock)(void) = ^{
        // 视频编码配置
        PLVideoStreamingConfiguration *videoConfiguration = [PLVideoStreamingConfiguration configurationWithVideoSize:self.view.bounds.size
                                                                                                         videoQuality:kPLVideoStreamingQualityMedium3];
    
        // 音频编码配置
        PLAudioStreamingConfiguration *audioConfiguration = [PLAudioStreamingConfiguration defaultConfiguration];
        
        // 推流 session
        self.session = [[PLCameraStreamingSession alloc] initWithVideoCaptureConfiguration:[PLVideoCaptureConfiguration defaultConfiguration]
                                                                 audioCaptureConfiguration:[PLAudioCaptureConfiguration defaultConfiguration]
                                                               videoStreamingConfiguration:videoConfiguration
                                                               audioStreamingConfiguration:audioConfiguration
                                                                                    stream:nil
                                                                          videoOrientation:AVCaptureVideoOrientationLandscapeRight];
        self.session.delegate = self;
        self.session.bufferDelegate = self;
        
        [self.view insertSubview:self.session.previewView atIndex:1];
        
        self.session.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        
        if (![self isStreamExist]) {
            [self getStreamWithCompletion:^(BOOL isSuccessful, PLStream *stream, NSError *error) {
                if (isSuccessful) {
                    self.session.stream = stream;
                    
                    [self getUrlsWithCompletion:^(BOOL isSuccessfull, NSDictionary *urls, NSError *error) {
                        if (isSuccessful) {
                            self.urls = urls;
                        }
                    }];
                }
            }];
        }
    };
    
    void (^noAccessBlock)(void) = ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Access", nil)
                                                            message:NSLocalizedString(@"!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    };
    
    switch ([PLCameraStreamingSession cameraAuthorizationStatus]) {
        case PLAuthorizationStatusAuthorized:
            permissionBlock();
            break;
        case PLAuthorizationStatusNotDetermined: {
            [PLCameraStreamingSession requestCameraAccessWithCompletionHandler:^(BOOL granted) {
                // 回调确保在主线程，可以安全对 UI 做操作
                granted ? permissionBlock() : noAccessBlock();
            }];
        }
            break;
        default:
            noAccessBlock();
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.bounds;
    if (CGRectGetWidth(bounds) < CGRectGetHeight(bounds)) {
        bounds.size = (CGSize){CGRectGetHeight(bounds), CGRectGetWidth(bounds)};
    }
    
    [self.toolbar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:0.2]]
                                       forToolbarPosition:UIBarPositionAny
                                               barMetrics:UIBarMetricsDefault];
    [self.toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.x = 0;
    toolbarFrame.origin.y = CGRectGetHeight(bounds) - CGRectGetHeight(toolbarFrame);
    toolbarFrame.size.width = CGRectGetWidth(bounds);
    self.toolbar.frame = toolbarFrame;
    
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight]
                                forKey:@"orientation"];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - <PLCameraStreamingSessionDelegate>

- (void)cameraStreamingSession:(PLCameraStreamingSession *)session streamStateDidChange:(PLStreamState)state {
    switch (state) {
        case PLStreamStateError: {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"rtmp 流链接失败，请确保网络环境良好再重新尝试"
                                                               delegate:nil
                                                      cancelButtonTitle:@"我知道了"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        case PLStreamStateDisconnected: {
            [self.endAudioPlayer play];
            
            UIView *juhua = [self.goLiveButton viewWithTag:1024];
            juhua.hidden = YES;
            [juhua removeFromSuperview];
            
            [self.dotView.layer removeAllAnimations];
            self.dotView.hidden = YES;
            
            CGRect bounds = self.goLiveCenterLayer.bounds;
            CGFloat newCornerRadius = CGRectGetMidX(bounds);
            
            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            animation1.fromValue = @(self.goLiveCenterLayer.cornerRadius);
            animation1.toValue = @(newCornerRadius);
            animation1.duration = 0.2f;
            animation1.fillMode = kCAFillModeForwards;
            animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            CATransform3D newTransform = CATransform3DIdentity;
            CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation2.fromValue = [NSValue valueWithCATransform3D:self.goLiveCenterLayer.transform];
            animation2.toValue = [NSValue valueWithCATransform3D:newTransform];
            animation2.duration = 0.2f;
            animation2.fillMode = kCAFillModeForwards;
            animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = @[animation1, animation2];
            
            [self.goLiveCenterLayer addAnimation:group forKey:nil];
            self.goLiveCenterLayer.cornerRadius = newCornerRadius;
            self.goLiveCenterLayer.transform = newTransform;
            
            self.fpsLabel.text = @"0 fps";
            self.fpsLabel.textColor = [UIColor lightTextColor];
            self.bpsInfoLabel.textColor = [UIColor lightTextColor];
            
            self.goLiveButton.enabled = YES;
        }
            break;
        case PLStreamStateConnecting: {
        }
            break;
        case PLStreamStateConnected: {
            [self.startAudioPlayer play];
            
            UIView *juhua = [self.goLiveButton viewWithTag:1024];
            juhua.hidden = YES;
            [juhua removeFromSuperview];
            
            self.dotView.hidden = NO;
            [self.dotView.layer removeAllAnimations];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"hidden"];
            animation.fromValue = @(NO);
            animation.toValue = @(YES);
            animation.duration = 0.6f;
            animation.fillMode = kCAFillModeForwards;
            animation.repeatCount = INFINITY;
            animation.autoreverses = YES;
            [self.dotView.layer addAnimation:animation forKey:nil];
            
            self.fpsLabel.text = @"30 fps";
            self.fpsLabel.textColor = [UIColor whiteColor];
            self.bpsInfoLabel.textColor = [UIColor whiteColor];
            
            CGFloat newCornerRadius = 4;
            
            CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
            animation1.fromValue = @(self.goLiveCenterLayer.cornerRadius);
            animation1.toValue = @(newCornerRadius);
            animation1.duration = 0.2f;
            animation1.fillMode = kCAFillModeForwards;
            animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            CGFloat scaleFactor = 0.6;
            CATransform3D newTransform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0);
            CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform"];
            animation2.fromValue = [NSValue valueWithCATransform3D:self.goLiveCenterLayer.transform];
            animation2.toValue = [NSValue valueWithCATransform3D:newTransform];
            animation2.duration = 0.2f;
            animation2.fillMode = kCAFillModeForwards;
            animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = @[animation1, animation2];
            
            [self.goLiveCenterLayer addAnimation:group forKey:nil];
            self.goLiveCenterLayer.cornerRadius = newCornerRadius;
            self.goLiveCenterLayer.transform = newTransform;
            
            self.goLiveButton.enabled = YES;
        }
            break;
        default: {
        }
            break;
    }
}

#pragma mark -

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CALayer *layer = [self.animateLayerMap objectForKey:anim];
    [layer removeFromSuperlayer];
}

- (void)runloop:(NSTimer *)timer {
    if (!self.isGoLiveButtonAnimating) {
        [self.animateTimer invalidate];
        self.animateTimer = nil;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CALayer *animationLayer = [CALayer layer];
        animationLayer.frame = self.goLiveButton.bounds;
        animationLayer.cornerRadius = CGRectGetMidX(self.goLiveButton.bounds);
        animationLayer.borderWidth = 3;
        animationLayer.borderColor = [UIColor whiteColor].CGColor;
        
        CATransform3D newTransform = CATransform3DMakeScale(1.5, 1.5, 1.0);
        CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform"];
        animation1.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        animation1.toValue = [NSValue valueWithCATransform3D:newTransform];
        animation1.fillMode = kCAFillModeForwards;
        animation1.removedOnCompletion = NO;
        
        float newOpacity = 0;
        CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation2.fromValue = @(1);
        animation2.toValue = @(newOpacity);
        animation2.fillMode = kCAFillModeForwards;
        animation2.removedOnCompletion = NO;
        animation2.delegate = self;
        [self.animateLayerMap setObject:animationLayer forKey:animation2];
        
        [self.goLiveButton.layer addSublayer:animationLayer];
        
        CAAnimationGroup *animateGroup = [CAAnimationGroup animation];
        animateGroup.duration = 1;
        animateGroup.animations = @[animation1, animation2];
        
        [animationLayer addAnimation:animateGroup forKey:nil];
        animationLayer.transform = newTransform;
        animationLayer.opacity = newOpacity;
    });
}

- (void)addLoadingCover {
    [self removeLoadingCoverAnimated:NO];
    
    self.goLiveCenterLayer.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6].CGColor;
    
    self.isGoLiveButtonAnimating = YES;
    [self runloop:nil];
    self.animateTimer = [NSTimer scheduledTimerWithTimeInterval:1.3
                                                         target:self
                                                       selector:@selector(runloop:)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)removeLoadingCoverAnimated:(BOOL)animated {
    self.isGoLiveButtonAnimating = NO;
    self.goLiveCenterLayer.backgroundColor = [UIColor redColor].CGColor;
}

- (BOOL)isStreamExist {
    return !!self.session.stream;
}

- (void)getStreamWithCompletion:(void (^)(BOOL isSuccessful, PLStream *stream, NSError *error))handler {
    self.creatingStream = YES;
    [self addLoadingCover];
    
    [[JPApiManager sharedManager] createStreamWithSuccess:^(id responseData) {
        self.creatingStream = NO;
        [self removeLoadingCoverAnimated:YES];
        
        if (handler) {
            handler(YES, responseData, nil);
        }
    } failure:^(NSError *error) {
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

- (void)getUrlsWithCompletion:(void (^)(BOOL isSuccessful, NSDictionary *urls, NSError *error))handler {
    [[JPApiManager sharedManager] getStreamPlayUrlsWithStreamID:self.session.stream.streamID success:^(id responseData) {
        if (handler) {
            handler(YES, responseData, nil);
        }
    } failure:^(NSError *error) {
        if (handler) {
            handler(NO, nil, error);
        }
    }];
}

#pragma mark - Property

- (JPShareViewController *)shareViewController {
    if (!_shareViewController) {
        _shareViewController = [[JPShareViewController alloc] init];
    }
    
    return _shareViewController;
}

- (JPQRViewController *)qrViewController {
    if (!_qrViewController) {
        _qrViewController = [[JPQRViewController alloc] init];
    }
    
    return _qrViewController;
}

- (void)tryToConnect {
    switch(self.session.streamState) {
        case PLStreamStateUnknow:
        case PLStreamStateDisconnected:
        case PLStreamStateError: {
            CGRect buttonBounds = self.goLiveButton.bounds;
            UIActivityIndicatorView *juhua = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            juhua.center = (CGPoint){CGRectGetMidX(buttonBounds), CGRectGetMidY(buttonBounds)};
            juhua.tag = 1024;
            juhua.hidesWhenStopped = YES;
            [self.goLiveButton addSubview:juhua];
            [juhua startAnimating];
            
            [self.session startWithCompleted:^(BOOL success) {
                NSLog(@"start: %d", success);
            }];
        }
            break;
        default: {
            [self.session stop];
        }
            break;
    }
}

- (void)setVideoQuality:(NSString *)videoQuality {
    if ([_videoQuality isEqualToString:videoQuality]) {
        return;
    }
    
    _videoQuality = videoQuality;
    // TODO: 貌似新版本 SDK 已经移除了该接口，先注释掉
//    if (self.session.isRunning) {
//        [self.session beginUpdateConfiguration];
//        self.session.videoConfiguration.videoQuality = videoQuality;
//        [self.session endUpdateConfiguration];
//    } else {
//        self.session.videoConfiguration.videoQuality = videoQuality;
//    }
}

#pragma mark - Action

- (IBAction)goLiveButtonPressed:(id)sender {
    self.goLiveButton.enabled = NO;
    
    if (PLStreamStateConnecting == self.session.streamState ||
        PLStreamStateConnected == self.session.streamState) {
        [self.session stop];
    } else {
        void (^action)(void) = ^{
            [self tryToConnect];
        };
        
        void (^failure)(NSError *error) = ^(NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops"
                                                                message:error.localizedDescription
                                                               delegate:nil
                                                      cancelButtonTitle:@"好吧"
                                                      otherButtonTitles:nil];
            [alertView show];
        };
        
        if (![self isStreamExist]) {
            [self getStreamWithCompletion:^(BOOL isSuccessful, PLStream *stream, NSError *error) {
                if (isSuccessful) {
                    self.session.stream = stream;
                    action();
                } else {
                    failure(error);
                }
            }];
        } else {
            action();
        }
    }
}

- (void)qrButtonPressed:(id)sender {
    [self.qrViewController presentFromViewController:self.navigationController withStream:self.session.stream];
}

- (void)shareButtonPressed:(id)sender {
    [self.shareViewController presentFromViewController:self.navigationController withURLS:self.urls];
}

- (IBAction)lightButtonPressed:(id)sender {
    static BOOL isLightOn = NO;
    
    NSString *imageName = nil;
    if (isLightOn) {
        imageName = @"btn_lignt_off.png";
        self.session.torchOn = NO;
    } else {
        imageName = @"btn_lignt_on.png";
        self.session.torchOn = YES;
    }
    isLightOn = !isLightOn;
    
    self.lightItem.image = [UIImage imageNamed:imageName];
}

- (IBAction)switchButtonPressed:(id)sender {
    [self.session toggleCamera];
}

- (IBAction)bpsButtonPressed:(id)sender {
    NSString *newVideoQuality = kPLVideoStreamingQualityMedium3;
    if ([kPLVideoStreamingQualityLow1 isEqualToString:self.videoQuality]) {
        self.bpsItem.image = [UIImage imageNamed:@"bps_high.png"];
        self.bpsInfoLabel.text = @"1 M bps";
    } else if ([kPLVideoStreamingQualityMedium1 isEqualToString:self.videoQuality]) {
        self.bpsItem.image = [UIImage imageNamed:@"bps_low.png"];
        self.bpsInfoLabel.text = @"150 K bps";
        newVideoQuality = kPLVideoStreamingQualityLow1;
    } else {
        self.bpsItem.image = [UIImage imageNamed:@"bps_medium.png"];
        self.bpsInfoLabel.text = @"500 K bps";
        newVideoQuality = kPLVideoStreamingQualityMedium1;
    }
    
    self.videoQuality = newVideoQuality;
}

@end

//
//  JPQRViewController.m
//  Jipai
//
//  Created on 14/12/9.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "JPQRViewController.h"
#import "AppDelegate.h"
#import "UIImage+QRCode.h"

#define kQRCodeSize (CGSize){120, 120}
#define kLabelSize  (CGSize){200, 30}

@interface JPQRViewController ()

@property (nonatomic, strong) UIImageView   *streamIDImageView;
@property (nonatomic, strong) UIImageView   *htmlImageView;
@property (nonatomic, strong) UILabel       *streamIDLabel;
@property (nonatomic, strong) UILabel       *htmlLabel;

@end

@implementation JPQRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    [self dismiss];
}

- (void)initQCViews {
    CGRect bounds = self.view.bounds;
    CGPoint center = CGPointZero;
    
    if (!_streamIDImageView) {
        self.streamIDImageView = [[UIImageView alloc] initWithFrame:(CGRect){{0, 0}, kQRCodeSize}];
        [self.view addSubview:self.streamIDImageView];
    }
    center = (CGPoint){CGRectGetWidth(bounds) * 0.5, CGRectGetHeight(bounds) * 0.5};
    self.streamIDImageView.center = center;
    
//    if (!_htmlImageView) {
//        self.htmlImageView = [[UIImageView alloc] initWithFrame:(CGRect){{0, 0}, kQRCodeSize}];
//        [self.view addSubview:self.htmlImageView];
//    }
//    center = (CGPoint){CGRectGetWidth(bounds) * 0.7, CGRectGetHeight(bounds) * 0.5};
//    self.htmlImageView.center = center;
    
    if (!_streamIDLabel) {
        self.streamIDLabel = [[UILabel alloc] initWithFrame:(CGRect){{0, 0}, kLabelSize}];
        self.streamIDLabel.backgroundColor = [UIColor clearColor];
        self.streamIDLabel.textColor = [UIColor whiteColor];
        self.streamIDLabel.shadowColor = [UIColor darkTextColor];
        self.streamIDLabel.shadowOffset = (CGSize){0, 0.5};
        self.streamIDLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.streamIDLabel];
    }
    center = (CGPoint){CGRectGetWidth(bounds) * 0.5, CGRectGetHeight(bounds) * 0.5 + kQRCodeSize.height * 0.7};
    self.streamIDLabel.center = center;
    
//    if (!_htmlLabel) {
//        self.htmlLabel = [[UILabel alloc] initWithFrame:(CGRect){{0, 0}, kLabelSize}];
//        self.htmlLabel.backgroundColor = [UIColor clearColor];
//        self.htmlLabel.textColor = [UIColor whiteColor];
//        self.htmlLabel.shadowColor = [UIColor darkTextColor];
//        self.htmlLabel.shadowOffset = (CGSize){0, 0.5};
//        self.htmlLabel.textAlignment = NSTextAlignmentCenter;
//        [self.view addSubview:self.htmlLabel];
//    }
//    center = (CGPoint){CGRectGetWidth(bounds) * 0.7, CGRectGetHeight(bounds) * 0.5 + kQRCodeSize.height * 0.7};
//    self.htmlLabel.center = center;
}

- (void)presentFromViewController:(UIViewController *)vc withStream:(PLStream *)stream {
    self.fromViewController = vc;
    self.stream = stream;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect blurFrame;
    CGSize size;
    if (CGRectGetWidth(frame) > CGRectGetHeight(frame)) {
        blurFrame.size = (CGSize){CGRectGetWidth(frame) * 0.8, 80};
        size = (CGSize){CGRectGetWidth(frame), CGRectGetHeight(frame)};
    } else {
        blurFrame.size = (CGSize){CGRectGetHeight(frame) * 0.8, 80};
        size = (CGSize){CGRectGetHeight(frame), CGRectGetWidth(frame)};
    }
    frame.size = size;
    
    self.view.frame = frame;
    
    [self initQCViews];
    
#warning 替换为 web 页面的 url
//    NSArray *coms = [stream.rtmpLiveURL.absoluteString componentsSeparatedByString:@"/"];
//    NSString *streamID = nil;
//    if (coms.count > 0) {
//        streamID = [coms lastObject];
//        UIImage *streamIDImage = [UIImage QRImageWithString:[NSString stringWithFormat:@"id:%@", streamID]];
//        self.streamIDImageView.image = streamIDImage;
//        self.streamIDLabel.text = @"流 ID";
//    }
//    
//    NSString *html = stream.playHtmlURL.absoluteString;
//    if (html) {
//        UIImage *htmlImage = [UIImage QRImageWithString:html];
//        self.htmlImageView.image = htmlImage;
//        self.htmlLabel.text = @"网页播放地址";
//    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController.view addSubview:self.view];
}

- (void)dismiss {
    [self.view removeFromSuperview];
}

@end

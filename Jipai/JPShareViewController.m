//
//  JPShareViewController.m
//  Jipai
//
//  Created on 14/11/5.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "JPShareViewController.h"
#import "AppDelegate.h"
#import "UIImage+View.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import <MessageUI/MessageUI.h>

@interface JPShareViewController ()
<
MFMailComposeViewControllerDelegate,
MFMessageComposeViewControllerDelegate
>

@property (nonatomic, strong) UIView    *blurView;
@property (nonatomic, strong) NSMutableArray    *buttons;
@property (nonatomic, strong) UILabel   *versionLabel;

@end

@implementation JPShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    CGSize size;
    if (CGRectGetWidth(frame) > CGRectGetHeight(frame)) {
        size = (CGSize){CGRectGetWidth(frame), CGRectGetHeight(frame)};
    } else {
        size = (CGSize){CGRectGetHeight(frame), CGRectGetWidth(frame)};
    }
    frame.size = size;
    
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
    self.versionLabel = [[UILabel alloc] initWithFrame:(CGRect){{0, CGRectGetHeight(frame) * 0.65}, {frame.size.width, 30}}];
    self.versionLabel.backgroundColor = [UIColor clearColor];
    self.versionLabel.textColor = [UIColor lightTextColor];
    self.versionLabel.textAlignment = NSTextAlignmentCenter;
    self.versionLabel.text = [NSString stringWithFormat:@"Version: %@", versionString];
    self.versionLabel.alpha = 0.0f;
    [self.view addSubview:self.versionLabel];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGRect frame = [UIScreen mainScreen].bounds;
    CGSize size;
    if (CGRectGetWidth(frame) > CGRectGetHeight(frame)) {
        size = (CGSize){CGRectGetWidth(frame) * 0.8, 80};
    } else {
        size = (CGSize){CGRectGetHeight(frame) * 0.8, 80};
    }
    frame.size = size;
    self.blurView.frame = frame;
    self.blurView.center = self.view.center;
    
    [self updateButtons];
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    [self dismiss];
}

- (void)updateButtons {
    CGRect bounds = self.fromViewController.view.bounds;
    CGFloat x = 0, y = 0, xFactor, yFactor;
    switch (self.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            x = CGRectGetWidth(bounds) * 0.2;
            y = CGRectGetMidY(bounds);
            xFactor = 1;
            yFactor = 0;
        }
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            x = CGRectGetMidX(bounds);
            y = CGRectGetHeight(bounds) * 0.2;
            xFactor = 0;
            yFactor = 1;
        }
            break;
        default:
            break;
    }
    
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        CGFloat xx = xFactor * idx * x + x;
        CGFloat yy = yFactor * idx * y + y;
        button.center = (CGPoint){xx, yy};
    }];
}

- (void)showButtons {
    self.buttons = [@[] mutableCopy];
    
    CGRect frame = (CGRect){{0, 0}, {60, 60}};
    
    UIButton *wxFriends = [UIButton buttonWithType:UIButtonTypeCustom];
    wxFriends.frame = frame;
    [wxFriends setImage:[UIImage imageNamed:@"share_wechat.png"] forState:UIControlStateNormal];
    [wxFriends addTarget:self action:@selector(wx:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wxFriends];
    [self.buttons addObject:wxFriends];
    
    UIButton *wxCircle = [UIButton buttonWithType:UIButtonTypeCustom];
    wxCircle.frame = frame;
    [wxCircle setImage:[UIImage imageNamed:@"share_circle.png"] forState:UIControlStateNormal];
    [wxCircle addTarget:self action:@selector(cicle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:wxCircle];
    [self.buttons addObject:wxCircle];
    
    UIButton *email = [UIButton buttonWithType:UIButtonTypeCustom];
    email.frame = frame;
    [email setImage:[UIImage imageNamed:@"share_mail.png"] forState:UIControlStateNormal];
    [email addTarget:self action:@selector(email:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:email];
    [self.buttons addObject:email];

    UIButton *sms = [UIButton buttonWithType:UIButtonTypeCustom];
    sms.frame = frame;
    [sms setImage:[UIImage imageNamed:@"share_message.png"] forState:UIControlStateNormal];
    [sms addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sms];
    [self.buttons addObject:sms];
    
    [self updateButtons];
}

- (void)shareToWxScene:(int)scene {
    NSString *url = self.urls[@"hls"];
    WXWebpageObject *localWXWebpageObject = [WXWebpageObject object];
    localWXWebpageObject.webpageUrl = url;
    WXMediaMessage *localWXMediaMessage =  [WXMediaMessage message];
    
    localWXMediaMessage.mediaObject = localWXWebpageObject;
    localWXMediaMessage.title = @"我在直播";
    localWXMediaMessage.description = @"来自极拍－随时随地拍直播";
    localWXMediaMessage.thumbData = UIImagePNGRepresentation([UIImage imageNamed:@"icon.png"]);
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.message = localWXMediaMessage;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

- (void)wx:(id)sender {
    [self shareToWxScene:WXSceneSession];
}

- (void)cicle:(id)sender {
    [self shareToWxScene:WXSceneTimeline];
}

- (void)email:(id)sender {
    [self displayEmail];
}

- (void)sms:(id)sender {
    [self displaySms];
}

#pragma mark -

- (void)displayEmail {
    if (![MFMailComposeViewController canSendMail]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"请检查您的邮件配置"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"极拍直播"];
    
    // Attach an image to the email.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"icon"
                                                     ofType:@"png"];
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [picker addAttachmentData:myData mimeType:@"image/png"
                     fileName:@"icon"];
    
    // Fill out the email body text.
    NSString *url = self.urls[@"hls"];
    NSString *emailBody = [NSString stringWithFormat:@"我正在我的手机上使用极拍进行直播，快来看啊!\n直播地址: %@", url];
    [picker setMessageBody:emailBody isHTML:NO];
    
    // Present the mail composition interface.
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)displaySms {
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"请检查您的 Message 配置"
                                                           delegate:nil
                                                  cancelButtonTitle:@"好的" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    
    NSString *url = self.urls[@"hls"];
    NSString *body = [NSString stringWithFormat:@"我正在我的手机上使用极拍进行直播，快来看啊!\n直播地址: %@", url];
    picker.body = body;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)presentFromViewController:(UIViewController *)vc withURLS:(NSDictionary *)urls {
    self.fromViewController = vc;
    self.urls = urls;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect blurFrame;
    CGSize size;
    if (CGRectGetWidth(frame) > CGRectGetHeight(frame)) {
        blurFrame.size = (CGSize){CGRectGetWidth(frame) * 0.8, 80};
        size = (CGSize){CGRectGetWidth(frame), CGRectGetWidth(frame)};
    } else {
        blurFrame.size = (CGSize){CGRectGetHeight(frame) * 0.8, 80};
        size = (CGSize){CGRectGetHeight(frame), CGRectGetHeight(frame)};
    }
    frame.size = size;
    
    self.view.frame = frame;
    self.blurView = [[UIView alloc] initWithFrame:blurFrame];
    self.blurView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    self.blurView.layer.cornerRadius = 40;
    self.blurView.layer.masksToBounds = YES;
    self.blurView.center = (CGPoint){CGRectGetMidX(frame), CGRectGetMidY(vc.view.bounds)};
    [self.view addSubview:self.blurView];
    self.blurView.alpha = 0.0;
    self.blurView.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController.view addSubview:self.view];
    [self showButtons];
    
    [UIView animateWithDuration:0.233f animations:^{
        self.blurView.alpha = 1.0f;
        self.versionLabel.alpha = 1.0f;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.233f animations:^{
        self.blurView.alpha = 0.0f;
        self.versionLabel.alpha = 0.0f;
        [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            button.alpha = 0;
        }];
    } completion:^(BOOL finished) {
        [self.blurView removeFromSuperview];
        self.blurView = nil;
        [self.view removeFromSuperview];
        [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.buttons = nil;
    }];
}

@end

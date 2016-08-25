//
//  JPCaptureViewController.h
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface JPCaptureViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *goLiveButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *lightItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bpsItem;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *soundItem;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

- (IBAction)goLiveButtonPressed:(id)sender;
- (IBAction)lightButtonPressed:(id)sender;
- (IBAction)switchButtonPressed:(id)sender;
- (IBAction)bpsButtonPressed:(id)sender;

@end

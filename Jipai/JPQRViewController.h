//
//  JPQRViewController.h
//  Jipai
//
//  Created on 14/12/9.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLStream;
@interface JPQRViewController : UIViewController

@property (nonatomic, weak) UIViewController    *fromViewController;
@property (nonatomic, weak) PLStream          *stream;

- (void)presentFromViewController:(UIViewController *)vc withStream:(PLStream *)stream;
- (void)dismiss;

@end

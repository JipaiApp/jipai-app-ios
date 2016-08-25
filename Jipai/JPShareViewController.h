//
//  JPShareViewController.h
//  Jipai
//
//  Created on 14/11/5.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PLStream;
@interface JPShareViewController : UIViewController

@property (nonatomic, weak) UIViewController    *fromViewController;
@property (nonatomic, weak) NSDictionary    *urls;

- (void)presentFromViewController:(UIViewController *)vc withURLS:(NSDictionary *)urls;
- (void)dismiss;

@end

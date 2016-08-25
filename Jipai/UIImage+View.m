//
//  UIImage+View.m
//  Jipai
//
//  Created on 14/11/5.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "UIImage+View.h"
#import "AppDelegate.h"

@implementation UIImage (View)

+ (UIImage *)appWindowImage {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIView *snapView = [delegate.window.rootViewController.view snapshotViewAfterScreenUpdates:NO];
    UIImage *image = [self imageFromView:snapView];
    
    return image;
}

+ (UIImage *)imageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    // [view.layer renderInContext:UIGraphicsGetCurrentContext()]; // <- same result...
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end

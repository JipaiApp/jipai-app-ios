//
//  JPButton.h
//  Jipai
//
//  Created on 14/11/5.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPButton : UIButton

@property (nonatomic, strong) UIImage   *topImage;
@property (nonatomic, strong) UIImage   *bottomImage;

+ (instancetype)buttonWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage;

@end

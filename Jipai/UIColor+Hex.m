//
//  UIColor+Hex.m
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(NSInteger)hex {
    CGFloat r = ((CGFloat)((hex & 0xFF0000) >> 16)) / 255.0;
    CGFloat g = ((CGFloat)((hex & 0x00FF00) >> 8)) / 255.0;
    CGFloat b = ((CGFloat)((hex & 0x0000FF) >> 0)) / 255.0;
    const CGFloat colors[] = {r, g, b, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorRef = CGColorCreate(colorSpace, colors);
    UIColor *result = [UIColor colorWithCGColor:colorRef];
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(colorRef);
    
    return result;
}

@end

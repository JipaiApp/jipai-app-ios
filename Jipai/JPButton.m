//
//  JPButton.m
//  Jipai
//
//  Created on 14/11/5.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "JPButton.h"
#import "CAMediaTimingFunction+AdditionalEquations.h"

@interface JPButton ()

@property (nonatomic, strong) UIImageView   *topImageView;
@property (nonatomic, strong) UIImageView   *bottomImageView;

@end

@implementation JPButton

+ (instancetype)buttonWithTopImage:(UIImage *)topImage bottomImage:(UIImage *)bottomImage {
    JPButton *button = [JPButton buttonWithType:UIButtonTypeCustom];
    button.topImage = topImage;
    button.bottomImage = bottomImage;
    
    return button;
}

- (void)innerInit {
    self.clipsToBounds = NO;
    [self addTarget:self
               action:@selector(touchDown)
     forControlEvents:UIControlEventTouchDown];
    
    [self addTarget:self
               action:@selector(touchUpInside)
     forControlEvents:UIControlEventTouchUpInside];
    
    [self addTarget:self
               action:@selector(touchDragEnter)
     forControlEvents:UIControlEventTouchDragEnter];
    
    [self addTarget:self
               action:@selector(touchDragExit)
     forControlEvents:UIControlEventTouchDragExit];
}

- (void)awakeFromNib {
    [self innerInit];
}

+ (id)buttonWithType:(UIButtonType)buttonType {
    JPButton *button = (JPButton *)[super buttonWithType:buttonType];
    [button innerInit];
    
    return button;
}

- (void)animateTopLayerTo:(CATransform3D)topTransform bottomLayerTo:(CATransform3D)bottomTransform {
    CGFloat duratoin = 0.433;
    
    CALayer *topLayer = self.topImageView.layer;
    
    CABasicAnimation *topAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    topAnimation.fromValue = [NSValue valueWithCATransform3D:topLayer.transform];
    topAnimation.toValue = [NSValue valueWithCATransform3D:topTransform];
    topAnimation.duration = duratoin;
    topAnimation.fillMode = kCAFillModeForwards;
    topAnimation.timingFunction = [CAMediaTimingFunction easeInOutBack];
    [topLayer addAnimation:topAnimation forKey:nil];
    topLayer.transform = topTransform;
    
    CALayer *bottomLayer = self.bottomImageView.layer;
    
    CABasicAnimation *bottomAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    bottomAnimation.fromValue = [NSValue valueWithCATransform3D:bottomLayer.transform];
    bottomAnimation.toValue = [NSValue valueWithCATransform3D:bottomTransform];
    bottomAnimation.duration = duratoin;
    bottomAnimation.fillMode = kCAFillModeForwards;
    bottomAnimation.timingFunction = [CAMediaTimingFunction easeInOutBack];
    [bottomLayer addAnimation:bottomAnimation forKey:nil];
    bottomLayer.transform = bottomTransform;
}

- (void)hitAnimation {
    CATransform3D topTransform = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D bottomTransform = CATransform3DMakeScale(0.9, 0.9, 1);
    [self animateTopLayerTo:topTransform bottomLayerTo:bottomTransform];
}

- (void)reverseAnimation {
    [self animateTopLayerTo:CATransform3DIdentity bottomLayerTo:CATransform3DIdentity];
}

- (void)touchDown {
    [self hitAnimation];
}

- (void)touchUpInside {
    [self reverseAnimation];
}

- (void)touchDragEnter {
    [self hitAnimation];
}

- (void)touchDragExit {
    [self reverseAnimation];
}

- (void)setTopImage:(UIImage *)topImage {
    _topImage = topImage;
    
    if (!self.topImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:topImage];
        CGRect bounds = self.bounds;
        imageView.center = (CGPoint){CGRectGetMidX(bounds), CGRectGetMidY(bounds)};
        [self addSubview:imageView];
        self.topImageView = imageView;
    }
    
    self.topImageView.image = topImage;
}

- (void)setBottomImage:(UIImage *)bottomImage {
    _bottomImage = bottomImage;
    
    if (!self.bottomImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:bottomImage];
        CGRect bounds = self.bounds;
        imageView.center = (CGPoint){CGRectGetMidX(bounds), CGRectGetMidY(bounds)};
        [self insertSubview:imageView atIndex:0];
        self.bottomImageView = imageView;
    }
    
    self.bottomImageView.image = bottomImage;
}

@end

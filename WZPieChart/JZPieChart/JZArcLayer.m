//
//  JZArcLayer.m
//  Test
//
//  Created by liweizhao on 2018/5/25.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "JZArcLayer.h"

@interface JZArcLayer()

@property (nonatomic, strong) UIBezierPath *renderBezierPath;

@end

@implementation JZArcLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    self.fillColor = [UIColor clearColor].CGColor;
    self.strokeColor = [UIColor clearColor].CGColor;
//    self.lineCap = @"round";
}

- (void)updateWithLeading:(CGFloat)leading trailing:(CGFloat)trailing; {
    _leading = leading;
    _trailing = trailing;
    if (leading < 0) {
        leading = 0;
    }
    
    if (trailing < 0) {
        trailing = 0;
    }
    
    if (leading > 1) {
        leading = 1;
    }
    
    if (trailing > 1) {
        trailing = 1;
    }
    
    if (trailing < leading) {
        CGFloat tmp = trailing;
        trailing = leading;
        leading = tmp;
    }

    [_renderBezierPath removeAllPoints];
    if (!_renderBezierPath) {
        _renderBezierPath = [UIBezierPath bezierPath];
    }
    
//    - M_PI_2   ~   M_PI * 2.0 - M_PI_2
    CGFloat startAngle = (M_PI * 2.0 * leading) - M_PI_2;
    CGFloat endAngle = (M_PI * 2.0 * trailing) - M_PI_2;

    // 真实半径
    if (_radius < self.lineWidth) {
        self.lineWidth = _radius;
    }
    CGFloat radius = _radius - self.lineWidth / 2.0;
    
    [_renderBezierPath addArcWithCenter:CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)
                               radius:radius
                           startAngle:startAngle
                             endAngle:endAngle
                            clockwise:true];
 
    self.path = _renderBezierPath.CGPath;
   
}

#pragma mark - Accessor


@end

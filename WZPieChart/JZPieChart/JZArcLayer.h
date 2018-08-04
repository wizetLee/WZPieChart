//
//  JZArcLayer.h
//  Test
//
//  Created by liweizhao on 2018/5/25.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

/// 弧度
@interface JZArcLayer : CAShapeLayer

/*
 1、弧的 开始 - 结尾
 2、弧半径
 3、弧宽度
 4、颜色（渐变与否）(暂不支持)
 */

/// 包括外环的半径
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign, readonly) CGFloat leading;
@property (nonatomic, assign, readonly) CGFloat trailing;

/// 配置弧度的开端末端 0 <= leading <= trailing <= 1.0
- (void)updateWithLeading:(CGFloat)leading trailing:(CGFloat)trailing;

@end

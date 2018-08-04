//
//  JZPieChartInputProtocol.h
//  Test
//
//  Created by liweizhao on 2018/5/28.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JZPieChartInputProtocol <NSObject>

@required
/// 权重值
- (CGFloat)weight;

@optional

/// 渲染的颜色--如不实现会使用默认的颜色组
- (UIColor *)renderColor;

@end

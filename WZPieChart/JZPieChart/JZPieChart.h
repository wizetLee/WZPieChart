//
//  JZPieChart.h
//  Test
//
//  Created by liweizhao on 2018/5/25.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JZPieChartInputProtocol.h"


@class JZPieChart;
@protocol JZPieChartProtocol <NSObject>

/// 选中角标
- (void)pieChart:(JZPieChart *)pieChart didClickAtIndex:(NSUInteger)index;

@end

/// 圆形分格统计图表  外环边缘radius = self.frame.size.width / 2.0
@interface JZPieChart : UIView

@property (nonatomic,   weak) id<JZPieChartProtocol> delegate;
/// 宽度 default 30.0
@property (nonatomic, assign) CGFloat lineWidth;
/// 点击高亮的颜色  default：yellowColor
@property (nonatomic, strong) UIColor *highlightLayerColor;
/// 可点击 default : false
@property (nonatomic, assign) BOOL touchable;
/// 饼块间隙 默认0  范围[0, +∞)、  建议范围[0.0, 0.005]
@property (nonatomic, assign) CGFloat gap;

- (void)updateWithData:(NSArray <JZPieChartInputProtocol>*)array;
/// 选中角标
- (void)pitchOnIndex:(NSInteger)index;
/// 预设的颜色
+ (NSArray <UIColor *> *)standerdColors;

@end

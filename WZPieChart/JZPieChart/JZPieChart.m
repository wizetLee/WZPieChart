//
//  JZPieChart.m
//  Test
//
//  Created by liweizhao on 2018/5/25.
//  Copyright © 2018年 wizet. All rights reserved.
//

#import "JZPieChart.h"
#import "JZArcLayer.h"

@interface JZPieChart()

@property (nonatomic, strong) NSArray <UIColor *>* defaultColor;
@property (nonatomic, strong) JZArcLayer *highlightLayer;
@property (nonatomic, strong) NSMutableArray <JZArcLayer *>*partsContainer;//容器
@property (nonatomic, strong) NSMutableArray <JZArcLayer *>*partsReusePool;//容器
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@end

@implementation JZPieChart

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self defaultConfig];
    }
    return self;
}

- (void)defaultConfig {
    
    _partsContainer = [NSMutableArray array];
    _partsReusePool = [NSMutableArray array];
    
    _highlightLayer = [[JZArcLayer alloc] init];
    [self.layer addSublayer:_highlightLayer];
    _highlightLayer.hidden = true;
    _highlightLayerColor = UIColor.yellowColor;
    
    self.lineWidth = 30.0; //default
    _gap = 0.0;
    _defaultColor = [self.class standerdColors];
    
    {//手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        [self addGestureRecognizer:tap];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        [self addGestureRecognizer:pan];
        _tap = tap;
        _pan = pan;
    }
    
    self.touchable = false;
}

- (void)gesture:(UIGestureRecognizer *)gesture {
    [self caculateAngleWith:[gesture locationInView:self]];
}

- (void)caculateAngleWith:(CGPoint)curPoint {
    
    {//过滤
        CGFloat radius = self.frame.size.width / 2.0;
        CGFloat a = pow(radius, 2.0);
        CGFloat b = pow(curPoint.x - self.bounds.size.width / 2.0, 2.0);
        CGFloat c = pow(curPoint.y - self.bounds.size.height / 2.0, 2.0);
        if (a - (b + c) > 0) {
            radius = radius - _lineWidth;
            a = pow(radius, 2);
            if (a - (b + c) > 0) {
                return;
            }
        } else {
            return;
        }
    }
    
    CGPoint centerRelativeToFatherView = CGPointMake(self.frame.size.width / 2.0
                                                     , self.frame.size.height / 2.0);
    //计算tan值
    double currentAngle = atan2(curPoint.y - centerRelativeToFatherView.y
                                , curPoint.x - centerRelativeToFatherView.x);
    
    double touchAngle = currentAngle;
    {//计算之前点的位置的部分
        if ((currentAngle > -M_PI_2 && currentAngle <= 0)
            || (currentAngle > 0 && currentAngle <= M_PI_2)) {
            touchAngle = currentAngle + M_PI_2;
        } else {
            if (currentAngle > M_PI_2 && currentAngle <= M_PI) {
                touchAngle = currentAngle + M_PI_2;
            } else {
                touchAngle = currentAngle + M_PI_2 * 5;
            }
        }
        
        [self touchedAngle:touchAngle];
    }
}

- (void)touchedAngle:(CGFloat)angle {
    CGFloat value = angle / (M_PI * 2.0	);
    [_partsContainer enumerateObjectsUsingBlock:^(JZArcLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (value > obj.leading && value < obj.trailing) {
            if (_selectedIndex == idx) {
            } else {
                [self pitchOnIndex:idx];
            }
            *stop = true;
        }
    }];
}

- (void)hideHighlightLayer {
    _highlightLayer.hidden = true;
    _highlightLayer.frame = CGRectZero;
    _selectedIndex = -1;
}

#pragma mark - Public
- (void)updateWithData:(NSArray <JZPieChartInputProtocol>*)array {
    [self hideHighlightLayer];
    
    [_partsContainer enumerateObjectsUsingBlock:^(JZArcLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [_partsReusePool addObject:obj];
        [obj removeFromSuperlayer];
    }];
    [_partsContainer removeAllObjects];
    
    if (array.count < 1) {
        return;
    }
    
    __block CGFloat totalValue = 0.0;
    [array enumerateObjectsUsingBlock:^(id <JZPieChartInputProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalValue = totalValue + [obj weight];
    }];
    
    
    // 配置间隙
    CGFloat gap = (array.count > 1) ? totalValue * _gap : 0;
    totalValue = totalValue + gap * (array.count);
    CGFloat gapPercentage = gap / totalValue;
    
    __block CGFloat curPercentage = 0.0;
    [array enumerateObjectsUsingBlock:^(id <JZPieChartInputProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        JZArcLayer *arcLayer = nil;
        {// 获取、配置layer
            if (_partsReusePool.count) {
                arcLayer = _partsReusePool.lastObject;
                [_partsReusePool removeLastObject];
            } else {
                arcLayer = [[JZArcLayer alloc] init];
            }
            [_partsContainer addObject:arcLayer];
            
            arcLayer.frame = self.bounds;
            CGFloat radius = (self.frame.size.width<self.frame.size.height)? self.frame.size.width/2.0 : self.frame.size.height/2.0;
            arcLayer.radius  = radius;
            arcLayer.lineWidth = _lineWidth;
            
            if ([obj respondsToSelector:@selector(renderColor)]
                && [obj renderColor]) {
                arcLayer.strokeColor = [obj renderColor].CGColor;
            } else {
                arcLayer.strokeColor = _defaultColor[idx % _defaultColor.count].CGColor;
            }
        }
        
        
        {// 绘制layer
            CGFloat value = [obj weight] / totalValue;
            [arcLayer updateWithLeading:curPercentage trailing:curPercentage + value];
            [self.layer addSublayer:arcLayer];
            curPercentage = curPercentage + value + gapPercentage;
        }
    }];
}

- (void)pitchOnIndex:(NSInteger)index {
    if (index >= 0
        && _partsContainer.count > index) {
        
        JZArcLayer *obj = _partsContainer[index];
        if ([_delegate respondsToSelector:@selector(pieChart:didClickAtIndex:)]) {
            [_delegate pieChart:self didClickAtIndex:index];
        }
        
        // 高亮追踪的角标
        _selectedIndex = index;
        
        if (_touchable) {
            [CATransaction begin];
            [CATransaction setAnimationDuration:0];
            {// 配置高亮layer
                _highlightLayer.hidden = false;
                _highlightLayer.frame = self.bounds;
                CGFloat radius = (self.frame.size.width<self.frame.size.height)? self.frame.size.width/2.0 : self.frame.size.height/2.0;
                _highlightLayer.radius  = radius;
                _highlightLayer.lineWidth = _lineWidth;
                _highlightLayer.strokeColor = _highlightLayerColor.CGColor;
                [_highlightLayer updateWithLeading:obj.leading trailing:obj.trailing];
                
                [self.layer insertSublayer:_highlightLayer
                                   atIndex:(unsigned int)(self.layer.sublayers.count)];
            }
            [CATransaction commit];
        }
        
    } else {
        _highlightLayer.hidden = true;
    }
}

+ (NSArray <UIColor *> *)standerdColors {
    return @[
             [UIColor colorWithRed:246.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1.0],
             [UIColor colorWithRed:246.0/255.0 green:91.0/255.0 blue:38.0/255.0 alpha:1.0],
             [UIColor colorWithRed:246.0/255.0 green:117.0/255.0 blue:38.0/255.0 alpha:1.0],
             [UIColor colorWithRed:246.0/255.0 green:165.0/255.0 blue:38.0/255.0 alpha:1.0],
             [UIColor colorWithRed:245.0/255.0 green:198.0/255.0 blue:44.0/255.0 alpha:1.0],
             [UIColor colorWithRed:238.0/255.0 green:218.0/255.0 blue:29.0/255.0 alpha:1.0],
             [UIColor colorWithRed:45.0/255.0 green:190.0/255.0 blue:231.0/255.0 alpha:1.0],
             [UIColor colorWithRed:64.0/255.0 green:139.0/255.0 blue:255.0/255.0 alpha:1.0],
             [UIColor colorWithRed:64.0/255.0 green:85.0/255.0 blue:255.0/255.0 alpha:1.0],
             [UIColor colorWithRed:56.0/255.0 green:42.0/255.0 blue:247.0/255.0 alpha:1.0],
             ];
}

#pragma mark - Accessor
- (void)setTouchable:(BOOL)touchable {
    if (_touchable == touchable) {
        return;
    }
    
    _touchable = touchable;
    _pan.enabled = _touchable;
    _tap.enabled = _touchable;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (lineWidth < 0.0) {
        _lineWidth = 0.0;
    } else if (lineWidth > (self.frame.size.width / 2.0)) {
        _lineWidth = self.frame.size.width / 2.0;
    } else {
        _lineWidth = lineWidth;
    }
    
}


@end

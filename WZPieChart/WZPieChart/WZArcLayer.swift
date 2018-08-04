
//  WZArcLayer.swift
//  WZPieChart
//
//  Created by liweizhao on 2018/6/2.
//  Copyright © 2018年 wizet. All rights reserved.
//

import Foundation
import UIKit


/// 专注于弧度绘制
class WZArcLayer: CAShapeLayer {
    
    // 半径
    var radius : CGFloat = 0
    
    // 0 <= leading <= trailing <= 1.0
    var leading : CGFloat = 0         // 起始点
    var trailing :CGFloat = 0        // 末端点
    
    private let renderBezierPath : UIBezierPath = UIBezierPath()
    
    override init(layer: Any) {
        super.init(layer: layer)
        defaultConfig()
    }
    
    override init() {
        super.init()
        defaultConfig()
    }
    
    private func defaultConfig() -> () {
        self.fillColor = UIColor.clear.cgColor
        self.strokeColor = UIColor.clear.cgColor
//        self.lineCap = "round"
    }
    
    
    /// 根据数据更新UI
    ///
    /// - Parameters:
    ///   - leading: 0.0---1.0
    ///   - trailing: 0.0---1.0   bigger than leading
    public func update(_ leading : CGFloat = 0.0, _ trailing : CGFloat = 1.0) -> () {
        self.leading = leading
        self.trailing = trailing
        //数据过滤
        
        var leadingCorrectionValue : CGFloat = closeIntervalFilter(minimum: 0.0, maximum: 1.0, correctionValue: leading)
        var trailingCorrectionValue : CGFloat = closeIntervalFilter(minimum: 0.0, maximum: 1.0, correctionValue: trailing)
        
        if leadingCorrectionValue > trailingCorrectionValue {
            let tmp : CGFloat = trailingCorrectionValue
            trailingCorrectionValue = leadingCorrectionValue
            leadingCorrectionValue = tmp
        }
        
        
        //路径绘制
        
        renderBezierPath.removeAllPoints()
        
        //自纠正lineWidth
        if radius < self.lineWidth {
            self.lineWidth = radius
        }
        let tpmRadius : CGFloat = radius - self.lineWidth / 2.0

        let startAngle : CGFloat = CGFloat.pi * 2.0 * leadingCorrectionValue - CGFloat.pi / 2.0
        let endAngle : CGFloat = CGFloat.pi * 2.0 * trailingCorrectionValue - CGFloat.pi / 2.0
        
        ///- M_PI_2   ~   M_PI * 2.0 - M_PI_2
        renderBezierPath.addArc(withCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                                radius: tpmRadius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: true)
        
        self.path = renderBezierPath.cgPath
    }

    /// 将数值过滤至指定的的区间内 --- mathematics close interval [minimum, maximum]
    ///
    /// - Parameters:
    ///   - minimum: 区间最小值
    ///   - maximum: 区间最大值
    /// - Returns: 得到一个在指定闭区间内的值
    private func closeIntervalFilter(minimum : CGFloat, maximum : CGFloat, correctionValue : CGFloat) -> CGFloat {
        var value = correctionValue
        if (correctionValue < minimum) {
            value = minimum;
        }
        
        if (correctionValue > maximum) {
            value = maximum;
        }
        
        return value;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



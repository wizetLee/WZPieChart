//
//  WZPieChart.swift
//  WZPieChart
//
//  Created by wizet on 2018/6/1.
//  Copyright © 2018年 wizet. All rights reserved.
//

import Foundation
import UIKit

@objc protocol WZPieChartProtocol : AnyObject {
    func pieChartPitch(index : UInt) -> ()
}

@objc protocol WZPieChartInputProtocol : AnyObject  {
    
   func weight() -> CGFloat
   @objc optional func renderColor() -> UIColor
}

class WZPieChart : UIView  {
   
    //MARK: - Private
    /// 可否点击 存取属性
    private var touchablePrivate : Bool = false;
    /// 默认的颜色 只有10种
    private let defaultColor : [UIColor] = { return standaredColors() }()
    
    private let highlightLayer : WZArcLayer = WZArcLayer()
    private var partsContainer : [WZArcLayer] = []
    private var partsReusePool : [WZArcLayer] = []
    private var selectedIndex : Int = -1
    private lazy var tap : UITapGestureRecognizer = {
       return UITapGestureRecognizer(target: self, action: #selector(gesture(gesture:)))
    }()
    private lazy var pan : UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(gesture(gesture:)))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        defaultConig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("line: \(#line) function: \(#function) class : \(type(of: self)) ")
    }
    
    /// 基本配置
    func defaultConig() -> () {
        self.layer.addSublayer(highlightLayer)
        highlightLayer.isHidden = true
        highlightLayer.backgroundColor = UIColor.clear.cgColor
        
        lineWidth = 30.0
        gap = 0.0
        
        self.addGestureRecognizer(tap)
        self.addGestureRecognizer(pan)
        
        touchable = false   //默认：不可点击
    }
    
    /// 手势处理
    @objc func gesture(gesture : UIGestureRecognizer) -> () {
        let point = gesture.location(in: self)
        angleCalculation(point: point)
    }
    
    static func customColor0_255(r:CGFloat , g:CGFloat , b:CGFloat, a:CGFloat) -> UIColor {
        return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a/255.0)
    }
    
    /// 获取颜色数组
    ///
    /// - Returns: 10种自定义的颜色
    static func standaredColors() -> (Array<UIColor>) {
        return [
            customColor0_255(r: 246, g: 38, b: 38, a: 255),
            customColor0_255(r: 246, g: 91, b: 38, a: 255),
            customColor0_255(r: 246, g: 117, b: 38, a: 255),
            customColor0_255(r: 246, g: 165, b: 38, a: 255),
            customColor0_255(r: 245, g: 198, b: 44, a: 255),
            customColor0_255(r: 238, g: 218, b: 29, a: 255),
            customColor0_255(r: 45, g: 190, b: 231, a: 255),
            customColor0_255(r: 64, g: 139, b: 255, a: 255),
            customColor0_255(r: 64, g: 85, b: 255, a: 255),
            customColor0_255(r: 56, g: 42, b: 247, a: 255),
        ]
    }
    
    /// 通过手势得到的点计算手势
    ///
    /// - Parameter point: 计算点
    private func angleCalculation(point : CGPoint) -> () {
        
        // 点的过滤
        var radius = frame.size.width / 2.0
        var a = pow(radius, 2.0)
        let b = pow(point.x - frame.size.width / 2.0, 2.0)
        let c = pow(point.y - frame.size.width / 2.0, 2.0)
        if (a - (b + c) > 0) {
            radius = radius - lineWidth;
            a = pow(radius, 2);
            if (a - (b + c) > 0) {
                return;
            }
        } else {
            return;
        }
        
        let center : CGPoint = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let curAngle : CGFloat = atan2(point.y - center.y, point.x - center.x)
        var touchAngle : CGFloat = curAngle
        
        if ((curAngle > -(CGFloat.pi / 2.0)  && curAngle <= 0)
            || (curAngle > 0 && curAngle <= (CGFloat.pi / 2.0))) {
            touchAngle = curAngle + (CGFloat.pi / 2.0);
        } else {
            if (curAngle > (CGFloat.pi / 2.0) && curAngle <= CGFloat.pi) {
                touchAngle = curAngle + (CGFloat.pi / 2.0);
            } else {
                touchAngle = curAngle + (CGFloat.pi / 2.0) * 5;
            }
        }
        
        touchedAngle(angle: touchAngle)
    }
    
    private func touchedAngle(angle : CGFloat) -> () {
        let value : CGFloat  = angle / (CGFloat.pi * 2.0)
        for (index, layer) in partsContainer.enumerated() {
            if value > layer.leading && value < layer.trailing {
                if selectedIndex == index {
                    
                } else {
                    pitchOn(index)
                }
                break
            }
            
        }
    }
    
    //MARK: - Public
    public var delegate : WZPieChartProtocol?
    
    /// 饼图的线宽，范围：0 - self.frame.size.width/2.0
    public var lineWidth : CGFloat = 20.0 {
        didSet {
            //过滤
            if lineWidth > (self.frame.size.width / 2.0) {
               lineWidth = self.frame.size.width / 2.0
            } else if lineWidth < 0.0 {
                lineWidth = 0.0
            }
        }
    }
    
    /// 可否点击 计算属性
    public var touchable : Bool   {
        set {
            touchablePrivate = newValue
            tap.isEnabled = newValue
            pan.isEnabled = newValue
        }
        get {
          return touchablePrivate
        }
    }
    
    /// 饼块间距 默认0  范围[0, +∞)、  建议范围[0.0, 0.005]
    public var gap : CGFloat = 0.0;
    
    /// 点击时高亮的颜色
    public var highlightColor : UIColor = UIColor.yellow
    
    /// 更新图表
    ///
    /// - Parameter dataSource: 数据源
    public func update(dataSource : Array<WZPieChartInputProtocol>) -> () {
     
        // 初始化一些配置
        highlightLayer.isHidden = true
        selectedIndex = -1
        
        for obj in partsContainer {
            partsReusePool.append(obj)
            obj.removeFromSuperlayer()
        }
        partsContainer.removeAll()
        
        if dataSource.count < 1 {
            return
        }
        
        var totalValue : CGFloat = 0.0
        for obj in dataSource {
            totalValue = totalValue + obj.weight()//权重计算
        }
        
        let gap = dataSource.count > 1 ? self.gap * totalValue : 0.0
        totalValue = totalValue + gap * CGFloat(dataSource.count)
        let gapPercentage = gap / totalValue;
        
        var curPercentage : CGFloat = 0.0
        for (idx, obj) in dataSource.enumerated() {
            let value = obj.weight() / totalValue;
            
            var layer : WZArcLayer? = nil
            if partsReusePool.count > 0 {
                layer = partsReusePool.last
                partsReusePool.removeLast()
            } else {
                layer = WZArcLayer()
            }
            guard layer != nil else {
                return
            }
            
            partsContainer.append(layer!)
            
            layer!.frame = self.bounds
            layer!.radius  = frame.size.width / 2.0
            layer!.lineWidth = lineWidth
            
            if obj.renderColor != nil {
                layer!.strokeColor = obj.renderColor!().cgColor
            } else {
               layer!.strokeColor = defaultColor[idx % defaultColor.count].cgColor
            }
            
            self.layer.addSublayer(layer!)
            layer!.update(curPercentage, curPercentage + value)
            curPercentage = curPercentage + value + gapPercentage
         
        }
    }
    
    
    /// 选中某角标达到高亮效果
    ///
    /// - Parameter index: 选中的角标
    public func pitchOn(_ index : Int) -> () {
        if index >= 0
            && index < partsContainer.count {
            
            //选中的对象
            let layer : WZArcLayer = partsContainer[index]
            //回调选中的角标
            delegate?.pieChartPitch(index: UInt(index))
            selectedIndex = index
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.0)
            
            highlightLayer.isHidden = false
            highlightLayer.frame = self.bounds
            highlightLayer.radius  = self.frame.size.width / 2.0;
            highlightLayer.lineWidth = lineWidth;
            highlightLayer.strokeColor = highlightColor.cgColor;
            highlightLayer.update(layer.leading, layer.trailing)
            
            if self.layer.sublayers != nil {
                self.layer.insertSublayer(highlightLayer, at: UInt32(self.layer.sublayers!.count))
            }
            
            CATransaction.commit()
        } else {
            highlightLayer.isHidden = true
        }
    }
}



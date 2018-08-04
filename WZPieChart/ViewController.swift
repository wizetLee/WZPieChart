//
//  ViewController.swift
//  WZPieChart
//
//  Created by liweizhao on 2018/6/1.
//  Copyright © 2018年 wizet. All rights reserved.
//

import UIKit


class ViewController: UIViewController, WZPieChartProtocol, JZPieChartProtocol{
  
  
    var chart : WZPieChart?
    var chart2 : JZPieChart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let WH = UIScreen.main.bounds.size.width / 3.0 * 2.0
        
        let chart  = WZPieChart(frame: CGRect(x: 0.0, y: 0.0, width: WH, height: WH))
        chart.backgroundColor = UIColor.white
        self.view.addSubview(chart)

        chart.lineWidth = chart.frame.size.width / 2
        chart.highlightColor = UIColor.green
        chart.delegate = self
        chart.gap = 0.001
        chart.touchable = true
      
        
        // -----------
        
        let chart2 : JZPieChart = JZPieChart(frame: CGRect(x: 0.0, y: WH, width: WH, height: WH))
        chart2.backgroundColor = UIColor.white
        self.view.addSubview(chart2)
//        chart2.lineWidth = chart2.frame.size.width / 2
        chart2.highlightLayerColor = UIColor.green
        chart2.delegate = self
        chart2.gap = 0.001
        
        chart2.touchable = true
      
        self.chart = chart;
        self.chart2 = chart2
        chart.pitchOn(9)
        chart2.pitch(on: 2);
        
        let btn = UIButton(frame: CGRect(x: 0.0, y: UIScreen.main.bounds.size.height - 44.0, width: 88.0, height: 44.0))
        self.view.addSubview(btn)
        btn.backgroundColor = UIColor.black;
        btn.setTitle("刷新", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.addTarget(self, action: #selector(update), for: .touchUpInside)
    }

   
    @objc func update() -> Void {
        var models : [Model] = []
        for _ in 0..<arc4random_uniform(10)  {
            let tmp = Model()
            tmp.score = CGFloat(arc4random() % 100)
            models.append(tmp)
        }
        
        self.chart!.lineWidth = CGFloat(arc4random_uniform(UInt32(self.chart!.frame.size.width / 2.0)))
        self.chart2!.lineWidth = (self.chart!.lineWidth)
        
        self.chart?.gap = CGFloat(arc4random_uniform(10)) * 0.001;
        self.chart2?.gap = self.chart!.gap
        
        self.chart?.update(dataSource: models)
        self.chart2?.update(withData: models)
     
    }
    
    //MARK: WZPieChartProtocol
    func pieChartPitch(index : UInt) -> () {
        print("chart 选中了\(index)")
    }
    
    func pieChart(_ pieChart: JZPieChart!, didClickAt index: UInt) {
        print("chart2 选中了\(index)")
    }
    
}

class Model :NSObject,  WZPieChartInputProtocol, JZPieChartInputProtocol {

    var score : CGFloat = 0.0
    func weight() -> CGFloat {
        return score
    }
}




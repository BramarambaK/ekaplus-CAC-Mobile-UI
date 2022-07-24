//
//  chartComponentView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 01/04/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol ChartComponentViewDelegate {
    func UpdateChartPickerValue(MyPickerData:String?)
}

final class chartComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var SelectedData:[JSON] = []
    var chartSelectedData:[JSON] = []
    var chartFilterData:[JSON] = []
    var chartView: HIChartView!
    var charFilter:[String] = []
    var selectFilter:String?
    var delegate:AdvancedCompositeDelegate?
    var filterjson:JSON?
    var chartFilterValue:String?
    var ConnectUserInfo:JSON?
    
    //MARK: - IBOutlet
    @IBOutlet weak var ChartLabel: UILabel!
    @IBOutlet weak var ChartView: UIView!
    @IBOutlet weak var FilterLabel: UILabel!
    @IBOutlet weak var filterView: UIView!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: chartComponentView.self), owner: self, options: nil)?.first as! chartComponentView
        return view as! Self
    }
    
    func config(){
        if app_metaData!["flow"][ls_taskName!]["fields"].count > 0 {
            ConnectManager.shared.appendDynamicData(Meta: app_metaData!["flow"][ls_taskName!]["fields"].arrayValue, Data: SelectedData) { (ResultData) in
                self.SelectedData = ResultData
                self.renderChartUI()
            }
        }
    }
    
    private func renderChartUI(){
        if SelectedData.count > 0 {
            ChartLabel.isHidden = false
            ChartView.isHidden = false
            filterView.isHidden = false
            ChartLabel.text = app_metaData!["flow"][ls_taskName!]["layout"]["header"]["label"].stringValue
            FilterLabel.text = chartFilterValue ?? ""
            var li_filterExpressionCheck = 0
            
            for eachData in SelectedData {
                li_filterExpressionCheck = 0
                for each in app_metaData!["flow"][ls_taskName!]["fields"].arrayValue {
                    switch each["filterType"].string {
                    case "filterData":
                        li_filterExpressionCheck = 1
                        if let filterExpression = each["filterExpression"].string {
                            
                            let result:String = ConnectManager.shared.evaluateJavaExpression(expression: filterExpression, data: eachData) as? String ?? ""
                            
                            if result == "true" {
                                chartSelectedData.append(eachData)
                            }
                        }
                    case "dropdown":
                        filterjson = each
                        if each["selectedAll"].string != nil && charFilter.contains(each["selectedAll"].stringValue) == false{
                            charFilter.append(each["selectedAll"].stringValue)
                            selectFilter = each["selectedAll"].stringValue
                        }
                    default:
                        break
                    }
                }
            }
            
            if filterjson != nil{
                for eachData in chartSelectedData {
                    if filterjson!["valueExpression"] != nil {
                        let result:String = ConnectManager.shared.evaluateJavaExpression(expression: filterjson!["valueExpression"].stringValue, data:eachData) as? String ?? ""
                        
                        let splitresult = result.split(separator: ",")
                        
                        for i in 0..<splitresult.count {
                            if charFilter.contains(String(splitresult[i])) != true{
                                charFilter.append(String(splitresult[i]))
                            }
                        }
                    }else if charFilter.contains(eachData[filterjson!["filterBy"].stringValue].stringValue) == false {
                        charFilter.append(eachData[filterjson!["filterBy"].stringValue].stringValue)
                    }
                }
            }
            
            if li_filterExpressionCheck == 0 {
                chartSelectedData = SelectedData
            }
            
            if charFilter.count > 0 {
                if chartFilterValue == nil {
                    FilterLabel.text = charFilter[0]
                }
                self.filterChartData()
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                self.addGestureRecognizer(tap)
            }else{
                FilterLabel.text = ""
            }
        }
        else{
            ChartLabel.isHidden = true
            ChartView.isHidden = true
            filterView.isHidden = true
        }
//        self.plotChart(ChartData: chartSelectedData)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.delegate?.setChartDelegate(chartDelegate: self)
        self.delegate?.addChartPickerView(MyChartPickerData: charFilter)
    }
    
    private func plotChart(ChartData:[JSON]?){
        
        self.delegate?.setChartDelegate(chartDelegate: self)
        delegate?.updateScreenData(taskName: ls_taskName!, ScreenData: ChartData ?? [])
        
        chartFilterData = ChartData!
        
        var label:JSON = []
        var valueJson:[JSON] = []
        var categoriesValue:[String] = []
        var chartDataValue:[[Double]] = []
        var Bars:[HIBar] = []
        var suffixValue:String = ""
        var prefixValue:String = ""
        for each in app_metaData!["flow"][ls_taskName!]["fields"].arrayValue{
            switch each["type"] {
            case "label":
                label = each
            case "value":
                valueJson.append(each)
            default:
                break
            }
            
        }
        
        if ChartData!.count > 0 {
            for each in ChartData! {
                if categoriesValue.contains("\(each[label["key"].stringValue].stringValue)") == false{
                    categoriesValue.append("\(each[label["key"].stringValue].stringValue)")
                }
                
                if let index = categoriesValue.firstIndex(of:"\(each[label["key"].stringValue].stringValue)") {
                    
                    var indValue:Double = 0
                    
                    for i in 0..<valueJson.count{
                        var individualDataValue:[Double] = []
                        if chartDataValue.count != 0 && chartDataValue.count != i {
                            individualDataValue = chartDataValue[i]
                        }
                        if individualDataValue.count == 0 || individualDataValue.count == index{
                            indValue += each[valueJson[i]["key"].stringValue].doubleValue
                            individualDataValue.insert(indValue, at: index)
                        }else{
                            indValue = individualDataValue[index]
                            indValue += each[valueJson[i]["key"].stringValue].doubleValue
                            individualDataValue.remove(at: index)
                            individualDataValue.insert(indValue, at: index)
                            chartDataValue.remove(at: i)
                        }
                        if valueJson.count == chartDataValue.count {
                            chartDataValue.remove(at: i)
                        }
                        chartDataValue.insert(individualDataValue, at: i)
                    }
                }
            }
            
            let dataValueSorted = chartDataValue[0].sorted()
            var sortedCategoriesValue:[String] = []
            var sortedDataValue:[[Double]] = []
            
            for each in dataValueSorted {
                let valueIndex =  chartDataValue[0].firstIndex(of: each)
                sortedCategoriesValue.append(categoriesValue[valueIndex!])
                for i in 0..<chartDataValue.count{
                    var individualDataValue:[Double] = []
                    if sortedDataValue.count != 0 && sortedDataValue.count != i {
                        individualDataValue = sortedDataValue[i]
                        sortedDataValue.remove(at: i)
                    }
                    individualDataValue.append(chartDataValue[i][valueIndex!])
                    sortedDataValue.insert(individualDataValue, at: i)
                }
            }

            categoriesValue = sortedCategoriesValue
            chartDataValue = sortedDataValue
            
            if valueJson[0]["suffix"] != nil {
                let suffixString:String = ConnectManager.shared.evaluateJavaExpression(expression:   valueJson[0]["suffix"].stringValue, data: ChartData![0]) as? String ?? ""
                
                suffixValue = suffixString
            }else if valueJson[0]["prefix"] != nil {
                
                var prefixString:String = ""
                
                if valueJson[0]["prefix"].stringValue.contains("userInfo") == true{
                    prefixString = ConnectManager.shared.evaluateJavaExpression(expression: valueJson[0]["prefix"].stringValue.replacingOccurrences(of: "userInfo.", with: ""), data: ConnectUserInfo) as? String ?? ""
                }else{
                    prefixString = ConnectManager.shared.evaluateJavaExpression(expression: valueJson[0]["prefix"].stringValue, data: ChartData![0]) as? String ?? ""
                }
                
                prefixValue = prefixString
            }
        }
        
        chartView = HIChartView(frame: ChartView.bounds)
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        for view in ChartView.subviews{
            view.removeFromSuperview()
        }
        ChartView.addSubview(chartView)
        
        //Configure the Chart 
        
        let options = HIOptions()
        
        let chart = HIChart()
        chart.type = "bar"
        options.chart = chart
        
        let exporting = HIExporting()
        exporting.enabled = false
        options.exporting = exporting
        
        let credits = HICredits()
        credits.enabled = false
        options.credits = credits
        
        let tooltip = HITooltip()
        tooltip.enabled = NSNumber(booleanLiteral: app_metaData!["flow"][ls_taskName!]["layout"]["toolTipHover"]["enable"].bool ?? false)
        
        var expression:String = app_metaData!["flow"][ls_taskName!]["layout"]["toolTipHover"]["valueExpression"].string ?? ""

        for each in valueJson {
            expression = ConnectManager.shared.evaluateJavaExpression(expression: expression, data: JSON.init(parseJSON: [each["key"].stringValue:"this.point.x"].jsonString())) as? String ?? ""
        }
        
        let TooltipValueExpression:String = "function() {\(expression)}"
        
        tooltip.formatter = HIFunction.init(jsFunction: "\(TooltipValueExpression)")
        options.tooltip = tooltip
        
        let xAxis = HIXAxis()
        xAxis.categories = categoriesValue
        options.xAxis = [xAxis]
        
        let yAxis = HIYAxis()
        yAxis.min = 0
        yAxis.visible = false
        yAxis.title = HITitle()
        yAxis.title.text = ""
        options.yAxis = [yAxis]
        
        let title = HITitle()
        title.text = ""
        options.title = title
        
        let legend = HILegend()
        legend.enabled = false
        options.legend = legend
        
        let chartFunction = HIFunction(closure: { (context) in
            self.drillDownChartFilter(category: "\(context!.getProperty("this.category")!)")
        }, properties: ["this.x", "this.y","this.index","this.category"])
        
        let plotOptions = HIPlotOptions()
        plotOptions.series = HISeries()
        plotOptions.series.point =  HIPoint()
        plotOptions.series.point.events = HIEvents()
        plotOptions.series.point.events.click = chartFunction
        plotOptions.series.stacking = "normal"
        let dataLabels = HIDataLabels()
        dataLabels.enabled = true
        dataLabels.format = "\(prefixValue){point.y:.2f} \(suffixValue)"
        plotOptions.series.dataLabels = [dataLabels]
        options.plotOptions = plotOptions
        
        for i in (0..<chartDataValue.count).reversed() {
            let Bar = HIBar()
            Bar.data = chartDataValue[i]
            if valueJson[i]["backgroundColor"].string != nil {
                let lscolors = valueJson[i]["backgroundColor"].stringValue.replacingOccurrences(of: "#", with: "")
                Bar.color = HIColor(hexValue: "\(lscolors)")
            }else if valueJson[i]["backgroundColor"].array != nil {
                Bar.colorByPoint = true
                var larrcolors:[String] = []
                
                for each in valueJson[i]["backgroundColor"].arrayValue {
                    larrcolors.append(each.rawValue as! String)
                }
                
                options.colors = larrcolors
            }
            Bars.append(Bar)
        }
        
        options.series = Bars
        
        chartView.options = options
         
    }
    
    func filterChartData(){
        chartFilterData.removeAll()
        if chartSelectedData.count > 0 {
            if selectFilter != nil && selectFilter! == FilterLabel.text! {
                chartFilterData = chartSelectedData
            }else{
                for eachData in chartSelectedData {
                    let splitFilterData = eachData[filterjson!["key"].stringValue].stringValue.split(separator: ",")
                    for i in 0..<splitFilterData.count {
                        if splitFilterData[i] == FilterLabel.text!{
                            chartFilterData.append(eachData)
                            break
                        }
                    }
                }
            }
            delegate?.updateScreenData(taskName: ls_taskName!, ScreenData: chartFilterData)
            self.plotChart(ChartData: chartFilterData)
        }
    }
    
    func drillDownChartFilter(category:String?){
        var labelKey:String = ""
        for each in app_metaData!["flow"][ls_taskName!]["fields"].arrayValue {
            switch each["type"] {
            case "label":
                labelKey = each["key"].stringValue
            default:
                break
            }
        }
        
        var drillDownChartData:[JSON] = []
        
        let DrillChartData = chartFilterData
        
        for eachData in DrillChartData {
            if eachData[labelKey].stringValue == category!{
                drillDownChartData.append(eachData)
            }
        }
        
        delegate?.updateScreenData(taskName: ls_taskName!, ScreenData: drillDownChartData)
    }
    
}

extension chartComponentView : ChartComponentViewDelegate{
    func UpdateChartPickerValue(MyPickerData: String?) {
        if MyPickerData != nil {
            self.FilterLabel.text = MyPickerData!
            self.filterChartData()
        }
    }
}

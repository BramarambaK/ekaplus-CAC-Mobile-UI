//
//  ChartViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 06/11/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController,HUDRenderer {
    
    //MARK: - Variable
    var ls_ScreenTitle:String?
    var ls_taskName:String?
    var li_xaxis:Bool = false
    var li_yaxis:Bool = false
    var layoutJson:JSON?
    var chartView:HIChartView!
    let optionsProvider = OptionProvider()
    
    //MARK: - IBOutlet
    @IBOutlet weak var chartContainerView: UIView!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        if ls_ScreenTitle != nil {
            self.navigationItem.title = "\(ls_ScreenTitle ?? "")"
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        let BackButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action:  #selector(goBack))
        
        self.navigationItem.setLeftBarButtonItems([BackButton], animated: true)
        
        self.setupChart()
    }
    
    func setupChart() {
        let chartView = HIChartView(frame: chartContainerView.bounds)
        chartView.frame = chartContainerView.bounds
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chartView.backgroundColor = .lightGray
        
        switch layoutJson!["flow"]["\((layoutJson!["flow"].dictionary!.keys).first!)"]["layout"]["type"].stringValue {
        case ChartType.StackedBar.rawValue,ChartType.Bar.rawValue,ChartType.Bar3D.rawValue,ChartType.StackedPercentageBar.rawValue:
            getChartOptions { (chartOptionsResponse) in
                let chartOptions = chartOptionsResponse
                let options = self.optionsProvider.hiOptions(for: chartOptions)
                options.legend.enabled = true
                var Barcolour:[String] = []
                for fieldEach in self.layoutJson!["flow"]["\((self.layoutJson!["flow"].dictionary!.keys).first!)"]["fields"].arrayValue{
                    switch fieldEach["type"] {
                    case "value":
                        Barcolour.append(fieldEach["backgroundColor"].stringValue)
                        break
                    default:
                        break
                    }
                }
                if Barcolour.count > 0 {
                    options.colors = Barcolour
                }
                chartView.options = options
                DispatchQueue.main.async {
                    self.chartContainerView.addSubview(chartView)
                }
            }
        default:
            let label = UILabel()
            label.text  = NSLocalizedString("Unable to render chart.", comment: " ")
            
            label.tag = Tags.unableToRender.rawValue
            self.chartContainerView.addSubview(label)
            
            label.numberOfLines = 0
            label.frame = chartContainerView.bounds
            label.textAlignment = .center
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    
    //MARK: - Local Function
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getChartOptions(completion: @escaping (ChartOptionsModel)->()){
        var chartOptions = ChartOptionsModel()
        var larr_xaxis:[String] = []
        var larr_yaxis:[String] = []
        var larr_series:[[Double]] = []
        var ls_xaxis:String = ""
        
        chartOptions.name = layoutJson!["flow"]["\((layoutJson!["flow"].dictionary!.keys).first!)"]["layout"]["header"]["label"].stringValue
        
        var dataBodyDictionary:[String : Any] = [:]
        
        dataBodyDictionary = ["appId":"\(self.layoutJson!["appId"].stringValue)",
                              "workFlowTask":"\(self.ls_taskName!)","deviceType": "mobile"] as [String : Any]
        dataBodyDictionary["operation"] = []
        
        self.showActivityIndicator()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { (dataResponse) in
            self.hideActivityIndicator()
            
            switch dataResponse {
            case .success(let Data):
                var li_Value:Int = 0
                
                switch self.layoutJson!["flow"]["\((self.layoutJson!["flow"].dictionary!.keys).first!)"]["layout"]["type"].stringValue {
                case ChartType.StackedBar.rawValue,ChartType.Bar3D.rawValue,ChartType.Bar.rawValue,ChartType.StackedPercentageBar.rawValue:
                    chartOptions.type = ChartType(rawValue: self.layoutJson!["flow"]["\((self.layoutJson!["flow"].dictionary!.keys).first!)"]["layout"]["type"].stringValue)
                    
                    for each in Data["data"].arrayValue{
                        self.li_xaxis = false
                        self.li_yaxis = false
                        li_Value = 0
                        for fieldEach in self.layoutJson!["flow"]["\((self.layoutJson!["flow"].dictionary!.keys).first!)"]["fields"].arrayValue{
                            switch fieldEach["type"] {
                            case "label":
                                if self.li_xaxis != true{
                                    if !larr_xaxis.contains(each[fieldEach["key"].stringValue].stringValue){
                                        larr_xaxis.append(each[fieldEach["key"].stringValue].stringValue)
                                        ls_xaxis = each[fieldEach["key"].stringValue].stringValue
                                    }
                                    self.li_xaxis = true
                                }
                                else if self.li_xaxis == true{
                                    if !larr_yaxis.contains(each[fieldEach["key"].stringValue].stringValue){
                                        larr_yaxis.append(each[fieldEach["key"].stringValue].stringValue)
                                    }
                                    self.li_yaxis = true
                                }
                                
                            case "value":
                                let indexvalue = larr_xaxis.firstIndex(of: ls_xaxis)
                                
                                if larr_series.count > 0 && larr_series.count >= li_Value+1 && larr_series[li_Value] != nil {
                                    var larr_value:[Double] = larr_series[li_Value]
                                    if larr_value.count > indexvalue! {
                                        let WholeValue = larr_value[indexvalue!]
                                        let newValue = each[fieldEach["key"].stringValue].doubleValue
                                        larr_value.remove(at: indexvalue!)
                                        larr_value.insert(WholeValue+newValue, at: indexvalue!)
                                    }else{
                                        larr_value.insert(each[fieldEach["key"].stringValue].doubleValue, at: indexvalue!)
                                    }
                                    larr_series.remove(at: li_Value)
                                    larr_series.insert(larr_value, at: li_Value)
                                    
                                    print(larr_value)
                                }else{
                                    var larr_value:[Double] = []
                                    larr_value.append(each[fieldEach["key"].stringValue].doubleValue)
                                    larr_series.insert(larr_value, at: li_Value)
                                }
                                
                                li_Value += 1
                                print(li_Value)
                                
                            default:
                                break
                            }
                            
                        }
                    }
                    
                    if larr_xaxis.count == 0 {
                        chartOptions.xaxis = nil
                    }else{
                        chartOptions.xaxis = larr_xaxis
                    }
                    
                    if larr_yaxis.count == 0 {
                        chartOptions.yaxis = nil
                    }else{
                        chartOptions.yaxis = larr_yaxis
                    }
                    
                    chartOptions.series = larr_series
                    chartOptions.seriesNames = larr_xaxis
                    chartOptions.columnIdsForTooltipFormatter = larr_xaxis
                    chartOptions.filterValuesForColumn = nil
                    completion(chartOptions)
                default:
                    break
                }
                
            case .failure( _):
                break
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
}

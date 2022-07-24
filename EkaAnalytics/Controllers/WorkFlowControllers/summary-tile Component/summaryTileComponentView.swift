//
//  summaryTileComponentView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 26/02/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class summaryTileComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var SelectedData:[JSON] = []
    var ConnectUserInfo:JSON?
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var MainStackView: UIStackView!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: summaryTileComponentView.self), owner: self, options: nil)?.first as! summaryTileComponentView
        return view as! Self
    }
    
    //MARK: - Configure the View
    
    func config(){
        
        if app_metaData!["flow"][ls_taskName!]["fields"].count > 0 {
            
            ConnectManager.shared.appendDynamicData(Meta: app_metaData!["flow"][ls_taskName!]["fields"][0].arrayValue, Data: SelectedData) { (ResultData) in
                self.SelectedData = ResultData
                self.renderSummaryUI()
            }
        }
    }
    
    private func renderSummaryUI(){
        
        var larr_fields:[JSON] = []
        var larr_stackView:[UIStackView] = []
        
        for i in 0..<app_metaData!["flow"][ls_taskName!]["fields"][0].count{
            if app_metaData!["flow"][ls_taskName!]["fields"][0][i]["type"] == nil || app_metaData!["flow"][ls_taskName!]["fields"][0][i]["type"] == "hidden"{
                larr_fields.append(app_metaData!["flow"][ls_taskName!]["fields"][0][i])
            }
        }
        
        for _ in 0..<larr_fields.count/2{
            //Stack View
            let individualStackView = UIStackView()
            individualStackView.axis  = NSLayoutConstraint.Axis.horizontal
            individualStackView.distribution  = UIStackView.Distribution.fillEqually
            larr_stackView.append(individualStackView)
        }
        
        var li_count = 2
        var j = 0
        
        for i in 0..<larr_fields.count{
            
            let summaryTitleView = summaryCustomView().loadNib()
            
            let labelResult:String = ConnectManager.shared.evaluateJavaExpression(expression: larr_fields[i]["label"].string ?? "", data: nil) as? String ?? ""
            
            var ls_Count:String = ""
            switch larr_fields[i]["aggregateFunction"].stringValue{
            case "count":
                var count = 0
                ls_Count = "-"
                for each in SelectedData {
                    if let filterExpression =  larr_fields[i]["filterExpression"].string {
                        
                        let result:String = ConnectManager.shared.evaluateJavaExpression(expression: filterExpression, data: each) as? String ?? ""
                        
                        if result == "true"{
                            count += 1
                            ls_Count = "\(count)"
                        }
                    }
                    else{
                        ls_Count = "\(SelectedData.count)"
                    }
                }
            case "sum":
                var li_sumTotal:Int = 0
                ls_Count = "-"
                for each in SelectedData {
                    if let filterExpression =  larr_fields[i]["filterExpression"].string {
                        
                        let result:String = ConnectManager.shared.evaluateJavaExpression(expression: filterExpression, data: each) as? String ?? ""
                        
                        if result == "true"{
                            li_sumTotal += each["\(larr_fields[i]["key"].stringValue)"].intValue
                            ls_Count = "\(li_sumTotal)"
                        }
                    }else{
                        li_sumTotal += each["\(larr_fields[i]["key"].stringValue)"].intValue
                        ls_Count = "\(li_sumTotal)"
                    }
                }
                if SelectedData.count > 0 && ls_Count != "-" {
                    if larr_fields[i]["suffix"] != nil {
                        
                        let suffixString = ConnectManager.shared.evaluateJavaExpression(expression: larr_fields[i]["suffix"].stringValue, data: SelectedData[0])
                        
                        ls_Count = "\(li_sumTotal) " + "\(suffixString)"
                    }else if larr_fields[i]["prefix"] != nil {
                        
                        var prefixString:String = ""
                        
                        if larr_fields[i]["prefix"].stringValue.contains("userInfo") == true{
                            prefixString = ConnectManager.shared.evaluateJavaExpression(expression: larr_fields[i]["prefix"].stringValue.replacingOccurrences(of: "userInfo.", with: ""), data: ConnectUserInfo) as? String ?? ""
                        }else{
                            prefixString = ConnectManager.shared.evaluateJavaExpression(expression: larr_fields[i]["prefix"].stringValue, data: SelectedData[0]) as? String ?? ""
                        }
                        
                        ls_Count = "\(prefixString) " + "\(li_sumTotal) "
                    }
                }else{
                    ls_Count = "-"
                }
                
            case "product":
                if let filterExpression =  larr_fields[i]["filterExpression"].string {
                    ls_Count = ConnectManager.shared.evaluateJavaExpression(expression: filterExpression, data: SelectedData[0]) as? String ?? ""
                }else{
                    ls_Count = "-"
                }
                
            default:
                ls_Count = "-"
            }
            
            summaryTitleView.config(label: labelResult, count: ls_Count)
            
            
            if li_count == 0 {
                self.MainStackView.addArrangedSubview(larr_stackView[j])
                li_count = 2
                j += 1
                larr_stackView[j].addArrangedSubview(summaryTitleView)
            }else{
                larr_stackView[j].addArrangedSubview(summaryTitleView)
                li_count -= 1
            }
            
        }
        self.MainStackView.addArrangedSubview(larr_stackView[j])
    }
    
}

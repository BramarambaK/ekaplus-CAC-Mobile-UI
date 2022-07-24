//
//  lastUpdatedComponentView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 21/03/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class lastUpdatedComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var SelectedData:[JSON] = []
    
    //MARK: - IBOutlet
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: lastUpdatedComponentView.self), owner: self, options: nil)?.first as! lastUpdatedComponentView
        return view as! Self
    }
    
    func config(){
        if SelectedData.count > 0 {
            var UpdateTime:Double = 0
            for each in SelectedData {
                if UpdateTime < each["sys__updatedOn"].doubleValue {
                    UpdateTime = each["sys__updatedOn"].doubleValue
                }
            }
            
            var Timeformat:String = ""
            var Dateformat:String = ""
            
            for each in app_metaData!["flow"][ls_taskName!]["fields"].arrayValue{
                if each["key"].string == "time" {
                    Timeformat = each["format"].stringValue
                }
                
                if each["key"].string == "date" {
                    Dateformat = each["format"].stringValue
                }
                
            }
            
            let TimeString = Utility.DateFormatString(dateFormat: Timeformat, timeInterval: UpdateTime)
            
            let DateString = Utility.DateFormatString(dateFormat: Dateformat, timeInterval: UpdateTime)
            
            self.lastUpdatedLabel.text = "Last updated at \(TimeString) on \(DateString)"
        }
    }
}

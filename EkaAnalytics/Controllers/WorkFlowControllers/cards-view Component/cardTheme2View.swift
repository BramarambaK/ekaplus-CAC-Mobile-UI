//
//  cardTheme2View.swift
//  EkaAnalytics
//
//  Created by Shreeram on 14/10/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

class cardTheme2View: UIView {
    
    @IBOutlet weak var MainStackView: UIStackView!
    
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: cardTheme2View.self), owner: self, options: nil)?.first as! cardTheme2View
        return view as! Self
    }
    
    func config(data:[JSON],fields:[JSON])
    {
        self.UpdateCardthemeUI(data: data, fields: fields)
    }
    
    private func UpdateCardthemeUI(data:[JSON],fields:[JSON]){
        
        var individualFields:JSON = [:]
        
        for i in 0..<fields.count{
            if fields[i].dictionaryObject != nil {
                individualFields = fields[i]
            }else{
                for j in 0..<fields[i].count {
                    individualFields = fields[i][j]
                }
            }
            
            let individualStackView = UIStackView()
            individualStackView.axis  = NSLayoutConstraint.Axis.horizontal
            individualStackView.distribution  = UIStackView.Distribution.fillProportionally
            individualStackView.spacing = 5
            
            if individualFields["type"].stringValue == "heading" {
                var ls_label:String = ""
                
                if individualFields["valueExpression"].string != nil {
                    ls_label = ConnectManager.shared.evaluateJavaExpression(expression: individualFields["valueExpression"].stringValue, data: data[0]) as? String ?? ""
                }else{
                    ls_label = data[0]["\(individualFields["key"])"].string ?? ""
                }
                
                //Text Label
                let textLabel = UILabel()
                textLabel.text  = ls_label
                textLabel.numberOfLines = 0
                textLabel.textAlignment = .left
                
                individualStackView.addArrangedSubview(textLabel)
            }
            else if individualFields["type"].stringValue == "detailsArray" {
                individualStackView.axis  = NSLayoutConstraint.Axis.vertical
                if individualFields["valueExpression"].string != nil {
                    let larr_data:[Any] = ConnectManager.shared.evaluateJavaExpression(expression: individualFields["valueExpression"].stringValue, data: data[0],"detailsArray") as! [Any]
                    
                    for j in 0..<larr_data.count{
                        let individualData = larr_data[j]
                        
                        let HStackView = UIStackView()
                        HStackView.axis  = NSLayoutConstraint.Axis.horizontal
                        HStackView.distribution  = UIStackView.Distribution.fillProportionally
                        HStackView.spacing = 0
                        
                        
                        //label Text Label
                        let textLabel = UILabel()
                        textLabel.text  = JSON.init(rawValue: individualData)!["label"].stringValue
                        textLabel.numberOfLines = 0
                        textLabel.textAlignment = .left
                        if j%2 == 0{
                            textLabel.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.2)
                        }
                        
                        
                        HStackView.addArrangedSubview(textLabel)
                        
                        //label Text Label
                        let valueLabel = UILabel()
                        valueLabel.text  = JSON.init(rawValue: individualData)!["value"].stringValue
                        valueLabel.numberOfLines = 0
                        valueLabel.textAlignment = .left
                        if j%2 == 0{
                            valueLabel.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 0.2)
                        }
                        
                        HStackView.addArrangedSubview(valueLabel)
                        
                        individualStackView.addArrangedSubview(HStackView)
                    }
                }
                
            }
            MainStackView.addArrangedSubview(individualStackView)
            MainStackView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}

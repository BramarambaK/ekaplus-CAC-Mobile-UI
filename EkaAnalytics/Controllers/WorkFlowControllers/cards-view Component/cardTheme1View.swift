//
//  cardTheme1View.swift
//  EkaAnalytics
//
//  Created by Shreeram on 06/10/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class cardTheme1View: UIView {
    
    //MARK: - IBOutlet
    @IBOutlet weak var MainStackView: UIStackView!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: cardTheme1View.self), owner: self, options: nil)?.first as! cardTheme1View
        return view as! Self
    }
    
    func config(data:JSON,fields:[JSON])
    {
        self.UpdateCardthemeUI(data: data, fields: fields)
    }
    
    private func UpdateCardthemeUI(data:JSON,fields:[JSON]){
        for i in 0..<fields.count{
            let individualFields = fields[i]
            
            if individualFields["visibility"] == nil || ConnectManager.shared.evaluateJavaExpression(expression:  individualFields["visibility"].stringValue, data: data) as? String ?? "" == "true" {
                let individualStackView = UIStackView()
                individualStackView.axis  = NSLayoutConstraint.Axis.horizontal
                individualStackView.distribution  = UIStackView.Distribution.fillProportionally
                individualStackView.spacing = 5
                
                if individualFields["config"]["iconClassExpression"] != nil {
                    let iconExpression:String = ConnectManager.shared.evaluateJavaExpression(expression: individualFields["config"]["iconClassExpression"].stringValue, data: data) as? String ?? ""
                    let imageView = UIImageView()
                    imageView.widthAnchor.constraint(equalToConstant: 20.0).isActive = true
                    imageView.image = UIImage(named: iconExpression)
                    individualStackView.addArrangedSubview(imageView)
                }
                
                var ls_label:String = ""
                
                if individualFields["valueExpression"].string != nil {
                    ls_label = ConnectManager.shared.evaluateJavaExpression(expression: individualFields["valueExpression"].stringValue, data: data) as? String ?? ""
                }else{
                    ls_label = data["\(individualFields["key"])"].string ?? ""
                }
                
                //Text Label
                let textLabel = UILabel()
                textLabel.text  = ls_label
                textLabel.numberOfLines = 0
                textLabel.textAlignment = .left
                
                individualStackView.addArrangedSubview(textLabel)
                
                MainStackView.addArrangedSubview(individualStackView)
                MainStackView.translatesAutoresizingMaskIntoConstraints = false
                
            }
        }
    }
}

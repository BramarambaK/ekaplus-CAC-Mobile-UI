//
//  MenuComponentView.swift
//  EkaAnalytics
//
//  Created by Shreeram on 06/09/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class MenuComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    
    //MARK: - IBOutlet
    @IBOutlet weak var stackView: UIStackView!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: MenuComponentView.self), owner: self, options: nil)?.first as! MenuComponentView
        return view as! Self
    }
    
    func config(){
        
        for i in 0..<app_metaData!["flow"][ls_taskName!]["decisions"].count {
            
            let menuView = UIView()
            menuView.heightAnchor.constraint(equalToConstant: 75).isActive = true
            
            let menuLabel = UILabel()
            if i == 0 {
                menuLabel.backgroundColor = UIColor(red: 16/255, green: 131/255, blue: 64/255, alpha: 1)
            }else{
                menuLabel.backgroundColor = UIColor(red: 177/255, green: 181/255, blue: 186/255, alpha: 1)
            }
            menuLabel.clipsToBounds = true
            menuLabel.textAlignment = .center
            menuLabel.text = "\(i+1)"
            menuLabel.textColor = .white
            menuLabel.layer.cornerRadius = 25
            
            menuView.addSubview(menuLabel)
            
            menuLabel.translatesAutoresizingMaskIntoConstraints = false
            menuLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
            menuLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            menuLabel.centerXAnchor.constraint(equalTo: menuView.centerXAnchor, constant: 0).isActive = true
            menuLabel.centerYAnchor.constraint(equalTo: menuView.centerYAnchor, constant:0).isActive = true
            
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 8.0
            
            stackView.addArrangedSubview(menuView)
        }
    }
    
}

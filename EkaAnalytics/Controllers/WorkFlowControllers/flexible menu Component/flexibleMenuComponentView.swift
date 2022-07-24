//
//  flexibleMenuComponentView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 24/03/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class flexibleMenuComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var ldict_ScreenData:[JSON]?
    var larr_ScreenData:[String:[JSON]] = [:]
    var qucikLinkData:[JSON?] = []
    var delegate:AdvancedCompositeDelegate?
    
    //MARK: - IBOutlet
    @IBOutlet weak var flexibleMenuStack: UIStackView!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: flexibleMenuComponentView.self), owner: self, options: nil)?.first as! flexibleMenuComponentView
        return view as! Self
    }
    
    func config(){
        if qucikLinkData.count>0 {
            self.getScreenData()
        }
    }
    
    private func getScreenData(){
        
        let dataBodyDictionary = ["appId":"\(app_metaData!["appId"].stringValue)","workFlowTask":"\(ls_taskName ?? "")","deviceType":"mobile"] as [String : Any]
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { [self] (dataResponse) in
            
            switch dataResponse {
            case .success(let dataJson):
                self.qucikLinkData = dataJson["data"][0]["navbar"][0]["apiMenuData"][0]["menu"].arrayValue
                
                flexibleMenuStack.removeAllArrangedSubviews()
                
                for each in qucikLinkData {
                    let MenuView = flexibleMenuView().loadNib()
                    MenuView.tag = 1
                    MenuView.MenuLabel.text = "\(each!["label"])"
                    flexibleMenuStack.addArrangedSubview(MenuView)
                    flexibleMenuStack.translatesAutoresizingMaskIntoConstraints = false
                    let tap = MyTapGesture(target: self, action: #selector(MenuClicked(sender:)))
                    tap.menuItem = each!
                    MenuView.addGestureRecognizer(tap)
                }
                
                
            case .failure(let error):
                print(error.description)
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
    
    @objc func MenuClicked(sender:MyTapGesture) {
        delegate?.gettaskDetails(taskName: sender.menuItem["handler"].stringValue, queryparameter: nil)
    }
    
}

class MyTapGesture: UITapGestureRecognizer {
    var menuItem = JSON()
}

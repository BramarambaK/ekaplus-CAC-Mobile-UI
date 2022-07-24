//
//  QueryComponentView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 16/02/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol QueryComponentViewDelegate {
    func UpdatePickerValue(MyPickerData:JSON?)
}

final class QueryComponentView: UIView {
    
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var ldict_dropdownData:JSON?
    var larr_dropDownServiceKey:[[String:Any]]=[]
    var ldict_ScreenData:[JSON]?
    var larr_ScreenData:[String:[JSON]] = [:]
    var delegate:AdvancedCompositeDelegate?
    var SelectedQuery:JSON?
    
    //MARK: - IBOutlet
    @IBOutlet weak var lbl_Header: UILabel!
    @IBOutlet weak var lbl_SubHeader: UILabel!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: QueryComponentView.self), owner: self, options: nil)?.first as! QueryComponentView
        return view as! Self
    }
    
    //MARK: - Configure the View
    func config(viewData:String?){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
        
        if viewData != nil {
            DispatchQueue.main.async {
                let splitviewData = viewData!.components(separatedBy: "\n")
                self.lbl_Header.text = splitviewData[0]
                if splitviewData.count > 1 {
                    self.lbl_SubHeader.text = splitviewData[1]
                }
            }
        }
        
        if app_metaData!["flow"][ls_taskName!]["layout"]["getInitialData"] == true && larr_ScreenData.count == 0 {
            self.getScreenData()
        }
        
        if ldict_dropdownData == nil {
            self.getMDMData()
        }
        
    }
    
    //MARK: - Local Function
    
    private func getScreenData(){
        
        let dataBodyDictionary = ["appId":"\(app_metaData!["appId"].stringValue)","workFlowTask":"\(ls_taskName ?? "")","deviceType":"mobile","qP":["from":0,"size":app_metaData!["flow"][ls_taskName!]["rows"].stringValue]] as [String : Any]
        
        self.larr_ScreenData.removeAll()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { (dataResponse) in
            
            switch dataResponse {
            case .success(let dataJson):
                self.larr_ScreenData.removeAll()
                self.ldict_ScreenData = dataJson["data"].arrayValue
                
                let ls_filterBy = self.app_metaData!["flow"][self.ls_taskName!]["fields"][0]["filterBy"].string
                
                if ls_filterBy != nil {
                    for i in 0..<self.ldict_ScreenData!.count {
                        var larrData:[JSON] = self.larr_ScreenData["\(self.ldict_ScreenData![i]["\(ls_filterBy!)"])"] ?? []
                        
                        larrData.append(self.ldict_ScreenData![i])
                        
                        self.larr_ScreenData["\(self.ldict_ScreenData![i]["\(ls_filterBy!)"])"] = larrData
                    }
                }
                
                if self.ldict_dropdownData != nil {
                    self.delegate?.updateData(larr_ScreenData: self.larr_ScreenData)
                    self.delegate?.refreshScreen(MyPickerData: self.ldict_dropdownData!["\(self.larr_dropDownServiceKey[0]["serviceKey"]!)"].arrayValue)
                }
                
            case .failure(let error):
                print(error.description)
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
    
    private func getMDMData(){
        
        let ldict_object:JSON? = app_metaData!["objectMeta"]
        
        for each in app_metaData!["flow"][ls_taskName!]["fields"].arrayValue {
            
            let rowField = ldict_object!["fields"]["\(each["key"])"]
            
            if ((rowField["type"] == "dropdown"||each["filterType"] == "dropdown") && rowField["serviceKey"] != JSON.null && rowField["parent"] == JSON.null){
                var DropdownServiceKey:[String:Any] = [:]
                if rowField["dependsOn"] != JSON.null {
                    DropdownServiceKey["serviceKey"] = rowField["serviceKey"].stringValue
                    DropdownServiceKey["dependsOn"] = rowField["dependsOn"].arrayObject
                }else{
                    DropdownServiceKey["serviceKey"] = rowField["serviceKey"].stringValue
                }
                larr_dropDownServiceKey.append(DropdownServiceKey)
            }
        }
        
        if larr_dropDownServiceKey.count > 0 {
            
            let bodyObject = ["deviceType":"mobile","appId":"\(app_metaData!["appId"].stringValue)","workFlowTask":ls_taskName!, "data": larr_dropDownServiceKey] as [String : Any]
            
            ConnectManager.shared.getMdmData(bodyObject: bodyObject) { (response) in
                
                switch response{
                case .success(let json):
                    
                    /*
                     let mdmData = ["\(self.larr_dropDownServiceKey[0]["serviceKey"]!)":[["key":"10125675","value":"Mortlock P + V Nominees\n10125675"],["key":"13819023","value":"BJ & SRF ACKLAND\n13819023"]]].jsonString()
                     
                     self.ldict_dropdownData = JSON(parseJSON: mdmData)
                     */
                    
                    self.ldict_dropdownData = json
                    if self.ldict_dropdownData!["\(self.larr_dropDownServiceKey[0]["serviceKey"]!)"] != nil{
                        self.config(viewData: self.SelectedQuery?["value"].string ?? self.ldict_dropdownData!["\(self.larr_dropDownServiceKey[0]["serviceKey"]!)"][0]["value"].stringValue)
                        self.delegate?.setDelegate(delegate: self)
                        if self.SelectedQuery == nil {
                            self.delegate?.setInitalValue(SelectedData: self.larr_ScreenData["\(self.ldict_dropdownData!["\(self.larr_dropDownServiceKey[0]["serviceKey"]!)"][0]["key"].stringValue)"], query: self.ldict_dropdownData!["\(self.larr_dropDownServiceKey[0]["serviceKey"]!)"][0])
                        }else{
                            self.delegate?.setInitalValue(SelectedData: self.larr_ScreenData["\(self.SelectedQuery!["key"].stringValue)"], query: self.SelectedQuery)
                        }
                    }
                case .failure(let error):
                    print(error.description)
                case .failureJson(let errorJson):
                    print(errorJson)
                }
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        self.delegate?.setDelegate(delegate: self)
        self.delegate?.updateData(larr_ScreenData: self.larr_ScreenData)
        
        if ldict_dropdownData != nil {
            self.delegate?.addPickerView(MyPickerData: self.ldict_dropdownData!["\(self.larr_dropDownServiceKey[0]["serviceKey"]!)"].arrayValue)
        }
    }
}

extension QueryComponentView : QueryComponentViewDelegate{
    
    func UpdatePickerValue(MyPickerData: JSON?) {
        if MyPickerData != nil {
            self.config(viewData: MyPickerData!["value"].stringValue)
        }
    }
    
}

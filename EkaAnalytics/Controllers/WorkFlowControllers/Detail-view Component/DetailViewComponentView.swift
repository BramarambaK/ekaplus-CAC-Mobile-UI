//
//  DetailViewComponentView.swift
//  EkaAnalytics
//
//  Created by Shreeram on 22/11/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

class DetailViewComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var larr_screenFields:[JSON]?
    var ldict_object:JSON?
    var larr_ScreenData:JSON?
    var delegate:AdvancedCompositeDelegate?
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableView_Height: NSLayoutConstraint!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: DetailViewComponentView.self), owner: self, options: nil)?.first as! DetailViewComponentView
        return view as! Self
    }
    
    func config(){
        tableView.delegate = self
        tableView.dataSource = self
        
        larr_screenFields = app_metaData!["flow"][ls_taskName!]["fields"].array
        self.ldict_object = app_metaData!["objectMeta"]
        self.setupData()
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: DetailTableViewCell.reuseIdentifier)
    }
    
    private func setupData(){
        if app_metaData!["flow"][ls_taskName!]["layout"]["getInitialData"].bool == true {
            getScreenData()
        }
    }
    
    private func getScreenData(){
        var dataBodyDictionary = ["appId":"\(self.app_metaData!["appId"].stringValue)","workFlowTask":"\(ls_taskName ?? "")","deviceType":"mobile"] as [String : Any]
        
        if self.larr_ScreenData != nil {
            dataBodyDictionary["payLoadData"] = self.larr_ScreenData!.dictionaryObject!
        }
        
        delegate?.showIndicator()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) {  (dataResponse) in
            
            self.delegate?.hideIndicator()
            
            switch dataResponse {
            case .success(let dataJson):
                self.larr_ScreenData = dataJson["data"][0]
                self.tableView.reloadData()
            case .failure(let error):
                print(error.description)
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
    
}

extension DetailViewComponentView:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return larr_screenFields![section].count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowField = ldict_object!["fields"]["\(larr_screenFields![indexPath.section][indexPath.row]["key"])"]
        
        switch larr_screenFields![indexPath.section][indexPath.row]["type"].string {
        case "hidden":
            let SelectedField = ldict_object!["fields"]["\(larr_screenFields![indexPath.section][indexPath.row]["key"])"]
            
            if let visibility =  ldict_object!["fields"][SelectedField["labelKey"].stringValue]["UIupdates"]["visibility"].string {
                let result:String = ConnectManager.shared.evaluateJavaExpression(expression: visibility, data: larr_ScreenData) as? String ?? ""
                
                if result == "true" {
                    self.larr_screenFields![indexPath.section][indexPath.row]["type"] = nil
                    self.tableView.reloadData()
                }
            }
            
            
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            return cell
        default:
            if rowField != nil{
                let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableViewCell.reuseIdentifier, for: indexPath) as! DetailTableViewCell
                
                if larr_screenFields![indexPath.section][indexPath.row]["label"].string == nil {
                    cell.lbl_Columnlabel.text = "\(rowField[rowField["labelKey"].stringValue])" + ":"
                }else{
                    cell.lbl_Columnlabel.text = "\(larr_screenFields![indexPath.section][indexPath.row]["label"].stringValue)" + ":"
                }
                
                if larr_ScreenData != nil {
                    switch rowField["type"].stringValue {
                    case "dropdown" :
                        cell.lbl_ColumnValue.text = larr_ScreenData!["\(rowField["dropdownValue"])"].stringValue
                    default :
                        if larr_screenFields![indexPath.section][indexPath.row]["valueExpression"].string != nil{
                            let result:String = ConnectManager.shared.evaluateJavaExpression(expression: larr_screenFields![indexPath.section][indexPath.row]["valueExpression"].stringValue, data: larr_ScreenData) as? String ?? ""
                            cell.lbl_ColumnValue.text = result
                        }else{
                            cell.lbl_ColumnValue.text = larr_ScreenData!["\(rowField["labelKey"])"].stringValue
                        }
                    }
                }
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowField:JSON = []
        
        rowField = larr_screenFields![indexPath.section][indexPath.row]
        
        switch rowField["type"] {
        case "hidden":
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            var screenData:[JSON] = []
            screenData.append(self.larr_ScreenData!)
            
            self.tableView_Height.constant = self.tableView.contentSize.height
            self.delegate?.updateScreenData(taskName: self.ls_taskName!, ScreenData: screenData)
        }
    }
    
}

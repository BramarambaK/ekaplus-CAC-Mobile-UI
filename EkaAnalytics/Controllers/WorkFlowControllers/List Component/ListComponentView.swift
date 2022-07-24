//
//  ListComponentView.swift
//  EkaAnalytics
//
//  Created by Shreeram on 23/11/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

class ListComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var selectedData:JSON?
    var larr_Decision:[JSON]?
    var ldict_rowDecision:JSON?
    var larr_rawData:[JSON] = []
    var rootNavVC:UINavigationController!
    var delegate:AdvancedCompositeDelegate?
    var larr_Datasource:[[[NSMutableAttributedString]]] = []
    
    lazy var DynamicApiController:DynamicAppApiController = {
        return DynamicAppApiController()
    }()
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: ListComponentView.self), owner: self, options: nil)?.first as! ListComponentView
        return view as! Self
    }
    
    func config(){
        tableView.delegate = self
        tableView.dataSource = self
        
        if larr_rawData.count == 0 {
            tableView.noDataMessage = "No Data"
        }else{
            tableView.noDataMessage = nil
        }
        
        self.setupData()
        
        tableView.register(UINib(nibName: "ListTableViewCell", bundle: nil), forCellReuseIdentifier: ListTableViewCell.reuseIdentifier)
    }
    
    private func setupData(){
        if app_metaData!["flow"][ls_taskName!]["layout"]["getInitialData"].bool == true || app_metaData!["flow"][ls_taskName!]["layout"]["getInitialData"].bool == nil {
            self.getScreenData()
        }
        
        larr_Decision = app_metaData?["flow"][ls_taskName!]["decisions"].arrayValue
        
        if larr_Decision != nil && larr_Decision!.count > 0{
            for n in 0...larr_Decision!.count-1 {
                switch self.larr_Decision![n]["position"].stringValue {
                case "row-selection":
                    self.ldict_rowDecision = larr_Decision![n]
                default:
                    break
                }
            }
        }
    }
    
    private func getScreenData(){
        
        var dataBodyDictionary = ["appId":"\(self.app_metaData!["appId"].stringValue)","workFlowTask":"\(ls_taskName ?? "")","deviceType":"mobile"] as [String : Any]
        
        if self.selectedData != nil {
            dataBodyDictionary["payLoadData"] = self.selectedData?.dictionaryObject
        }
        
        delegate?.showIndicator()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { (dataResponse) in
            
            self.delegate?.hideIndicator()
            
            switch dataResponse {
            case .success(let dataJson):
                let listData = (dataJson.dictionary!["data"]!).arrayValue
                
                for each in listData{
                    self.larr_rawData.append(each)
                }
                
                if listData.count > 0 {
                    let larr_fields = self.app_metaData!["flow"][self.ls_taskName!]["fields"].arrayValue
                    let ldict_object = self.app_metaData!["objectMeta"]["fields"].dictionaryValue
                    
                    self.delegate?.showIndicator()
                    self.DynamicApiController.DataObjectMapping(DataJson: self.larr_rawData, FieldsJson: larr_fields, ObjectJson: ldict_object, DropDownData: nil) { (DataMappingresponse) in
                        
                        self.delegate?.hideIndicator()
                        
                        switch DataMappingresponse{
                        case .success(let listData):
                            self.larr_Datasource = listData as [[[NSMutableAttributedString]]]
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.setNeedsLayout()
                                self.tableView.layoutIfNeeded()
                                self.tableView.reloadData()
                            }
                        case .failure(let error):
                            print(error.description)
                        case .failureJson(_):
                            break
                        }
                        
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

extension ListComponentView:UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if larr_Datasource.count > 0 {
            tableView.noDataMessage = nil
        }
        return larr_Datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListTableViewCell.reuseIdentifier, for: indexPath) as! ListTableViewCell
        
        
        let rowData = larr_Datasource[indexPath.row]
        
        if rowData.count > 0 {
            
            //Row 0
            if rowData[0].count == 3 {
                if rowData[0][0].string  != "" {
                    cell.imageView?.image = UIImage(named: rowData[0][0].string)
                    cell.rowWidth00.constant = 20
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-65)/2
                    cell.rowWidth02.constant = (cell.contentView.bounds.width-65)/2
                }else{
                    cell.rowWidth00.constant = 0
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-45)/2
                    cell.rowWidth02.constant = (cell.contentView.bounds.width-45)/2
                }
                
                //Set Value for Label
                cell.lbl_row01.attributedText = rowData[0][1]
                cell.lbl_row02.attributedText = rowData[0][2]
                
            }
            else if rowData[0].count == 2{
                if rowData[0][0].string  != "" {
                    cell.imageView?.image = UIImage(named: rowData[0][0].string)
                    cell.rowWidth00.constant = 20
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-65)
                }else{
                    cell.rowWidth00.constant = 0
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-45)
                }
                
                cell.lbl_row01.attributedText = rowData[0][1]
            }
            else{
                cell.rowSep00.constant = 0
            }
            
            //Row 1
            if rowData[1].count == 3 {
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth11.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth12.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowSep10.constant = 1
                cell.rowSep11.constant = 1
                
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
                cell.lbl_row11.attributedText = rowData[1][1]
                cell.lbl_row12.attributedText = rowData[1][2]
            }
            else if rowData[1].count == 2{
                //Set Row width
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowWidth12.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowSep10.constant = 1
                cell.rowSep11.constant = 0
                
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
                cell.lbl_row12.attributedText = rowData[1][1]
            }
            else if rowData[1].count == 1{
                //Set Row width
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)
                cell.rowSep10.constant = 0
                cell.rowSep11.constant = 0
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
            }
            else{
                cell.rowSep01.constant = 0
            }
            
            //Row 2
            if rowData[2].count == 3 {
                //Set Row width
                cell.rowWidth20.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth21.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth22.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowSep20.constant = 1
                cell.rowSep21.constant = 1
                
                //Set Value for Label
                cell.lbl_row20.attributedText = rowData[2][0]
                cell.lbl_row21.attributedText = rowData[2][1]
                cell.lbl_row22.attributedText = rowData[2][2]
            }
            else if rowData[2].count == 2{
                //Set Row width
                cell.rowWidth20.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowWidth22.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowSep20.constant = 0
                cell.rowSep21.constant = 1
                
                //Set Value for Label
                cell.lbl_row20.attributedText = rowData[2][0]
                cell.lbl_row22.attributedText = rowData[2][1]
            }
            else if rowData[2].count == 1{
                //Set Row width
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)
                cell.rowSep10.constant = 0
                cell.rowSep11.constant = 0
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
            }else{
                cell.rowSep01.constant = 0
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ldict_rowDecision != nil {
            
            let bodydictionary = ["appId":"\(self.app_metaData!["appId"].stringValue)","workFlowTask":"\(ldict_rowDecision!["outcomes"][0]["name"])", "deviceType":"mobile"] as [String : Any]
            
            delegate?.showIndicator()
            
            ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                self.delegate?.hideIndicator()
                switch taskResponse {
                case .success(let json):
                    if self.ldict_rowDecision!["outcomes"][0]["targetPath"] != nil {
                        let WebVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "WebViewVC") as! WebViewController
                        WebVC.ls_taskName = self.ldict_rowDecision!.dictionaryValue["outcomes"]![0]["name"].stringValue
                        WebVC.layoutJson = json
                        WebVC.ls_previousWorkflow = self.ls_taskName
                        WebVC.ls_targetPath = self.ldict_rowDecision!["outcomes"][0]["targetPath"].stringValue
                        WebVC.ls_orientation = self.ldict_rowDecision!["outcomes"][0]["orientation"].stringValue
                        WebVC.ldict_ScreenData = self.larr_rawData[indexPath.row]
                        WebVC.ls_appName = self.app_metaData!["appId"].stringValue
                        self.rootNavVC.pushViewController(WebVC, animated: true)
                    }else{
                        
                        switch json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["layout"]["name"].stringValue {
                            
                        case "view":
                            let DetailVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
                            DetailVC.app_metaData =  json
                            DetailVC.ls_appName = self.app_metaData!["appId"].stringValue
                            DetailVC.ls_taskName = self.ldict_rowDecision!["outcomes"][0]["name"].stringValue
                            DetailVC.larr_ScreenData = self.larr_rawData[indexPath.row]
                            
                            if json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue.contains("${"){
                            }
                            else{
                                DetailVC.ls_ScreenTitle = json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                            }
                            
                            self.delegate?.pushViewController(Vc: DetailVC)
                        
                            
                        default:
                            let DetailVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
                            DetailVC.app_metaData =  json
                            DetailVC.ls_appName = self.app_metaData!["appId"].stringValue
                            DetailVC.ls_taskName = self.ldict_rowDecision!["outcomes"][0]["name"].stringValue
                            DetailVC.larr_ScreenData = self.larr_rawData[indexPath.row]
                            
                            if json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue.contains("${"){
                                
                                let title = json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                                
                                var titleString:String? = ""
                                
                                if title != "null"{
                                    let titleStartIndex =  title.range(of: "${")?.upperBound
                                    let titleEndIndex =  title.range(of: "}")?.lowerBound
                                    
                                    
                                    if titleStartIndex != nil && titleEndIndex != nil {
                                        var titleSubstring = title[(title.range(of: "${"))!.upperBound..<(title.range(of: "}"))!.lowerBound]
                                        if titleSubstring.contains("."){
                                            let titleSubstringsplit = titleSubstring.components(separatedBy: ".")
                                            titleSubstring = "\(titleSubstringsplit[titleSubstringsplit.count-1])"
                                        }
                                        
                                        let titleReplaceSubstring = title[(title.range(of: "${"))!.lowerBound ..< (title.range(of: "}"))!.upperBound]
                                        if self.larr_rawData.count > 0 {
                                            titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_rawData[indexPath.row]["\(titleSubstring)"].stringValue)
                                        }
                                    }else{
                                        titleString = title
                                    }
                                }else{
                                    titleString = nil
                                }
                                DetailVC.ls_ScreenTitle = titleString
                                
                            }else{
                                DetailVC.ls_ScreenTitle = json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                            }
                            
                            self.delegate?.pushViewController(Vc: DetailVC)
                        }
                    }
                    
                case .failure(let error):
                    print(error.localizedDescription)
                case .failureJson(_):
                    break
                }
            }
        }
    }
}

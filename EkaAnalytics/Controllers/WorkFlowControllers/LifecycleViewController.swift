//
//  LIfecycleViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 02/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

class LifeCycleViewController: UIViewController,HUDRenderer,UITableViewDelegate,UITableViewDataSource {
    
    //MARK: - Variable
    
    var app_metadata:JSON?
    var ls_taskName:String?
    var ldict_ScreenData:JSON?
    var ls_appName:String?
    var ls_topHeading:String = ""
    var ls_heading:String = ""
    
    var ldict_topHeading:[JSON] = []
    var ldict_header:[JSON] = []
    var ldict_row1:[JSON] = []
    var ldict_row2:[JSON] = []
    var ldict_row3:[JSON] = []
    var larr_lifeCycleArray:[Any] = []
    
    let defaultPageSize = 10
    var DataCurrentpage = 0
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MMM-dd"
        return df
    }()
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var LifeCycleTableView: UITableView!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let BackButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action:  #selector(goBack))
        
        self.navigationItem.setLeftBarButtonItems([BackButton], animated: true)
        
        //Screen Title
        
        if let ls_ScreenTitle = app_metadata!["flow"][ls_taskName!]["label"].string {
            self.navigationItem.title = "\(ls_ScreenTitle)"
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        LifeCycleTableView.estimatedRowHeight = 100
        
        WorkFlowProcess()
        
    }
    
    //MARK: - Tableview Delegate and DataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return larr_lifeCycleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if ldict_topHeading.count > 0 && indexPath.row == 0{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopHeaderCell", for: indexPath) as! TopHeaderTableViewCell
            
            cell.lbl_topHeader.text = larr_lifeCycleArray[indexPath.row] as? String
            cell.selectionStyle = .none
            return cell
        }else if (ldict_header.count > 0 && indexPath.row == 1) || (ldict_header.count > 0 && indexPath.row == 0){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderTableViewCell
            
            cell.lbl_Header.text = larr_lifeCycleArray[indexPath.row] as? String
             cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LifeCycleCell", for: indexPath) as! LifeCycleTableViewCell
            
            cell.lblDate.text = ((larr_lifeCycleArray[indexPath.row] as! NSArray)[0] as! NSArray)[0] as? String
            cell.lblPrice.text = ((larr_lifeCycleArray[indexPath.row] as! NSArray)[1] as! NSArray)[0] as? String
            if (larr_lifeCycleArray[indexPath.row] as! NSArray).count > 2 {
                cell.lblRemarks.text = ((larr_lifeCycleArray[indexPath.row] as! NSArray)[2] as! NSArray)[0] as? String
            }
            cell.indicatorImageView.image = #imageLiteral(resourceName: "Published_with _bg")
            cell.selectionStyle = .none
            if indexPath.row == larr_lifeCycleArray.count - 1{
                cell.dashedLineView.isHidden = true
            }
            return cell
        }
    }
    
    
    //MARK: - Local Function
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func WorkFlowProcess(){
        
        if let fields = app_metadata!["flow"][ls_taskName!]["fields"].array {
            
            for each in fields {
                switch each["placement"] {
                case "topHeading":
                    ldict_topHeading.append(each)
                case "header":
                    ldict_header.append(each)
                case "row1":
                    ldict_row1.append(each)
                case "row2":
                    ldict_row2.append(each)
                case "row3":
                    ldict_row3.append(each)
                default:
                    break
                }
            }
        }
        getScreenData()
    }
    
    func getScreenData(){
        
        let bodydictionary = ["appId":"\(self.ls_appName!)", "workFlowTask":"\(self.ls_taskName!)","payLoadData":ldict_ScreenData!.dictionaryObject!] as [String : Any]
        
        
////        let bodydictionary = ["appId":"\(self.ls_appName!)",
//            "workFlowTask":"\(self.ls_taskName!)","params":["start": self.DataCurrentpage,"limit":self.defaultPageSize]] as [String : Any]
        
        self.showActivityIndicator()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: bodydictionary) {
            (dataResponse) in
            
            self.hideActivityIndicator()
            
            switch dataResponse {
            case .success(let dataJson):
                
                //Top Heading
                
                if self.ldict_topHeading.count > 0 {
                    for each in self.ldict_topHeading {
                        if (self.app_metadata!["objectMeta"]["fields"][each["key"].stringValue]).count > 0{
                            let labelKey = self.app_metadata!["objectMeta"]["fields"][each["key"].stringValue]["labelKey"].stringValue
                            
                            self.ls_topHeading = self.ls_topHeading + "\(self.ldict_ScreenData![labelKey])"
                        }else{
                            self.ls_topHeading = self.ls_topHeading + "\(each["key"].stringValue) : "
                        }
                    }
                    self.larr_lifeCycleArray.append(self.ls_topHeading)
                }
                
                //Heading
                
                if self.ldict_header.count > 0 {
                    for each in self.ldict_header {
                        let headerFieldObjectMeta = self.app_metadata!["objectMeta"]["fields"][each["key"].stringValue]
                        let ls_labelKey = headerFieldObjectMeta["labelKey"].stringValue
                        let ls_label = "\(headerFieldObjectMeta[headerFieldObjectMeta["labelKey"].stringValue].stringValue) : "
                        
                        var ls_Data = ""
                        
                        if each["dateformat"] != JSON.null {
                            let ls_datavalue:String = "\((self.ldict_ScreenData![ls_labelKey].stringValue).components(separatedBy: "T")[0])"
                            self.dateFormatter.dateFormat =
                                each["dateformat"].stringValue
                            
                            if ls_datavalue.count > 0 {
                                ls_Data = self.dateFormatter.string(from: self.dateFormatter.date(from: ls_datavalue)!) + "\n"
                            }else{
                                ls_Data = "\n"
                            }
                        }else{
                            if dataJson["data"][0] != nil {
                                 ls_Data = "\(dataJson["data"][0][ls_labelKey].stringValue)\n"
                            }else{
                                ls_Data = "\(self.ldict_ScreenData![ls_labelKey].stringValue)\n"
                            }
                        }
                        
                        if ls_Data.count > 0 {
                             self.ls_heading = self.ls_heading + ls_label + ls_Data
                        }
                       
                    }
                    
                    self.larr_lifeCycleArray.append(self.ls_heading)
                }
                
                
                if self.ldict_row1.count > 0 || self.ldict_row2.count > 0 || self.ldict_row3.count > 0 {
                    
                    if let data = dataJson["data"].array {
                        var larr_RowData:[[Any]] = []
                        for each in data {
                            larr_RowData = []
                            
                            if self.ldict_row1.count > 0 {
                                var larr_Row1Data:String = ""
                                for eachRow1 in self.ldict_row1{
                                    let ls_labelKey = self.app_metadata!["objectMeta"]["fields"][eachRow1["key"].stringValue]["labelKey"].stringValue
                                    let ls_label = "\(self.app_metadata!["objectMeta"]["fields"][eachRow1["key"].stringValue][self.app_metadata!["objectMeta"]["fields"][eachRow1["key"].stringValue]["labelKey"].stringValue].stringValue) : "
                                    
                                    var ls_Data = ""
                                    
                                    if eachRow1["dateformat"] != JSON.null {
                                        if (each[ls_labelKey].stringValue).count > 2 {
                                            let ls_datavalue:String = "\((each[ls_labelKey].stringValue).replacingOccurrences(of: "T", with: " "))"
                                            self.dateFormatter.dateFormat =
                                                eachRow1["dateformat"].stringValue
                                            ls_Data = self.dateFormatter.string(from: self.dateFormatter.date(from: ls_datavalue)!) + "\n"
                                        }else{
                                            if ls_labelKey != "" {
                                                ls_Data = "\(each[ls_labelKey].stringValue)\n"
                                            }else{
                                                ls_Data = "\(each[eachRow1["key"].stringValue].stringValue)\n"
                                            }
                                        }
                                    }else{
                                        if ls_labelKey != "" {
                                            ls_Data = "\(each[ls_labelKey].stringValue)\n"
                                        }else{
                                            ls_Data = "\(each[eachRow1["key"].stringValue].stringValue)\n"
                                        }
                                    }

                                    if ls_Data.count > 0 {
                                        larr_Row1Data = larr_Row1Data + ls_label + ls_Data
                                    }
                                }
                                larr_RowData.append([larr_Row1Data])
                            }
                            
                            if self.ldict_row2.count > 0 {
                                var larr_Row2Data:String = ""
                                for eachRow2 in self.ldict_row2{
                                    let ls_labelKey = self.app_metadata!["objectMeta"]["fields"][eachRow2["key"].stringValue]["labelKey"].stringValue
                                    let ls_label = "\(self.app_metadata!["objectMeta"]["fields"][eachRow2["key"].stringValue][self.app_metadata!["objectMeta"]["fields"][eachRow2["key"].stringValue]["labelKey"].stringValue].stringValue) : "
                                    
                                    var ls_Data = ""
                                    
                                    if ls_labelKey != "" {
                                        ls_Data = "\(each[ls_labelKey].stringValue)\n"
                                    }else{
                                        ls_Data = "\(each[eachRow2["key"].stringValue].stringValue)\n"
                                    }
                                    
                                    if ls_Data.count > 0 {
                                         larr_Row2Data = larr_Row2Data + ls_label + ls_Data
                                    }
                                   
                                }
                                larr_RowData.append([larr_Row2Data])
                            }
                            
                            if self.ldict_row3.count > 0 {
                                var larr_Row3Data:String = ""
                                for eachRow3 in self.ldict_row3{
                                    let ls_labelKey = self.app_metadata!["objectMeta"]["fields"][eachRow3["key"].stringValue]["labelKey"].stringValue
                                    let ls_label = "\(self.app_metadata!["objectMeta"]["fields"][eachRow3["key"].stringValue][self.app_metadata!["objectMeta"]["fields"][eachRow3["key"].stringValue]["labelKey"].stringValue].stringValue) : "
                                    
                                    var ls_Data = ""
                                    
                                    if ls_labelKey != "" {
                                        ls_Data = "\(each[ls_labelKey].stringValue)\n"
                                    }else{
                                        ls_Data = "\(each[eachRow3["key"].stringValue].stringValue)\n"
                                    }
                                    
                                    if ls_Data.count > 0 {
                                        larr_Row3Data = larr_Row3Data + ls_label + ls_Data
                                    }
                                   
                                }
                                larr_RowData.append([larr_Row3Data])
                            }
                            
                            self.larr_lifeCycleArray.append(larr_RowData)
                        }
                    }
                }
                
                
                self.LifeCycleTableView.reloadData()
                
            case .failure(let error):
                self.showAlert(message: error.description)
                
            case .failureJson(let errorJson):
                print(errorJson)
            }
            
        }
    }
}

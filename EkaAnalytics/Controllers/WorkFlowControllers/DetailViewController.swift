//
//  DetailViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 23/01/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit
import JavaScriptCore

protocol DetailViewDelegate {
    func DetailViewHeight(workFlowName:String,tableHeight:CGFloat)
}

class DetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,HUDRenderer {
    
    //MARK: - Variable
    var ls_ScreenTitle:String?
    var app_metaData:JSON?
    var ls_appName:String?
    var ls_taskName:String?
    var larr_screenFields:[JSON]?
    var ldict_object:JSON?
    var larr_ScreenData:JSON?
    var larr_Decision:[JSON]?
    var ldict_Decision:JSON?
    var delegate:DetailViewDelegate?
    var larr_dropDownServiceKey:[[String:Any]]=[]
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableView_Height: NSLayoutConstraint!
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let BackButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action:  #selector(goBack))
        
        self.navigationItem.setLeftBarButtonItems([BackButton], animated: true)
        
        if ls_ScreenTitle != nil {
            DispatchQueue.main.async {
                self.setTitle("\(self.ls_ScreenTitle ?? "")")
            }
            
//            self.navigationItem.title = "\(ls_ScreenTitle ?? "")"
//            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        }
        
        larr_screenFields = app_metaData!["flow"][ls_taskName!]["fields"].array
        self.ldict_object = app_metaData!["objectMeta"]
        self.larr_Decision = app_metaData!["flow"][ls_taskName!]["decisions"].array
        
        self.setupData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize = tableView.contentSize
    }

    
    //MARK: - TableView Delegate and Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return larr_screenFields![section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowField = ldict_object!["fields"]["\(larr_screenFields![indexPath.section][indexPath.row]["key"])"]
        
        if larr_screenFields![indexPath.section][indexPath.row]["type"] == JSON.null {
            if rowField != nil{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! DetailViewTableViewCell
                
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
            
        }else{
            switch larr_screenFields![indexPath.section][indexPath.row]["type"].stringValue {
            case "hidden":
                let SelectedField = ldict_object!["fields"]["\(larr_screenFields![indexPath.section][indexPath.row]["key"])"]
                
                self.VisibilityandDisability(field: SelectedField, Section: indexPath.section, Row: indexPath.row)
                
                let cell = UITableViewCell()
                cell.selectionStyle = .none
                return cell
            default:
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
            self.tableView_Height.constant = self.tableView.contentSize.height
            self.view.layoutIfNeeded()
            self.delegate?.DetailViewHeight(workFlowName: self.ls_taskName!, tableHeight: self.tableView_Height.constant)
        }
    }
    
    //MARK: - Local Function
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc
    func optionsButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        let config = FTPopOverMenuConfiguration.default()
        config?.tintColor = .white
        config?.textColor = .black
        config?.menuWidth = 150
        config?.menuTextMargin = 15
        
        var menuArray:[String] = []
        
        for each in larr_Decision! {
            menuArray.append(each["label"].stringValue)
        }
        
        FTPopOverMenu.show(from: event, withMenuArray: menuArray, doneBlock: { (selectedIndex) in
            print(self.larr_Decision![selectedIndex])
            
            self.showActivityIndicator()
            
            self.ldict_Decision = self.larr_Decision![selectedIndex]
            
            let bodydictionary = ["appId":"\(self.ls_appName!)",
                "workFlowTask":"\( self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])",
                "deviceType":"mobile"] as [String : Any]
            
            ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                self.hideActivityIndicator()
                
                switch taskResponse {
                case .success(let json):
                    switch json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["name"].stringValue {
                        
                    case "cancelpopup":
                        var alertController : UIAlertController
                        
                         let title = "\(json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["option"]["headerMessage"])"
                        
                        var titleString:String? = ""
                        
                        if title != "null"{
                        let titleStartIndex =  title.range(of: "${")?.upperBound
                        let titleEndIndex =  title.range(of: "}")?.lowerBound
                        
                        
                        if titleStartIndex != nil && titleEndIndex != nil {
                        let titleSubstring = title[(title.range(of: "${"))!.upperBound..<(title.range(of: "}"))!.lowerBound]
                        let titleReplaceSubstring = title[(title.range(of: "${"))!.lowerBound ..< (title.range(of: "}"))!.upperBound]
                            titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_ScreenData!["\(titleSubstring)"].stringValue)
                        }else{
                        titleString = title
                        }
                        }else{
                        titleString = nil
                        }
                        
                        let message = "\(json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["option"]["bodyMessage"])"
                        
                        let msgStartIndex =  message.range(of: "${")?.upperBound
                        let msgEndIndex =  message.range(of: "}")?.lowerBound
                        var msgString = ""
                        
                        if msgStartIndex != nil && msgEndIndex != nil {
                        let messageSubstring =  message[(message.range(of: "${"))!.upperBound..<(message.range(of: "}"))!.lowerBound]
                        let messageReplaceSubstring = message[(message.range(of: "${"))!.lowerBound ..< (message.range(of: "}"))!.upperBound]
                        msgString = message.replacingOccurrences(of: messageReplaceSubstring, with: self.larr_ScreenData!["\(messageSubstring)"].stringValue)
                        }else{
                        msgString = message
                        }
                        
                        alertController = UIAlertController(title: titleString , message: msgString, preferredStyle:UIAlertController.Style.actionSheet)
                        
                        
                        let decision = json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["decisions"]
                        
                        for i in 0..<decision.count {
                            let Action = UIAlertAction(title: decision[i]["label"].stringValue, style:UIAlertAction.Style.default) { (finish) in
                                
                                if decision[i]["type"] != JSON.null && decision[i]["type"] == "submit" {
                                    self.submitData(decision: decision[i].dictionaryValue)
                                }
                                
                            }
                            alertController.addAction(Action)
                        }
                        
                        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    default:
                        let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                         CreateVC.app_metaData =  json
//                         CreateVC.ls_appName = self.ls_appName!
                        CreateVC.ls_taskName = self.larr_Decision![selectedIndex]["outcomes"][0]["name"].stringValue
                        if self.larr_Decision![selectedIndex]["outcomes"][0]["data"] != nil {
                             CreateVC.ldict_ScreenData = self.larr_ScreenData?.dictionary
                         }
                         
                        if json["flow"][self.larr_Decision![selectedIndex]["outcomes"][0]["name"].stringValue]["label"].stringValue.contains("${"){
                             
                            let title = json["flow"][self.larr_Decision![selectedIndex]["outcomes"][0]["name"].stringValue]["label"].stringValue
                             
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
                                     if self.larr_ScreenData!.count > 0 {
                                         titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_ScreenData!["\(titleSubstring)"].stringValue)
                                     }
                                 }else{
                                     titleString = title
                                 }
                             }else{
                                 titleString = nil
                             }
                             CreateVC.ls_ScreenTitle = titleString
                             
                         }else{
                            CreateVC.ls_ScreenTitle = json["flow"][self.larr_Decision![selectedIndex]["outcomes"][0]["name"].stringValue]["label"].stringValue
                         }
                         
                        
                         self.navigationController?.pushViewController(CreateVC, animated: true)
//                        break
                    }
                case .failure(let error):
                    self.showAlert(message: error.description)
                case .failureJson(_):
                    break
                }
            }
        }) {
            print("Dismiss")
        }
    }
    
    func submitData(decision:[String:JSON]){

        var bodydictionary:[String : Any] = [:]
        
        bodydictionary = ["workflowTaskName":decision["task"]!.stringValue,"task": decision["task"]!.stringValue,"appId":ls_appName!,"output":[decision["task"]!.stringValue:larr_ScreenData!.dictionaryObject!],"deviceType" : "mobile"] as [String : Any]
        
        self.showActivityIndicator()
        
        ConnectManager.shared.submitRecord(type: .post, dataBodyDictionary: bodydictionary) {  (resultResponse) in
            self.hideActivityIndicator()
            switch resultResponse {
            case .success(let result):
                if result["showPopUp"].boolValue == true{
                    self.showAlert(title: "", message: result["message"].stringValue, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true, handler: { (success) in
                        if success{
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
                        }
                    })
                }
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func setupData(){
        if larr_Decision!.count > 0 {
            let btnOptions = UIBarButtonItem(image: #imageLiteral(resourceName: "meat_balls").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(optionsButtonTapped(_:event:)))
            btnOptions.tintColor = .white
            self.navigationItem.rightBarButtonItem = btnOptions
        }
        
        if app_metaData!["flow"][ls_taskName!]["layout"]["getInitialData"].bool == true {
            getScreenData()
        }
    }
        
    @objc func barBtnTapped(_ sender:Any?){
        self.view.endEditing(true)
        
        let selectedButton = sender as! UIButton
        var selectedDecision:[String:JSON] = [:]
        
        selectedDecision = app_metaData!["flow"][ls_taskName!]["decisions"][selectedButton.tag].dictionaryValue
        
        if selectedDecision["type"] == "submit" {
            submitData(decision: selectedDecision)
        }
        else{
            
            switch (selectedDecision["outcomes"]![0]["action"].stringValue).uppercased() {
            case "CANCEL":
                self.navigationController?.popViewController(animated: true)
                
            default:
                
                self.showActivityIndicator()
                
                let bodydictionary = ["appId":"\(ls_appName!)","workFlowTask":"\(selectedDecision["outcomes"]![0]["name"])", "deviceType":"mobile"] as [String : Any]
                
                ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                    self.hideActivityIndicator()
                    switch taskResponse {
                    case .success(let json):
                        let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                        CreateVC.app_metaData =  json
//                        CreateVC.ls_appName = self.ls_appName!
                        CreateVC.ls_taskName = selectedDecision["outcomes"]![0]["name"].stringValue
                        if selectedDecision["outcomes"]![0]["data"] != nil {
                            CreateVC.ldict_ScreenData = self.larr_ScreenData?.dictionary
                        }
                        
                        if json["flow"][selectedDecision["outcomes"]![0]["name"].stringValue]["label"].stringValue.contains("${"){
                            
                            let title = json["flow"][selectedDecision["outcomes"]![0]["name"].stringValue]["label"].stringValue
                            
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
                                    if self.larr_ScreenData!.count > 0 {
                                        titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_ScreenData!["\(titleSubstring)"].stringValue)
                                    }
                                }else{
                                    titleString = title
                                }
                            }else{
                                titleString = nil
                            }
                            CreateVC.ls_ScreenTitle = titleString
                            
                        }else{
                             CreateVC.ls_ScreenTitle = json["flow"][selectedDecision["outcomes"]![0]["name"].stringValue]["label"].stringValue
                        }
                        
                       
                        self.navigationController?.pushViewController(CreateVC, animated: true)
                        
                    case .failure(let error):
                        self.showAlert(message: error.localizedDescription)
                    case .failureJson(_):
                        break
                    }
                }
            }
        }
    }
    
    func getScreenData(){
        var dataBodyDictionary = ["appId":"\(ls_appName!)","workFlowTask":"\(ls_taskName ?? "")","deviceType":"mobile"] as [String : Any]
        
        if self.larr_ScreenData != nil {
            dataBodyDictionary["payLoadData"] = self.larr_ScreenData!.dictionaryObject!
        }
        
        self.showActivityIndicator()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) {  (dataResponse) in
            self.hideActivityIndicator()
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
    
    func VisibilityandDisability(field:JSON,Section:Int,Row:Int){
        if larr_ScreenData != nil {
            //Visibility with JavaScript
            if let visibility =  ldict_object!["fields"][field["labelKey"].stringValue]["UIupdates"]["visibility"].string {
                
                var visibilityString:String? = ""
                
                let visibilityStartIndex =  visibility.range(of: "${")?.upperBound
                let visibilityEndIndex =  visibility.range(of: "}")?.lowerBound
                
                if visibilityStartIndex != nil && visibilityEndIndex != nil {
                    let visibilitySubstring = visibility[(visibility.range(of: "${"))!.upperBound..<(visibility.range(of: "}"))!.lowerBound]
                    let visibilityReplaceSubstring = visibility[(visibility.range(of: "${"))!.lowerBound ..< (visibility.range(of: "}"))!.upperBound]
                    visibilityString = visibility.replacingOccurrences(of: visibilityReplaceSubstring, with: larr_ScreenData!["\(visibilitySubstring)"].stringValue)
                }
                
                let jsSource = "var javascriptFunc = function() {\(visibilityString!)}"
                
                let context = JSContext()
                context?.evaluateScript(jsSource)
                
                let testFunction = context?.objectForKeyedSubscript("javascriptFunc")
                let result = testFunction?.call(withArguments: [])
                
                if result!.toString()! == "true" {
                    self.larr_screenFields![Section][Row]["type"] = nil
                    self.tableView.reloadData() 
                }else{
                    print("No")
                }
            }
        }
    }
}

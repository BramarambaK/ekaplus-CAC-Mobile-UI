//
//  WorkFlowDashViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 23/04/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

class WorkFlowDashViewController: UIViewController,WFHamburgerMenuDelegate,HUDRenderer,MLdelegate {

    //MARK: - Variable
    
    var app:App!  //Passed from previous VC
    var menuVC:WorkFlowMenuViewController!
    var app_metadata:JSON?
    var ls_objectName:String?
    var listData:[JSON]?
    var larr_Decision:[JSON]?
    var ls_Title:String?
    var ls_HomeWorkFlow:String?
    var ls_previousWorkflow:String?
    var li_Check:Int = 0
    var larr_navbarDetails:JSON?
    var larr_dropDownServiceKey:[[String:Any]]=[]
    var ldict_dropdownData:JSON = [:]
    var larr_SortList:[String] = []
    var larr_FilterList:[JSON] = []
    var lb_Search:Bool = false
    var li_newVersion = 0
    
    let defaultPageSize = 10
    var DataCurrentpage = 0
    
    lazy var DynamicApiController:DynamicAppApiController = {
        return DynamicAppApiController()
    }()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupData()
        self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(app.categoryName)
    }
    
//    override func willMove(toParent parent: UIViewController?) {
//        super.willMove(toParent: parent)
//        self.navigationController?.navigationBar.barTintColor = Utility.appThemeColor
//    }
    
    override func viewDidLayoutSubviews() {
        for view in (self.navigationController?.navigationBar.subviews)! {
            if #available(iOS 13.0, *) {
                let margins = view.layoutMargins
                var frame = view.frame
                frame.origin.x = -margins.left
                frame.size.width += (margins.left + margins.right)
                view.frame = frame
            } else {
                view.layoutMargins = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10)
            }
        }
    }
    
    //MARK: - Delegate Method
    
     func selectedMenu(handler: String, queryparameter: String?) {
        menuVC.dismissHamburgerMenu()
        if ls_HomeWorkFlow != handler {
            ls_previousWorkflow = handler
            gettaskDetails(taskName: handler, isHome: false)
        }
    }
    
    func MLProcessText(enteredText: String?) {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "NLPProcess"), object: nil, userInfo: ["ProcessedText":enteredText!])
    }
    
    //MARK: - Local Function
    
    func setupData(){
        menuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? WorkFlowMenuViewController
        menuVC.backgroundcolor = Utility.colorForCategory(app.categoryName)
        menuVC.delegate = self
        
        //        setNavigationBarWithSideMenu()
        getHomeScreenDetails()
        getnavBarDetails()
    }
    
    func setNavigationBarWithSideMenu()
    {
       
        
        //Add Back Button
        let backBtn = UIButton(type: UIButton.ButtonType.system)
        backBtn.tintColor = .white
        backBtn.setImage(UIImage.init(named: "Back")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        backBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let backBarItem = UIBarButtonItem(customView: backBtn)
        
        //Add Hamburger Button
        let sideMenuBtn = UIButton(type: UIButton.ButtonType.system)
        sideMenuBtn.tintColor = .white
        sideMenuBtn.setImage(UIImage.init(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        sideMenuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        sideMenuBtn.addTarget(menuVC, action: #selector(menuVC.hamburgerClicked(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: sideMenuBtn)
        
        //Based on the config add the buttons
        if larr_navbarDetails?["navbar"].count ?? 0 > 0 && larr_navbarDetails != nil  {
            self.navigationItem.leftBarButtonItems = [backBarItem,customBarItem]
            menuVC.TableViewDatasource = larr_navbarDetails!["navbar"].arrayValue
        }else{
            self.navigationItem.leftBarButtonItems = [backBarItem]
        }
        
    }
    
    
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getHomeScreenDetails(){
        self.showActivityIndicator()
        
        let bodydictionary = ["appId":"\(app_metadata!["sys__UUID"].stringValue)",
            "workFlowTask":"home","deviceType" : "mobile"] as [String : Any]
        
        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) { (homeResponse) in
            self.hideActivityIndicator()
            
            switch homeResponse {
            case .success(let json):
                DispatchQueue.main.async {
                    self.gettaskDetails(taskName: (json["flow"]["home"]["workflow"].stringValue), isHome: true)
                    self.ls_HomeWorkFlow = json["flow"]["home"]["workflow"].stringValue
                    self.ls_previousWorkflow = json["flow"]["home"]["workflow"].stringValue
                }
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            case .failureJson(_):
                break
            }
        }
    }
    
    func gettaskDetails(taskName:String,isHome:Bool){
        
        self.showActivityIndicator()
        
        let bodydictionary = ["appId":"\(app_metadata!["sys__UUID"].stringValue)",
            "workFlowTask":"\(taskName)",
            "deviceType":"mobile"] as [String : Any]
        
        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
            self.hideActivityIndicator()
            
            switch taskResponse {
            case .success(let json):
                self.ls_Title = json["flow"][taskName]["label"].stringValue
                self.larr_Decision = json["flow"][taskName]["decisions"].arrayValue
                let larr_fields = json["flow"][taskName]["fields"].arrayValue
                let ldict_object = json["objectMeta"]["fields"].dictionaryValue
                
                switch json["flow"][taskName]["layout"]["name"].stringValue {
                case "list":
                    self.setNavigationBarWithSideMenu()
                    
                    self.larr_FilterList = []
                    self.larr_SortList = []
                    
                    for each in larr_fields{
                        
                        if each["filter"] != nil && each["filter"] == true {
                            self.larr_FilterList.append(each)
                        }
                        
                        if each["sort"] != nil && each["sort"] == true {
                            self.larr_SortList.append(each["key"].stringValue)
                        }
                    }
                    
                    self.lb_Search = json["flow"][taskName]["layout"]["options"]["serverSearch"].bool ?? false
                    
                    
                    var dataBodyDictionary:[String : Any] = [:]
                    
                    if json["flow"][taskName]["layout"]["lazyLoading"] == true{
                        dataBodyDictionary = ["appId":"\(self.app_metadata!["sys__UUID"].stringValue)",
                            "workFlowTask":"\(taskName)","deviceType": "mobile","params":["from": self.DataCurrentpage,"size":self.defaultPageSize]] as [String : Any]
                        dataBodyDictionary["operation"] = []
                    }else{
                        dataBodyDictionary = ["appId":"\(self.app_metadata!["sys__UUID"].stringValue)",
                            "workFlowTask":"\(taskName)","deviceType" : "mobile"] as [String : Any]
                    }
                    
                    
                    self.showActivityIndicator()
                    
                    ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) {  (dataResponse) in
                        self.hideActivityIndicator()
                        
                        switch dataResponse {
                         case .success(let dataJson):
                            self.listData = (dataJson.dictionary!["data"]!).arrayValue
                            if self.listData!.count > 0 {
                                
                                for each in larr_fields {
                                    if ldict_object["\(each["key"])"] != nil  && ldict_object["\(each["key"])"]!["type"].stringValue == "dropdown" {
                                        if ldict_object["\(each["key"])"]!["propertyKey"] != nil{
                                            self.ldict_dropdownData[each["key"].stringValue] = ldict_object["\(each["key"])"]!["propertyKey"]["\(each["key"])"]
                                        }else{
                                            var DropdownServiceKey:[String:Any] = [:]
                                            
                                            DropdownServiceKey["serviceKey"] = ldict_object["\(each["key"])"]!["serviceKey"].stringValue
                                            
                                            if ldict_object["\(each["key"])"]!["dependsOn"] != JSON.null {
                                                DropdownServiceKey["dependsOn"] = ldict_object["\(each["key"])"]!["dependsOn"].arrayObject
                                            }
                                            self.larr_dropDownServiceKey.append(DropdownServiceKey)
                                        }
                                    }
                                }
                                
                                self.showActivityIndicator()
                                
                                self.DynamicApiController.DataObjectMapping(DataJson: self.listData!, FieldsJson: larr_fields, ObjectJson: ldict_object, DropDownData: self.ldict_dropdownData) { (DataMappingresponse) in
                                    
                                    self.hideActivityIndicator()
                                    switch DataMappingresponse{
                                    case .success(let listData):
                                        let ListVC = self.storyboard?.instantiateViewController(withIdentifier: "ListVC") as! ListViewController
                                        ListVC.larr_Datasource = listData as [[[NSMutableAttributedString]]]
                                        ListVC.larr_Decision = self.larr_Decision!
                                        ListVC.ls_ScreenTitle = self.ls_Title!
                                        ListVC.ls_appName = self.app_metadata!.dictionaryValue["sys__UUID"]!.stringValue
                                        ListVC.ls_taskName = taskName
//                                        ListVC.ls_tentantId = self.ls_tentantId!
                                        ListVC.larr_rawData = self.listData
                                        ListVC.DataCurrentpage = self.DataCurrentpage
//                                        ListVC.ls_Selectedappname = self.app.name
                                        ListVC.larr_FilterList = self.larr_FilterList
                                        ListVC.larr_SortList = self.larr_SortList
                                        ListVC.lb_Search = self.lb_Search
                                        
                                        var rightBarbutton:[UIBarButtonItem] = []
                                        
                                        if self.larr_Decision!.count > 0 {
                                            for n in 0...self.larr_Decision!.count-1 {
                                                
                                                if  self.larr_Decision![n]["selection"] == "default" {
                                                    let rightBtn1 = UIButton(type: .custom)
                                                    
                                                    if self.larr_Decision![n]["label"].string != nil {
                                                        rightBtn1.setTitle(self.larr_Decision![n]["label"].stringValue, for: .normal)
                                                    }else if self.larr_Decision![n]["iconClass"] != nil {
                                                        rightBtn1.setImage(UIImage(named: self.larr_Decision![n]["iconClass"].stringValue), for: .normal)
                                                    }
                                        
                                                    //                                                rightBtn1.setTitle(self.larr_Decision![n]["label"].stringValue, for: .normal)
                                                    rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                                    rightBtn1.tag = n
                                                    rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                                    let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                                    
                                                    rightBarbutton.append(rightBtn1item)
                                                }
                                            }
                                        }
                                        self.navigationItem.setRightBarButtonItems(rightBarbutton, animated: true)
                                        
                                        if isHome == true{
                                            ListVC.ls_ScreenTitle = nil
                                            ListVC.willMove(toParent: self)
                                            self.view.addSubview(ListVC.view)
                                            self.addChild(ListVC)
                                            ListVC.didMove(toParent: self)
                                            self.navigationItem.title = "\(self.ls_Title!)"
                                            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                                            
                                        }
                                        else{ self.navigationController?.pushViewController(ListVC, animated: true)
                                        }
                                    case .failure(_):
                                        break
                                    case .failureJson(_):
                                        break
                                    }
                                }
                               
                            }
                            else{
                                let ListVC = self.storyboard?.instantiateViewController(withIdentifier: "ListVC") as! ListViewController
                                ListVC.ls_ScreenTitle = self.ls_Title!
                                ListVC.ls_appName = self.app_metadata!.dictionaryValue["sys__UUID"]!.stringValue
                                ListVC.larr_Decision = self.larr_Decision!
                                ListVC.ls_taskName = taskName
//                                ListVC.ls_tentantId = self.ls_tentantId!
                                ListVC.larr_rawData = self.listData
//                                ListVC.ls_Selectedappname = self.app.name
                                ListVC.larr_FilterList = self.larr_FilterList
                                ListVC.larr_SortList = self.larr_SortList
                                ListVC.lb_Search = self.lb_Search
                                var rightBarbutton:[UIBarButtonItem] = []
                                
                                if self.larr_Decision!.count > 0 {
                                    
                                    for n in 0...self.larr_Decision!.count-1 {
                                        
                                        if  self.larr_Decision![n]["selection"] == "default" {
                                            let rightBtn1 = UIButton(type: .custom)
                                            if self.larr_Decision![n]["label"].string != nil {
                                                rightBtn1.setTitle(self.larr_Decision![n]["label"].stringValue, for: .normal)
                                            }else if self.larr_Decision![n]["iconClass"] != nil {
                                                rightBtn1.setImage(UIImage(named: self.larr_Decision![n]["iconClass"].stringValue), for: .normal)
                                            }
                                           
                                            rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                            rightBtn1.tag = n
                                            rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                            let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                            
                                            rightBarbutton.append(rightBtn1item)
                                        }
                                    }
                                    
                                }
                                
                                self.navigationItem.setRightBarButtonItems(rightBarbutton, animated: true)
                                
                                if isHome == true{
                                    ListVC.ls_ScreenTitle = nil
                                    ListVC.willMove(toParent: self)
                                    self.view.addSubview(ListVC.view)
                                    self.addChild(ListVC)
                                    ListVC.didMove(toParent: self)
                                    self.navigationItem.title = "\(self.ls_Title!)"
                                    self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                                    
                                }
                                else{ self.navigationController?.pushViewController(ListVC, animated: true)
                                }
                                
                            }
                        case .failure(_):
//                            self.showAlert(message: error.description)
                            
                            let ListVC = self.storyboard?.instantiateViewController(withIdentifier: "ListVC") as! ListViewController
                            ListVC.ls_ScreenTitle = self.ls_Title!
                            ListVC.ls_appName = self.app_metadata!.dictionaryValue["sys__UUID"]!.stringValue
                            ListVC.larr_Decision = self.larr_Decision!
                            ListVC.ls_taskName = taskName
//                            ListVC.ls_tentantId = self.ls_tentantId!
                            ListVC.larr_rawData = []
                            ListVC.larr_FilterList = self.larr_FilterList
                            ListVC.larr_SortList = self.larr_SortList
                            ListVC.lb_Search = self.lb_Search
                            
                            var rightBarbutton:[UIBarButtonItem] = []
                            
                            if self.larr_Decision!.count > 0 {
                                
                                for n in 0...self.larr_Decision!.count-1 {
                                    
                                    if  self.larr_Decision![n]["selection"] == "default" {
                                        let rightBtn1 = UIButton(type: .custom)
                                        if self.larr_Decision![n]["label"].string != nil {
                                            rightBtn1.setTitle(self.larr_Decision![n]["label"].stringValue, for: .normal)
                                        }else if self.larr_Decision![n]["iconClass"] != nil {
                                            rightBtn1.setImage(UIImage(named: self.larr_Decision![n]["iconClass"].stringValue), for: .normal)
                                        }
                                        
                                        rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                        rightBtn1.tag = n
                                        rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                        let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                        
                                        rightBarbutton.append(rightBtn1item)
                                    }
                                }
                            }
                            
                            self.navigationItem.setRightBarButtonItems(rightBarbutton, animated: true)
                            
                            if isHome == true{
                                ListVC.ls_ScreenTitle = nil
                                ListVC.willMove(toParent: self)
                                self.view.addSubview(ListVC.view)
                                self.addChild(ListVC)
                                ListVC.didMove(toParent: self)
                                self.navigationItem.title = "\(self.ls_Title!)"
                                if self.navigationController != nil {
                                    self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                                }
                            }
                            else{ self.navigationController?.pushViewController(ListVC, animated: true)
                            }
                            
                        case .failureJson(_):
                            break
                        }
                    }
                    
                case "create":
                    if self.li_Check == 0 {
                        self.li_Check = 1
                        let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                        CreateVC.app_metaData =  json
//                        CreateVC.ls_appName = self.app_metadata!["sys__UUID"].stringValue
                        CreateVC.ls_taskName = taskName
//                        CreateVC.ls_Selectedappname = self.app.name
                        CreateVC.ls_previousWorkflow = self.ls_previousWorkflow!
                        
                        var rightBarbutton:[UIBarButtonItem] = []
                        var leftBarbutton:[UIBarButtonItem] = []
                        
                        if self.larr_Decision!.count > 0 {
                            for n in 0...self.larr_Decision!.count-1 {
                                
                                switch self.larr_Decision![n]["position"].stringValue {
                                case "TopRight":
                                    
                                    if  json["flow"][taskName]["fields"].count > 1 {
                                        let rightBtn1 = UIButton(type: .custom)
                                        if self.larr_Decision![n]["outcomes"][0]["style"]["btnImage"].stringValue != "" {
                                            rightBtn1.setImage(UIImage(named: self.larr_Decision![n]["outcomes"][0]["style"]["btnImage"].stringValue), for: .normal)
                                            rightBtn1.tag = n
                                        }else{
                                            rightBtn1.setTitle("Next", for: .normal)
                                            rightBtn1.tag = 9999
                                        }
                                        rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                        rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                        let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                        
                                        rightBarbutton.append(rightBtn1item)
                                    }
                                    else{
                                        let rightBtn1 = UIButton(type: .custom)
                                        if self.larr_Decision![n]["label"].stringValue == "" {
                                            rightBtn1.setImage(UIImage(named: self.larr_Decision![n]["outcomes"][0]["style"]["btnImage"].stringValue), for: .normal)
                                        }else{ rightBtn1.setTitle(self.larr_Decision![n]["label"].stringValue, for: .normal)
                                        }
                                        rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                        rightBtn1.tag = n
                                        rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                        let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                        
                                        rightBarbutton.append(rightBtn1item)
                                    }
                                case "TopLeft":
                                    let leftBtn1 = UIButton(type: .custom)
                                    leftBtn1.setTitle(self.larr_Decision![n]["label"].stringValue, for: .normal)
                                    leftBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                    leftBtn1.tag = n
                                    leftBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                    let leftBtn1item = UIBarButtonItem(customView: leftBtn1)
                                    
                                    leftBarbutton.append(leftBtn1item)
                                default:
                                    break
                                }
                            }
                            
                            if rightBarbutton.count > 0 {
                                self.navigationItem.setRightBarButtonItems(rightBarbutton, animated: true)
                            }
                            
                            if leftBarbutton.count > 0 {
                                self.navigationItem.setLeftBarButtonItems(leftBarbutton, animated: true)
                            }
                            
                            
                        }
                        if isHome == true{
                            CreateVC.ls_ScreenTitle = nil
                            CreateVC.willMove(toParent: self)
                            self.view.addSubview(CreateVC.view)
                            self.addChild(CreateVC)
                            CreateVC.didMove(toParent: self)
                            self.navigationItem.title = "\(self.ls_Title!)"
                            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
                        }else{
                            CreateVC.ls_ScreenTitle = nil
                            //                        CreateVC.ls_ScreenTitle = self.ls_Title!
                            self.navigationController?.pushViewController(CreateVC, animated: true)
                        }
                    }
                default:
                    break
                }
                
            case .failure(let error):
                self.showAlert(message: error.description)
                
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func getnavBarDetails(){
        self.showActivityIndicator()
        
        ConnectManager.shared.getNavBarDetails(app_Id: app_metadata!["sys__UUID"].stringValue) {  (navBarResponse) in
            self.hideActivityIndicator()
            switch navBarResponse {
            case .success(let json):
                if json.array == nil {
                    self.larr_navbarDetails = json
                }else{
                    for i in 0..<2{
                        if json[i]["deviceType"].stringValue == "mobile"{
                            self.larr_navbarDetails = json[i]
                            break
                        }
                    }
                }
                self.setNavigationBarWithSideMenu()
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            case .failureJson(_):
                break
            }
        }
    }
    
    @objc func barBtnTapped(_ sender:Any?){
        
        let selectedButton = sender as! UIButton
        if selectedButton.tag == 9999{
            self.view.endEditing(true)
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "Next"), object: nil, userInfo:["sender":sender!])
        }else{
            let selectedButton = sender as! UIButton
            let selectedDecision = larr_Decision![selectedButton.tag]
            
            
            if selectedDecision["type"] == "submit" {
                submitData(decision: selectedDecision)
            }
            else{
                
                switch (selectedDecision["outcomes"][0]["action"].stringValue).uppercased() {
                case "CANCEL":
                    self.navigationController?.popViewController(animated: true)
                case "AUDIO":
                    let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpeechVC") as! SpeechViewController
                    nextViewController.providesPresentationContextTransitionStyle = true
                    nextViewController.definesPresentationContext = true
                    nextViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    nextViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    nextViewController.delegate = self
                    if selectedDecision["outcomes"][0]["version"].string != nil {
                        self.li_newVersion = 1
                    }
                    self.present(nextViewController, animated: true, completion: nil)
                default:
                    self.showActivityIndicator()
                    
                    let bodydictionary = ["appId":"\(app_metadata!["sys__UUID"].stringValue)",
                        "workFlowTask":"\(selectedDecision.dictionaryValue["outcomes"]![0]["name"])", "deviceType":"mobile"] as [String : Any]
                    
                    ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                        self.hideActivityIndicator()
                        switch taskResponse {
                        case .success(let json):
                            let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                            CreateVC.app_metaData =  json
//                            CreateVC.ls_appName = self.app_metadata!["sys__UUID"].stringValue
                            CreateVC.ls_taskName = selectedDecision["outcomes"][0]["name"].stringValue
                            CreateVC.ls_ScreenTitle = json["flow"][selectedDecision["outcomes"][0]["name"].stringValue]["label"].stringValue
//                            CreateVC.ls_Selectedappname = self.app.name
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
    }
    
    func submitData(decision:JSON){
        self.view.endEditing(true)
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "Submit"), object: nil, userInfo: ["decision":decision])
    }
}

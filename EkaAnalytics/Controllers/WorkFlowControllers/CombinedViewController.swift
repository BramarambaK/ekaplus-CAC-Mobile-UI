//
//  CombinedViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 14/12/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

class CombinedViewController: UIViewController,HUDRenderer,ListViewDelegate {
    
    //MARK: - Variable
    var ls_ScreenTitle:String?
    var ls_taskName:String?
    var app_metaData:JSON?
    var ldict_Decision:JSON?
    var larr_Decision:[JSON]?
    var ls_appName:String?
    var larr_ScreenData:JSON?
    var larr_Workflow:[JSON]?
    var ls_Selectedappname:String?
    var ldict_dropdownData:JSON = [:]
    var ldict_Worflowappmeta:JSON = [:]
    var ldict_WorflowHeight:[String:CGFloat] = [:]
    var menuArray:[String] = []
    var ls_ViewController:UIViewController?
    
    //MARK: - Privates
    @IBOutlet private weak var customView: UIView!
    @IBOutlet private weak var customView1: UIView!
    @IBOutlet private weak var customViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var customViewHeightConstraint1: NSLayoutConstraint!
    @IBOutlet weak var SegmentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var SegmentedController: UISegmentedControl!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
    }
    
    //MARK: - Local Function
    
    func setupInitialUI(){
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let BackButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action:  #selector(goBack))
        self.navigationItem.setLeftBarButtonItems([BackButton], animated: true)
        
        if ls_ScreenTitle != nil {
            self.navigationItem.title = "\(ls_ScreenTitle ?? "")"
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = Utility.appThemeColor
                appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
                self.navigationController!.navigationBar.standardAppearance = appearance;
                self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
            } else {
                self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            }
        }
        
        self.larr_Workflow = app_metaData!["flow"][ls_taskName!]["workflows"].array
        self.larr_Decision = app_metaData!["flow"][ls_taskName!]["decisions"].array
        self.customViewHeightConstraint1.constant = 0
        self.customViewHeightConstraint.constant = 0
        self.SegmentViewHeight.constant = 0
        self.SegmentedController.removeAllSegments()
        
        if larr_Decision!.count > 0 {
            menuArray = []
            
            for each in larr_Decision! {
                if let displayed = each["displayed"].string{
                    var displayedSplit:[String] = displayed.components(separatedBy: "==")
                    if displayedSplit.count > 1 {
                    if displayed.contains("||"){
                        let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                        var licheck = 0
                        for j in 0..<valueSplit.count {
                            if larr_ScreenData!["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                licheck = 1
                            }
                        }
                        if licheck == 1 {
                            menuArray.append(each["label"].stringValue)
                        }
                    }else if displayed.contains("&&"){
                        let valueSplit:[String] = displayedSplit[1].components(separatedBy: "&&")
                        var licheck = 0
                        for j in 0..<valueSplit.count {
                            if larr_ScreenData!["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                if j == 0 && licheck == 0 {
                                    licheck = 1
                                }else if licheck != 1 {
                                    licheck = 0
                                }
                            }
                        }
                        if licheck == 1 {
                            menuArray.append(each["label"].stringValue)
                        }
                    }else{
                        if larr_ScreenData != nil && larr_ScreenData!["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() == "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                            menuArray.append(each["label"].stringValue)
                        }
                    }
                    }else{
                        displayedSplit = displayed.components(separatedBy: "!=")
                        if displayed.contains("||"){
                            let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                            var licheck = 0
                            for j in 0..<valueSplit.count {
                                if larr_ScreenData!["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() != "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                    licheck = 1
                                }
                            }
                            if licheck == 1 {
                                menuArray.append(each["label"].stringValue)
                            }
                        }else if displayed.contains("&&"){
                            let valueSplit:[String] = displayedSplit[1].components(separatedBy: "&&")
                            var licheck = 0
                            for j in 0..<valueSplit.count {
                                if larr_ScreenData!["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() != "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                    if j == 0 && licheck == 0 {
                                        licheck = 1
                                    }else if licheck != 1 {
                                        licheck = 0
                                    }
                                }
                            }
                            if licheck == 1 {
                                menuArray.append(each["label"].stringValue)
                            }
                        }else{
                            if larr_ScreenData != nil && larr_ScreenData!["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() != "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                menuArray.append(each["label"].stringValue)
                            }
                        }
                    }
                }else{
                    menuArray.append(each["label"].stringValue)
                }
            }
            
            if menuArray.count > 0 {
                let btnOptions = UIBarButtonItem(image: #imageLiteral(resourceName: "meat_balls").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(optionsButtonTapped(_:event:)))
                self.navigationItem.rightBarButtonItem = btnOptions
                
            }
        }
        
        self.workFlowMetaData()
    }
    
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
        
        FTPopOverMenu.show(from: event, withMenuArray: menuArray, doneBlock: { (selectedIndex) in
            self.showActivityIndicator()
            
            for each in self.larr_Decision! {
                if each["label"].stringValue.uppercased() == self.menuArray[selectedIndex].uppercased() {
                    self.ldict_Decision = each
                }
            }
            
            if self.ldict_Decision!["executeDecision"] == nil {
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
                                titleString = ConnectManager.shared.evaluateJavaExpression(expression: title, data: self.larr_ScreenData!) as? String ?? ""
                            }else{
                                titleString = nil
                            }
                            
                            let msgString:String = ConnectManager.shared.evaluateJavaExpression(expression: json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["option"]["bodyMessage"].string ?? "", data: self.larr_ScreenData!) as? String ?? ""
                            
                            if json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["remarks"].bool == nil || json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["remarks"].bool == false {
                                alertController = UIAlertController(title: titleString , message: msgString, preferredStyle: UIAlertController.Style.actionSheet)
                            }else{
                                alertController = UIAlertController(title: titleString , message: msgString, preferredStyle:UIAlertController.Style.alert)
                                alertController.addTextField { (textField : UITextField!) -> Void in
                                    textField.placeholder = "Remarks"
                                }
                            }
                            
                            let decision = json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["decisions"]
                            
                            for i in 0..<decision.count {
                                let Action = UIAlertAction(title: decision[i]["label"].stringValue, style: UIAlertAction.Style.default) { (finish) in
                                    
                                    if decision[i]["type"] != JSON.null && decision[i]["type"] == "submit" {
                                        if json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["remarks"].bool == true {
                                            let RemarksTextField = alertController.textFields![0] as UITextField
                                        }
                                       
                                        self.submitData(decision: decision[i].dictionaryValue)
                                    }
                                    
                                }
                                alertController.addAction(Action)
                            }
                            
                            alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        default:
                            break
                        }
                    case .failure(let error):
                        self.showAlert(message: error.description)
                        
                    case .failureJson(let errorJson):
                        self.showAlert(message: errorJson["errorMessage"].stringValue)
                    }
                }
            }else if self.ldict_Decision!["executeDecision"].boolValue == true {
                print(self.ldict_Decision)
                self.hideActivityIndicator()
            }
        }) {
            print("Dismiss")
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        switch container {
        case is ListViewController:
            customViewHeightConstraint1.constant = container.preferredContentSize.height
        case is DetailViewController:
            customViewHeightConstraint.constant = container.preferredContentSize.height
        default:
            break
        }
    }
    
    private func addChildViewController() {
        
        for i in 0..<larr_Workflow!.count{
            
            if larr_Workflow![i]["display"].string != nil {
                switch ldict_Worflowappmeta[larr_Workflow![i]["workflows"][0]["name"].stringValue]["flow"][larr_Workflow![i]["workflows"][0]["name"].stringValue]["layout"]["name"] {
                case "list":
                    guard let ListVC = UIStoryboard(name: "WorkFlow", bundle: nil)
                            .instantiateViewController(withIdentifier: "ListVC") as? ListViewController
                    else { return }
                    
                    ListVC.ls_appName =  self.ls_appName!
                    ListVC.ls_taskName = larr_Workflow![i]["workflows"][0]["name"].stringValue
                    ListVC.larr_rawData = []
                    ListVC.delegate = self
                    if larr_Workflow![i]["workflows"][0]["data"].string != nil {
                        ListVC.ldict_ScreenData = self.larr_ScreenData
                    }
                    ListVC.lb_ScreenHeight = false
                    ListVC.layoutJson = ldict_Worflowappmeta[larr_Workflow![i]["workflows"][0]["name"].stringValue]
                    ListVC.larr_Decision = ldict_Worflowappmeta[larr_Workflow![i]["workflows"][0]["name"].stringValue]["flow"][larr_Workflow![i]["workflows"][0]["name"].stringValue]["decisions"].arrayValue
//                    ListVC.larr_Decision = ldict_Worflowappmeta[larr_Workflow![i]["name"].stringValue]["flow"][larr_Workflow![0]["name"].stringValue]["decisions"].arrayValue
                    addChild(ListVC)
                    customView1.addSubview(ListVC.view)
                    activateRequiredConstraints1(for: ListVC.view)
                    ListVC.didMove(toParent: self)
                default:
                    break
                }
            }
            else{
                switch ldict_Worflowappmeta[larr_Workflow![i]["name"].stringValue]["flow"][larr_Workflow![i]["name"].stringValue]["layout"]["name"].stringValue {
                
                case "view":
                    guard let DetailVC = UIStoryboard(name: "WorkFlow", bundle: nil)
                            .instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController
                    else { return }
                    
                    DetailVC.app_metaData = ldict_Worflowappmeta[larr_Workflow![i]["name"].stringValue]
                    DetailVC.ls_appName = self.ls_appName!
                    DetailVC.ls_taskName = larr_Workflow![i]["name"].stringValue
                    DetailVC.larr_ScreenData = self.larr_ScreenData
                    
                    addChild(DetailVC)
                    customView.addSubview(DetailVC.view)
                    activateRequiredConstraints(for: DetailVC.view)
                    DetailVC.didMove(toParent: self)
                
                case "list":
                    
                    guard let ListVC = UIStoryboard(name: "WorkFlow", bundle: nil)
                            .instantiateViewController(withIdentifier: "ListVC") as? ListViewController
                    else { return }
                    
                    ListVC.ls_appName =  self.ls_appName!
                    ListVC.ls_taskName = larr_Workflow![i]["name"].stringValue
                    ListVC.larr_rawData = []
                    if larr_Workflow![i]["data"].string != nil {
                        ListVC.ldict_ScreenData = self.larr_ScreenData
                    }
                    ListVC.lb_ScreenHeight = false
                    ListVC.delegate = self
                    ListVC.layoutJson = ldict_Worflowappmeta[larr_Workflow![i]["name"].stringValue]
                    ListVC.larr_Decision = ldict_Worflowappmeta[larr_Workflow![i]["name"].stringValue]["flow"][larr_Workflow![i]["name"].stringValue]["decisions"].arrayValue
                    addChild(ListVC)
                    customView1.addSubview(ListVC.view)
                    activateRequiredConstraints1(for: ListVC.view)
                    ListVC.didMove(toParent: self)
                default:
                    break
                }
            }
        }
    }
    
    
    private func activateRequiredConstraints(for childView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: customView.leadingAnchor, constant: 0),
            childView.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: 0),
            childView.topAnchor.constraint(equalTo: customView.topAnchor, constant: 0),
            childView.bottomAnchor.constraint(equalTo: customView.bottomAnchor, constant: 0)
        ])
    }
    
    private func activateRequiredConstraints1(for childView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: customView1.leadingAnchor, constant: 0),
            childView.trailingAnchor.constraint(equalTo: customView1.trailingAnchor, constant: 0),
            childView.topAnchor.constraint(equalTo: customView1.topAnchor, constant: 0),
            childView.bottomAnchor.constraint(equalTo: customView1.bottomAnchor, constant: 0)
        ])
    }
    
    func workFlowMetaData(){
        
        self.showActivityIndicator()
        
        for each in larr_Workflow!{
            
            if each["display"] == "tabs"{
                self.SegmentViewHeight.constant = 35
                for i in 0..<each["workflows"].count{
                    self.SegmentedController.insertSegment(withTitle: each["workflows"][i]["tabHeader"].stringValue, at: i, animated: false)
                    
                    if app_metaData!["flow"][ls_taskName!]["layout"]["footer"].bool == nil ||  app_metaData!["flow"][ls_taskName!]["layout"]["footer"].bool == true {
                        self.getData(workFlowName: each["workflows"][i]["name"].stringValue)
                    }
                    
                    self.SegmentedController.selectedSegmentIndex = 0
                    let bodydictionary = ["appId":"\(ls_appName!)","workFlowTask":"\(each["workflows"][i]["name"].stringValue)", "deviceType":"mobile"] as [String : Any]
                    
                    ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                        self.hideActivityIndicator()
                        switch taskResponse {
                        case .success(let json):
                            for individualWorkflow in self.larr_Workflow!{
                                for i in 0..<individualWorkflow["workflows"].count{
                                    if json["flow"][individualWorkflow["workflows"][i]["name"].stringValue].dictionary != nil {
                                        self.ldict_Worflowappmeta[individualWorkflow["workflows"][i]["name"].stringValue] = json
                                    }
                                }
                            }
                            if self.larr_Workflow!.count < self.ldict_Worflowappmeta.count{
                                self.addChildViewController()
                            }
                        case .failure(let error):
                            self.showAlert(message: error.localizedDescription)
                            
                        case .failureJson(let errorJson):
                            self.showAlert(message: errorJson["errorMessage"].stringValue)
                        }
                    }
                }
            }else{
                if app_metaData!["flow"]["composite"] != nil {
                    self.hideActivityIndicator()
                    self.ldict_Worflowappmeta[each["name"].stringValue] = app_metaData!["flow"]["composite"][each["name"].stringValue]
                    if self.larr_Workflow!.count == self.ldict_Worflowappmeta.count{
                        self.addChildViewController()
                    }
                }else{
                    let bodydictionary = ["appId":"\(ls_appName!)","workFlowTask":"\(each["name"])", "deviceType":"mobile"] as [String : Any]
                    
                    ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                        self.hideActivityIndicator()
                        switch taskResponse {
                        case .success(let json):
                            for individualWorkflow in self.larr_Workflow!{
                                if json["flow"][individualWorkflow["name"].stringValue].dictionary != nil {
                                    self.ldict_Worflowappmeta[individualWorkflow["name"].stringValue] = json
                                }
                            }
                            if self.larr_Workflow!.count == self.ldict_Worflowappmeta.count{
                                self.addChildViewController()
                            }
                        case .failure(let error):
                            self.showAlert(message: error.localizedDescription)
                        case .failureJson(let errorJson):
                            self.showAlert(message: errorJson["errorMessage"].stringValue)
                        }
                    }
                }
            }
        }
        self.hideActivityIndicator()
    }
    
    @IBAction func SegmentAction(_ sender: UISegmentedControl) {
        //Remove all the subview
        for IndividualSubView in customView1.subviews{
            IndividualSubView.removeFromSuperview()
        }
        
        for i in 0..<larr_Workflow!.count{
            if larr_Workflow![i]["display"].string != nil {
                switch ldict_Worflowappmeta[larr_Workflow![i]["workflows"][SegmentedController.selectedSegmentIndex]["name"].stringValue]["flow"][larr_Workflow![i]["workflows"][SegmentedController.selectedSegmentIndex]["name"].stringValue]["layout"]["name"] {
                case "list":
                    guard let ListVC = UIStoryboard(name: "WorkFlow", bundle: nil)
                            .instantiateViewController(withIdentifier: "ListVC") as? ListViewController
                    else { return }
                    
                    ListVC.ls_appName =  self.ls_appName!
                    ListVC.ls_taskName = larr_Workflow![i]["workflows"][SegmentedController.selectedSegmentIndex]["name"].stringValue
                    ListVC.larr_rawData = []
                    if larr_Workflow![i]["workflows"][SegmentedController.selectedSegmentIndex]["data"].string != nil {
                        ListVC.ldict_ScreenData = self.larr_ScreenData
                    }
                    ListVC.lb_ScreenHeight = false
                    ListVC.delegate = self
                    ListVC.layoutJson = ldict_Worflowappmeta[larr_Workflow![i]["workflows"][SegmentedController.selectedSegmentIndex]["name"].stringValue]
                    ListVC.larr_Decision = ldict_Worflowappmeta[larr_Workflow![i]["workflows"][SegmentedController.selectedSegmentIndex]["name"].stringValue]["flow"][larr_Workflow![i]["workflows"][SegmentedController.selectedSegmentIndex]["name"].stringValue]["decisions"].arrayValue
                    addChild(ListVC)
                    customView1.addSubview(ListVC.view)
                    activateRequiredConstraints1(for: ListVC.view)
                    ListVC.didMove(toParent: self)
                default:
                    break
                }
            }
        }
    }
    
    func submitData(decision:[String:JSON]){
        
        let bodydictionary:[String : Any] = ["workflowTaskName":decision["task"]!.stringValue,"task": decision["task"]!.stringValue,"appId":ls_appName!,"output":[decision["task"]!.stringValue:larr_ScreenData!.dictionaryObject!],"deviceType" : "mobile"] as [String : Any]
        
        self.showActivityIndicator()
        
        ConnectManager.shared.submitRecord(type: .post, dataBodyDictionary: bodydictionary) {  (resultResponse) in
            self.hideActivityIndicator()
            switch resultResponse {
            case .success(let result):
                if result["showPopUp"].boolValue == true{
                    
                    var msgString:String = result["message"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if  (Array(result["message"].stringValue)[1] == ":") {
                        msgString = result["message"].stringValue.replacingOccurrences(of: ":- ", with: "")
                    }
                    
                    self.showAlert(title: "", message: msgString, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true, handler: { (success) in
                        if success{
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
                        }
                    })
                }
            case .failure(let error):
                self.showAlert(message: error.description)
                
            case .failureJson(let errorJson):
                self.showAlert(message: errorJson["errorMessage"].stringValue)
            }
        }
        
    }
    
    func SegmentedTitle(workFlowName: String, listCount: String) {
        if app_metaData!["flow"][ls_taskName!]["layout"]["footer"].bool == nil ||  app_metaData!["flow"][ls_taskName!]["layout"]["footer"].bool == true {
            for each in larr_Workflow!{
                if each["display"] == "tabs"{
                    for i in 0..<each["workflows"].count{
                        if each["workflows"][i]["name"].stringValue.uppercased() == workFlowName.uppercased() {
                            SegmentedController.setTitle("\(each["workflows"][i]["tabHeader"].stringValue) (\(listCount))", forSegmentAt: i)
                        }
                    }
                }
            }
        }
    }
    
    func getData(workFlowName: String) {
        
        let dataBodyDictionary = ["appId":"\(ls_appName!)","workFlowTask":"\(workFlowName)","deviceType":"mobile","qP":["from": 0,"size":1],"operation":["pagination"]] as [String : Any]
        
        self.showActivityIndicator()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { (dataResponse) in
            
            self.hideActivityIndicator()
            switch dataResponse {
            case .success(let dataJson):
                self.SegmentedTitle(workFlowName: workFlowName, listCount: dataJson["totalCount"].stringValue)
               
            case .failure(let error):
                print(error.description)
                
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
}

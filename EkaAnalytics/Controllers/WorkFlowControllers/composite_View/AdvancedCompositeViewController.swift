//
//  AdvancedCompositeViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 11/02/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol AdvancedCompositeDelegate {
    //Query Component Delegate
    func addPickerView(MyPickerData:[JSON])
    func setDelegate(delegate:QueryComponentViewDelegate)
    func updateData(larr_ScreenData:[String:[JSON]])
    func setInitalValue(SelectedData:[JSON]?,query:JSON?)
    func refreshScreen(MyPickerData:[JSON])
    func gettaskDetails(taskName:String,queryparameter: String?)
    func updateScreenData(taskName:String,ScreenData:[JSON])
    func updateSelectedTab(SelectedTab:Int?)
    
    //Chart Component Delegate
    func setChartDelegate(chartDelegate:ChartComponentViewDelegate)
    func addChartPickerView(MyChartPickerData:[String]?)
    
    //Card Component Delegate
    func UpdateCardFilter(SelectedTab:Int?)
    
    func hideUnhideComponenet(componentName:String,Status:Bool)
    func refreshIndividualView(TaskId:String)
    
    func showIndicator()
    func hideIndicator()
    func pushViewController(Vc:UIViewController)
}

final class AdvancedCompositeViewController: UIViewController,HUDRenderer {
    
    //MARK: Variable
    var app:App!
    var app_metaData:JSON?
    var ls_taskName:String?
    var larr_Workflow:[JSON] = []
    var extractedWorkflow:[JSON] = []
    var ldict_Worflowappmeta:JSON = [:]
    var liworkflowCount:Int = 0
    var toolBar = UIToolbar()
    var picker  = UIPickerView()
    var MyPickerData:[JSON] = []
    var delegate:QueryComponentViewDelegate?
    var larr_ScreenData:[String:[JSON]] = [:]
    var larr_SubViewScreenData:[String:[JSON]] = [:]
    var SelectedData:[JSON]?
    var larr_Tabbar:[String] =  []
    var SelectedTab:Int?
    var larr_Decision:[JSON]?
    var ldict_Decision:JSON?
    var menuArray:[String] = []
    
    
    //Chart Component
    var MyChartPickerData:[String]?
    var chartDelegate:ChartComponentViewDelegate?
    var chartFilterValue:String?
    var hideUnhideComponenet:[String:Bool] = [:]
    
    //Query Component
    var SelectedQuery:JSON?
    
    //Card Component
    var SelectedCardTab:Int?
    
    var ConnectUserInfo:JSON?
    
    //MARK: IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let BackButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action:  #selector(goBack))
        
        self.navigationItem.setLeftBarButtonItems([BackButton], animated: true)
        
        if app_metaData != nil {
            
            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = Utility.appThemeColor
                appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
                self.navigationController!.navigationBar.standardAppearance = appearance;
                self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
            } else {
                self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            }
            
            self.navigationItem.title = app_metaData!["flow"][ls_taskName!]["label"].stringValue
            larr_Workflow = app_metaData!["flow"][ls_taskName!]["workflows"].arrayValue
            self.larr_Decision = app_metaData!["flow"][ls_taskName!]["decisions"].array
            
            if larr_Decision!.count > 0 {
                self.addMoreOption()
            }
        }
        
        self.tableView.estimatedRowHeight = 100
        
        ConnectManager.shared.getConnectUserInfo { (result) in
            switch result {
            case .success(let userInfo):
                self.ConnectUserInfo = userInfo
                self.getWorkflowData(workflowarray: self.larr_Workflow)
            case .failure(let error):
                print(error)
                self.getWorkflowData(workflowarray: self.larr_Workflow)
            case .failureJson( let errorJson):
                print(errorJson)
                self.getWorkflowData(workflowarray: self.larr_Workflow)
            }
        }
    }
    
    //MARK: Local Function
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func addMoreOption(){
        menuArray = []
        
        for each in larr_Decision! {
            if let displayed = each["displayed"].string{
                var displayedSplit:[String] = displayed.components(separatedBy: "==")
                if displayedSplit.count > 1 {
                    if displayed.contains("||"){
                        let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                        var licheck = 0
                        for j in 0..<valueSplit.count {
                            if SelectedData![0]["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
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
                            if SelectedData![0]["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
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
                        if SelectedData != nil && SelectedData![0]["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() == "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                            menuArray.append(each["label"].stringValue)
                        }
                    }
                }else{
                    displayedSplit = displayed.components(separatedBy: "!=")
                    if displayed.contains("||"){
                        let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                        var licheck = 0
                        for j in 0..<valueSplit.count {
                            if SelectedData![0]["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() != "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
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
                            if SelectedData![0]["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() != "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
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
                        if SelectedData != nil && SelectedData![0]["\(displayedSplit[0].trimmingCharacters(in: .whitespacesAndNewlines))"].stringValue.uppercased() != "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
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
                
                let bodydictionary = ["appId":"\(self.app_metaData!["flow"][self.ls_taskName!]["refTypeId"].stringValue)","workFlowTask":"\( self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])",
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
                                    titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.SelectedData![0]["\(titleSubstring)"].stringValue)
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
                                msgString = message.replacingOccurrences(of: messageReplaceSubstring, with: self.SelectedData![0]["\(messageSubstring)"].stringValue)
                            }else{
                                msgString = message
                            }
                            
                            alertController = UIAlertController(title: titleString , message: msgString, preferredStyle:UIAlertController.Style.actionSheet)
                            
                            
                            let decision = json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["decisions"]
                            
                            for i in 0..<decision.count {
                                let Action = UIAlertAction(title: decision[i]["label"].stringValue, style: UIAlertAction.Style.default) { (finish) in
                                    
                                    if decision[i]["type"] != JSON.null && decision[i]["type"] == "submit" {
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
                        print(errorJson)
                    }
                }
            }else if self.ldict_Decision!["executeDecision"].boolValue == true {
                print(self.ldict_Decision ?? "")
                self.hideActivityIndicator()
            }
        }) {
            print("Dismiss")
        }
    }
    
    private func getWorkflowData(workflowarray:[JSON]) {
        
        for each in workflowarray{
            if each["name"] != nil {
                self.extractedWorkflow.append(each)
                self.getWorkFlowAppMeta(individualWorkflowName: each["name"].stringValue )
            }else{
                if each["visibility"] != nil {
                    if  each["visibility"].stringValue.contains("userInfo") == true {
                        let result:String = ConnectManager.shared.evaluateJavaExpression(expression: each["visibility"].stringValue.replacingOccurrences(of: "userInfo.", with: ""), data: ConnectUserInfo) as? String ?? ""
                        if result == "true" {
                            if each["display"].string == "tabs" {
                                self.extractedWorkflow.append([])
                                larr_Tabbar.removeAll()
                                for i in 0..<each["workflows"].count {
                                    self.larr_Tabbar.append(each["workflows"][i]["tabHeader"].stringValue)
                                }
                                self.getWorkflowData(workflowarray: each["workflows"]["\(SelectedTab ?? 0)"]["workflows"].arrayValue)
                            }else{
                                self.getWorkflowData(workflowarray: each["workflows"].arrayValue)
                            }
                        }
                    }else{
                        let result:String = ConnectManager.shared.evaluateJavaExpression(expression: each["visibility"].stringValue, data: nil) as? String ?? ""
                        if result == "true" {
                            if each["display"].string == "tabs" {
                                self.extractedWorkflow.append([])
                                larr_Tabbar.removeAll()
                                for i in 0..<each["workflows"].count {
                                    self.larr_Tabbar.append(each["workflows"][i]["tabHeader"].stringValue)
                                }
                                self.getWorkflowData(workflowarray: each["workflows"][SelectedTab ?? 0]["workflows"].arrayValue)
                            }else{
                                self.getWorkflowData(workflowarray: each["workflows"].arrayValue)
                            }
                        }
                    }
                }else{
                    self.getWorkflowData(workflowarray: each["workflows"].arrayValue)
                }
            }
        }
    }
    
    private func getWorkFlowAppMeta(individualWorkflowName:String) {
        liworkflowCount += 1
        
        if app_metaData!["flow"]["composite"] != nil {
            if app_metaData!["flow"]["composite"][individualWorkflowName].dictionary != nil {
                if  self.ldict_Worflowappmeta[individualWorkflowName] != nil {
                    self.liworkflowCount -= 1
                }
                self.ldict_Worflowappmeta[individualWorkflowName] =  app_metaData!["flow"]["composite"][individualWorkflowName]
            }
            
            
            if self.liworkflowCount == app_metaData!["flow"]["composite"].count{
                self.reloadTableview(tableView: self.tableView)
            }
            
            //            if self.liworkflowCount == self.ldict_Worflowappmeta.count{
            //                self.reloadTableview(tableView: self.tableView)
            //            }
            
        }else{
            self.showActivityIndicator()
            let bodydictionary = ["appId":"\(app_metaData!["appId"].stringValue)","workFlowTask":"\(individualWorkflowName)", "deviceType":"mobile"] as [String : Any]
            
            ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                self.hideActivityIndicator()
                switch taskResponse {
                case .success(let json):
                    for individualWorkflow in self.extractedWorkflow{
                        if json["flow"][individualWorkflow["name"].stringValue].dictionary != nil {
                            if  self.ldict_Worflowappmeta[individualWorkflow["name"].stringValue] != nil {
                                self.liworkflowCount -= 1
                            }
                            self.ldict_Worflowappmeta[individualWorkflow["name"].stringValue] = json
                        }
                    }
                    
                    if self.liworkflowCount == self.ldict_Worflowappmeta.count{
                        self.reloadTableview(tableView: self.tableView)
                    }
                    
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                    break
                case .failureJson(_):
                    break
                }
            }
        }
    }
    
    func submitData(decision:[String:JSON]){
        
        let bodydictionary:[String : Any] = ["workflowTaskName":decision["task"]!.stringValue,"task": decision["task"]!.stringValue,"appId":self.app_metaData!["flow"][ls_taskName!]["refTypeId"].stringValue,"output":[decision["task"]!.stringValue:self.SelectedData![0].dictionaryObject],"deviceType" : "mobile"] as [String : Any]
        
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
    
}


extension AdvancedCompositeViewController:UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extractedWorkflow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        
        switch ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]["flow"][extractedWorkflow[indexPath.row]["name"].stringValue]["layout"]["name"].stringValue{
        case "query":
            let newView = QueryComponentView().loadNib()
            newView.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            newView.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            newView.SelectedQuery = self.SelectedQuery
            newView.config(viewData: SelectedQuery?["value"].string)
            newView.larr_ScreenData = larr_ScreenData
            newView.tag = indexPath.row
            newView.delegate = self
            
            cell.contentView.addSubview(newView)
            activateRequiredConstraints(for: newView, tableviewCell: cell)
            
        case "summary-tile":
            let summaryTitleView = summaryTileComponentView().loadNib()
            summaryTitleView.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            summaryTitleView.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            summaryTitleView.SelectedData = SelectedData ?? []
            summaryTitleView.ConnectUserInfo = ConnectUserInfo
            summaryTitleView.config()
            
            cell.contentView.addSubview(summaryTitleView)
            activateRequiredConstraints(for: summaryTitleView, tableviewCell: cell)
            
        case "cards-view":
            let cardsview = cardsViewComponentView().loadNib()
            cardsview.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            cardsview.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            cardsview.ls_SelectedCardTab = self.SelectedCardTab
            cardsview.delegate = self
            if let data = extractedWorkflow[indexPath.row]["data"].string {
                if larr_SubViewScreenData["\(data.split(separator: ".")[data.split(separator: ".").count-1])"] != nil {
                    cardsview.SelectedData = larr_SubViewScreenData["\(data.split(separator: ".")[data.split(separator: ".").count-1])"] ?? []
                }else{
                    cardsview.SelectedData = SelectedData ?? []
                }
            }
            cardsview.config()
            
            cell.contentView.addSubview(cardsview)
            activateRequiredConstraints(for: cardsview, tableviewCell: cell)
            
        case "lastUpdated":
            let lastUpdated = lastUpdatedComponentView().loadNib()
            lastUpdated.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            lastUpdated.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            lastUpdated.SelectedData = SelectedData ?? []
            lastUpdated.config()
            
            cell.contentView.addSubview(lastUpdated)
            activateRequiredConstraints(for: lastUpdated, tableviewCell: cell)
            
        case "flexible-menu":
            if ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]["flow"][extractedWorkflow[indexPath.row]["name"].stringValue]["layout"]["visibility"] != "hidden" {
                let flexibleMenu = flexibleMenuComponentView().loadNib()
                flexibleMenu.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
                flexibleMenu.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
                flexibleMenu.config()
                flexibleMenu.delegate = self
                cell.contentView.addSubview(flexibleMenu)
                activateRequiredConstraints(for: flexibleMenu, tableviewCell: cell)
            }
            
        case "chart":
            let chartView = chartComponentView().loadNib()
            chartView.delegate = self
            chartView.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            chartView.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            chartView.SelectedData = SelectedData ?? []
            chartView.chartFilterValue = self.chartFilterValue
            chartView.ConnectUserInfo = ConnectUserInfo
            chartView.config()
            cell.contentView.addSubview(chartView)
            activateRequiredConstraints(for: chartView, tableviewCell: cell)
            
        case "menu":
            let menuView = MenuComponentView().loadNib()
            menuView.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            menuView.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            menuView.config()
            
            cell.contentView.addSubview(menuView)
            activateRequiredConstraints(for: menuView, tableviewCell: cell)
            
        case "view":
            let DetailViewComponentView = DetailViewComponentView().loadNib()
            DetailViewComponentView.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            DetailViewComponentView.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            DetailViewComponentView.larr_ScreenData = SelectedData![0]
            DetailViewComponentView.delegate = self
            DetailViewComponentView.config()
            
            cell.contentView.addSubview(DetailViewComponentView)
            activateRequiredConstraints(for: DetailViewComponentView, tableviewCell: cell)
            
        case "list":

            let ListComponentView = ListComponentView().loadNib()
            ListComponentView.ls_taskName = extractedWorkflow[indexPath.row]["name"].stringValue
            ListComponentView.app_metaData = ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]
            ListComponentView.selectedData = SelectedData![0]
            ListComponentView.delegate = self
            ListComponentView.config()

            cell.contentView.addSubview(ListComponentView)
            activateRequiredConstraints(for: ListComponentView, tableviewCell: cell)
            
        default:
            if larr_Tabbar.count > 0 {
                let compositeTabView = CompositeTabView().loadNib()
                compositeTabView.tabBarDataSource  = larr_Tabbar
                compositeTabView.ls_SelectedCardTab = self.SelectedTab
                compositeTabView.delegate = self
                cell.contentView.addSubview(compositeTabView)
                activateRequiredConstraints(for: compositeTabView, tableviewCell: cell)
            }
            
            print("\(ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]["flow"][extractedWorkflow[indexPath.row]["name"].stringValue]["layout"]["name"].stringValue)")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]["flow"][extractedWorkflow[indexPath.row]["name"].stringValue]["layout"]["name"].stringValue{
        case "flexible-menu":
            if ldict_Worflowappmeta[extractedWorkflow[indexPath.row]["name"].stringValue]["flow"][extractedWorkflow[indexPath.row]["name"].stringValue]["layout"]["visibility"] != "hidden" {
                return UITableView.automaticDimension
            }else{
                return 1
            }
        default:
            if hideUnhideComponenet[extractedWorkflow[indexPath.row]["name"].stringValue] != nil &&  hideUnhideComponenet[extractedWorkflow[indexPath.row]["name"].stringValue] == false{
                return 1
                
            }else{
                return UITableView.automaticDimension
            }
        }
    }
    
    private func activateRequiredConstraints(for childView: UIView,tableviewCell:UITableViewCell) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.topAnchor.constraint(equalTo: tableviewCell.contentView.topAnchor).isActive = true
        childView.bottomAnchor.constraint(equalTo: tableviewCell.contentView.bottomAnchor).isActive = true
        childView.leadingAnchor.constraint(equalTo: tableviewCell.contentView.leadingAnchor).isActive = true
        childView.trailingAnchor.constraint(equalTo: tableviewCell.contentView.trailingAnchor).isActive = true
    }
    
}

extension AdvancedCompositeViewController:UIPickerViewDelegate,UIPickerViewDataSource,AdvancedCompositeDelegate{
    
    func updateSelectedTab(SelectedTab: Int?) {
        self.SelectedTab = SelectedTab
        extractedWorkflow.removeAll()
        self.getWorkflowData(workflowarray: self.larr_Workflow)
    }
    
    func UpdateCardFilter(SelectedTab: Int?) {
        self.SelectedCardTab = SelectedTab
    }
    
    func hideUnhideComponenet(componentName: String, Status: Bool) {
        self.hideUnhideComponenet[componentName] = Status
    }
    
    func setInitalValue(SelectedData: [JSON]?,query:JSON?) {
        if SelectedData != nil{
            self.SelectedData = SelectedData
            if SelectedQuery == nil {
                SelectedQuery = query
                self.refreshCompositeRow()
            }
        }
    }
    
    func refreshScreen(MyPickerData:[JSON]) {
        if MyPickerData.count > 0 {
            SelectedData = larr_ScreenData["\(MyPickerData[0]["key"])"] ?? []
        }
        //        self.refreshCompositeRow()
    }
    
    func setDelegate(delegate: QueryComponentViewDelegate) {
        self.delegate = delegate
    }
    
    func setChartDelegate(chartDelegate: ChartComponentViewDelegate) {
        self.chartDelegate = chartDelegate
    }
    
    func updateData(larr_ScreenData: [String : [JSON]]) {
        self.larr_ScreenData = larr_ScreenData
        self.refreshCompositeRow()
    }
    
    func updateScreenData(taskName: String, ScreenData: [JSON]) {
        self.larr_SubViewScreenData[taskName] = ScreenData
        self.refreshIndividualView(TaskId: taskName)
        //        self.refreshCompositeRow()
    }
    
    func addPickerView(MyPickerData:[JSON]) {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        self.MyPickerData = MyPickerData
        self.MyChartPickerData = nil
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 400, width: UIScreen.main.bounds.size.width, height: 400)
        self.view.addSubview(picker)
        
        if MyPickerData.count > 0 && SelectedQuery != nil {
            picker.selectRow(MyPickerData.firstIndex(of: SelectedQuery!)!, inComponent: 0, animated: true)
        }
        
        self.addDoneToolBarButton()
    }
    
    func addChartPickerView(MyChartPickerData: [String]?) {
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        self.MyPickerData = []
        self.MyChartPickerData = MyChartPickerData
        picker = UIPickerView.init()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = UIColor.white
        picker.setValue(UIColor.black, forKey: "textColor")
        picker.autoresizingMask = .flexibleWidth
        picker.contentMode = .center
        picker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 400, width: UIScreen.main.bounds.size.width, height: 400)
        self.view.addSubview(picker)
        
        self.addDoneToolBarButton()
    }
    
    
    private func addDoneToolBarButton(){
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 400, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .default
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,target: self, action:  #selector(onDoneButtonTapped))
        let cancelBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,target: self, action:  #selector(onDoneButtonTapped))
        
        toolBar.items = [cancelBtnDone,spaceButton,doneBtnDone]
        self.view.addSubview(toolBar)
    }
    
    
    @objc func onDoneButtonTapped() {
        if MyChartPickerData != nil {
            
        }else{
            if SelectedQuery == nil {
                SelectedQuery = MyPickerData[0]
                SelectedData = larr_ScreenData["\(MyPickerData[0]["key"])"] ?? []
            }
        }
        toolBar.removeFromSuperview()
        picker.removeFromSuperview()
        //        self.refreshCompositeRow()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if MyChartPickerData != nil {
            return MyChartPickerData!.count
        }else{
            return MyPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: self.view.frame.width-20, height: 44));
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        if MyChartPickerData != nil {
            label.attributedText = NSAttributedString(string: MyChartPickerData![row])
        }else{
            label.attributedText = NSAttributedString(string: MyPickerData[row]["value"].stringValue)
        }
        label.sizeToFit()
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if MyChartPickerData != nil {
            return 50.0
        }else{
            return 80.0
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if MyChartPickerData != nil{
            self.chartFilterValue = MyChartPickerData?[row]
            chartDelegate?.UpdateChartPickerValue(MyPickerData: MyChartPickerData?[row])
        }else{
            delegate?.UpdatePickerValue(MyPickerData: MyPickerData[row])
            SelectedQuery = MyPickerData[row]
            SelectedData = larr_ScreenData["\(MyPickerData[row]["key"])"] ?? []
            larr_SubViewScreenData.removeAll()
            larr_SubViewScreenData["\(MyPickerData[row]["key"])"] = SelectedData
        }
        self.refreshCompositeRow()
    }
    
    
    func gettaskDetails(taskName:String,queryparameter: String?){
        
        self.showActivityIndicator()
        
        var dataBodyDictionary:[String : Any] = [:]
        
        dataBodyDictionary = ["appId":"\(app_metaData!["appId"].stringValue)",
                              "workFlowTask":"\(taskName)","deviceType": "mobile"] as [String : Any]
        dataBodyDictionary["operation"] = []
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { (dataResponse) in
            self.hideActivityIndicator()
        }
        
        let bodydictionary = ["appId":"\(app_metaData!["appId"].stringValue)",
                              "workFlowTask":"\(taskName)",
                              "deviceType":"mobile"] as [String : Any]
        
        
        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
            self.hideActivityIndicator()
            switch taskResponse {
            case .success(let json):
                let larr_fields = json["flow"][taskName]["fields"].arrayValue
                let larr_Decision = json["flow"][taskName]["decisions"].arrayValue
                let ls_Title = json["flow"][taskName]["label"].stringValue
                
                switch json["flow"][taskName]["layout"]["name"].stringValue {
                case "list":
                    var larr_SortList:[String] = []
                    var larr_FilterList:[JSON] = []
                    
                    for each in larr_fields{
                        
                        if each["filter"] != nil && each["filter"] == true {
                            larr_FilterList.append(each)
                        }
                        
                        if each["sort"] != nil && each["sort"] == true {
                            larr_SortList.append(each["key"].stringValue)
                        }
                    }
                    
                    let ListVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "ListVC") as! ListViewController
                    ListVC.lb_Search = json["flow"][taskName]["layout"]["options"]["serverSearch"].bool ?? false
                    ListVC.larr_Decision = larr_Decision
                    ListVC.ls_ScreenTitle = ls_Title
                    ListVC.ls_appName = self.app_metaData!.dictionaryValue["sys__UUID"]!.stringValue
                    ListVC.ls_taskName = taskName
                    //                    ListVC.ls_Selectedappname = self.app.name
                    ListVC.larr_FilterList = larr_FilterList
                    ListVC.larr_SortList = larr_SortList
                    ListVC.layoutJson = json
                    ListVC.app = self.app
                    ListVC.ls_selectedQueryParameter = queryparameter
                    ListVC.ls_previousWorkflow = taskName
                    ListVC.ls_HomeWorkFlow  = taskName
                    self.navigationController?.pushViewController(ListVC, animated: true)
                    
                case "create":
                    let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                    CreateVC.app_metaData =  json
                    //                    CreateVC.ls_appName = self.app_metaData!["sys__UUID"].stringValue
                    CreateVC.ls_taskName = taskName
                    //                    CreateVC.ls_Selectedappname = self.app.name
                    CreateVC.ls_ScreenTitle = ls_Title
                    CreateVC.app = self.app
                    self.navigationController?.pushViewController(CreateVC, animated: true)
                    
                case "customv2":
                    
                    let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "AdvCompositeVC") as! AdvancedCompositeViewController
                    customVC.app_metaData = json
                    customVC.ls_taskName = taskName
                    self.navigationController?.pushViewController(customVC, animated: true)
                    
                    
                case "chart":
                    let ChartVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
                    ChartVC.layoutJson = json
                    ChartVC.ls_taskName = taskName
                    ChartVC.ls_ScreenTitle = ls_Title
                    self.navigationController?.pushViewController(ChartVC, animated: true)
                    
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
    
    private func refreshCompositeRow(){
        self.showActivityIndicator()
        for i in 0..<extractedWorkflow.count{
            switch ldict_Worflowappmeta[extractedWorkflow[i]["name"].stringValue]["flow"][extractedWorkflow[i]["name"].stringValue]["layout"]["name"].stringValue{
            
            case "query":
                break
                
            case "summary-tile":
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                
            case "cards-view":
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                //Refresh the tableview height
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                
            case "lastUpdated":
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                
            case "flexible-menu":
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                
            case "chart":
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                
            case "menu" :
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                
            case "view" :
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                
            default:
                print("\(ldict_Worflowappmeta[extractedWorkflow[i]["name"].stringValue]["flow"][extractedWorkflow[i]["name"].stringValue]["layout"]["name"].stringValue)")
            }
        }
        self.hideActivityIndicator()
    }
    
    func refreshIndividualView(TaskId: String) {
        self.showActivityIndicator()
        for i in 0..<extractedWorkflow.count{
            if let data = extractedWorkflow[i]["data"].string {
                if data.split(separator: ".")[data.split(separator: ".").count-1] == TaskId {
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
            }
        }
        
        //Refresh the tableview height
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
        self.hideActivityIndicator()
    }
    
    func showIndicator() {
        self.showActivityIndicator()
    }
    
    func hideIndicator() {
        self.hideActivityIndicator()
    }
    
    func pushViewController(Vc: UIViewController) {
        self.navigationController?.pushViewController(Vc, animated: true)
    }
}

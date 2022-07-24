//
//  CompositeViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 19/02/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit


class CompositeViewController: UIViewController,HUDRenderer,UITableViewDataSource,UITableViewDelegate,DetailViewDelegate,CreateViewDelegate {
    
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
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let BackButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action:  #selector(goBack))
        self.navigationItem.setLeftBarButtonItems([BackButton], animated: true)
        
        if ls_ScreenTitle != nil {
            self.navigationItem.title = "\(ls_ScreenTitle ?? "")"
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        self.larr_Decision = app_metaData!["flow"][ls_taskName!]["decisions"].array
        self.larr_Workflow = app_metaData!["flow"][ls_taskName!]["workflows"].array
        
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
        
        workFlowMetaData()
    }
    
    //MARK: - TableView Datasource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return larr_Workflow!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if ls_ViewController != nil {
//            ls_ViewController?.removeFromParentViewController()
//            ls_ViewController?.didMove(toParentViewController: nil)
//        }
        
        let cell = UITableViewCell()
        
        if let Individual_appMeta = ldict_Worflowappmeta[larr_Workflow![indexPath.row]["name"].stringValue].dictionary  {
            
            cell.layoutIfNeeded()
            
            switch Individual_appMeta["flow"]![larr_Workflow![indexPath.row]["name"].stringValue]["layout"]["name"].stringValue {
            case "view":
                let DetailVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
                DetailVC.app_metaData = JSON.init(Individual_appMeta)
                DetailVC.ls_appName = self.ls_appName
                DetailVC.ls_taskName = larr_Workflow![indexPath.row]["name"].stringValue
                DetailVC.larr_ScreenData = self.larr_ScreenData
                DetailVC.delegate = self
                ls_ViewController = DetailVC
                
                self.addChild(DetailVC)
                cell.contentView.addSubview(DetailVC.view)
                
                DetailVC.view.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addConstraint(NSLayoutConstraint(item: DetailVC.view!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: DetailVC.view!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: DetailVC.view!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: DetailVC.view!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
                
                DetailVC.didMove(toParent: self)
                DetailVC.view.layoutIfNeeded()
                
            case "list":
                
               let ListVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "ListVC") as! ListViewController
                
                ListVC.ls_appName =  self.ls_appName!
                ListVC.ls_taskName = larr_Workflow![indexPath.row]["name"].stringValue
                ListVC.larr_rawData = []
                if larr_Workflow![indexPath.row]["data"].string != nil {
                    ListVC.ldict_ScreenData = self.larr_ScreenData
                }
                ListVC.lb_ScreenHeight = false
                ListVC.layoutJson = ldict_Worflowappmeta[larr_Workflow![indexPath.row]["name"].stringValue]
                ListVC.larr_Decision = JSON.init(Individual_appMeta)["flow"][larr_Workflow![indexPath.row]["name"].stringValue]["decisions"].arrayValue
                ls_ViewController = ListVC
                
                self.addChild(ListVC)
                cell.contentView.addSubview(ListVC.view)
                
                ListVC.view.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addConstraint(NSLayoutConstraint(item: ListVC.view!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: ListVC.view!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: ListVC.view!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: ListVC.view!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
                
                ListVC.didMove(toParent: self)
                ListVC.view.layoutIfNeeded()
                
            case "create":
                let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                CreateVC.app_metaData = JSON.init(Individual_appMeta)
//                CreateVC.ls_appName =  self.ls_appName!
                CreateVC.ls_taskName = larr_Workflow![indexPath.row]["name"].stringValue
//                CreateVC.ls_Selectedappname = self.ls_Selectedappname
                CreateVC.ldict_ScreenData = self.larr_ScreenData!.dictionaryValue
                CreateVC.createdelegate = self
                
                self.addChild(CreateVC)
                cell.contentView.addSubview(CreateVC.view)
                
                CreateVC.view.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addConstraint(NSLayoutConstraint(item: CreateVC.view!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: CreateVC.view!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: CreateVC.view!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: 0.0))
                cell.contentView.addConstraint(NSLayoutConstraint(item: CreateVC.view!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: cell.contentView, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
                
                CreateVC.didMove(toParent: self)
                CreateVC.view.layoutIfNeeded()
                
            default:
                print("default")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let ls_height = self.ldict_WorflowHeight[larr_Workflow![indexPath.row]["name"].stringValue] {
            return ls_height
        }else{
            return UITableView.automaticDimension
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
    
    func submitData(decision:[String:JSON]){
        
        let bodydictionary:[String : Any] = ["workflowTaskName":decision["task"]!.stringValue,"task": decision["task"]!.stringValue,"appId":ls_appName!,"output":[decision["task"]!.stringValue:larr_ScreenData!.dictionaryObject!],"deviceType" : "mobile"] as [String : Any]
        
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
    
    func workFlowMetaData(){
        self.showActivityIndicator()
        
        for each in larr_Workflow!{
            
            let bodydictionary = ["appId":"\(ls_appName!)","workFlowTask":"\(each["name"])", "deviceType":"mobile"] as [String : Any]
            
            ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                self.hideActivityIndicator()
                switch taskResponse {
                case .success(let json):
                    for individualWorkflow in self.larr_Workflow!{
                        if json["flow"][individualWorkflow["name"].stringValue].dictionary != nil {
                            self.ldict_Worflowappmeta[individualWorkflow["name"].stringValue] = json
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.tableView.setNeedsLayout()
                                self.tableView.layoutSubviews()
//                                self.tableView.layoutIfNeeded()
                                self.tableView.reloadData()
                            }
                        }
                    }
                case .failure(let error):
                    self.showAlert(message: error.localizedDescription)
                    break
                case .failureJson(let errorJson):
                    print(errorJson)
                }
            }
        }
    }
    
    func DetailViewHeight(workFlowName: String, tableHeight: CGFloat) {
        self.ldict_WorflowHeight[workFlowName] = tableHeight
        DispatchQueue.main.async {
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
        }
    }
    
    func CreateViewHeight(workFlowName: String, tableHeight: CGFloat) {
        self.ldict_WorflowHeight[workFlowName] = tableHeight
    }
}

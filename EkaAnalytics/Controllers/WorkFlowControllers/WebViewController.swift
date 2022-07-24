//
//  WebViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 30/07/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController,WKNavigationDelegate,WKScriptMessageHandler,HUDRenderer {
    
    //MARK: - Variable
    var ls_appName:String?
    var ls_targetPath:String?
    var ls_taskName:String?
    var ls_orientation:String?
    var ls_previousWorkflow:String?
    var webView: WKWebView!
    var layoutJson:JSON?
    var larr_ButtonURL:[String] = []
    var larr_sessionStorage:[Any]?
    var ldict_ScreenData:JSON?
    var RightmenuArray:[JSON] = []
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ls_orientation == "landscape" {
            AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeLeft)
        }else{
            AppUtility.lockOrientation(.all, andRotateTo: .portrait)
        }
        
        larr_sessionStorage = layoutJson!["flow"][ls_taskName!]["layout"]["sessionStorage"].arrayObject
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        //Set title for the screen
        if let ls_ScreenTitle = layoutJson!["flow"]["\(ls_taskName!)"]["label"].string   {
            if ls_ScreenTitle.contains("${"){
                let title = ls_ScreenTitle
                
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
                        if self.ldict_ScreenData!.count > 0 {
                            titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.ldict_ScreenData!["\(titleSubstring)"].stringValue)
                        }
                    }else{
                        titleString = title
                    }
                }else{
                    titleString = nil
                }
               self.navigationItem.title = titleString
                
            }else{
                self.navigationItem.title = ls_ScreenTitle
            }
           
            self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        //Set the navigation bar
        setupData()
        
        self.setupWebView()
        self.view.addSubview(self.webView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        AppUtility.lockOrientation(.all)
    }
    
    
    //MARK: - Local Function
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        var js =  "sessionStorage.clear();"
        js = js + "sessionStorage.setItem('accessToken', '\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")');"
        js = js + "sessionStorage.setItem('Device-Id', '\(Utility.getVendorID())');"
        
        if ldict_ScreenData != nil {
            js = js + "sessionStorage.setItem('__selectedData__',JSON.stringify({'selected':{'\(ls_taskName!)' : \(ldict_ScreenData!)}}));"
        }
        
        if larr_sessionStorage != nil {
            for each in larr_sessionStorage!{
                js = js + "sessionStorage.setItem('\(each)', '\(ldict_ScreenData!["\(each)"])');"
            }
        }
        
        let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(userScript)
        
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.view.bounds, configuration: config)
        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        var urlString = ""
        
        if UIbaseURL.count > 0 {
            urlString = "\(UIbaseURL)/connect/\(BaseTenantID)/app/\(ls_targetPath!)"
        }else{
            urlString = "\(baseURL)/connect/\(BaseTenantID)/app/\(ls_targetPath!)"
        }
        
        print(urlString)
        let url = URL(string:urlString)!
        let request = URLRequest(url: url)
        self.webView.load(request)
        
        self.webView.navigationDelegate = self
    }
    
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "loginAction" {
            print("JavaScript is sending a message \(message.body)")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func barBtnTapped(_ sender:Any?){
        
        self.view.endEditing(true)
        
        let selectedButton = sender as! UIButton
        let selectedDecision:[String:JSON] = layoutJson!["flow"][ls_taskName!]["decisions"][selectedButton.tag].dictionaryValue
        
        if selectedDecision["type"] == "submit" {
            print("submit")
        }
        else{
            switch (selectedDecision["outcomes"]![0]["action"].stringValue).uppercased() {
            case "CANCEL":
                self.navigationController?.popViewController(animated: true)
                
            default:
                if self.ls_previousWorkflow! == selectedDecision["outcomes"]![0]["name"].stringValue{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        
    }
    
    func setupData(){
        //Add Bar Button Item in the screen.
        var rightBarbutton:[UIBarButtonItem] = []
        var leftBarbutton:[UIBarButtonItem] = []
        self.RightmenuArray = []
        
        if layoutJson!["flow"][ls_taskName!]["decisions"].count > 0 {
            for i in 0...layoutJson!["flow"][ls_taskName!]["decisions"].count-1 {
                if  layoutJson!["flow"][ls_taskName!]["decisions"][i]["position"] == "TopRight" || layoutJson!["flow"][ls_taskName!]["decisions"][i]["position"] == "bottom"{
                    
                    
                    if let displayed =  layoutJson!["flow"][ls_taskName!]["decisions"][i]["displayed"].string{
                        var displayedSplit:[String] = displayed.components(separatedBy: "==")
                        if displayedSplit.count > 1 {
                            
                            if displayed.contains("||"){
                                let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                                var licheck = 0
                                for j in 0..<valueSplit.count {
                                    if "'\(ldict_ScreenData![displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                        licheck = 1
                                    }
                                }
                                
                                if licheck == 1 {
                                    RightmenuArray.append(self.layoutJson!["flow"][ls_taskName!]["decisions"][i])
                                }
                            }else if displayed.contains("&&"){
                                let valueSplit:[String] = displayedSplit[1].components(separatedBy: "&&")
                                var licheck = 0
                                for j in 0..<valueSplit.count {
                                    if "'\(ldict_ScreenData![displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                        if j == 0 && licheck == 0 {
                                            licheck = 1
                                        }else if licheck != 1 {
                                            licheck = 0
                                        }
                                    }
                                }
                                if licheck == 1 {
                                    RightmenuArray.append(self.layoutJson!["flow"][ls_taskName!]["decisions"][i])
                                }
                            }else{
                                if "'\(ldict_ScreenData![displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                    RightmenuArray.append(self.layoutJson!["flow"][ls_taskName!]["decisions"][i])
                                }
                            }
                            
                        }else{
                            displayedSplit = displayed.components(separatedBy: "!=")
                            if displayed.contains("||"){
                                let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                                var licheck = 0
                                for j in 0..<valueSplit.count {
                                    if "'\(ldict_ScreenData![displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                        licheck = 1
                                    }
                                }
                                if licheck == 1 {
                                    RightmenuArray.append(self.layoutJson!["flow"][ls_taskName!]["decisions"][i])
                                }
                            }else if displayed.contains("&&"){
                                let valueSplit:[String] = displayedSplit[1].components(separatedBy: "&&")
                                var licheck = 0
                                for j in 0..<valueSplit.count {
                                    if "'\(ldict_ScreenData![displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                        if j == 0 && licheck == 0 {
                                            licheck = 1
                                        }else if licheck != 1 {
                                            licheck = 0
                                        }
                                    }
                                }
                                if licheck == 1 {
                                    RightmenuArray.append(self.layoutJson!["flow"][ls_taskName!]["decisions"][i])
                                }
                            }else{
                                if "'\(ldict_ScreenData![displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                    RightmenuArray.append(self.layoutJson!["flow"][ls_taskName!]["decisions"][i])
                                }
                            }
                        }
                        
                        
                    }else{
                        RightmenuArray.append(self.layoutJson!["flow"][ls_taskName!]["decisions"][i])
                    }
                }
                else if  layoutJson!["flow"][ls_taskName!]["decisions"][i]["position"] == "TopLeft"{
                    
                    if let tragetURL = layoutJson!["flow"][ls_taskName!]["decisions"][i]["outcomes"][0]["targetPath"].string {
                        self.larr_ButtonURL.append(tragetURL)
                    }
                    
                    let LeftBtn = UIButton(type: .custom)
                    LeftBtn.setTitle(layoutJson!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue, for: .normal)
                    LeftBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                    LeftBtn.tag = i
                    LeftBtn.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                    let leftBarbtn = UIBarButtonItem(customView: LeftBtn)
                    leftBarbutton.append(leftBarbtn)
                    
                }
            }
        }
        
        if RightmenuArray.count > 1 {
            let rightBtn1 = UIButton(type: .custom)
            rightBtn1.setImage(#imageLiteral(resourceName: "meat_balls"), for: .normal)
            rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            rightBtn1.addTarget(self, action: #selector(optionsButtonTapped(_:event:)), for: .touchUpInside)
            let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
            rightBarbutton.append(rightBtn1item)
        }else if RightmenuArray.count == 1{
            let rightBtn1 = UIButton(type: .custom)
            if self.RightmenuArray[0]["outcomes"][0]["style"]["btnImage"].stringValue != "" {
                rightBtn1.setImage(UIImage(named: self.RightmenuArray[0]["outcomes"][0]["style"]["btnImage"].stringValue), for: .normal)
                rightBtn1.tag = 9997
            }else{
                rightBtn1.setTitle(self.RightmenuArray[0]["label"].stringValue, for: .normal)
                rightBtn1.tag = 9997
            }
            rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
            let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
            
            rightBarbutton.append(rightBtn1item)
        }
        
        if rightBarbutton.count > 0 {
            self.navigationItem.setRightBarButtonItems(rightBarbutton, animated: true)
        }
        
        if leftBarbutton.count > 0 {
            self.navigationItem.setLeftBarButtonItems(leftBarbutton, animated: true)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideActivityIndicator()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if larr_ButtonURL.contains("\(webView.url!)") {
            self.navigationController?.popViewController(animated: true)
        }else{
            self.showActivityIndicator()
        }
    }
    
    @objc func optionsButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        
        var alertController : UIAlertController
        
        alertController = UIAlertController(title: nil , message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for i in 0..<RightmenuArray.count{
            
            let BtnString:String = RightmenuArray[i]["label"].stringValue
            
            let Action = UIAlertAction(title: BtnString, style: .default) { (finish) in
                
                let selectedDecision = self.RightmenuArray[i].dictionaryValue
                
                if selectedDecision["type"] == "submit" {
                    //                      self.submitData(decision: selectedDecision)
                }
                else{
                    switch (selectedDecision["outcomes"]![0]["action"].stringValue).uppercased() {
                    case "CANCEL":
                        self.navigationController?.popViewController(animated: true)
                        
                    default:
                        
                        self.showActivityIndicator()
                        
                        let bodydictionary = ["appId":"\(self.ls_appName!)","workFlowTask":"\(selectedDecision["outcomes"]![0]["name"])", "deviceType":"mobile"] as [String : Any]
                        
                        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) { (taskResponse) in
                            self.hideActivityIndicator()
                            switch taskResponse {
                            case .success(let json):
                                let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                                CreateVC.app_metaData =  json
//                                CreateVC.ls_appName = self.ls_appName!
                                CreateVC.ls_taskName = selectedDecision["outcomes"]![0]["name"].stringValue
                                if selectedDecision["outcomes"]![0]["data"] != nil {
                                    CreateVC.ldict_ScreenData = self.ldict_ScreenData?.dictionaryValue
                                }
                                
                                if let ls_ScreenTitle = json["flow"][selectedDecision["outcomes"]![0]["name"].stringValue]["label"].string  {
                                    if ls_ScreenTitle.contains("${"){
                                        let title = ls_ScreenTitle
                                        
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
                                                if self.ldict_ScreenData!.count > 0 {
                                                    titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.ldict_ScreenData!["\(titleSubstring)"].stringValue)
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
                                    
                                    self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
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
            
            alertController.addAction(Action)
        }
        
        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}

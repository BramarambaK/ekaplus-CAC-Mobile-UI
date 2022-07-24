//
//  CreateViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 25/04/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc protocol crudDelegate {
    @objc optional func refreshData()
    @objc optional func sendDataBackToHomePageViewController(bodyJson: [String:String],larr_error:[String:String]?)
    @objc optional func updatebodyJson(bodyJson:[String:String])
}

protocol CreateViewDelegate {
    func CreateViewHeight(workFlowName:String,tableHeight:CGFloat)
}

final class CreateViewController: UIViewController,HUDRenderer,UITextFieldDelegate,KeyboardObserver,UIPickerViewDelegate,UIPickerViewDataSource,crudDelegate,MLdelegate {
    
    
    func updatebodyJson(bodyJson:[String:String]){
        larr_bodyJson["\(bodyJson.keys.first!)"] = "\(bodyJson.values.first!)"
        print(larr_bodyJson)
    }
    
    func sendDataBackToHomePageViewController(bodyJson: [String : String],larr_error:[String:String]?) {
        self.larr_bodyJson = bodyJson
        self.larr_error = larr_error ?? [:]
        self.reloadTableview(tableView: self.tableView)
        self.ls_previousBtn = 1
    }
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lv_bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView_Height: NSLayoutConstraint!
    
    
    //MARK: - Variable
    var app:App!
    var larr_fields:[JSON]?
    var ldict_object:JSON?
    var app_metaData:JSON?
    var ls_taskName:String?
    var larr_bodyJson:[String:String] = [:]
    var larr_recomendationJson:[String:String] = [:]
    var larr_keybodyJson:[String:String] = [:]
    var myPickerData:[JSON] = []
    var activeTextfield : UITextField?
    var larr_dropDownServiceKey:[[String:Any]]=[]
    var ldict_dropdownData:JSON?
    let dataPicker = UIPickerView()
    var ls_ScreenMode = "Create"
    var ldict_ScreenData:[String:JSON]?
    var datePicker : UIDatePicker!
    var larr_screenFields:[JSON]?
    var ls_ScreenTitle:String?
    var ls_SelectedKey:String?
    var ls_SelectedValue:String?
    var larr_dropdownValue:[String:String] = [:]
    var larr_MLFields:[String] = []
    var larr_processedStirng:JSON = []
    var monthYearPicker = MonthPickerView()
    var ls_previousWorkflow:String?
    var RightmenuArray:[JSON] = []
    var larr_screenServiceKeys:[JSON] = []
    var larr_tempscreenServiceKeys:[JSON] = []
    var li_ScreenNumber = 0
    var ls_previousBtn:Int = 0
    var li_newVersion = 0
    var li_eventChk:Bool = true
    var ls_individualJson:JSON?
    var larr_error:[String:String] = [:]
    var larr_OfflineFileds:[String] = []
    var larr_selectedDropdown:[String:String] = [:]
    var delegate:crudDelegate?
    var createdelegate:CreateViewDelegate?
    
    var container: UIView{
        return self.scrollView
    }
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MMM-dd"
        return df
    }()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(hex: "EEEEF3")
        
        tableView.register(UINib(nibName: "CheckboxTableViewCell", bundle: nil), forCellReuseIdentifier: CheckboxTableViewCell.reuseIdentifier)
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        if ls_ScreenTitle != nil {
            self.navigationItem.title = ls_ScreenTitle
            
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
        
        tableView.estimatedRowHeight = 40.5
        self.bottomViewHeight.constant = 0.0
        self.lv_bottomView.isHidden = true
        
        // Do any additional setup after loading the view.
        self.registerForKeyboardNotifications(shouldRegister: true)
        
        self.larr_fields = app_metaData!["flow"][ls_taskName!]["fields"].arrayValue
        self.ldict_object = app_metaData!["objectMeta"]
        
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self)
        //Register Notification
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(Submit), name: NSNotification.Name("Submit"), object: nil)
        nc.addObserver(self, selector: #selector(Next), name: NSNotification.Name("Next"), object: nil)
        nc.addObserver(self, selector: #selector(processText), name: NSNotification.Name("NLPProcess"), object: nil)
        
        
        if ldict_ScreenData != nil {
            
            for i in 0..<larr_fields!.count{
                self.setupValue(fieldsJson: larr_fields![i].arrayValue)
            }
            
        }
        
        if larr_processedStirng.count > 0 && ls_previousBtn == 0 {
            self.processedtextParsing(dataJson:larr_processedStirng)
        }
        
        if ldict_dropdownData == nil {
            self.larr_dropDownServiceKey.removeAll()
            self.getMDMData()
        }
        
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let SelectedRow = textField.tag-(1000)
        let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
        self.larr_recomendationJson.removeValue(forKey: "\(SelectedField["labelKey"].stringValue)")
        self.reloadTableview(tableView: self.tableView)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if activeTextfield != nil{
            let SelectedRow = activeTextfield!.tag-(1000)
            
            let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
            
            if SelectedField["children"].arrayValue.count > 0  {
                larr_keybodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                if SelectedField["dropdownValue"].string != nil {
                    larr_bodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
                }
                
                //Reset the child
                if  larr_bodyJson[SelectedField["labelKey"].stringValue] !=  activeTextfield!.text!{
                    for i in 0..<SelectedField["children"].arrayValue.count{
                        larr_keybodyJson[SelectedField["children"][i].stringValue] = ""
                        larr_bodyJson[SelectedField["children"][i].stringValue] = ""
                        let ChildField = ldict_object!["fields"]["\(SelectedField["children"][i].stringValue)"]
                        if ChildField["dropdownValue"].string != nil {
                            larr_bodyJson[ChildField["dropdownValue"].stringValue] = ""
                        }
                    }
                }
            }
            
            if myPickerData.count > 0 {
                larr_keybodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                if SelectedField["dropdownValue"].string != nil {
                    larr_keybodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
                }
            }else{
                larr_keybodyJson[SelectedField["labelKey"].stringValue] = activeTextfield?.text!
            }
            
            larr_bodyJson[SelectedField["labelKey"].stringValue] = activeTextfield?.text!
            
            activeTextfield = nil
        }
        
        activeTextfield = textField
        let SelectedRow = textField.tag-(1000)
        var selectedRow:Int = 0
        
        let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
        
        if larr_screenFields![SelectedRow]["type"] == "readOnly" {
            return false
        }else{
            
            switch SelectedField["type"]{
            case "dropdown","radio":
                larr_selectedDropdown = [:]
                
                if larr_bodyJson[SelectedField["labelKey"].stringValue] != nil{
                    larr_selectedDropdown[SelectedField["labelKey"].stringValue] = larr_bodyJson[SelectedField["labelKey"].stringValue] ?? ""
                    
                    if larr_bodyJson[SelectedField["dropdownValue"].stringValue] != nil{
                        larr_selectedDropdown[SelectedField["dropdownValue"].stringValue] = larr_bodyJson[SelectedField["dropdownValue"].stringValue] ?? ""
                    }
                    
                }else{
                    larr_selectedDropdown[SelectedField["dropdownValue"].stringValue] = ""
                    larr_bodyJson[SelectedField["dropdownValue"].stringValue] = ""
                }
                
                dataPicker.delegate = self
                textField.inputView = dataPicker
                textField.inputAccessoryView = self.addToolbarbutton()
                
                if SelectedField["propertyKey"] != JSON.null {
                    var DropdownJSON:[JSON] = SelectedField["propertyKey"]["\(SelectedField["propertyKey"].dictionaryValue.keys.first!)"].arrayValue
                    let blankJSON =  ["key":"","value":"---Select---"]
                    DropdownJSON.insert(JSON.init(parseJSON: blankJSON.jsonString()), at: 0)
                    myPickerData = DropdownJSON
                }
                else{
                    if ldict_dropdownData != nil {
                        if SelectedField["parent"].count > 0 {
                            ldict_dropdownData![SelectedField["serviceKey"].stringValue] = []
                        }
                        
                        
                        let DropDownValue = self.ldict_dropdownData?.dictionaryValue
                        
                        self.ldict_dropdownData = JSON.init(rawValue: DropDownValue!)
                        
                        if ldict_dropdownData![SelectedField["serviceKey"].stringValue] == JSON.null ||  ldict_dropdownData![SelectedField["serviceKey"].stringValue].count == 0 {
                            
                            myPickerData = []
                            
                            if ldict_dropdownData![SelectedField["labelKey"].stringValue] == JSON.null ||  ldict_dropdownData![SelectedField["labelKey"].stringValue].count == 0 {
                                
                                var larr_dependDropDownServiceKey:[[String:Any]] = []
                                var larr_dependsOn:[String] = []
                                for i in 0..<SelectedField["parent"].count{
                                    larr_dependsOn.append(larr_keybodyJson[SelectedField["parent"][i].stringValue] ?? "")
                                }
                                var DropdownServiceKey:[String:Any] = [:]
                                DropdownServiceKey["serviceKey"] = SelectedField["serviceKey"].stringValue
                                DropdownServiceKey["dependsOn"] = larr_dependsOn
                                larr_dependDropDownServiceKey.append(DropdownServiceKey)
                                
                                if larr_dependDropDownServiceKey.count > 0 {
                                    
                                    let bodyObject = ["deviceType":"mobile","appId":app_metaData!["appId"].stringValue,"workFlowTask":ls_taskName!, "data": larr_dependDropDownServiceKey] as [String : Any]
                                    
                                    self.showActivityIndicator()
                                    ConnectManager.shared.getMdmData(bodyObject: bodyObject) { [self]  (response) in
                                        self.hideActivityIndicator()
                                        switch response{
                                        case .success(let json):
                                            if self.activeTextfield != nil{
                                                let ls_SelectedRow = self.activeTextfield!.tag-(1000)
                                                self.dataPicker.delegate = self
                                                self.activeTextfield!.inputView = self.dataPicker
                                                
                                                let ls_SelectedField = self.ldict_object!["fields"]["\(self.larr_screenFields![ls_SelectedRow]["key"])"]
                                                
                                                if let filterBy = self.larr_screenFields![SelectedRow]["filterBy"].string {
                                                    var DropdownJSON:[JSON] = self.dropdownFilterBy(filterBy: filterBy, dropdowndata: json[ls_SelectedField["serviceKey"].stringValue].arrayValue)
                                                    let blankJSON =  ["key":"","value":"---Select---"]
                                                    DropdownJSON.insert(JSON.init(parseJSON: blankJSON.jsonString()), at: 0)
                                                    myPickerData = DropdownJSON
                                                }else{
                                                    if json[ls_SelectedField["serviceKey"].stringValue] == nil && app_metaData!["flow"][self.ls_taskName!]["layout"]["offlineSupport"] == true {
                                                        self.activeTextfield!.inputView = nil
                                                        self.activeTextfield?.inputAccessoryView = nil
                                                    }else{
                                                        var DropdownJSON:[JSON] = json[ls_SelectedField["serviceKey"].stringValue].arrayValue
                                                        let blankJSON =  ["key":"","value":"---Select---"]
                                                        DropdownJSON.insert(JSON.init(parseJSON: blankJSON.jsonString()), at: 0)
                                                        myPickerData = DropdownJSON
                                                    }
                                                }
                                                
                                                if self.larr_screenServiceKeys.contains(ls_SelectedField) {
                                                    self.ldict_dropdownData![ls_SelectedField["labelKey"].stringValue] = json[ls_SelectedField["serviceKey"].stringValue]
                                                }else{
                                                    self.ldict_dropdownData![ls_SelectedField["serviceKey"].stringValue] = json[ls_SelectedField["serviceKey"].stringValue]
                                                }
                                            }
                                        case .failure(let error):
                                            self.showAlert(message:error.description)
                                            self.view.endEditing(true)
                                            
                                        case .failureJson(_):
                                            break
                                        }
                                    }
                                }
                            }
                            else{
                                var DropdownJSON:[JSON] = ldict_dropdownData![SelectedField["labelKey"].stringValue].arrayValue
                                let blankJSON =  ["key":"","value":"---Select---"]
                                DropdownJSON.insert(JSON.init(parseJSON: blankJSON.jsonString()), at: 0)
                                myPickerData = DropdownJSON
                            }
                            
                        }else{
                            if let filterBy = larr_screenFields![SelectedRow]["filterBy"].string {
                                var DropdownJSON:[JSON] = dropdownFilterBy(filterBy: filterBy, dropdowndata: ldict_dropdownData![SelectedField["serviceKey"].stringValue].arrayValue)
                                let blankJSON =  ["key":"","value":"---Select---"]
                                DropdownJSON.insert(JSON.init(parseJSON: blankJSON.jsonString()), at: 0)
                                myPickerData = DropdownJSON
                            }else{
                                var DropdownJSON:[JSON] = ldict_dropdownData![SelectedField["serviceKey"].stringValue].arrayValue
                                let blankJSON =  ["key":"","value":"---Select---"]
                                DropdownJSON.insert(JSON.init(parseJSON: blankJSON.jsonString()), at: 0)
                                myPickerData = DropdownJSON
                            }
                        }
                        
                    }
                    else{
                        myPickerData = []
                        if app_metaData!["flow"][ls_taskName!]["layout"]["offlineSupport"] == true {
                            self.larr_OfflineFileds.append(SelectedField["labelKey"].stringValue)
                            textField.inputView = nil
                            textField.inputAccessoryView = nil
                        }
                    }
                }
                
                if SelectedField["dropdownValue"].string != nil {
                    textField.text = larr_bodyJson[SelectedField["dropdownValue"].stringValue]
                }else{
                    
                    for each in myPickerData {
                        if each["key"].stringValue == larr_bodyJson[SelectedField["labelKey"].stringValue]{
                            textField.text = each["value"].stringValue
                        }
                    }
                }
                selectedRow = 0
                
                dataPicker.selectRow(selectedRow, inComponent: 0, animated: true)
                
                
            case "datepicker":
                self.myPickerData = []
                self.pickUpDate(textField)
                
            case "monthpicker":
                self.myPickerData = []
                let toolbarDone = UIToolbar.init()
                toolbarDone.sizeToFit()
                let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                                      target: self, action: #selector(doneButtonAction))
                
                toolbarDone.items = [spaceButton,barBtnDone] // You can even add cancel button too
                
                textField.inputView = monthYearPicker
                textField.inputAccessoryView = toolbarDone
                
                
                monthYearPicker.onDateSelected = { (month: Int, year: Int) in
                    let dateFormatter1 = DateFormatter()
                    let SelectedRow = self.activeTextfield!.tag-(1000)
                    
                    let SelectedField = self.ldict_object!["fields"]["\(self.larr_screenFields![SelectedRow]["key"])"]
                    
                    if SelectedField["format"].string != nil{
                        dateFormatter1.dateFormat = SelectedField["format"].stringValue
                    }else{
                        if  SelectedField["type"] == "monthpicker" {
                            dateFormatter1.dateFormat = (self.app_metaData!["properties"]["month_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
                        }else{
                            dateFormatter1.dateFormat = (self.app_metaData!["properties"]["date_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
                        }
                        
                    }
                    
                    dateFormatter1.locale = NSLocale.current
                    dateFormatter1.locale = NSLocale(localeIdentifier: "en_US") as Locale?
                    var c = DateComponents()
                    c.year = year
                    c.month = month
                    c.day = 05
                    
                    // Get NSDate given the above date components
                    let date = NSCalendar(identifier: NSCalendar.Identifier.gregorian)?.date(from: c)
                    
                    self.activeTextfield?.text = dateFormatter1.string(from: date!)
                    
                    self.larr_bodyJson[SelectedField["labelKey"].stringValue] = self.activeTextfield?.text!
                }
                
                
            default:
                self.myPickerData = []
                if (SelectedField["dataType"].stringValue).uppercased() == "NUMBER"{
                    textField.keyboardType = .numbersAndPunctuation
                }
                textField.inputView = nil
                textField.inputAccessoryView = nil
            }
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
        let SelectedRow = textField.tag-(1000)
        let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
        
        if activeTextfield == textField {
            
            if SelectedField["type"] == "dropdown" {
                larr_bodyJson[SelectedField["dropdownValue"].stringValue] = activeTextfield?.text!
                if larr_OfflineFileds.contains(SelectedField["labelKey"].stringValue) == false {
                    larr_OfflineFileds.append(SelectedField["labelKey"].stringValue)
                }
            }else{
                larr_bodyJson[SelectedField["labelKey"].stringValue] = activeTextfield?.text!
            }
            
            if SelectedField["children"].arrayValue.count > 0 && myPickerData.count > 0 {
                larr_keybodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                if SelectedField["dropdownValue"].string != nil {
                    larr_bodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
                }
            }
            
            if myPickerData.count > 0 {
                larr_keybodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                if SelectedField["dropdownValue"].string != nil {
                    larr_keybodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
                }
            }else{
                larr_keybodyJson[SelectedField["labelKey"].stringValue] = activeTextfield?.text!
            }
            activeTextfield = nil
        }
        
        if let event = larr_screenFields![textField.tag-1000]["event"].string{
            
            if event.uppercased() != "EXTERNAL"{
                
                let result:String = ConnectManager.shared.evaluateJavaExpression(expression: event, data: JSON.init(parseJSON: larr_bodyJson.jsonString())) as? String ?? ""
                
                if result != "true" {
                    showAlert(title: "", message: result, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true) { response in
                        self.larr_bodyJson[SelectedField["labelKey"].stringValue] = ""
                    }
                }
                
            }
        }
        
    }
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var Data = ""
        if activeTextfield?.text == "" {
            Data = "\(myPickerData[0].dictionaryValue["value"]!)"
            ls_SelectedKey = myPickerData[0].dictionaryValue["key"]?.stringValue
            ls_SelectedValue = myPickerData[0].dictionaryValue["value"]?.stringValue
            activeTextfield?.text = Data
            
            let SelectedRow = activeTextfield!.tag-(1000)
            
            let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
            larr_bodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
            if SelectedField["dropdownValue"].string != nil {
                larr_bodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
            }
        }else{
            Data = "\(myPickerData[row].dictionaryValue["value"]!)"
            ls_SelectedKey = myPickerData[row].dictionaryValue["key"]?.stringValue
            ls_SelectedValue = myPickerData[row].dictionaryValue["value"]?.stringValue
        }
        
        if (activeTextfield?.text! == Data) {
            pickerView.selectRow(row, inComponent: 0, animated: true)
        }
        return Data
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if myPickerData.count > 0 {
            activeTextfield?.text = "\(myPickerData[row].dictionaryValue["value"]!)"
            ls_SelectedKey = "\(myPickerData[row].dictionaryValue["key"]!)"
            ls_SelectedValue = "\(myPickerData[row].dictionaryValue["value"]!)"
            
            
            let SelectedRow = activeTextfield!.tag-(1000)
            
            let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
            larr_bodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
            if SelectedField["dropdownValue"].string != nil {
                larr_bodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
            }
        }
    }
    
    //MARK: - MLDelegate
    
    func MLProcessText(enteredText: String?) {
        if li_newVersion == 0 {
            if enteredText!.count > 0 {
                
                let bodyObject = ["sentence":enteredText!,"appId":app_metaData!["appId"].stringValue,"workFlowTask":ls_taskName!] as [String : Any]
                self.showActivityIndicator()
                
                ConnectManager.shared.getProcessedString(dataBodyDictionary: bodyObject) {  (response) in
                    self.hideActivityIndicator()
                    
                    switch response {
                    case .success(let dataJson):
                        if dataJson["tags"] != nil {
                            self.processedtextParsing(dataJson: dataJson["tags"])
                        }
                        
                    case .failure(let error):
                        print(error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }else{
                showAlert(message: "No Data to process.")
            }
        }else{
            if enteredText!.count > 0 {
                
                let bodyObject = ["sentence":enteredText!,"appId":app_metaData!["appId"].stringValue,"workFlowTask":ls_taskName!] as [String : Any]
                self.showActivityIndicator()
                
                ConnectManager.shared.getProcessedString(dataBodyDictionary: bodyObject) {  (response) in
                    self.hideActivityIndicator()
                    
                    switch response {
                    case .success(let dataJson):
                        if dataJson["tags"] != nil {
                            self.processedtextParsing(dataJson: dataJson["tags"])
                        }
                        
                        self.reloadTableview(tableView: self.tableView)
                        
                    case .failure(let error):
                        print(error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }else{
                showAlert(message: "No Data to process.")
            }
        }
        
        
    }
    
    //MARK: - Local Function
    
    func setupData(){
        
        //Reset the Service Key
        self.larr_screenServiceKeys = []
        
        // Get the Screen Field array
        if larr_fields![li_ScreenNumber].array != nil {
            larr_screenFields = larr_fields![li_ScreenNumber].arrayValue
        }else{
            larr_screenFields = larr_fields![li_ScreenNumber].dictionaryValue["fields"]!.arrayValue
        }
        
        for i in 0..<larr_screenFields!.count {
            let rowField = ldict_object!["fields"]["\(larr_screenFields![i]["key"])"]
            if rowField != nil {
                if rowField["labelKey"].stringValue != ""{
                    if larr_bodyJson [rowField["labelKey"].stringValue] == nil {
                        larr_bodyJson [rowField["labelKey"].stringValue] = ""
                    }
                }else{
                    larr_bodyJson ["\(larr_screenFields![i]["key"])"] = ""
                }
                
            }
        }
        
        
        //Add Bar Button Item in the screen.
        var px = 10
        var rightBarbutton:[UIBarButtonItem] = []
        var leftBarbutton:[UIBarButtonItem] = []
        
        if larr_fields!.count-1 == li_ScreenNumber {
            
            if li_ScreenNumber == 0 && larr_fields!.count-1 == 0{
                if app_metaData!["flow"][ls_taskName!]["layout"]["recommedationNeed"].boolValue == true && ls_ScreenMode != "Offline"{
                    self.getRecomendationdetails()
                }
            }
            
            if app_metaData!["flow"][ls_taskName!]["decisions"].count > 0 {
                
                for i in 0...app_metaData!["flow"][ls_taskName!]["decisions"].count-1 {
                    if  app_metaData!["flow"][ls_taskName!]["decisions"][i]["position"] == ""{
                        
                        let ls_btnTitle = "    \(app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue)    "
                        
                        let Stringsize: CGSize = ls_btnTitle.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)])
                        
                        let btn = UIButton(frame: CGRect(x: px, y: 10, width: Int(Stringsize.width)+25, height: 100))
                        btn.setTitle("   \(app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue)   ", for: .normal)
                        btn.setTitleColor(.black , for: .normal)
                        btn.sizeToFit()
                        btn.borderWidth = 1
                        btn.cornerRadius = 5
                        btn.borderColor = .lightGray
                        btn.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                        btn.tag = i
                        px = px + Int(Stringsize.width)+25
                        self.lv_bottomView.addSubview(btn)
                    }
                    else if  app_metaData!["flow"][ls_taskName!]["decisions"][i]["position"] == "TopRight" || app_metaData!["flow"][ls_taskName!]["decisions"][i]["position"] == "bottom"{
                        
                        if larr_fields!.count == 1{
                            let rightBtn1 = UIButton(type: .custom)
                            if self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["outcomes"][0]["style"]["btnImage"].stringValue != "" {
                                rightBtn1.setImage(UIImage(named: self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["outcomes"][0]["style"]["btnImage"].stringValue), for: .normal)
                            }else{
                                rightBtn1.setTitle(app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue, for: .normal)
                            }
                            rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                            rightBtn1.tag = i
                            rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                            let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                            
                            rightBarbutton.append(rightBtn1item)
                        }else{
                            if app_metaData!["flow"][ls_taskName!]["decisions"][i]["type"].stringValue == "submit" || app_metaData!["flow"][ls_taskName!]["decisions"][i]["outcomes"][0]["version"] != nil{
                                let rightBtn1 = UIButton(type: .custom)
                                if app_metaData!["flow"][ls_taskName!]["decisions"][i]["type"].stringValue == "submit" {
                                    rightBtn1.setTitle(app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue, for: .normal)
                                    rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                    rightBtn1.tag = i
                                    rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                    let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                    
                                    rightBarbutton.append(rightBtn1item)
                                }else if app_metaData!["flow"][ls_taskName!]["decisions"][i]["outcomes"][0]["version"] != nil {
                                    RightmenuArray.append(self.app_metaData!["flow"][ls_taskName!]["decisions"][i])
                                }
                            }
                        }
                    }
                    else if  app_metaData!["flow"][ls_taskName!]["decisions"][i]["position"] == "TopLeft"{
                        
                        if larr_fields!.count == 1{
                            let LeftBtn = UIButton(type: .custom)
                            LeftBtn.setTitle(app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue, for: .normal)
                            LeftBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                            LeftBtn.tag = i
                            LeftBtn.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                            let leftBarbtn = UIBarButtonItem(customView: LeftBtn)
                            leftBarbutton.append(leftBarbtn)
                        }else{
                            let LeftBtn = UIButton(type: .custom)
                            LeftBtn.setTitle("Previous", for: .normal)
                            LeftBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                            LeftBtn.tag = 9998
                            LeftBtn.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                            let leftBarbtn = UIBarButtonItem(customView: LeftBtn)
                            
                            leftBarbutton.append(leftBarbtn)
                        }
                    }
                    
                }
            }
            
            if RightmenuArray.count > 0{
                let rightBtn1 = UIButton(type: .custom)
                rightBtn1.setImage(#imageLiteral(resourceName: "meat_balls"), for: .normal)
                rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                rightBtn1.addTarget(self, action: #selector(optionsButtonTapped(_:event:)), for: .touchUpInside)
                let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                rightBarbutton.append(rightBtn1item)
            }
        }
        else{
            if li_ScreenNumber == 0{
                
                if app_metaData!["flow"][ls_taskName!]["layout"]["recommedationNeed"].boolValue == true && ls_ScreenMode != "Offline"{
                    self.getRecomendationdetails()
                }
                
                self.RightmenuArray = []
                
                if app_metaData!["flow"][ls_taskName!]["decisions"].count > 0 {
                    
                    for i in 0...app_metaData!["flow"][ls_taskName!]["decisions"].count-1 {
                        
                        switch app_metaData!["flow"][ls_taskName!]["decisions"][i]["position"] {
                        case "TopLeft":
                            let LeftBtn = UIButton(type: .custom)
                            LeftBtn.setTitle(app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue, for: .normal)
                            LeftBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                            LeftBtn.tag = i
                            LeftBtn.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                            let leftBarbtn = UIBarButtonItem(customView: LeftBtn)
                            
                            leftBarbutton.append(leftBarbtn)
                        case "TopRight","bottom":
                            let rightBtn1 = UIButton(type: .custom)
                            if  app_metaData!["flow"][ls_taskName!]["fields"].count > 1 {
                                if self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["type"].stringValue == "submit" {
                                    rightBtn1.setTitle("Next", for: .normal)
                                    rightBtn1.tag = 9999
                                    rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                    rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                    let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                    
                                    rightBarbutton.append(rightBtn1item)
                                }else {
                                    if self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"] != nil && self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"] != "" {
                                        RightmenuArray.append(self.app_metaData!["flow"][ls_taskName!]["decisions"][i])
                                    }
                                }
                            }
                            else{
                                
                                if self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["type"].stringValue == "submit" {
                                    rightBtn1.setTitle(self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue, for: .normal)
                                }else if self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue == "" {
                                    rightBtn1.setImage(UIImage(named: self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["outcomes"][0]["style"]["btnImage"].stringValue), for: .normal)
                                }else{ rightBtn1.setTitle(self.app_metaData!["flow"][ls_taskName!]["decisions"][i]["label"].stringValue, for: .normal)
                                }
                                
                                rightBtn1.tag = i
                                rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                                rightBtn1.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                                let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                                
                                rightBarbutton.append(rightBtn1item)
                            }
                        default:
                            break
                        }
                    }
                }
            }
            else{
                let LeftBtn = UIButton(type: .custom)
                LeftBtn.setTitle("Previous", for: .normal)
                LeftBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                LeftBtn.tag = 9998
                LeftBtn.addTarget(self, action: #selector(self.barBtnTapped(_:)), for: .touchUpInside)
                let leftBarbtn = UIBarButtonItem(customView: LeftBtn)
                
                leftBarbutton.append(leftBarbtn)
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
        }
        
        if rightBarbutton.count > 0 {
            self.navigationItem.setRightBarButtonItems(rightBarbutton, animated: true)
        }
        
        if leftBarbutton.count > 0 {
            self.navigationItem.setLeftBarButtonItems(leftBarbutton, animated: true)
        }
    }
    
    @objc func buttonAction(sender: UIButton) {
        
        if sender.tag == 9999{
            let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
            CreateVC.app_metaData =  self.app_metaData
            //            CreateVC.ls_appName = self.ls_appName
            CreateVC.ls_taskName = self.ls_taskName
            CreateVC.ldict_ScreenData = self.ldict_ScreenData
            CreateVC.li_ScreenNumber = self.li_ScreenNumber + 1
            CreateVC.larr_recomendationJson = self.larr_recomendationJson
            CreateVC.larr_error = self.larr_error
            CreateVC.ls_ScreenMode = self.ls_ScreenMode
            self.navigationController?.pushViewController(CreateVC, animated: true)
        }else{
            let selectedDecision = app_metaData!["flow"][ls_taskName!]["decisions"][sender.tag].dictionaryValue
            
            if selectedDecision["type"] != nil && selectedDecision["type"] == "submit" {
                
                submitData(decision: selectedDecision)
            }
            else{
                
                if selectedDecision["outcomes"]![0]["action"] == "reset" {
                    ls_ScreenMode = "reset"
                    self.reloadTableview(tableView: tableView)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        }
    }
    
    func submitData(decision:[String:JSON]){
        
        var bodydictionary:[String : Any] = [:]
        
        if ldict_ScreenData != nil && ldict_ScreenData!.count > 0 {
            bodydictionary = ["deviceType" : "mobile","workflowTaskName":self.ls_taskName!,"task": decision["task"]!.stringValue,"appId":app_metaData!["appId"].stringValue,"id": ldict_ScreenData!["_id"]?.string ?? "","output":[self.ls_taskName!:larr_bodyJson]]  as [String : Any]
        }else{
            bodydictionary = ["deviceType" : "mobile","workflowTaskName":self.ls_taskName!,"task": decision["task"]!.stringValue,"appId":app_metaData!["appId"].stringValue,"output":[self.ls_taskName!:larr_bodyJson]]  as [String : Any]
        }
        self.showActivityIndicator()
        
        ConnectManager.shared.submitRecord(type: .post, dataBodyDictionary: bodydictionary) {  (resultResponse) in
            
            self.hideActivityIndicator()
            
            switch resultResponse {
            case .success(let result):
                if self.ls_ScreenMode == "Offline" {
                    
                    var larr_tempBodyJson:[String:String] = [:]
                    
                    for each in self.ldict_ScreenData! {
                        larr_tempBodyJson[each.key] = each.value.stringValue
                    }
                    
                    ConnectManager.shared.DeleteDataFromCoredata(task: self.ls_taskName!, responseBody: larr_tempBodyJson.jsonString())
                }
                if result["showPopUp"].boolValue == true{
                    self.showAlert(title: "", message: result["message"].stringValue, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true, handler: { (success) in
                        if success{
                            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                            self.navigationController!.popToViewController(viewControllers[viewControllers.count - Int(self.larr_fields!.count+1)], animated: true)
                        }
                    })
                }else if result["action"].string?.uppercased() == "CANCEL" {
                    self.navigationController?.popViewController(animated: true)
                }
                else if let nextScreen = result["navigateURL"].string {
                    if nextScreen == self.ls_previousWorkflow {
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.gettaskDetails(taskName: nextScreen, previousScreenResponse: result)
                    }
                }
                else{
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(let errorJson):
                self.showAlert(message: errorJson["errorMessage"].stringValue)
                self.larr_error = [:]
                for i in 0..<errorJson["errors"].count {
                    var ls_field = errorJson["errors"][i]["errorContext"].stringValue.replacingOccurrences(of: "{field:", with: "")
                    ls_field = ls_field.replacingOccurrences(of: "}", with: "")
                    self.larr_error["\(ls_field)"] = errorJson["errors"][i]["errorMessage"].stringValue
                }
                self.reloadTableview(tableView: self.tableView)
            }
        }
    }
    
    func screenDataRefresh(decision:[String:JSON]){
        
        var bodydictionary:[String : Any] = [:]
        
        if ldict_ScreenData != nil && ldict_ScreenData!.count > 0 {
            bodydictionary = ["deviceType" : "mobile","workflowTaskName":self.ls_taskName!,"task": decision["task"]!.stringValue,"appId":app_metaData!["appId"].stringValue,"id":"","output":[self.ls_taskName!:larr_bodyJson]]  as [String : Any]
        }else{
            bodydictionary = ["deviceType" : "mobile","workflowTaskName":self.ls_taskName!,"task": decision["task"]!.stringValue,"appId":app_metaData!["appId"].stringValue,"output":[self.ls_taskName!:larr_bodyJson]]  as [String : Any]
        }
        self.showActivityIndicator()
        
        ConnectManager.shared.submitRecord(type: .post, dataBodyDictionary: bodydictionary) {  (resultResponse) in
            
            self.hideActivityIndicator()
            switch resultResponse {
            case .success(let result):
                for each in self.larr_bodyJson {
                    self.larr_bodyJson[each.key] = result["data"][each.key].stringValue
                }
                self.larr_dropDownServiceKey.removeAll()
                self.getMDMData()
                self.reloadTableview(tableView: self.tableView)
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(let errorJson):
                self.showAlert(message: errorJson["errorMessage"].stringValue)
                self.larr_error = [:]
                for i in 0..<errorJson["errors"].count {
                    var ls_field = errorJson["errors"][i]["errorContext"].stringValue.replacingOccurrences(of: "{field:", with: "")
                    ls_field = ls_field.replacingOccurrences(of: "}", with: "")
                    self.larr_error["\(ls_field)"] = errorJson["errors"][i]["errorMessage"].stringValue
                }
                self.reloadTableview(tableView: self.tableView)
            }
        }
    }
    
    @objc func doneButtonAction()
    {
        if activeTextfield != nil && (ls_SelectedKey != nil || myPickerData.count > 0) && (ls_SelectedValue != nil || myPickerData.count > 0){
            
            if (myPickerData.count == 0){
                ls_SelectedKey = ""
                ls_SelectedValue = ""
            }
            
            let SelectedRow = activeTextfield!.tag-(1000)
            
            let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
            
            
            if SelectedField["children"].arrayValue.count > 0  {
                larr_keybodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                larr_bodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                if let index = larr_MLFields.firstIndex(of: SelectedField["labelKey"].stringValue) {
                    larr_MLFields.remove(at: index)
                    larr_processedStirng[SelectedField["labelKey"].stringValue] = nil
                }
                if SelectedField["dropdownValue"].string != nil {
                    larr_bodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
                    larr_processedStirng[SelectedField["dropdownValue"].stringValue] = nil
                }
                
                larr_recomendationJson.removeValue(forKey: "\(SelectedField["labelKey"].stringValue)")
                larr_recomendationJson.removeValue(forKey: "\(SelectedField["dropdownValue"].stringValue)")
                
                
                //Reset the child
                if  larr_bodyJson[SelectedField["labelKey"].stringValue] !=  activeTextfield!.text!{
                    for i in 0..<SelectedField["children"].arrayValue.count{
                        larr_keybodyJson[SelectedField["children"][i].stringValue] = ""
                        larr_bodyJson[SelectedField["children"][i].stringValue] = ""
                        ldict_dropdownData?[SelectedField["children"][i].stringValue] = nil
                        
                        if let index = larr_MLFields.firstIndex(of: SelectedField["children"][i].stringValue) {
                            larr_MLFields.remove(at: index)
                        }
                        let ChildField = ldict_object!["fields"]["\(SelectedField["children"][i].stringValue)"]
                        if let index = larr_MLFields.firstIndex(of: ChildField["labelKey"].stringValue) {
                            larr_MLFields.remove(at: index)
                        }
                        if ChildField["dropdownValue"].string != nil {
                            larr_bodyJson[ChildField["dropdownValue"].stringValue] = ""
                        }
                    }
                    
                    //If selected field has child field call the depedent dropdown.
                    if SelectedField["children"].arrayValue.count > 0 {
                        self.getDependentDropDown()
                    }
                }
                
                self.VisibilityandDisability(field: SelectedField)
            }
            else{
                if myPickerData.count > 0 {
                    larr_keybodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                    larr_bodyJson[SelectedField["labelKey"].stringValue] = "\(ls_SelectedKey ?? myPickerData[0]["key"].stringValue)"
                    if let index = larr_MLFields.firstIndex(of: SelectedField["labelKey"].stringValue) {
                        larr_MLFields.remove(at: index)
                    }
                    
                    if SelectedField["dropdownValue"].string != nil {
                        if ls_SelectedValue == "---Select---" {
                            larr_bodyJson[SelectedField["dropdownValue"].stringValue] = ""
                        }else{
                            larr_bodyJson[SelectedField["dropdownValue"].stringValue] = "\(ls_SelectedValue ?? myPickerData[0]["value"].stringValue)"
                        }
                    }
                }
                else{
                    larr_keybodyJson[SelectedField["labelKey"].stringValue] = activeTextfield?.text!
                }
                larr_recomendationJson.removeValue(forKey: "\(SelectedField["labelKey"].stringValue)")
                larr_recomendationJson.removeValue(forKey: "\(SelectedField["dropdownValue"].stringValue)")
                
            }
            
            if let fieldSelected = larr_screenFields![SelectedRow]["event"].string {
                if fieldSelected.uppercased() == "EXTERNAL"{
                    for i in 0 ..< app_metaData!["flow"][ls_taskName!]["decisions"].count{
                        if app_metaData!["flow"][ls_taskName!]["decisions"][i]["selection"].stringValue.uppercased() == "EXTERNAL" {
                            self.screenDataRefresh(decision: app_metaData!["flow"][ls_taskName!]["decisions"][i].dictionaryValue)
                        }
                    }
                }
            }
            
            //            larr_bodyJson[SelectedField["labelKey"].stringValue] = activeTextfield?.text!
            if app_metaData!["flow"][ls_taskName!]["layout"]["recommedationNeed"].boolValue == true{
                self.getIndividualRecomendationdetails(FieldName:SelectedField["labelKey"].stringValue)
            }
            activeTextfield = nil
        }
        self.reloadTableview(tableView: self.tableView)
        self.view.endEditing(true)
    }
    
    @objc func rightBtnTapped(_ sender: Any?) {
        self.view.endEditing(true)
        let selectedButton = sender as! UIButton
        
        if selectedButton.tag == 9999{
            let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
            CreateVC.app_metaData =  self.app_metaData
            CreateVC.ls_taskName = self.ls_taskName
            CreateVC.ldict_ScreenData = self.ldict_ScreenData
            CreateVC.li_ScreenNumber = self.li_ScreenNumber + 1
            CreateVC.larr_bodyJson = self.larr_bodyJson
            CreateVC.ls_ScreenTitle = app_metaData!["flow"][ls_taskName!]["label"].stringValue
            CreateVC.larr_processedStirng = self.larr_processedStirng
            CreateVC.larr_recomendationJson = self.larr_recomendationJson
            CreateVC.delegate = self
            CreateVC.larr_error = self.larr_error
            CreateVC.ls_ScreenMode = self.ls_ScreenMode
            self.navigationController?.pushViewController(CreateVC, animated: true)
        }
        else if selectedButton.tag == 9998{
            self.navigationController?.popViewController(animated: true)
            self.delegate?.sendDataBackToHomePageViewController?(bodyJson: self.larr_bodyJson, larr_error: self.larr_error)
        }
        else{
            let selectedDecision = app_metaData!["flow"][ls_taskName!]["decisions"][selectedButton.tag].dictionaryValue
            
            
            if selectedDecision["type"] != nil && selectedDecision["type"] == "submit" {
                submitData(decision: selectedDecision)
            }
            else{
                if selectedDecision["outcomes"]![0]["action"] == "reset" {
                    ls_ScreenMode = "reset"
                    self.reloadTableview(tableView: self.tableView)
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @objc func leftBtnTapped(_ sender: Any?) {
        
        let selectedButton = sender as! UIButton
        
        let selectedDecision = app_metaData!["flow"][ls_taskName!]["decisions"][selectedButton.tag].dictionaryValue
        
        if selectedDecision["type"] != nil && selectedDecision["type"] == "submit" {
            submitData(decision: selectedDecision)
        }
        else{
            
            if selectedDecision["outcomes"]![0]["action"] == "reset" {
                ls_ScreenMode = "reset"
                self.reloadTableview(tableView: tableView)
            }else{
                self.navigationController?.popViewController(animated: true)
            }
            
        }
        
    }
    
    
    func pickUpDate(_ textField : UITextField){
        
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        if #available(iOS 13.4, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        }
        
        if (textField.text!.count > 1) {
            
            
            let SelectedRow = textField.tag-(1000)
            
            let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
            
            
            let formatter = DateFormatter()
            
            if SelectedField["format"].string != nil{
                formatter.dateFormat = SelectedField["format"].stringValue
            }else{
                if  SelectedField["type"] == "monthpicker" {
                    formatter.dateFormat = (app_metaData!["properties"]["month_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
                }else{
                    formatter.dateFormat = (app_metaData!["properties"]["date_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
                }
            }
            
            formatter.locale = NSLocale.current
            
            let textDate = formatter.date(from: textField.text!)
            if textDate != nil {
                self.datePicker.setDate(textDate!, animated: true)
            }
        }else{
            self.datePicker.setDate(Date(), animated: true)
        }
        
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar.init()
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
    
    @objc func barBtnTapped(_ sender:Any?){
        
        self.view.endEditing(true)
        
        let selectedButton = sender as! UIButton
        if selectedButton.tag == 9999{
            let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
            CreateVC.app_metaData =  self.app_metaData
            CreateVC.ls_taskName = self.ls_taskName
            CreateVC.ldict_ScreenData = self.ldict_ScreenData
            CreateVC.li_ScreenNumber = self.li_ScreenNumber + 1
            CreateVC.larr_bodyJson = self.larr_bodyJson
            CreateVC.larr_keybodyJson = self.larr_keybodyJson
            CreateVC.ls_ScreenTitle = app_metaData!["flow"][ls_taskName!]["label"].stringValue
            CreateVC.larr_processedStirng = self.larr_processedStirng
            CreateVC.larr_recomendationJson = self.larr_recomendationJson
            CreateVC.delegate = self
            CreateVC.larr_error = self.larr_error
            CreateVC.ls_ScreenMode = self.ls_ScreenMode
            self.navigationController?.pushViewController(CreateVC, animated: true)
        }
        else if selectedButton.tag == 9998{
            self.view.endEditing(true)
            self.navigationController?.popViewController(animated: true)
            self.delegate?.sendDataBackToHomePageViewController?(bodyJson: self.larr_bodyJson, larr_error: self.larr_error)
        }
        else{
            let selectedButton = sender as! UIButton
            var selectedDecision:[String:JSON] = [:]
            if selectedButton.tag == 9997 {
                selectedDecision = RightmenuArray[0].dictionaryValue
            }else{
                selectedDecision = app_metaData!["flow"][ls_taskName!]["decisions"][selectedButton.tag].dictionaryValue
            }
            
            
            
            if selectedDecision["type"] == "submit" {
                submitData(decision: selectedDecision)
            }
            else{
                
                switch (selectedDecision["outcomes"]![0]["action"].stringValue).uppercased() {
                case "CANCEL":
                    self.navigationController?.popViewController(animated: true)
                case "AUDIO":
                    NotificationCenter.default.removeObserver(self)
                    let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpeechVC") as! SpeechViewController
                    nextViewController.providesPresentationContextTransitionStyle = true
                    nextViewController.definesPresentationContext = true
                    nextViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                    nextViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                    nextViewController.delegate = self
                    if selectedDecision["outcomes"]![0]["version"].string != nil {
                        self.li_newVersion = 1
                    }
                    self.present(nextViewController, animated: true, completion: nil)
                    
                case "RESET":
                    ls_ScreenMode = "reset"
                    self.reloadTableview(tableView: tableView)
                    
                default:
                    
                    if ls_previousWorkflow == nil {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else if ls_previousWorkflow! == selectedDecision["outcomes"]![0]["name"].stringValue{
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.showActivityIndicator()
                        
                        let bodydictionary = ["appId":"\(app_metaData!["appId"].stringValue)","workFlowTask":"\(selectedDecision["outcomes"]![0]["name"])", "deviceType":"mobile"] as [String : Any]
                        
                        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary)  { (taskResponse) in
                            self.hideActivityIndicator()
                            switch taskResponse {
                            case .success(let json):
                                let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                                CreateVC.app_metaData =  json
                                //                                CreateVC.ls_appName = self.ls_appName!
                                CreateVC.ls_taskName = selectedDecision["outcomes"]![0]["name"].stringValue
                                
                                CreateVC.ls_ScreenTitle = json["flow"][selectedDecision["outcomes"]![0]["name"].stringValue]["label"].stringValue
                                CreateVC.larr_recomendationJson = self.larr_recomendationJson
                                CreateVC.larr_error = self.larr_error
                                CreateVC.ls_ScreenMode  = self.ls_ScreenMode
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
    }
    
    private func VisibilityandDisability(field:JSON){
        //Event Functionality
        //1.Loop through the child
        for i in 0..<field["children"].arrayValue.count{
            //2.Loop through the screen
            for j in li_ScreenNumber..<larr_fields!.count{
                //3.Loop through the records
                for k in 0..<larr_fields![j].count{
                    //Check for Children and field record
                    if larr_fields![j][k]["key"].stringValue == field["children"][i].stringValue {
                        
                        //Visibility with JavaScript
                        if let visibility =  ldict_object!["fields"][self.larr_fields![j][k]["key"].stringValue]["UIupdates"]["visibility"].string {
                            
                            let result:String = ConnectManager.shared.evaluateJavaExpression(expression: visibility, data: JSON.init(parseJSON: larr_bodyJson.jsonString())) as? String ?? ""
                            
                            if result == "true" {
                                if li_ScreenNumber == j {
                                    self.larr_screenFields![k]["type"] = nil
                                    self.larr_fields![j][k]["type"] = nil
                                }else{
                                    self.larr_fields![j][k]["type"] = nil
                                }
                            }else{
                                if li_ScreenNumber == j {
                                    self.larr_screenFields![k]["type"] = "hidden"
                                    self.larr_fields![j][k]["type"] = "hidden"
                                    self.larr_bodyJson[self.larr_fields![j][k]["key"].stringValue] = nil
                                }else{
                                    self.larr_fields![j][k]["type"] = "hidden"
                                    self.larr_bodyJson[self.larr_fields![j][k]["key"].stringValue] = nil
                                }
                            }
                        }
                        
                        
                        //Disability with JavaScript
                        if let disability =  ldict_object!["fields"][self.larr_fields![j][k]["key"].stringValue]["UIupdates"]["disability"].string {
                            
                            var disabilityString:String? = ""
                            
                            let disabilityStartIndex =  disability.range(of: "${")?.upperBound
                            let disabilityEndIndex =  disability.range(of: "}")?.lowerBound
                            
                            if disabilityStartIndex != nil && disabilityEndIndex != nil {
                                let disabilitySubstring = disability[(disability.range(of: "${"))!.upperBound..<(disability.range(of: "}"))!.lowerBound]
                                let disabilityReplaceSubstring = disability[(disability.range(of: "${"))!.lowerBound ..< (disability.range(of: "}"))!.upperBound]
                                if larr_bodyJson["\(disabilitySubstring)"] != nil {
                                    disabilityString = disability.replacingOccurrences(of: disabilityReplaceSubstring, with:larr_bodyJson["\(disabilitySubstring)"]!)
                                }else{
                                    disabilityString = disability.replacingOccurrences(of: disabilityReplaceSubstring, with:"")
                                }
                            }
                            
                            let jsSource = "var javascriptFunc = function() {\(disabilityString!)}"
                            
                            let context = JSContext()
                            context?.evaluateScript(jsSource)
                            
                            let testFunction = context?.objectForKeyedSubscript("javascriptFunc")
                            let result = testFunction?.call(withArguments: [])
                            
                            if result!.toString()! == "true" {
                                if li_ScreenNumber == j {
                                    self.larr_screenFields![k]["type"] = "readOnly"
                                    self.larr_fields![j][k]["type"] = "readOnly"
                                }else{
                                    self.larr_fields![j][k]["type"] = "readOnly"
                                }
                            }else{
                                if li_ScreenNumber == j {
                                    self.larr_screenFields![k]["type"] = nil
                                    self.larr_fields![j][k]["type"] = nil
                                }else{
                                    self.larr_fields![j][k]["type"] = nil
                                }
                            }
                        }
                        
                        //value with JavaScript
                        if let value =  ldict_object!["fields"][self.larr_fields![j][k]["key"].stringValue]["UIupdates"]["value"].string {
                            
                            var valueString:String? = ""
                            
                            let valueStartIndex =  value.range(of: "${")?.upperBound
                            let valueEndIndex =  value.range(of: "}")?.lowerBound
                            
                            if valueStartIndex != nil && valueEndIndex != nil {
                                let valueSubstring = value[(value.range(of: "${"))!.upperBound..<(value.range(of: "}"))!.lowerBound]
                                let valueReplaceSubstring = value[(value.range(of: "${"))!.lowerBound ..< (value.range(of: "}"))!.upperBound]
                                if larr_bodyJson["\(valueSubstring)"] != nil {
                                    valueString = value.replacingOccurrences(of: valueReplaceSubstring, with:larr_bodyJson["\(valueSubstring)"]!)
                                }
                                else{
                                    valueString = value.replacingOccurrences(of: valueReplaceSubstring, with:"")
                                }
                                
                            }
                            
                            let jsSource = "var javascriptFunc = function() {\(valueString!)}"
                            
                            let context = JSContext()
                            context?.evaluateScript(jsSource)
                            
                            let testFunction = context?.objectForKeyedSubscript("javascriptFunc")
                            let result = testFunction?.call(withArguments: [])
                            
                            if result!.toString()! != "undefined" {
                                larr_bodyJson["\(self.larr_screenFields![k]["key"].stringValue)"] = result!.toString()!
                            }
                        }
                        break
                    }
                }
                break
            }
        }
    }
    
    
    @objc func optionsButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        
        var alertController : UIAlertController
        
        alertController = UIAlertController(title: nil , message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for i in 0..<RightmenuArray.count{
            
            var BtnString:String = ""
            
            if RightmenuArray[i]["label"].stringValue.contains(",") {
                BtnString = RightmenuArray[i]["label"].stringValue.replacingOccurrences(of: ",", with: "")
            }else{
                BtnString = RightmenuArray[i]["label"].stringValue
            }
            
            let Action = UIAlertAction(title: BtnString, style: .default) { (finish) in
                
                let selectedDecision = self.RightmenuArray[i].dictionaryValue
                
                if selectedDecision["type"] == "submit" {
                    self.submitData(decision: selectedDecision)
                }
                else{
                    switch (selectedDecision["outcomes"]![0]["action"].stringValue).uppercased() {
                    case "CANCEL":
                        self.navigationController?.popViewController(animated: true)
                    case "AUDIO":
                        NotificationCenter.default.removeObserver(self)
                        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpeechVC") as! SpeechViewController
                        if selectedDecision["outcomes"]![0]["version"].string != nil {
                            self.li_newVersion = 1
                        }
                        nextViewController.providesPresentationContextTransitionStyle = true
                        nextViewController.definesPresentationContext = true
                        nextViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                        nextViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                        nextViewController.delegate = self
                        self.present(nextViewController, animated: true, completion: nil)
                    default:
                        
                        if selectedDecision["outcomes"]![0]["type"].string == "client" && selectedDecision["outcomes"]![0]["data"].dictionaryObject != nil{
                            self.larr_bodyJson = [:]
                            self.larr_MLFields = []
                            self.larr_processedStirng = []
                            self.larr_recomendationJson = [:]
                            
                            for each in selectedDecision["outcomes"]![0]["data"].dictionaryValue{
                                self.larr_bodyJson[each.key] = each.value.stringValue
                            }
                            self.getDependentDropDown()
                            
                            self.larr_bodyJson.removeValue(forKey: "sys__createdOn")
                            self.larr_bodyJson.removeValue(forKey: "userId")
                            self.larr_bodyJson.removeValue(forKey: "sys__createdBy")
                            self.larr_bodyJson.removeValue(forKey: "sys__data__state")
                            
                            self.reloadTableview(tableView: self.tableView)
                            print("Clone")
                        }else if self.ls_previousWorkflow != nil && self.ls_previousWorkflow! == selectedDecision["outcomes"]![0]["name"].stringValue{
                            self.navigationController?.popViewController(animated: true)
                        }else{
                            self.showActivityIndicator()
                            
                            let bodydictionary = ["appId":"\(self.app_metaData!["appId"].stringValue)","workFlowTask":"\(selectedDecision["outcomes"]![0]["name"])", "deviceType":"mobile"] as [String : Any]
                            
                            ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) { (taskResponse) in
                                self.hideActivityIndicator()
                                switch taskResponse {
                                case .success(let json):
                                    let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                                    CreateVC.app_metaData =  json
                                    CreateVC.ls_taskName = selectedDecision["outcomes"]![0]["name"].stringValue
                                    
                                    CreateVC.ls_ScreenTitle = json["flow"][selectedDecision["outcomes"]![0]["name"].stringValue]["label"].stringValue
                                    CreateVC.larr_error = self.larr_error
                                    CreateVC.ls_ScreenMode =  self.ls_ScreenMode
                                    
                                    if selectedDecision["outcomes"]![0]["data"].string != nil {
                                        var bodyJson:[String:JSON] = [:]
                                        for each in self.larr_bodyJson {
                                            if bodyJson[each.key] == nil {
                                                bodyJson[each.key] = JSON.init(stringLiteral: each.value)
                                            }
                                        }
                                        CreateVC.ldict_ScreenData = bodyJson
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
            }
            
            alertController.addAction(Action)
        }
        
        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    //MARK: - ToolBar Button action
    
    func addToolbarbutton() -> UIToolbar {
        let toolbar = UIToolbar.init()
        toolbar.sizeToFit()
        let barBtnCancel = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,
                                                target: self, action: #selector(cancelButtonAction))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self, action: #selector(doneButtonAction))
        
        toolbar.items = [barBtnCancel,spaceButton,barBtnDone]
        return toolbar
    }
    
    @objc func cancelButtonAction(){
        if larr_selectedDropdown.count > 0 {
            for each in larr_selectedDropdown{
                larr_bodyJson[each.key] = each.value
            }
        }
        activeTextfield = nil
        self.view.endEditing(true)
        self.reloadTableview(tableView: self.tableView)
    }
    
    @objc func doneClick()
    {
        let dateFormatter1 = DateFormatter()
        
        let SelectedRow = activeTextfield!.tag-(1000)
        
        let SelectedField = ldict_object!["fields"]["\(larr_screenFields![SelectedRow]["key"])"]
        
        larr_recomendationJson.removeValue(forKey: "\(SelectedField["labelKey"].stringValue)")
        
        if SelectedField["format"].string != nil{
            dateFormatter1.dateFormat = SelectedField["format"].stringValue
        }else{
            if  SelectedField["type"] == "monthpicker" {
                dateFormatter1.dateFormat = (app_metaData!["properties"]["month_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
            }else{
                dateFormatter1.dateFormat = (app_metaData!["properties"]["date_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
            }
            
        }
        
        dateFormatter1.locale = NSLocale.current
        //        dateFormatter1.locale = NSLocale(localeIdentifier: "en_US") as Locale?
        activeTextfield?.text = dateFormatter1.string(from: datePicker.date)
        larr_bodyJson[SelectedField["labelKey"].stringValue] = activeTextfield?.text!
        self.larr_recomendationJson.removeValue(forKey: "\(SelectedField["labelKey"].stringValue)")
        
        if let event = larr_screenFields![SelectedRow]["event"].string{
            if event.uppercased() == "EXTERNAL"{
                for i in 0 ..< app_metaData!["flow"][ls_taskName!]["decisions"].count{
                    if app_metaData!["flow"][ls_taskName!]["decisions"][i]["selection"].stringValue.uppercased() == "EXTERNAL" {
                        self.screenDataRefresh(decision: app_metaData!["flow"][ls_taskName!]["decisions"][i].dictionaryValue)
                    }
                }
            }else{
                
                let result:String = ConnectManager.shared.evaluateJavaExpression(expression: event, data: JSON.init(parseJSON: larr_bodyJson.jsonString())) as? String ?? ""
                
                if result != "true" {
                    showAlert(title: "", message: result, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true) { response in
                        self.activeTextfield?.text = ""
                        self.larr_bodyJson[SelectedField["labelKey"].stringValue] = self.activeTextfield?.text!
                        self.reloadTableview(tableView: self.tableView)
                        self.view.endEditing(true)
                    }
                }
            }
            
        }
        
        self.reloadTableview(tableView: self.tableView)
        self.view.endEditing(true)
    }
    
    @objc func cancelClick()
    {
        self.activeTextfield = nil
        self.view.endEditing(true)
    }
    
    @objc func Submit(notification:NSNotification){
        let userInfo:Dictionary<String,JSON> = notification.userInfo as! Dictionary<String,JSON>
        self.submitData(decision: (userInfo["decision"]! as JSON).dictionaryValue)
    }
    
    @objc func Next(notification:NSNotification){
        let userInfo:Dictionary<String,Any> = notification.userInfo as! Dictionary<String,Any>
        self.barBtnTapped(userInfo["sender"])
    }
    
    func getScreenData(){
        let dataBodyDictionary = ["appId":"\(app_metaData!["appId"].stringValue)","workFlowTask":"\(ls_taskName ?? "")","deviceType":"mobile"] as [String : Any]
        self.showActivityIndicator()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) {  (dataResponse) in
            self.hideActivityIndicator()
            switch dataResponse {
            case .success(let dataJson):
                self.ldict_ScreenData = dataJson["data"].dictionaryValue
                self.getDependentDropDown()
                self.reloadTableview(tableView: self.tableView)
            case .failure(let error):
                print(error.description)
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
    
    func getMDMData(){
        
        larr_screenServiceKeys = []
        
        for i in 0..<larr_screenFields!.count{
            let rowField = ldict_object!["fields"]["\(larr_screenFields![i]["key"])"]
            switch rowField["type"] {
            case "dropdown":
                //Prepare the service key get the dropdown values.
                if rowField["type"] == "dropdown" && rowField["serviceKey"] != JSON.null {
                    if rowField["parent"] == JSON.null {
                        var DropdownServiceKey:[String:Any] = [:]
                        if let lazy = rowField["lazy"].bool  {
                            if lazy == false {
                                DropdownServiceKey["serviceKey"] = rowField["serviceKey"].stringValue
                                if rowField["dependsOn"] != JSON.null {
                                    DropdownServiceKey["dependsOn"] = rowField["dependsOn"].arrayObject!
                                }
                                larr_dropDownServiceKey.append(DropdownServiceKey)
                            }
                        }else{
                            DropdownServiceKey["serviceKey"] = rowField["serviceKey"].stringValue
                            if rowField["dependsOn"] != JSON.null {
                                DropdownServiceKey["dependsOn"] = rowField["dependsOn"].arrayObject!
                            }
                            larr_dropDownServiceKey.append(DropdownServiceKey)
                        }
                    }
                    else{
                        //Get all the service key which has parent
                        self.larr_screenServiceKeys.append(rowField)
                    }
                }
            default:
                break
            }
        }
        
        
        if larr_dropDownServiceKey.count > 0 {
            
            let bodyObject = ["deviceType":"mobile","appId":app_metaData!["appId"].stringValue,"workFlowTask":ls_taskName!, "data": larr_dropDownServiceKey] as [String : Any]
            
            self.showActivityIndicator()
            ConnectManager.shared.getMdmData(bodyObject: bodyObject) { (response) in
                self.hideActivityIndicator()
                switch response{
                case .success(let json):
                    self.ldict_dropdownData = json
                case .failure(let error):
                    self.showAlert(message:error.description)
                case .failureJson(_):
                    break
                }
                
                self.processedtextParsing(dataJson:self.larr_processedStirng)
                self.getDependentDropDown()
                
            }
        }
    }
    
    @objc func processText(notification:NSNotification){
        let userInfo:Dictionary<String,String> = notification.userInfo as! Dictionary<String,String>
        
        let ls_audioText = userInfo["ProcessedText"]!
        
        self.MLProcessText(enteredText: ls_audioText)
    }
    
    private func processedtextParsing(dataJson:JSON){
        
        self.larr_MLFields = []
        
        self.larr_processedStirng = dataJson
        
        if dataJson.dictionaryValue.count > 0 {
            
            let processedDict = Array(dataJson.dictionaryValue)
            
            for each in processedDict {
                
                if each.key != "o" && each.value != nil{
                    if self.larr_dropdownValue[each.key] != nil {
                        
                        let Fieldmeta = self.app_metaData!["objectMeta"]["fields"][self.larr_dropdownValue[each.key]!]
                        
                        switch Fieldmeta["type"] {
                        case "dropdown":
                            if ldict_dropdownData != nil {
                                
                                var myDropdownData:[JSON] = []
                                
                                if Fieldmeta["propertyKey"] != JSON.null {
                                    myDropdownData = Fieldmeta["propertyKey"]["\(Fieldmeta["labelKey"])"].arrayValue
                                }else{
                                    if self.ldict_dropdownData![Fieldmeta["serviceKey"].stringValue].arrayValue.count > 0{
                                        myDropdownData = self.ldict_dropdownData![Fieldmeta["serviceKey"].stringValue].arrayValue
                                    }else{
                                        myDropdownData = self.ldict_dropdownData![Fieldmeta["labelKey"].stringValue].arrayValue
                                    }
                                }
                                
                                
                                for DropDowneach in myDropdownData {
                                    if ((DropDowneach["value"].stringValue).uppercased() == (each.value.stringValue.uppercased())) && (larr_bodyJson[each.key]?.uppercased() != each.value.stringValue.uppercased()) {
                                        
                                        
                                        if Fieldmeta["children"].arrayValue.count > 0  {
                                            larr_keybodyJson[Fieldmeta["labelKey"].stringValue] = (DropDowneach["key"].stringValue)
                                            
                                            for  i in 0..<Fieldmeta["children"].arrayValue.count {
                                                let fieldJson = ldict_object!["fields"]["\(Fieldmeta["children"][i])"]
                                                
                                                self.larr_bodyJson["\(Fieldmeta["children"][i])"] = ""
                                                self.larr_recomendationJson.removeValue(forKey: Fieldmeta["children"][i].stringValue)
                                                self.larr_bodyJson["\(fieldJson["dropdownValue"].stringValue)"] = ""
                                            }
                                        }
                                        
                                        //Remove Recoomendation value
                                        self.larr_recomendationJson.removeValue(forKey: Fieldmeta["labelKey"].stringValue)
                                        self.larr_recomendationJson.removeValue(forKey: Fieldmeta["dropdownValue"].stringValue)
                                        
                                        
                                        self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = DropDowneach["key"].stringValue
                                        self.larr_bodyJson[Fieldmeta["dropdownValue"].stringValue] = DropDowneach["value"].stringValue
                                        self.larr_MLFields.append(Fieldmeta["labelKey"].stringValue)
                                        
                                        break
                                    }
                                    else if ((DropDowneach["value"].stringValue).contains(each.value.stringValue)){
                                        
                                        if Fieldmeta["children"].arrayValue.count > 0  {
                                            larr_keybodyJson[Fieldmeta["labelKey"].stringValue] = (DropDowneach["key"].stringValue)
                                        }
                                        
                                        self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = DropDowneach["key"].stringValue
                                        self.larr_bodyJson[Fieldmeta["dropdownValue"].stringValue] = DropDowneach["value"].stringValue
                                        self.larr_MLFields.append(Fieldmeta["labelKey"].stringValue)
                                        
                                    }
                                }
                            }
                        default:
                            self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = each.value.stringValue
                            break
                            
                        }
                    }
                    else{
                        let Fieldmeta = self.app_metaData!["objectMeta"]["fields"][each.key]
                        
                        switch Fieldmeta["type"] {
                        case "dropdown":
                            
                            if Fieldmeta["propertyKey"] != JSON.null {
                                let myDropdownData = Fieldmeta["propertyKey"]["\(Fieldmeta["labelKey"])"].arrayValue
                                
                                for DropDowneach in myDropdownData {
                                    if ((DropDowneach["value"].stringValue).uppercased() == (each.value.stringValue.uppercased())) {
                                        
                                        self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = DropDowneach["key"].stringValue
                                        self.larr_bodyJson[Fieldmeta["dropdownValue"].stringValue] = DropDowneach["value"].stringValue
                                        self.larr_MLFields.append(Fieldmeta["labelKey"].stringValue)
                                        
                                        break
                                    }
                                    else if ((DropDowneach["value"].stringValue).contains(each.value.stringValue)){
                                        
                                        self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = DropDowneach["key"].stringValue
                                        self.larr_bodyJson[Fieldmeta["dropdownValue"].stringValue] = DropDowneach["value"].stringValue
                                        self.larr_MLFields.append(Fieldmeta["labelKey"].stringValue)
                                        
                                    }
                                }
                                
                            }
                            else if ldict_dropdownData != nil {
                                var myDropdownData:[JSON] = []
                                
                                myDropdownData  = self.ldict_dropdownData![Fieldmeta["serviceKey"].stringValue].arrayValue
                                
                                if myDropdownData.count == 0 {
                                    myDropdownData  = self.ldict_dropdownData![Fieldmeta["labelKey"].stringValue].arrayValue
                                }
                                
                                
                                for DropDowneach in myDropdownData {
                                    if ((DropDowneach["value"].stringValue).uppercased() == (each.value.stringValue.uppercased())) {
                                        
                                        if Fieldmeta["children"].arrayValue.count > 0  {
                                            larr_keybodyJson[Fieldmeta["labelKey"].stringValue] = (DropDowneach["key"].stringValue)
                                            
                                            for  i in 0..<Fieldmeta["children"].arrayValue.count {
                                                self.larr_bodyJson["\(Fieldmeta["children"][i])"] = ""
                                                //                                            print(Fieldmeta["children"].arrayValue)
                                            }
                                        }
                                        
                                        self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = DropDowneach["key"].stringValue
                                        self.larr_bodyJson[Fieldmeta["dropdownValue"].stringValue] = DropDowneach["value"].stringValue
                                        self.larr_MLFields.append(Fieldmeta["labelKey"].stringValue)
                                        
                                        break
                                    }
                                    else if ((DropDowneach["value"].stringValue).contains(each.value.stringValue)){
                                        
                                        if Fieldmeta["children"].arrayValue.count > 0  {
                                            larr_keybodyJson[Fieldmeta["labelKey"].stringValue] = (DropDowneach["key"].stringValue)
                                        }
                                        
                                        self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = DropDowneach["key"].stringValue
                                        self.larr_bodyJson[Fieldmeta["dropdownValue"].stringValue] = DropDowneach["value"].stringValue
                                        self.larr_MLFields.append(Fieldmeta["labelKey"].stringValue)
                                        
                                    }
                                    else{
                                        self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = ""
                                        self.larr_bodyJson[Fieldmeta["dropdownValue"].stringValue] = ""
                                    }
                                }
                                
                            }
                            
                        default:
                            self.larr_bodyJson[Fieldmeta["labelKey"].stringValue] = each.value.stringValue
                            self.larr_MLFields.append(Fieldmeta["labelKey"].stringValue)
                            break
                            
                        }
                        
                    }
                }
            }
        }
        self.reloadTableview(tableView: self.tableView)
    }
    
    
    func getRecomendationdetails(){
        
        let bodydictionary:[String : Any]  = ["appId" : app_metaData!["appId"].stringValue,"workFlowTask":self.ls_taskName!]  as [String : Any]
        self.showActivityIndicator()
        
        ConnectManager.shared.getRecommendationString(dataBodyDictionary: bodydictionary) {  (recommendationData) in
            self.hideActivityIndicator()
            
            switch recommendationData {
            case .success(let dataJson):
                if dataJson["message"].stringValue.count > 0 {
                    self.showAlert(title: "Recommendation", message: dataJson["message"].stringValue, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true) { (success) in
                        
                    }
                }else{
                    
                    self.larr_bodyJson = [:]
                    
                    for each in dataJson.dictionaryValue{
                        self.larr_bodyJson[each.key] = each.value.stringValue
                        self.larr_recomendationJson[each.key] = each.value.stringValue
                    }
                    self.getDependentDropDown()
                    
                    self.larr_bodyJson.removeValue(forKey: "msg")
                    self.larr_bodyJson.removeValue(forKey: "sys__createdOn")
                    self.larr_bodyJson.removeValue(forKey: "userId")
                    self.larr_bodyJson.removeValue(forKey: "sys__createdBy")
                    self.larr_bodyJson.removeValue(forKey: "sys__data__state")
                    
                    self.reloadTableview(tableView: self.tableView)
                }
                
            case .failure(let error):
                print(error.description)
                
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
    
    
    func getFieldValueFromDropdown(fieldDetail:JSON,dropDownValue:[JSON],ls_FieldKey:String?,ls_FieldValue:String?) -> String{
        
        if dropDownValue.count == 1  && (ls_FieldKey == nil || ls_FieldKey == "") && (ls_FieldValue == nil || ls_FieldValue == "")  {
            
            if fieldDetail["children"].count > 0 {
                self.larr_keybodyJson["\(fieldDetail["labelKey"])"] = dropDownValue[0]["key"].stringValue
            }
            
            if fieldDetail["dropdownValue"] != nil{
                self.larr_bodyJson["\(fieldDetail["dropdownValue"])"] = dropDownValue[0]["value"].stringValue
            }
            
            self.larr_bodyJson["\(fieldDetail["labelKey"])"] = dropDownValue[0]["key"].stringValue
            
            for i in 0..<fieldDetail["children"].count {
                if ldict_dropdownData![fieldDetail["children"][i].stringValue] == JSON.null {
                    getIndividualDependentDropDown(FieldName: fieldDetail["children"][i].stringValue)
                }
            }
            
            if let index = larr_MLFields.firstIndex(of: fieldDetail["labelKey"].stringValue) {
                larr_MLFields.remove(at: index)
            }
            
            return dropDownValue[0]["value"].stringValue
        }
        else{
            for each in dropDownValue {
                if ls_FieldKey != nil {
                    if each["key"].stringValue.uppercased() == ls_FieldKey!.uppercased()  {
                        if fieldDetail["children"].count > 0 {
                            self.larr_keybodyJson["\(fieldDetail["labelKey"])"] = each["key"].stringValue
                        }
                        
                        if fieldDetail["dropdownValue"] != nil{
                            self.larr_bodyJson["\(fieldDetail["dropdownValue"])"] = each["value"].stringValue
                        }
                        
                        return each["value"].stringValue
                    }
                }else{
                    if each["value"].stringValue.uppercased() == ls_FieldValue!.uppercased()  {
                        if fieldDetail["children"].count > 0 {
                            self.larr_keybodyJson["\(fieldDetail["labelKey"])"] = each["key"].stringValue
                        }
                        
                        if fieldDetail["dropdownValue"] != nil{
                            self.larr_bodyJson["\(fieldDetail["dropdownValue"])"] = each["value"].stringValue
                            self.larr_bodyJson["\(fieldDetail["labelKey"])"] = each["key"].stringValue
                        }
                        
                        return each["value"].stringValue
                    }
                }
            }
        }
        
        if dropDownValue.count == 1 && !larr_tempscreenServiceKeys.contains(fieldDetail)  {
            
            if fieldDetail["children"].count > 0 {
                self.larr_keybodyJson["\(fieldDetail["labelKey"])"] = dropDownValue[0]["key"].stringValue
            }
            
            if fieldDetail["dropdownValue"] != nil{
                self.larr_bodyJson["\(fieldDetail["dropdownValue"])"] = dropDownValue[0]["value"].stringValue
            }
            
            self.larr_bodyJson["\(fieldDetail["labelKey"])"] = dropDownValue[0]["key"].stringValue
            
            for i in 0..<fieldDetail["children"].count {
                if ldict_dropdownData![fieldDetail["children"][i].stringValue] == JSON.null {
                    getIndividualDependentDropDown(FieldName: fieldDetail["children"][i].stringValue)
                }
            }
            
            if let index = larr_MLFields.firstIndex(of: fieldDetail["labelKey"].stringValue) {
                larr_MLFields.remove(at: index)
            }
            
            larr_recomendationJson.removeValue(forKey: "\(fieldDetail["labelKey"].stringValue)")
            larr_recomendationJson.removeValue(forKey: "\(fieldDetail["dropdownValue"].stringValue)")
            
            return dropDownValue[0]["value"].stringValue
            
        }else{
            return ""
        }
        
    }
    
    private func getDependentDropDown(){
        //Call the dependentdropdown only if we have any data in the screen
        if ldict_ScreenData != nil || larr_bodyJson.count > 0  {
            
            var larr_dependDropDownServiceKey:[[String:Any]] = []
            let larr_DependentscreenServiceKeys = larr_screenServiceKeys
            var DependentscreenServiceKeys:[String] = []
            
            larr_tempscreenServiceKeys = []
            
            for i in 0..<larr_DependentscreenServiceKeys.count{
                if DependentscreenServiceKeys.contains(larr_DependentscreenServiceKeys[i]["serviceKey"].stringValue){
                    self.larr_tempscreenServiceKeys.append(larr_DependentscreenServiceKeys[i])
                }else{
                    var DropdownServiceKey:[String:Any] = [:]
                    var larr_dependsOn:[String] = []
                    for j in 0..<larr_DependentscreenServiceKeys[i]["parent"].arrayValue.count {
                        if ldict_ScreenData == nil {
                            if larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"] != nil && larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"]! != "" {
                                larr_dependsOn.append(larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"]!)
                            }else{
                                larr_dependsOn = []
                            }
                        }else{
                            if ldict_ScreenData!["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"] != nil {
                                larr_dependsOn.append(ldict_ScreenData!["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"]!.stringValue)
                            }else if larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"] != nil && larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"]! != "" {
                                larr_dependsOn.append(larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"]!)
                            }else{
                                larr_dependsOn = []
                            }
                        }
                    }
                    DependentscreenServiceKeys.append(larr_DependentscreenServiceKeys[i]["serviceKey"].stringValue)
                    DropdownServiceKey["serviceKey"] = larr_DependentscreenServiceKeys[i]["serviceKey"].stringValue
                    DropdownServiceKey["dependsOn"] = larr_dependsOn
                    if larr_dependsOn.count > 0 && larr_dependsOn.count == larr_DependentscreenServiceKeys[i]["parent"].arrayValue.count
                    {
                        larr_dependDropDownServiceKey.append(DropdownServiceKey)
                    }
                }
            }
            
            if larr_dependDropDownServiceKey.count > 0 {
                
                let bodyObject = ["deviceType":"mobile","appId":app_metaData!["appId"].stringValue,"workFlowTask":ls_taskName!, "data": larr_dependDropDownServiceKey] as [String : Any]
                
                self.showActivityIndicator()
                ConnectManager.shared.getMdmData(bodyObject: bodyObject) {
                    (response) in
                    self.hideActivityIndicator()
                    switch response{
                    case .success(let json):
                        for Individual in self.larr_screenServiceKeys {
                            
                            self.ldict_dropdownData?[Individual["labelKey"].stringValue] = json["\(Individual["serviceKey"].stringValue)"]
                        }
                        self.processedtextParsing(dataJson:self.larr_processedStirng)
                        if self.larr_tempscreenServiceKeys.count > 0 {
                            self.showActivityIndicator()
                            var larr_dependDropDownServiceKey:[[String:Any]] = []
                            let larr_DependentscreenServiceKeys = self.larr_tempscreenServiceKeys
                            
                            for i in 0..<larr_DependentscreenServiceKeys.count{
                                var DropdownServiceKey:[String:Any] = [:]
                                var larr_dependsOn:[String] = []
                                for j in 0..<larr_DependentscreenServiceKeys[i]["parent"].arrayValue.count {
                                    if self.ldict_ScreenData == nil {
                                        if self.larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"] != nil {
                                            larr_dependsOn.append(self.larr_bodyJson["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"]!)
                                            
                                        }
                                    }else{
                                        larr_dependsOn.append(self.ldict_ScreenData!["\(larr_DependentscreenServiceKeys[i]["parent"][j].stringValue)"]!.stringValue)
                                    }
                                }
                                DropdownServiceKey["serviceKey"] = larr_DependentscreenServiceKeys[i]["serviceKey"].stringValue
                                DropdownServiceKey["dependsOn"] = larr_dependsOn
                                
                                larr_dependDropDownServiceKey.append(DropdownServiceKey)
                            }
                            
                            let bodyObject = ["deviceType":"mobile","appId":self.app_metaData!["appId"].stringValue,"workFlowTask":self.ls_taskName!, "data": larr_dependDropDownServiceKey] as [String : Any]
                            
                            ConnectManager.shared.getMdmData(bodyObject: bodyObject) {
                                (response) in
                                self.hideActivityIndicator()
                                
                                switch response{
                                case .success(let json):
                                    for Individual in self.larr_tempscreenServiceKeys {
                                        self.ldict_dropdownData?[Individual["labelKey"].stringValue] = json["\(Individual["serviceKey"].stringValue)"]
                                        if let index = self.larr_tempscreenServiceKeys.firstIndex(of: Individual) {
                                            self.larr_tempscreenServiceKeys.remove(at: index)
                                        }
                                    }
                                    self.processedtextParsing(dataJson:self.larr_processedStirng)
                                    self.reloadTableview(tableView: self.tableView)
                                case .failure(let error):
                                    self.showAlert(message:error.description)
                                case .failureJson(_):
                                    break
                                }
                            }
                        }
                        else{
                            self.reloadTableview(tableView: self.tableView)
                        }
                    case .failure(let error):
                        self.showAlert(message:error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }
        }
    }
    
    private func getIndividualDependentDropDown(FieldName:String){
        if ldict_ScreenData != nil || larr_bodyJson.count > 0  {
            
            var larr_dependDropDownServiceKey:[[String:Any]] = []
            let larr_DependentscreenServiceKeys = ldict_object!["fields"][FieldName]
            var DependentscreenServiceKeys:[String] = []
            self.ls_individualJson = ldict_object!["fields"][FieldName]
            larr_tempscreenServiceKeys = []
            
            if DependentscreenServiceKeys.contains(larr_DependentscreenServiceKeys["serviceKey"].stringValue){
                self.larr_tempscreenServiceKeys.append(larr_DependentscreenServiceKeys)
            }else{
                var DropdownServiceKey:[String:Any] = [:]
                var larr_dependsOn:[String] = []
                for j in 0..<larr_DependentscreenServiceKeys["parent"].arrayValue.count {
                    if ldict_ScreenData == nil {
                        if larr_bodyJson["\(larr_DependentscreenServiceKeys["parent"][j].stringValue)"] != nil && larr_bodyJson["\(larr_DependentscreenServiceKeys["parent"][j].stringValue)"]! != "" {
                            larr_dependsOn.append(larr_bodyJson["\(larr_DependentscreenServiceKeys["parent"][j].stringValue)"]!)
                        }else{
                            larr_dependsOn = []
                        }
                    }else{
                        larr_dependsOn.append(ldict_ScreenData!["\(larr_DependentscreenServiceKeys["parent"][j].stringValue)"]!.stringValue)
                    }
                }
                DependentscreenServiceKeys.append(larr_DependentscreenServiceKeys["serviceKey"].stringValue)
                DropdownServiceKey["serviceKey"] = larr_DependentscreenServiceKeys["serviceKey"].stringValue
                DropdownServiceKey["dependsOn"] = larr_dependsOn
                if larr_dependsOn.count > 0 && larr_dependsOn.count == larr_DependentscreenServiceKeys["parent"].arrayValue.count
                {
                    larr_dependDropDownServiceKey.append(DropdownServiceKey)
                }
            }
            
            if larr_dependDropDownServiceKey.count > 0 {
                
                let bodyObject = ["deviceType":"mobile","appId":app_metaData!["appId"].stringValue,"workFlowTask":ls_taskName!, "data": larr_dependDropDownServiceKey] as [String : Any]
                
                self.showActivityIndicator()
                
                ConnectManager.shared.getMdmData(bodyObject: bodyObject) {  (response) in
                    self.hideActivityIndicator()
                    
                    switch response{
                    case .success(let json):
                        if json["\(self.ls_individualJson!["serviceKey"].stringValue)"] != JSON.null {
                            
                            self.ldict_dropdownData?[(self.ls_individualJson!["labelKey"].stringValue)] = json["\(self.ls_individualJson!["serviceKey"].stringValue)"]
                            
                        }
                        self.reloadTableview(tableView: self.tableView)
                    case .failure(let error):
                        self.showAlert(message:error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }
        }
    }
    
    func dropdownFilterBy(filterBy:String,dropdowndata:[JSON]) ->[JSON]{
        var PickerData:[JSON] = []
        
        for each in dropdowndata{
            
            var filterByString:String? = ""
            
            let filterByStartIndex =  filterBy.range(of: "${")?.upperBound
            let filterByEndIndex =  filterBy.range(of: "}")?.lowerBound
            
            if filterByStartIndex != nil && filterByEndIndex != nil {
                let filterByReplaceSubstring = filterBy[(filterBy.range(of: "${"))!.lowerBound ..< (filterBy.range(of: "}"))!.upperBound]
                filterByString = filterBy.replacingOccurrences(of: filterByReplaceSubstring, with:"\(each["value"])")
            }
            
            let jsSource = "var javascriptFunc = function() {\(filterByString!)}"
            
            let context = JSContext()
            context?.evaluateScript(jsSource)
            
            let testFunction = context?.objectForKeyedSubscript("javascriptFunc")
            let result = testFunction?.call(withArguments: [])
            
            if result!.toString()! == "true" {
                PickerData.append(each)
            }
            else{
                print("false")
            }
            
        }
        return PickerData
    }
    
    
    func gettaskDetails(taskName:String,previousScreenResponse:JSON? = nil){
        self.showActivityIndicator()
        
        let bodydictionary = ["appId": app_metaData!["appId"].stringValue,
                              "workFlowTask":"\(taskName)",
                              "deviceType":"mobile"] as [String : Any]
        
        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
            self.hideActivityIndicator()
            switch taskResponse {
            case .success(let json):
                let larr_fields = json["flow"][taskName]["fields"].arrayValue
                let larr_Decision = json["flow"][taskName]["decisions"].arrayValue
                
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
                    ListVC.ls_ScreenTitle = json["flow"][taskName]["label"].stringValue
                    ListVC.ls_appName = self.app_metaData!["appId"].stringValue
                    ListVC.ls_taskName = taskName
                    //                    ListVC.ls_Selectedappname = self.app.name
                    ListVC.larr_FilterList = larr_FilterList
                    ListVC.larr_SortList = larr_SortList
                    ListVC.layoutJson = json
                    ListVC.app = self.app
                    ListVC.previousScreenResponse = previousScreenResponse
                    self.navigationController?.pushViewController(ListVC, animated: true)
                    
                case "create":
                    let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                    CreateVC.app_metaData =  json
                    //                       CreateVC.ls_appName = self.ls_appName
                    CreateVC.ls_taskName = taskName
                    //                       CreateVC.ls_Selectedappname = self.ls_Selectedappname
                    CreateVC.ls_ScreenTitle = json["flow"][taskName]["label"].stringValue
                    CreateVC.larr_recomendationJson = self.larr_recomendationJson
                    CreateVC.larr_error = self.larr_error
                    CreateVC.ls_ScreenMode = self.ls_ScreenMode
                    self.navigationController?.pushViewController(CreateVC, animated: true)
                    
                case "customv2":
                    let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "CompositeVC") as! CompositeViewController
                    
                    customVC.ls_ScreenTitle = json["flow"][taskName]["label"].stringValue
                    customVC.ls_appName = self.app_metaData!["appId"].stringValue
                    customVC.ls_taskName = taskName
                    customVC.app_metaData = json
                    customVC.ls_Selectedappname = self.app.name
                    
                    self.navigationController?.pushViewController(customVC, animated: true)
                default:
                    break
                }
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(let errorJson):
                self.showAlert(message: errorJson["errorMessage"].stringValue)
            }
        }
    }
    
    func getIndividualRecomendationdetails(FieldName:String){
        
        let bodydictionary:[String : Any]  = ["appId" : app_metaData!["appId"].stringValue,"workFlowTask":self.ls_taskName!,"recommendation_field":FieldName]  as [String : Any]
        self.showActivityIndicator()
        
        ConnectManager.shared.getRecommendationString(dataBodyDictionary: bodydictionary) {  (recommendationData) in
            self.hideActivityIndicator()
            
            switch recommendationData {
            case .success(let dataJson):
                if dataJson["message"].stringValue.count > 0 {
                    self.showAlert(title: "Recommendation", message: dataJson["message"].stringValue, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true) { (success) in
                        
                    }
                }else{
                    
                    let larr_RecommendationJson = dataJson[self.ls_SelectedKey!]
                    
                    if larr_RecommendationJson != nil {
                        for each in larr_RecommendationJson.dictionaryValue{
                            self.larr_bodyJson[each.key] = each.value.stringValue
                            self.larr_recomendationJson[each.key] = each.value.stringValue
                        }
                        self.getDependentDropDown()
                    }
                    
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error.description)
            case .failureJson(_):
                break
            }
        }
    }
    
    func setupValue(fieldsJson:[JSON]){
        
        for each in fieldsJson {
            
            if larr_bodyJson[each["key"].stringValue] == "" && ldict_ScreenData?[each["key"].stringValue] != "" && ldict_ScreenData?[each["key"].stringValue] != nil {
                larr_bodyJson[each["key"].stringValue] = ldict_ScreenData?[each["key"].stringValue]?.stringValue
            }
            
            let fieldObject = ldict_object!["fields"]["\(each["key"])"]
            
            if fieldObject["type"].stringValue == "dropdown" {
                if larr_bodyJson[fieldObject["dropdownValue"].stringValue] == "" && ldict_ScreenData?[fieldObject["dropdownValue"].stringValue] != "" && ldict_ScreenData?[fieldObject["dropdownValue"].stringValue] != nil {
                    larr_bodyJson[fieldObject["dropdownValue"].stringValue] = ldict_ScreenData?[fieldObject["dropdownValue"].stringValue]?.stringValue
                }
            }
        }
        
    }
}

extension CreateViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return larr_screenFields!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowField:JSON = []
        
        if larr_screenFields![indexPath.row]["type"] != nil {
            rowField = larr_screenFields![indexPath.row]
        }else{
            rowField = ldict_object!["fields"]["\(larr_screenFields![indexPath.row]["key"])"]
        }
        
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
            self.createdelegate?.CreateViewHeight(workFlowName: self.ls_taskName!, tableHeight: self.tableView.contentSize.height)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var rowField = ldict_object!["fields"]["\(larr_screenFields![indexPath.row]["key"])"]
        
        if larr_screenFields![indexPath.row]["type"] != JSON.null {
            rowField["type"] = larr_screenFields![indexPath.row]["type"]
        }
        
        print(rowField)
        
        switch rowField["type"] {
            
        case "textbox":
            let textboxcell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            
            //Cell Key Label
            var keyLabel:String = ""
            
            if larr_screenFields![indexPath.row]["label"].string == nil {
                keyLabel = "\(rowField[rowField["labelKey"].stringValue])"
            }else{
                keyLabel = "\(larr_screenFields![indexPath.row]["label"].stringValue)"
            }
            
            if rowField["isRequired"].boolValue == true {
                keyLabel = keyLabel + " *"
            }
            
            textboxcell.lbl_KeyLabel.attributedText = NSAttributedString(string: keyLabel)
            
            //Cell Data Field
            textboxcell.ltxf_DataText.tag = 1000 + indexPath.row
            textboxcell.ltxf_DataText.isEnabled = true
            textboxcell.ltxf_DataText.textColor = .black
            textboxcell.lbl_KeyLabel.textColor = .black
            
            if (larr_screenFields![indexPath.row]["value"]) != JSON.null {
                textboxcell.ltxf_DataText.text = larr_screenFields![indexPath.row]["value"].stringValue
                larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = larr_screenFields![indexPath.row]["value"].stringValue
            }else{
                
                if larr_bodyJson[rowField["labelKey"].stringValue] != "" {
                    textboxcell.ltxf_DataText.text = larr_bodyJson[rowField["labelKey"].stringValue] ?? ""
                }else if larr_bodyJson[rowField["labelKey"].stringValue] != nil {
                    textboxcell.ltxf_DataText.text = larr_processedStirng[rowField["labelKey"].stringValue].string ?? ""
                }
            }
            
            //Cell General Setting
            
            //format a cell
            
            if let LabelStyle = larr_screenFields![indexPath.row]["formLabelStyle"].dictionary {
                if LabelStyle["color"] != nil {
                    textboxcell.ltxf_DataText.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                    textboxcell.lbl_KeyLabel.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                }
                if let labelfont = LabelStyle["font-size"]?.string{
                    textboxcell.lbl_KeyLabel.font =  textboxcell.lbl_KeyLabel.font.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                    textboxcell.ltxf_DataText.font =  textboxcell.ltxf_DataText.font!.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                }
                if let labelfont = LabelStyle["font"]?.string{
                    for each in labelfont.split(separator: " "){
                        if each.contains("px") {
                            textboxcell.lbl_KeyLabel.font =  textboxcell.lbl_KeyLabel.font.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            textboxcell.ltxf_DataText.font =  textboxcell.ltxf_DataText.font!.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            break
                        }
                    }
                    
                }
            }
            
            //HighLighting the Cell from ML
            textboxcell.lv_BackgroundView.backgroundColor = UIColor.white
            textboxcell.backgroundColor = UIColor.white
            if larr_MLFields.count > 0 && larr_MLFields.contains(rowField["labelKey"].stringValue){
                textboxcell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                textboxcell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if textboxcell.ltxf_DataText.text! != "" && larr_recomendationJson[rowField["labelKey"].stringValue] != nil{
                textboxcell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                textboxcell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if larr_error[rowField["labelKey"].stringValue] != nil {
                textboxcell.lv_separator.backgroundColor = UIColor.red
                textboxcell.lbl_Error.text = larr_error[rowField["labelKey"].stringValue]
            }else{
                textboxcell.lv_separator.backgroundColor = UIColor.lightGray
                textboxcell.lbl_Error.text = ""
            }
            
            textboxcell.selectionStyle = .none
            return textboxcell
            
        case "readOnly":
            let textboxcell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            
            //Cell Key Label
            var keyLabel:String = ""
            
            if larr_screenFields![indexPath.row]["label"].string == nil {
                keyLabel = "\(rowField[rowField["labelKey"].stringValue])"
            }else{
                keyLabel = "\(larr_screenFields![indexPath.row]["label"].stringValue)"
            }
            
            if rowField["isRequired"].boolValue == true {
                keyLabel = keyLabel + " *"
            }
            
            textboxcell.lbl_KeyLabel.attributedText = NSAttributedString(string: keyLabel)
            
            //Cell Data Field
            textboxcell.ltxf_DataText.tag = 1000 + indexPath.row
            
            if (larr_screenFields![indexPath.row]["value"]) != JSON.null {
                
                if larr_screenFields![indexPath.row]["value"].stringValue == "currentDate"{
                    dateFormatter.dateFormat = (app_metaData!["properties"]["date_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
                    textboxcell.ltxf_DataText.text = dateFormatter.string(from: Date())
                    larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = dateFormatter.string(from: Date())
                }else{
                    textboxcell.ltxf_DataText.text = larr_screenFields![indexPath.row]["value"].stringValue
                    larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = larr_screenFields![indexPath.row]["value"].stringValue
                }
            }else{
                textboxcell.ltxf_DataText.text = larr_bodyJson[rowField["labelKey"].stringValue] ?? ""
            }
            
            //Cell General Setting
            //format a cell
            
            if let LabelStyle = larr_screenFields![indexPath.row]["formLabelStyle"].dictionary {
                if LabelStyle["color"] != nil {
                    textboxcell.ltxf_DataText.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                    textboxcell.lbl_KeyLabel.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                }
                if let labelfont = LabelStyle["font-size"]?.string{
                    textboxcell.lbl_KeyLabel.font =  textboxcell.lbl_KeyLabel.font.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                    textboxcell.ltxf_DataText.font =  textboxcell.ltxf_DataText.font!.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                }
                if let labelfont = LabelStyle["font"]?.string{
                    for each in labelfont.split(separator: " "){
                        if each.contains("px") {
                            textboxcell.lbl_KeyLabel.font =  textboxcell.lbl_KeyLabel.font.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            textboxcell.ltxf_DataText.font =  textboxcell.ltxf_DataText.font!.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            break
                        }
                    }
                    
                }
            }
            
            //HighLighting the Cell from ML
            textboxcell.lv_BackgroundView.backgroundColor = UIColor.white
            textboxcell.backgroundColor = UIColor.white
            if larr_MLFields.count > 0 && larr_MLFields.contains(rowField["labelKey"].stringValue){
                textboxcell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                textboxcell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if textboxcell.ltxf_DataText.text! != "" && larr_recomendationJson[rowField["labelKey"].stringValue] != nil{
                textboxcell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                textboxcell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if larr_error[rowField["labelKey"].stringValue] != nil {
                textboxcell.lv_separator.backgroundColor = UIColor.red
                textboxcell.lbl_Error.text = larr_error[rowField["labelKey"].stringValue]
            }else{
                textboxcell.lv_separator.backgroundColor = UIColor.lightGray
                textboxcell.lbl_Error.text = ""
            }
            
            textboxcell.ltxf_DataText.isEnabled = false
            textboxcell.ltxf_DataText.textColor = UIColor.darkGray
            textboxcell.lbl_KeyLabel.textColor = UIColor.darkGray
            
            textboxcell.selectionStyle = .none
            return textboxcell
            
        case "dropdown":
            
            self.larr_dropdownValue[rowField["dropdownValue"].stringValue] = rowField["labelKey"].stringValue
            
            
            let textboxcell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! TextTableViewCell
            
            //Cell Key Label
            var keyLabel:String = ""
            
            if larr_screenFields![indexPath.row]["label"].string == nil {
                keyLabel = "\(rowField[rowField["labelKey"].stringValue])"
            }else{
                keyLabel = "\(larr_screenFields![indexPath.row]["label"].stringValue)"
            }
            
            if rowField["isRequired"].boolValue == true {
                keyLabel = keyLabel + " *"
            }
            
            textboxcell.lbl_KeyLabel.attributedText = NSAttributedString(string: keyLabel)
            
            textboxcell.selectionStyle = .none
            textboxcell.ltxf_DataText.tag = 1000 + indexPath.row
            
            var fieldValue:String = ""
            
            if (larr_screenFields![indexPath.row]["value"]) != JSON.null {
                fieldValue = larr_screenFields![indexPath.row]["value"].stringValue
                larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = larr_screenFields![indexPath.row]["value"].stringValue
            }else{
                if ls_ScreenMode == "reset" {
                    fieldValue = ""
                }
                else if( larr_bodyJson["\(larr_screenFields![indexPath.row]["key"].stringValue)"] != nil && larr_bodyJson["\(larr_screenFields![indexPath.row]["key"].stringValue)"] != "") || (larr_bodyJson["\(rowField["dropdownValue"].stringValue)"] != nil) {
                    
                    
                    if larr_bodyJson[rowField["labelKey"].stringValue] == nil {
                        larr_bodyJson [rowField["labelKey"].stringValue] = ""
                    }
                    
                    if rowField["propertyKey"] != JSON.null {
                        if larr_bodyJson[rowField["dropdownValue"].stringValue] == nil {
                            fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField,dropDownValue: rowField["propertyKey"]["\(rowField["propertyKey"].dictionaryValue.keys.first!)"].arrayValue, ls_FieldKey:larr_bodyJson[rowField["labelKey"].stringValue]! , ls_FieldValue: nil)
                            
                        }else{
                            fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField,dropDownValue: rowField["propertyKey"]["\(rowField["propertyKey"].dictionaryValue.keys.first!)"].arrayValue, ls_FieldKey:nil , ls_FieldValue: larr_bodyJson[rowField["dropdownValue"].stringValue]!)
                            if fieldValue == "" &&  larr_bodyJson[rowField["labelKey"].stringValue] != nil{
                                fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField,dropDownValue: rowField["propertyKey"]["\(rowField["propertyKey"].dictionaryValue.keys.first!)"].arrayValue, ls_FieldKey:larr_bodyJson[rowField["labelKey"].stringValue]! , ls_FieldValue: nil)
                            }
                        }
                    }
                    else if rowField["dropdownValue"].string != nil {
                        //If we have some dropdown values
                        if ldict_dropdownData != nil{
                            if ldict_dropdownData!["\(rowField["labelKey"])"]  != JSON.null{
                                if larr_bodyJson[rowField["dropdownValue"].stringValue] != nil && larr_bodyJson[rowField["dropdownValue"].stringValue] != "" {
                                    
                                    //Validate the KeyId
                                    
                                    if larr_bodyJson[rowField["labelKey"].stringValue] != nil {
                                        fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField, dropDownValue: ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue, ls_FieldKey:larr_bodyJson[rowField["labelKey"].stringValue]! , ls_FieldValue:nil)
                                        if fieldValue == "" {
                                            self.larr_bodyJson[rowField["labelKey"].stringValue] = nil
                                        }
                                        
                                    }
                                    
                                    //Validate the dropdownValue
                                    
                                    if fieldValue == "" && larr_bodyJson[rowField["dropdownValue"].stringValue] != nil && (larr_bodyJson[rowField["labelKey"].stringValue] == nil || larr_bodyJson[rowField["labelKey"].stringValue] == "") {
                                        fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField, dropDownValue: ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue, ls_FieldKey:nil , ls_FieldValue: larr_bodyJson[rowField["dropdownValue"].stringValue]!)
                                    }
                                }else{
                                    fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField, dropDownValue: ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue, ls_FieldKey:larr_bodyJson[rowField["labelKey"].stringValue]! , ls_FieldValue:nil)
                                    
                                }
                                
                            }else if ldict_dropdownData!["\(rowField["serviceKey"])"]  != JSON.null {
                                if larr_bodyJson[rowField["dropdownValue"].stringValue] != nil {
                                    fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField, dropDownValue: ldict_dropdownData!["\(rowField["serviceKey"])"].arrayValue, ls_FieldKey:nil , ls_FieldValue: larr_bodyJson[rowField["dropdownValue"].stringValue]!)
                                    if fieldValue == "" {
                                        fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField, dropDownValue: ldict_dropdownData!["\(rowField["serviceKey"])"].arrayValue, ls_FieldKey:larr_bodyJson[rowField["labelKey"].stringValue]! , ls_FieldValue:nil)
                                    }
                                }else{
                                    fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField, dropDownValue: ldict_dropdownData!["\(rowField["serviceKey"])"].arrayValue, ls_FieldKey:larr_bodyJson[rowField["labelKey"].stringValue]! , ls_FieldValue:nil)
                                }
                            }
                            else{
                                if app_metaData!["flow"][ls_taskName!]["layout"]["offlineSupport"] == true && larr_OfflineFileds.contains(rowField["labelKey"].stringValue) == true {
                                    fieldValue = larr_bodyJson[rowField["dropdownValue"].stringValue] ?? ""
                                }else{
                                    fieldValue = ""
                                }
                            }
                        }
                        else{
                            if app_metaData!["flow"][ls_taskName!]["layout"]["offlineSupport"] == true && larr_OfflineFileds.contains(rowField["labelKey"].stringValue) == true {
                                fieldValue = larr_bodyJson[rowField["dropdownValue"].stringValue] ?? ""
                            }else{
                                fieldValue = ""
                            }
                        }
                    }
                    else{
                        if ldict_dropdownData != nil{
                            if ldict_dropdownData!["\(rowField["labelKey"])"]  != JSON.null {
                                fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField,dropDownValue: ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue, ls_FieldKey: larr_bodyJson[rowField["labelKey"].stringValue]!, ls_FieldValue: nil)
                            }
                            else if ldict_dropdownData!["\(rowField["serviceKey"])"]  != JSON.null {
                                fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField,dropDownValue: ldict_dropdownData!["\(rowField["serviceKey"])"].arrayValue, ls_FieldKey: larr_bodyJson[rowField["labelKey"].stringValue]!, ls_FieldValue: nil)
                            }else{
                                fieldValue = ""
                            }
                        }else{
                            fieldValue = ""
                        }
                    }
                    
                    larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = larr_bodyJson["\(larr_screenFields![indexPath.row]["key"].stringValue)"]
                    
                }
                else if ldict_ScreenData?["\(larr_screenFields![indexPath.row]["key"].stringValue)"] != nil {
                    
                    larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = ""
                    
                    if ldict_dropdownData != nil{
                        if ldict_dropdownData![rowField["serviceKey"].stringValue].arrayValue.count > 0 {
                            fieldValue = self.getFieldValueFromDropdown(fieldDetail: rowField, dropDownValue: ldict_dropdownData![rowField["serviceKey"].stringValue].arrayValue, ls_FieldKey: ldict_ScreenData!["\(larr_screenFields![indexPath.row]["key"].stringValue)"]!.stringValue, ls_FieldValue: nil)
                        }
                        else{
                            fieldValue = ""
                        }
                    }
                    else{
                        fieldValue = ""
                    }
                    
                    larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = ldict_ScreenData!["\(larr_screenFields![indexPath.row]["key"].stringValue)"]!.stringValue
                    
                    if rowField["dropdownValue"] != nil && ldict_ScreenData!["\(rowField["dropdownValue"])"] != nil {
                        larr_bodyJson ["\(rowField["dropdownValue"])"] = ldict_ScreenData!["\(rowField["dropdownValue"])"]!.stringValue
                    }
                    
                    if  larr_screenFields![indexPath.row]["event"].string != nil &&  fieldValue == "" && li_eventChk == true {
                        li_eventChk = false
                        let fieldSelected = larr_screenFields![indexPath.row]["event"].stringValue
                        if fieldSelected.uppercased() == "EXTERNAL"{
                            for i in 0 ..< app_metaData!["flow"][ls_taskName!]["decisions"].count{
                                if app_metaData!["flow"][ls_taskName!]["decisions"][i]["selection"].stringValue.uppercased() == "EXTERNAL" {
                                    self.screenDataRefresh(decision: app_metaData!["flow"][ls_taskName!]["decisions"][i].dictionaryValue)
                                }
                            }
                        }
                    }
                    
                }
                else{
                    //When the screen loaded for the first time.
                    if ldict_dropdownData?["\(rowField["labelKey"])"].arrayValue.count == 1{
                        fieldValue = ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue[0]["value"].stringValue
                        larr_bodyJson[rowField["dropdownValue"].stringValue] = ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue[0]["value"].stringValue
                        larr_bodyJson[rowField["labelKey"].stringValue] = ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue[0]["key"].stringValue
                    }else{
                        fieldValue = ""
                        larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = ""
                        if rowField["dropdownValue"] != JSON.null{
                            larr_bodyJson [rowField["dropdownValue"].stringValue] = ""
                        }
                    }
                }
            }
            
            //Call Dependent Dropdown if required.
            if rowField["children"].count > 0 && self.larr_processedStirng[rowField["labelKey"].stringValue].string != nil {
                self.larr_processedStirng[rowField["labelKey"].stringValue] = nil
                self.getDependentDropDown()
            }
            
            textboxcell.ltxf_DataText.attributedText = NSAttributedString(string: fieldValue)
            
            //Cell General Setting
            
            //format a cell
            
            if let LabelStyle = larr_screenFields![indexPath.row]["formLabelStyle"].dictionary {
                if LabelStyle["color"] != nil {
                    textboxcell.ltxf_DataText.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                    textboxcell.lbl_KeyLabel.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                }
                if let labelfont = LabelStyle["font-size"]?.string{
                    textboxcell.lbl_KeyLabel.font =  textboxcell.lbl_KeyLabel.font.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                    textboxcell.ltxf_DataText.font =  textboxcell.ltxf_DataText.font!.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                }
                if let labelfont = LabelStyle["font"]?.string{
                    for each in labelfont.split(separator: " "){
                        if each.contains("px") {
                            textboxcell.lbl_KeyLabel.font =  textboxcell.lbl_KeyLabel.font.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            textboxcell.ltxf_DataText.font =  textboxcell.ltxf_DataText.font!.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            break
                        }
                    }
                    
                }
            }
            
            //HighLighting the Cell from ML
            textboxcell.lv_BackgroundView.backgroundColor = UIColor.white
            textboxcell.backgroundColor = UIColor.white
            if larr_MLFields.count > 0 && larr_MLFields.contains(rowField["labelKey"].stringValue){
                textboxcell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                textboxcell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if textboxcell.ltxf_DataText.text! != "" && (larr_recomendationJson[rowField["labelKey"].stringValue] != nil || larr_recomendationJson[rowField["dropdownValue"].stringValue] != nil){
                textboxcell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                textboxcell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if larr_error[rowField["labelKey"].stringValue] != nil {
                textboxcell.lv_separator.backgroundColor = UIColor.red
                textboxcell.lbl_Error.text = larr_error[rowField["labelKey"].stringValue]
            }else{
                textboxcell.lv_separator.backgroundColor = UIColor.lightGray
                textboxcell.lbl_Error.text = ""
            }
            
            if ldict_dropdownData?["\(rowField["labelKey"])"].arrayValue.count != nil{
                if ldict_dropdownData!["\(rowField["labelKey"])"].arrayValue.count == 1 {
                    textboxcell.ltxf_DataText.isEnabled = false
                    textboxcell.ltxf_DataText.textColor = UIColor.darkGray
                    textboxcell.lbl_KeyLabel.textColor = UIColor.darkGray
                }else{
                    textboxcell.ltxf_DataText.isEnabled = true
                    textboxcell.ltxf_DataText.textColor = UIColor.black
                    textboxcell.lbl_KeyLabel.textColor = UIColor.black
                }
            }else{
                textboxcell.ltxf_DataText.isEnabled = true
                textboxcell.ltxf_DataText.textColor = UIColor.black
                textboxcell.lbl_KeyLabel.textColor = UIColor.black
            }
            
            self.VisibilityandDisability(field: rowField)
            
            return textboxcell
            
        case "datepicker":
            let Datepickercell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateTableViewCell
            
            //Cell Key Label
            var keyLabel:String = ""
            
            if larr_screenFields![indexPath.row]["label"].string == nil {
                keyLabel = "\(rowField[rowField["labelKey"].stringValue])"
            }else{
                keyLabel = "\(larr_screenFields![indexPath.row]["label"].stringValue)"
            }
            
            if rowField["isRequired"].boolValue == true {
                keyLabel = keyLabel + " *"
            }
            
            Datepickercell.lbl_KeyLabel.attributedText = NSAttributedString(string: keyLabel)
            
            //Cell Data Field
            Datepickercell.ltxf_DataText.tag = 1000 + indexPath.row
            
            var fieldValue:String = ""
            
            if (larr_screenFields![indexPath.row]["value"]) != JSON.null {
                
                if larr_screenFields![indexPath.row]["value"].stringValue == "currentDate"{
                    dateFormatter.dateFormat = (app_metaData!["properties"]["date_picker_format"].stringValue).replacingOccurrences(of: "D", with: "d")
                    fieldValue = dateFormatter.string(from: Date())
                    larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = dateFormatter.string(from: Date())
                }else{
                    fieldValue = larr_screenFields![indexPath.row]["value"].stringValue
                    larr_bodyJson [larr_screenFields![indexPath.row]["key"].stringValue] = larr_screenFields![indexPath.row]["value"].stringValue
                }
            }else{
                
                if ldict_ScreenData != nil && ldict_ScreenData!.count > 0 && ldict_ScreenData!["\(larr_screenFields![indexPath.row]["key"].stringValue)"]?.string != nil{
                    fieldValue = "\((ldict_ScreenData!["\(larr_screenFields![indexPath.row]["key"].stringValue)"]?.string ?? "").components(separatedBy: "T")[0])"
                }else{
                    fieldValue = "\((larr_bodyJson[rowField["labelKey"].stringValue] ?? "").components(separatedBy: "T")[0])"
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = (rowField["format"].stringValue).replacingOccurrences(of: "D", with: "d")
                
                var date: Date?
                
                if fieldValue != "" {
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "yyyy-MM-dd"
                    date =  dateFormatterGet.date(from: fieldValue)
                    if date == nil {
                        date =  dateFormatter.date(from: fieldValue)
                    }
                }
                
                if date != nil {
                    let dateString = dateFormatter.string(from: date!)
                    larr_bodyJson[rowField["labelKey"].stringValue] = dateString
                    fieldValue = dateString
                }else{
                    larr_bodyJson[rowField["labelKey"].stringValue] = ""
                    fieldValue = ""
                }
                
            }
            
            Datepickercell.ltxf_DataText.attributedText = NSAttributedString(string: fieldValue)
            
            //Cell General Setting
            //format a cell
            
            if let LabelStyle = larr_screenFields![indexPath.row]["formLabelStyle"].dictionary {
                if LabelStyle["color"] != nil {
                    Datepickercell.ltxf_DataText.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                    Datepickercell.lbl_KeyLabel.textColor = UIColor(hex: LabelStyle["color"]?.string ?? "")
                }
                if let labelfont = LabelStyle["font-size"]?.string{
                    Datepickercell.lbl_KeyLabel.font =  Datepickercell.lbl_KeyLabel.font.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                    Datepickercell.ltxf_DataText.font =  Datepickercell.ltxf_DataText.font!.withSize(CGFloat(Double(labelfont.replacingOccurrences(of: "px", with: "")) ?? 0))
                }
                if let labelfont = LabelStyle["font"]?.string{
                    for each in labelfont.split(separator: " "){
                        if each.contains("px") {
                            Datepickercell.lbl_KeyLabel.font =  Datepickercell.lbl_KeyLabel.font.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            Datepickercell.ltxf_DataText.font =  Datepickercell.ltxf_DataText.font!.withSize(CGFloat(Double(each.replacingOccurrences(of: "px", with: "")) ?? 0))
                            break
                        }
                    }
                    
                }
            }
            
            //HighLighting the Cell from ML
            Datepickercell.lv_BackgroundView.backgroundColor = UIColor.white
            Datepickercell.backgroundColor = UIColor.white
            if larr_MLFields.count > 0 && larr_MLFields.contains(rowField["labelKey"].stringValue){
                Datepickercell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                Datepickercell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if Datepickercell.ltxf_DataText.text! != "" && larr_recomendationJson[rowField["labelKey"].stringValue] != nil{
                Datepickercell.lv_BackgroundView.backgroundColor = UIColor(hex: "FFFF99")
                Datepickercell.backgroundColor = UIColor(hex: "FFFF99")
            }
            
            if larr_error[rowField["labelKey"].stringValue] != nil {
                Datepickercell.lv_separator.backgroundColor = UIColor.red
                Datepickercell.lbl_Error.text = larr_error[rowField["labelKey"].stringValue]
            }else{
                Datepickercell.lv_separator.backgroundColor = UIColor.lightGray
                Datepickercell.lbl_Error.text = ""
            }
            
            Datepickercell.selectionStyle = .none
            return Datepickercell
            
        case "hidden":
            let hiddenCell = tableView.dequeueReusableCell(withIdentifier: "HiddenCell", for: indexPath) as! HiddenTableViewCell
            hiddenCell.selectionStyle = .none
            
            if larr_screenFields![indexPath.row]["value"].string != nil { larr_bodyJson[larr_screenFields![indexPath.row]["key"].stringValue] = larr_screenFields![indexPath.row]["value"].stringValue
                larr_keybodyJson[larr_screenFields![indexPath.row]["key"].stringValue] = larr_screenFields![indexPath.row]["value"].stringValue
            }else if ldict_ScreenData != nil && ldict_ScreenData![larr_screenFields![indexPath.row]["key"].stringValue] != nil{
                larr_bodyJson[larr_screenFields![indexPath.row]["key"].stringValue] = "\(ldict_ScreenData![larr_screenFields![indexPath.row]["key"].stringValue]!)"
            }
            
            return hiddenCell
            
        case "checkbox":
            let chkboxCell = tableView.dequeueReusableCell(withIdentifier: CheckboxTableViewCell.reuseIdentifier, for: indexPath) as! CheckboxTableViewCell
            chkboxCell.config(objectMeta: rowField)
            chkboxCell.delegate = self
            larr_bodyJson.removeValue(forKey: rowField["labelKey"].stringValue)
            chkboxCell.selectionStyle = .none
            return chkboxCell
            
        default:
            if rowField.count == 0 {
                let cell = UITableViewCell()
                let customView = UIView()
                customView.backgroundColor = UIColor(hex: "EEEEF3")
                customView.borderWidth = 0.5
                customView.borderColor = .lightGray
                cell.backgroundView = customView
                cell.selectionStyle = .none
                return cell
            }else{
                return  UITableViewCell()
            }
        }
    }
}

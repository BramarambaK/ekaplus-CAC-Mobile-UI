//
//  SwitchCorpViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 23/12/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class SwitchCorpViewController: UIViewController,UIGestureRecognizerDelegate,HUDRenderer,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var checkBoxOutlet:UIButton!{
        didSet{
            checkBoxOutlet.setImage(UIImage(named:"unchecked"), for: .normal)
            checkBoxOutlet.setImage(UIImage(named:"checked"), for: .selected)
            checkBoxOutlet.setTitle("", for: .normal)
            checkBoxOutlet.setTitle("", for: .selected)
        }
    }
    
    @IBOutlet weak var dropdownOutlet:UIButton!{
        didSet{
            dropdownOutlet.setImage(UIImage(named:"dropdown"), for: .normal)
            dropdownOutlet.setTitle("", for: .normal)
        }
    }
    
    @IBOutlet weak var lbl_CurrentCorp: UILabel!
    @IBOutlet weak var ltxf_CorpDropdown: UITextField!
    @IBOutlet weak var lbtn_SwitchCorp: UIButton!
    
    //MARK: - Varibale
    
    let dataPicker = UIPickerView()
    var myPickerData:[JSON] = []
    var selectedCorp:[String:JSON] = [:]
    var lb_agree:Bool = false
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backViewTap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        self.view.addGestureRecognizer(backViewTap)
        backViewTap.delegate = self
        self.lb_agree = false
        
        switchCorpAPIandUIUpdate()
    }
    
    @objc
    func tapHandler(_ sender:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.text! == "" && myPickerData.count > 0 {
            self.selectedCorp = myPickerData[0].dictionaryValue
        }
        
        dataPicker.delegate = self
        textField.inputView = dataPicker
        textField.inputAccessoryView = self.addToolbarbutton()
        return true
        
    }
    
    //MARK: - IBAction
    
    @IBAction func dropdownTapped(_ sender: UIButton){
        ltxf_CorpDropdown.becomeFirstResponder()
    }
    
    @IBAction func checkbox(_ sender: UIButton){
        sender.checkboxAnimation {
            self.lb_agree = sender.isSelected
        }
    }
    
    @IBAction func cancelbtnTapped(_ sender: UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchbtnTapped(_ sender: UIButton){
        
        let header:[String:String] = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(),"deviceType":"mobile"]
        
        
        let bodyString = ["corporateId": self.selectedCorp["key"]?.stringValue]
        
        if lb_agree == false {
            self.showAlert(message:NSLocalizedString("Please agree for switch corporate.", comment: "Please agree for switch corporate."))
        }else{
            self.showActivityIndicator()
            
            RequestManager.shared.request(.post, connectApiPath: .switchCorporate, httpBody: bodyString.jsonString(), connectHeaders: header) { response in
                
                self.hideActivityIndicator()
                
                switch response {
                case .success(let resultJson):
                    self.dismiss(animated: true, completion: nil)
                    let ls_msg = "The corporate has been switched to \(resultJson["corporateName"].stringValue)."
                    self.showAlert(title: "Warning", message: ls_msg, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true) { succeeded in
                        
                    }
                case .failure(let error):
                    print(error)
                case .failureJson(_):
                    print("")
                }
                
            }
            
        }
        
    }
    
    //MARK: - Local Function
    
    private func switchCorpAPIandUIUpdate(){
        self.showActivityIndicator()
        
        let header:[String:String] = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(),"deviceType":"mobile"]
        
        
        RequestManager.shared.request(.get, apiPath: nil, connectApiPath: .userCorpDetails, requestURL: nil, queryParameters: nil, httpBody: nil, headers: nil, connectHeaders: header, shouldCacheWithDiskUrl: nil, bodyData: nil) { response in
            
            self.hideActivityIndicator()
            
            switch response {
            case .success(let json):
                self.lbl_CurrentCorp.text = json.dictionaryValue["CorporateName"]?.stringValue
                self.getCorporatelist()
            case .failure(let error):
                print(error)
            case .failureJson(_):
                print("")
            }
            
        }
    }
    
    private func getCorporatelist(){
        
        self.showActivityIndicator()
        
        let header:[String:String] = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(),"deviceType":"mobile"]
        
        let queryParam:String = "?serviceKey=corporateListForCurrentUser&attributeOne=Y"
        
        RequestManager.shared.request(.get, apiPath: nil, connectApiPath: .listCorporate, requestURL: nil, queryParameters: queryParam, httpBody: nil, headers: nil, connectHeaders: header, shouldCacheWithDiskUrl: nil, bodyData: nil) { response in
            
            self.hideActivityIndicator()
            
            switch response {
            case .success(let json):
                self.myPickerData = json.dictionaryValue["data"]?.arrayValue ?? []
            case .failure(let error):
                print(error)
            case .failureJson(_):
                print("")
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
        Data = "\(myPickerData[row].dictionaryValue["value"]!)"
        return Data
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCorp = myPickerData[row].dictionaryValue
    }
    
    //MARK: - ToolBar Button action
    
    private func addToolbarbutton() -> UIToolbar {
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
        self.view.endEditing(true)
    }
    
    @objc func doneButtonAction()
    {
        self.ltxf_CorpDropdown.text! = selectedCorp["value"]?.stringValue ?? ""
        self.view.endEditing(true)
    }
    
}

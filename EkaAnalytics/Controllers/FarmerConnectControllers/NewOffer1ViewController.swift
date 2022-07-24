//
//  NewOffer1ViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 13/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol NewOfferdelegate {
    func publishNewOffer(_ larr_bodyDict:[String:Any])
}

final class NewOffer1ViewController: UIViewController,KeyboardObserver,OfferConfirmationdelegate,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,HUDRenderer {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ltxf_DeliveryFrom: UITextField!
    @IBOutlet weak var ltxf_DeliveryTo: UITextField!
    @IBOutlet weak var ltxf_ExpiryDate: UITextField!
    @IBOutlet weak var ltxf_Location: UITextField!
    @IBOutlet weak var ltxf_IncoTerm: UITextField!
    @IBOutlet weak var ltxf_PackingType: UITextField!
    @IBOutlet weak var ltxf_PackingSize: UITextField!
    @IBOutlet weak var lbtn_Publish: UIButton!
    @IBOutlet weak var lblPackingType_Height: NSLayoutConstraint!
    @IBOutlet weak var ltxfPackingType_Height: NSLayoutConstraint!
    @IBOutlet weak var lblPackingSize_Height: NSLayoutConstraint!
    @IBOutlet weak var ltxfPackingSize_Height: NSLayoutConstraint!
    
    //MARK: - Variable
    var container: UIView{
        return self.scrollView
    }
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    lazy var apiController:OfferApiController = {
        return OfferApiController()
    }()
    
    var activeTextField:UITextField?
    var larr_Location:[JSON] = []
    var larr_IncoTerm:[JSON] = []
    var larr_packingSize:[JSON] = []
    var larr_packingType:[JSON] = []
    var myPickerData:[Any] = []
    var larr_bodyDict:[String:Any] = [:]
    
    let thePicker = UIPickerView()
    
    var publishedPrice:PublishedBid?
    
    var delegate:NewOfferdelegate?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications(shouldRegister: true)
        
        let backbtn = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(backButtonTapped(_:event:)))
        backbtn.tintColor = Utility.appThemeColor
        self.navigationItem.leftBarButtonItem = backbtn
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = false
        
        ltxf_ExpiryDate.inputView = datePickerWithTag(0, nil)
        ltxf_ExpiryDate.addDoneToolBarButton()
        ltxf_DeliveryFrom.inputView = datePickerWithTag(1, nil)
        ltxf_DeliveryFrom.addDoneToolBarButton()
        ltxf_DeliveryTo.inputView = datePickerWithTag(2, nil)
        ltxf_DeliveryTo.addDoneToolBarButton()
        
        if publishedPrice == nil {
            setTitle(NSLocalizedString("New Offer", comment: ""), color: UIColor.black, backbuttonTint: Utility.appThemeColor, bckbtnimage: "cancel")
        }else{
            setTitle(publishedPrice!.id, color: UIColor.black, backbuttonTint: Utility.appThemeColor, bckbtnimage: "cancel")
        }
        
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) == "basic" {
            self.lblPackingSize_Height.constant = 0
            self.lblPackingType_Height.constant = 0
            self.ltxfPackingSize_Height.constant = 0
            self.ltxfPackingType_Height.constant = 0
        }else{
            self.lblPackingSize_Height.constant = 21
            self.lblPackingType_Height.constant = 21
            self.ltxfPackingSize_Height.constant = 45
            self.ltxfPackingType_Height.constant = 45
        }
        
        getDropdowndetails()
        setupData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
    }
    
    //MARK: - Local Function
    
    @objc
    func backButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        delegate?.publishNewOffer(self.larr_bodyDict)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        activeTextField?.text = selectedDate
        
        switch activeTextField {
        case ltxf_DeliveryFrom:
            larr_bodyDict.updateValue(selectedDate+"T17:59:52.125Z", forKey: "deliveryFromDateISOString")
        case ltxf_DeliveryTo:
            larr_bodyDict.updateValue(selectedDate+"T17:59:52.125Z", forKey: "deliveryToDateISOString")
        case ltxf_ExpiryDate:
            larr_bodyDict.updateValue(selectedDate+"T17:59:52.125Z", forKey: "expiryDateISOString")
        default:
            break
        }
        
    }
    
    func datePickerWithTag(_ tag:Int,_ date:String?)->UIDatePicker{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.tag = tag
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        if date != nil {
            datePicker.setDate(formatter.date(from: date!)!, animated: true)
        }
        datePicker.minimumDate = Date()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }
    
    func setupData(){
        if publishedPrice != nil {
            ltxf_DeliveryFrom.text = ((publishedPrice!.deliveryFromDate).components(separatedBy: "T"))[0]
            larr_bodyDict.updateValue(publishedPrice!.deliveryFromDate, forKey: "deliveryFromDateISOString")
            ltxf_DeliveryTo.text = ((publishedPrice!.deliveryToDate).components(separatedBy: "T"))[0]
            larr_bodyDict.updateValue(publishedPrice!.deliveryToDate, forKey: "deliveryToDateISOString")
            ltxf_ExpiryDate.text = ((publishedPrice!.expiryDate).components(separatedBy: "T"))[0]
            larr_bodyDict.updateValue(publishedPrice!.expiryDate, forKey: "expiryDateISOString")
            ltxf_Location.text = publishedPrice?.location
            larr_bodyDict.updateValue(ltxf_Location.text!, forKey: "location")
            ltxf_IncoTerm.text = publishedPrice?.incoTerm
            larr_bodyDict.updateValue(ltxf_IncoTerm.text!, forKey: "incoTerm")
            lbtn_Publish.setTitle(NSLocalizedString("Update", comment: ""), for: .normal)
            
            if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) != "basic" {
                ltxf_PackingType.text = publishedPrice?.packingType
                larr_bodyDict.updateValue(ltxf_PackingType.text!, forKey: "packingType")
                ltxf_PackingSize.text = publishedPrice?.packingSize
                larr_bodyDict.updateValue(ltxf_PackingSize.text!, forKey: "packingSize")
            }
//            larr_bodyDict.updateValue(publishedPrice!.id, forKey: "bidId")
        }
        else{
            ltxf_DeliveryFrom.text = (("\(larr_bodyDict["deliveryFromDateISOString"] ?? "")").components(separatedBy: "T"))[0]
            ltxf_DeliveryTo.text = (("\(larr_bodyDict["deliveryToDateISOString"] ?? "")").components(separatedBy: "T"))[0]
            ltxf_ExpiryDate.text = (("\(larr_bodyDict["expiryDateISOString"] ?? "")").components(separatedBy: "T"))[0]
            ltxf_Location.text = "\(larr_bodyDict["location"] ?? "")"
            ltxf_IncoTerm.text = "\(larr_bodyDict["incoTerm"] ?? "")"
            larr_bodyDict.updateValue("", forKey: "bidId")
            lbtn_Publish.setTitle(NSLocalizedString("Publish", comment: ""), for: .normal)
            ltxf_PackingSize.text = "\(larr_bodyDict["packingSize"] ?? "")"
            ltxf_PackingType.text = "\(larr_bodyDict["packingType"] ?? "")"
        }
    }
    
    func getDropdowndetails(){
        
        //Product
        self.showActivityIndicator()
        
        let larr_fields:String = "location,incoTerm,packingType,packingSize"
        
        apiController.getDropdownData(fieldData: larr_fields) { (response) in
            self.hideActivityIndicator()
            switch response{
            case .success(let json):
                self.larr_Location = json[0]["data"].arrayValue
                self.larr_IncoTerm = json[1]["data"].arrayValue
                self.larr_packingType = json[2]["data"].arrayValue
                self.larr_packingSize = json[3]["data"].arrayValue
            case .failure( _):
                self.showAlert(message: "Please check your app settings.")
            case .failureJson(_):
                break
            }
        }
    }
    
    
    //MARK: - Delegate
    
    //TextField
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField  = textField
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        
        switch textField {
        case ltxf_DeliveryFrom:
            if textField.text?.count == 0  {
                let selectedDate: String = dateFormatter.string(from: Date())
                ltxf_DeliveryFrom.text = selectedDate
                larr_bodyDict.updateValue(selectedDate+"T17:59:52.125Z", forKey: "deliveryFromDateISOString")
            }
            else{
                ltxf_DeliveryFrom.inputView = datePickerWithTag(1, "\((("\(larr_bodyDict["deliveryFromDateISOString"] ?? "")").components(separatedBy: "T"))[0])")
            }
        case ltxf_DeliveryTo:
            if textField.text?.count == 0  {
                let selectedDate: String = dateFormatter.string(from: Date())
                ltxf_DeliveryTo.text = selectedDate
                larr_bodyDict.updateValue(selectedDate+"T17:59:52.125Z", forKey: "deliveryToDateISOString")
            }else{
                ltxf_DeliveryTo.inputView = datePickerWithTag(2, "\((("\(larr_bodyDict["deliveryToDateISOString"] ?? "")").components(separatedBy: "T"))[0])")
            }
        case ltxf_ExpiryDate:
            if  textField.text?.count == 0{
                let selectedDate: String = dateFormatter.string(from: Date())
                ltxf_ExpiryDate.text = selectedDate
                larr_bodyDict.updateValue(selectedDate+"T17:59:52.125Z", forKey: "expiryDateISOString")
            }else{
                ltxf_ExpiryDate.inputView = datePickerWithTag(0, "\((("\(larr_bodyDict["expiryDateISOString"] ?? "")").components(separatedBy: "T"))[0])")
            }
        case ltxf_Location:
            myPickerData = larr_Location
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_Location.addDoneToolBarButton()
        case ltxf_IncoTerm:
            myPickerData = larr_IncoTerm
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_IncoTerm.addDoneToolBarButton()
        case ltxf_PackingType:
            myPickerData = larr_packingType
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_PackingType.addDoneToolBarButton()
        case ltxf_PackingSize:
            myPickerData = larr_packingSize
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_PackingSize.addDoneToolBarButton()
        default:
            break
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
        activeTextField = nil
        
        switch textField {
        case ltxf_Location:
            larr_bodyDict.updateValue(ltxf_Location.text!, forKey: "location")
        case ltxf_IncoTerm:
            larr_bodyDict.updateValue(ltxf_IncoTerm.text!, forKey: "incoTerm")
        case ltxf_PackingType:
            larr_bodyDict.updateValue(ltxf_PackingType.text!, forKey: "packingType")
        case ltxf_PackingSize:
            larr_bodyDict.updateValue(ltxf_PackingSize.text!, forKey: "packingSize")
        default:
            break
        }
    }
    
    func popViewcontroller(screenNumber: Int, resetValue: Bool) {
        if resetValue {
            delegate?.publishNewOffer([:])
        }else{
            delegate?.publishNewOffer(larr_bodyDict)
        }
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - screenNumber], animated: true)
    }
    
    //MARK: - PickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var  Data:String = ""
        
        if activeTextField != ltxf_DeliveryFrom ||  activeTextField != ltxf_ExpiryDate ||  activeTextField != ltxf_DeliveryTo {
            Data = "\((myPickerData[row] as! JSON)["value"])"
        }
        
        if activeTextField?.text?.count == 0 {
            activeTextField?.text = Data
        }
        
        return Data
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if myPickerData.count > 0 {
            let selectedText:JSON = myPickerData[row] as! JSON
            activeTextField!.text = "\(selectedText["value"])"
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func btnCancel_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPublishClicked(_ sender: Any) {
        
        guard self.ltxf_DeliveryFrom.text! <= self.ltxf_DeliveryTo.text! else {
            showAlert(message: NSLocalizedString("Delivery From Date must be higher than Delivery To date", comment: "ShipmentDate validation message"))
            return
        }

        
        if publishedPrice != nil {
            larr_bodyDict.removeValue(forKey: "offerType")
        }
        
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) == "basic"{
            if ltxf_ExpiryDate.text!.count > 0 && ltxf_Location.text!.count > 0 && ltxf_IncoTerm.text!.count > 0 && ltxf_DeliveryFrom.text!.count > 0 && ltxf_DeliveryTo.text!.count > 0{
                self.showActivityIndicator()
                
                let bidDetails:[String:Any] = larr_bodyDict
                
                
                if publishedPrice != nil {
                    apiController.updatePublishBids(BidId: publishedPrice!.id, body: bidDetails.jsonString()) { (response) in
                        self.hideActivityIndicator()
                        switch response {
                        case .success(_):
                            self.showAlert(title: NSLocalizedString("Success", comment: "Success alert title"), message: NSLocalizedString("Offer has been successfully updated.", comment: "Offer success message"), okButtonText: NSLocalizedString("Ok", comment: "Alert ok button"), cancelButtonText: nil, handler: { (success) in
                                if success {
                                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                                    self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
                                }
                            })
                        case .failure( _):
                            self.showAlert(message: NSLocalizedString("Failed to update the offer. Please try again.", comment: "publish offer Failed alert message"))
                        case .failureJson(_):
                            break
                        }
                    }
                }else{
                    apiController.publishBids(body: bidDetails.jsonString()) { (response) in
                        
                        self.hideActivityIndicator()
                        
                        switch response {
                            
                        case .success(let json):
                            let confirmationVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "OfferConfirmVC") as! OfferConfirmationViewController
                            confirmationVC.modalPresentationStyle = .overCurrentContext
                            confirmationVC.delegate = self
                            confirmationVC.ls_bidID = json["bidId"].stringValue
                            self.present(confirmationVC, animated: true, completion: nil)
                        case .failure(_):
                            self.showAlert(message: NSLocalizedString("Failed to publish an offer. Please try again.", comment: "publish offer Failed alert message"))
                        case .failureJson(_):
                            break
                        }
                    }
                }
            }
            else{
                 showAlert(message: NSLocalizedString("Enter all field.", comment: ""))
            }
        }else{
            if ltxf_ExpiryDate.text!.count > 0 && ltxf_Location.text!.count > 0 && ltxf_IncoTerm.text!.count > 0 && ltxf_DeliveryFrom.text!.count > 0 && ltxf_DeliveryTo.text!.count > 0 && ltxf_PackingSize.text!.count > 0 && ltxf_PackingType.text!.count > 0 {
                self.showActivityIndicator()
                
                let bidDetails:[String:Any] = larr_bodyDict
                
                
                if publishedPrice != nil {
                    apiController.updatePublishBids(BidId: publishedPrice!.id, body: bidDetails.jsonString()) { (response) in
                        self.hideActivityIndicator()
                        switch response {
                        case .success(_):
                            self.showAlert(title: NSLocalizedString("Success", comment: "Success alert title"), message: NSLocalizedString("Offer has been successfully updated.", comment: "Offer success message"), okButtonText: NSLocalizedString("Ok", comment: "Alert ok button"), cancelButtonText: nil, handler: { (success) in
                                if success {
                                    let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                                    self.navigationController!.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
                                }
                            })
                        case .failure( _):
                            self.showAlert(message: NSLocalizedString("Failed to update the offer. Please try again.", comment: "publish offer Failed alert message"))
                        case .failureJson(_):
                            break
                        }
                    }
                }else{
                    apiController.publishBids(body: bidDetails.jsonString()) { (response) in
                        
                        self.hideActivityIndicator()
                        
                        switch response {
                            
                        case .success(let json):
                            let confirmationVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "OfferConfirmVC") as! OfferConfirmationViewController
                            confirmationVC.modalPresentationStyle = .overCurrentContext
                            confirmationVC.delegate = self
                            confirmationVC.ls_bidID = json["bidId"].stringValue
                            self.present(confirmationVC, animated: true, completion: nil)
                        case .failure(_):
                            self.showAlert(message: NSLocalizedString("Failed to publish an offer. Please try again.", comment: "publish offer Failed alert message"))
                        case .failureJson(_):
                            break
                        }
                    }
                }
            }
            else{
                 showAlert(message: NSLocalizedString("Enter all field.", comment: ""))
            }
        }
    }
    
    @IBAction func deliveryFromCalendarTapped(_ sender: UIButton) {
           ltxf_DeliveryFrom.becomeFirstResponder()
       }
    
    @IBAction func deliveryToCalendarTapped(_ sender: UIButton) {
           ltxf_DeliveryTo.becomeFirstResponder()
       }
    
    @IBAction func expiryDateCalendarTapped(_ sender: Any) {
        ltxf_ExpiryDate.becomeFirstResponder()
    }
    
    
}


//
//  NewOfferViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 13/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

final class NewOfferViewController: UIViewController,KeyboardObserver,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,HUDRenderer,NewOfferdelegate {
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ltxf_Product: UITextField!
    @IBOutlet weak var ltxf_Quality: UITextField!
    @IBOutlet weak var ltxf_CropYear: UITextField!
    @IBOutlet weak var ltxf_PublishPrice: UITextField!
    @IBOutlet weak var ltxf_PublishPriceUnit: UITextField!
    @IBOutlet weak var ltxf_Quantity: UITextField!
    @IBOutlet weak var ltxf_QuantityUnit: UITextField!
    @IBOutlet weak var ltxf_PaymentTerm: UITextField!
    @IBOutlet weak var lbtn_Sales: UIButton!
    @IBOutlet weak var lbtn_purchase: UIButton!
    @IBOutlet weak var lblPaymentTerm_Height: NSLayoutConstraint!
    @IBOutlet weak var ltxfPaymentTerm_Height: NSLayoutConstraint!
    
    //MARK: - Variable
    
    var container: UIView{
        return self.scrollView
    }
    
    var activeTextfield:UITextField?
    var larr_Product:[JSON] = []
    var larr_Quality:[JSON] = []
    var larr_PublishPriceUnit:[JSON] = []
    var larr_QuantityUnit:[JSON] = []
    var larr_CropYear:[JSON] = []
    var larr_PaymentTerm:[JSON] = []
    
    var myPickerData:[Any] = []
    
    var larr_bodyDict:[String:Any] = [:]
    
    let thePicker = UIPickerView()
    
    var publishedPrice:PublishedBid?
    
    lazy var apiController:OfferApiController = {
        return OfferApiController()
    }()
    
    var ls_ResetScreen:Bool = false
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications(shouldRegister: true)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
            self.navigationController!.navigationBar.standardAppearance = appearance;
            self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
        }
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        
        if publishedPrice == nil {
            setTitle(NSLocalizedString("New Offer", comment: ""), color: UIColor.black, backbuttonTint: Utility.appThemeColor, bckbtnimage: "cancel")
        }else{
            setTitle(publishedPrice!.id, color: UIColor.black, backbuttonTint: Utility.appThemeColor, bckbtnimage: "cancel")
        }
        
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) == "basic" {
            self.lblPaymentTerm_Height.constant = 0
            self.ltxfPaymentTerm_Height.constant = 0
        }else{
            self.lblPaymentTerm_Height.constant = 21
            self.ltxfPaymentTerm_Height.constant = 45
        }
        
        
        lbtn_Sales.isSelected = true
        lbtn_Sales.borderColor = Utility.appThemeColor
        larr_bodyDict.updateValue("Sale", forKey: "offerType")
        lbtn_purchase.isSelected = false
        
        ltxf_PublishPrice.addDoneToolBarButton()
        ltxf_Quantity.addDoneToolBarButton()
        
        getDropdowndetails()
        
        setupData()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if #available(iOS 13.0, *) {
            if publishedPrice == nil {
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = Utility.appThemeColor
                appearance.titleTextAttributes = [.foregroundColor:Utility.appThemeColor]
                self.navigationController!.navigationBar.standardAppearance = appearance;
                self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
            }else{
                let appearance = UINavigationBarAppearance()
                appearance.backgroundColor = .white
                appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
                self.navigationController!.navigationBar.standardAppearance = appearance;
                self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ls_ResetScreen && publishedPrice == nil{
            lbtn_Sales.isSelected = true
            lbtn_Sales.borderColor = Utility.appThemeColor
            larr_bodyDict.updateValue("Sale", forKey: "offerType")
            lbtn_purchase.isSelected = false
            ltxf_Product.text = ""
            ltxf_Quality.text = ""
            ltxf_CropYear.text = ""
            ltxf_PublishPrice.text = ""
            ltxf_PublishPriceUnit.text = ""
            ltxf_Quantity.text = ""
            ltxf_QuantityUnit.text = ""
            ltxf_PaymentTerm.text = ""
        }
        else{
            if larr_bodyDict.count > 1 {
                //Offer Type
                if larr_bodyDict["offerType"] as! String == "Sale" {
                    lbtn_Sales.isSelected = true
                    lbtn_Sales.borderColor = Utility.appThemeColor
                    larr_bodyDict.updateValue("Sale", forKey: "offerType")
                    lbtn_purchase.isSelected = false
                }else{
                    lbtn_purchase.isSelected = true
                    lbtn_purchase.borderColor = Utility.appThemeColor
                    larr_bodyDict.updateValue("Purchase", forKey: "offerType")
                    lbtn_Sales.isSelected = false
                }
                ltxf_Product.text = "\(larr_bodyDict["product"] ?? "")"
                ltxf_Quality.text = "\(larr_bodyDict["quality"] ?? "")"
                ltxf_CropYear.text = "\(larr_bodyDict["cropYear"] ?? "")"
                ltxf_PublishPrice.text = "\(larr_bodyDict["publishedPrice"] ?? "")"
                ltxf_PublishPriceUnit.text = "\(larr_bodyDict["priceUnit"] ?? "")"
                ltxf_Quantity.text = "\(larr_bodyDict["quantity"] ?? "")"
                ltxf_QuantityUnit.text = "\(larr_bodyDict["quantityUnit"] ?? "")"
                
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) != "basic" {
                     ltxf_PaymentTerm.text = "\(larr_bodyDict["paymentTerms"] ?? "")"
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
    }
    
    //MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextfield = textField
        
        switch textField {
        case ltxf_Product:
            myPickerData = larr_Product
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_Product.addDoneToolBarButton()
        case ltxf_Quality:
            myPickerData = larr_Quality
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_Quality.addDoneToolBarButton()
        case ltxf_PublishPriceUnit:
            myPickerData = larr_PublishPriceUnit
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_PublishPriceUnit.addDoneToolBarButton()
        case ltxf_QuantityUnit:
            myPickerData = larr_QuantityUnit
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_QuantityUnit.addDoneToolBarButton()
        case ltxf_CropYear:
            myPickerData = larr_CropYear
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_CropYear.addDoneToolBarButton()
        case ltxf_PaymentTerm:
            myPickerData = larr_PaymentTerm
            thePicker.delegate = self
            textField.inputView = thePicker
            ltxf_PaymentTerm.addDoneToolBarButton()
        default:
            break
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
        activeTextfield = nil
        
        if textField.text!.count > 0 {
            switch textField {
            case ltxf_Product:
                larr_bodyDict.updateValue(ltxf_Product.text!, forKey: "product")
            case ltxf_Quality:
                larr_bodyDict.updateValue(ltxf_Quality.text!, forKey: "quality")
            case ltxf_CropYear:
                larr_bodyDict.updateValue(ltxf_CropYear.text!, forKey: "cropYear")
            case ltxf_PublishPrice:
                larr_bodyDict.updateValue(Double(ltxf_PublishPrice.text!)!, forKey: "publishedPrice")
            case ltxf_PublishPriceUnit:
                larr_bodyDict.updateValue(ltxf_PublishPriceUnit.text!, forKey: "priceUnit")
            case ltxf_Quantity:
                larr_bodyDict.updateValue(Double(ltxf_Quantity.text!)!, forKey: "quantity")
            case ltxf_QuantityUnit:
                larr_bodyDict.updateValue(ltxf_QuantityUnit.text!, forKey: "quantityUnit")
            case ltxf_PaymentTerm:
                larr_bodyDict.updateValue(ltxf_PaymentTerm.text!, forKey: "paymentTerms")
            default:
                break
            }
        }
    }
    
    
    //MARK: - Local Function
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func backButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupData(){
        
        if publishedPrice != nil {
//            //Offer Type
            if publishedPrice!.offerType == "Sale" {
                lbtn_Sales.isSelected = true
                lbtn_Sales.borderColor = Utility.appThemeColor
                larr_bodyDict.updateValue("Sale", forKey: "offerType")
                lbtn_purchase.isSelected = false
                lbtn_purchase.borderColor = UIColor.darkGray
                
            }else{
                lbtn_purchase.isSelected = true
                lbtn_purchase.borderColor = Utility.appThemeColor
                larr_bodyDict.updateValue("Purchase", forKey: "offerType")
                lbtn_Sales.isSelected = false
                lbtn_Sales.borderColor = UIColor.darkGray
            }

            lbtn_Sales.isUserInteractionEnabled = false
            lbtn_purchase.isUserInteractionEnabled = false
            ltxf_Product.text = publishedPrice?.product
            larr_bodyDict.updateValue(ltxf_Product.text!, forKey: "product")
            ltxf_Quality.text = publishedPrice?.quality
            larr_bodyDict.updateValue(ltxf_Quality.text!, forKey: "quality")
            ltxf_CropYear.text = publishedPrice?.cropYear
            larr_bodyDict.updateValue(ltxf_CropYear.text!, forKey: "cropYear")
            ltxf_PublishPrice.text = "\(publishedPrice?.price ?? 0)"
            larr_bodyDict.updateValue(Double(ltxf_PublishPrice.text!)!, forKey: "publishedPrice")
            ltxf_PublishPriceUnit.text = publishedPrice?.pricePerUnitQuantity
            larr_bodyDict.updateValue(ltxf_PublishPriceUnit.text!, forKey: "priceUnit")
            ltxf_Quantity.text = "\(publishedPrice!.quantity)"
            larr_bodyDict.updateValue(Double(ltxf_Quantity.text!)!, forKey: "quantity")
            ltxf_QuantityUnit.text = publishedPrice?.quantityUnit
            larr_bodyDict.updateValue(ltxf_QuantityUnit.text!, forKey: "quantityUnit")
            if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) != "basic" {
                ltxf_PaymentTerm.text = publishedPrice?.paymentTerms
                larr_bodyDict.updateValue(ltxf_PaymentTerm.text!, forKey: "paymentTerms")
            }
        }
        
    }
    
    
    func publishNewOffer(_ larr_bodyDict: [String : Any]) {
        if larr_bodyDict.count > 0 {
            self.ls_ResetScreen = false
            self.larr_bodyDict = larr_bodyDict
        }else{
            self.ls_ResetScreen = true
            self.larr_bodyDict = larr_bodyDict
        }
    }
    
    
    func getDropdowndetails(){
        //Product
        self.showActivityIndicator()
        
        let larr_fields:String = "product,quality,priceUnit,quantityUnit,cropYear,paymentTerms"
        
        apiController.getDropdownData(fieldData: larr_fields) { (response) in
            self.hideActivityIndicator()
            switch response{
            case .success(let json):
                self.larr_Product = json[0]["data"].arrayValue
                self.larr_Quality = json[1]["data"].arrayValue
                self.larr_PublishPriceUnit = json[2]["data"].arrayValue
                self.larr_QuantityUnit = json[3]["data"].arrayValue
                self.larr_CropYear = json[4]["data"].arrayValue
                self.larr_PaymentTerm = json[5]["data"].arrayValue
            case .failure( _):
                self.showAlert(message: "Please check your app settings.")
            case .failureJson(_):
                break
            }
        }
    }
    
    
    
    //MARK: - PickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let Data = "\((myPickerData[row] as! JSON)["value"])"
        
        if activeTextfield?.text?.count == 0 {
            activeTextfield?.text = Data
        }
        
        if (activeTextfield?.text! == Data) {
            pickerView.selectRow(row, inComponent: 0, animated: true)
        }
        
        return Data
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if myPickerData.count > 0 {
            let selectedText:JSON = myPickerData[row] as! JSON
            activeTextfield!.text = "\(selectedText["value"])"
        }
    }
    
    //MARK: - IBAction
    @IBAction func btn_SalesClicked(_ sender: Any) {
        if lbtn_Sales.isSelected != true {
            lbtn_purchase.isSelected = false
            lbtn_Sales.isSelected = true
            lbtn_Sales.borderColor = Utility.appThemeColor
            lbtn_purchase.borderColor = UIColor.darkGray
            larr_bodyDict.updateValue("Sale", forKey: "offerType")
        }
    }
    
    
    @IBAction func btn_PurchaseClicked(_ sender: Any) {
        if lbtn_purchase.isSelected != true {
            lbtn_purchase.isSelected = true
            lbtn_Sales.isSelected = false
            lbtn_purchase.borderColor = Utility.appThemeColor
            lbtn_Sales.borderColor = UIColor.darkGray
            larr_bodyDict.updateValue("Purchase", forKey: "offerType")
        }
    }
    
    @IBAction func btnCancel_Clicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNxt_Clicked(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) == "basic"{
            if ltxf_Product.text!.count > 0 && ltxf_Quality.text!.count > 0 && ltxf_CropYear.text!.count > 0 && ltxf_PublishPrice.text!.count > 0 && ltxf_PublishPriceUnit.text!.count > 0 && ltxf_Quantity.text!.count > 0 && ltxf_QuantityUnit.text!.count > 0{
                let offerListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "NewOffer1VC") as! NewOffer1ViewController
                offerListVC.larr_bodyDict = larr_bodyDict
                offerListVC.delegate = self
                if publishedPrice != nil{
                    offerListVC.publishedPrice = self.publishedPrice
                }
                self.navigationController?.pushViewController(offerListVC, animated: true)
            }else{
                showAlert(message: NSLocalizedString("Enter all field.", comment: ""))
            }
        }else{
            if ltxf_Product.text!.count > 0 && ltxf_Quality.text!.count > 0 && ltxf_CropYear.text!.count > 0 && ltxf_PublishPrice.text!.count > 0 && ltxf_PublishPriceUnit.text!.count > 0 && ltxf_Quantity.text!.count > 0 && ltxf_QuantityUnit.text!.count > 0 && ltxf_PaymentTerm.text!.count > 0{
                let offerListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "NewOffer1VC") as! NewOffer1ViewController
                offerListVC.larr_bodyDict = larr_bodyDict
                offerListVC.delegate = self
                if publishedPrice != nil{
                    offerListVC.publishedPrice = self.publishedPrice
                }
                self.navigationController?.pushViewController(offerListVC, animated: true)
            }else{
                 showAlert(message: NSLocalizedString("Enter all field.", comment: ""))
            }
        }
    }
    
}

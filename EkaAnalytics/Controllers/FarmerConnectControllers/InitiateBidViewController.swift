//
//  InitiateContractViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 19/03/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

final class InitiateBidViewController: GAITrackedViewController, KeyboardObserver, HUDRenderer, UITextFieldDelegate,FarmerNameListDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lblProduct: UILabel!
    
    @IBOutlet weak var lblQuality: UILabel!
    
    @IBOutlet weak var lblTerm: UILabel!
    
    @IBOutlet weak var lblCropYear: UILabel!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblBidPrice: UILabel!
    
    @IBOutlet weak var txfCounterBidPrice: UITextField!
    
    @IBOutlet weak var lblCounterBidPriceSuffix: UILabel!
    
    @IBOutlet weak var lblBidID: UILabel!
    
    @IBOutlet weak var lblOfferType: UILabel!
    
    @IBOutlet weak var txfDeliveryFrom: UITextField!
    @IBOutlet weak var txfDeliveryTo: UITextField!
    
    @IBOutlet weak var btnDeliveryFromDate: UIButton!
    @IBOutlet weak var btnDeliveryToDate: UIButton!
    
    @IBOutlet weak var txvRemarks: UITextView!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var btnCounter: UIButton!
    
    @IBOutlet weak var counterPriceBorderView: UIView!
    
    @IBOutlet weak var quantityBorderView: UIView!
    
    @IBOutlet weak var txfQuantity: UITextField!
    
    @IBOutlet weak var lblQuantityUnit: UILabel!
    
    @IBOutlet weak var lvFarmerDetails: UIView!
    
    @IBOutlet weak var FarmerDetailheight: NSLayoutConstraint!
    
    @IBOutlet weak var lblFarmerName: UILabel!
    
    @IBOutlet weak var lbtn_Select: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lblOfferName: UILabel!
    
    @IBOutlet weak var lblOfferRating: UILabel!
    
    @IBOutlet weak var lblOfferMobileNo: UILabel!
    @IBOutlet weak var offerDetailHeight: NSLayoutConstraint!
    @IBOutlet weak var lblPaymentTerm: UILabel!
    @IBOutlet weak var lblPackingType: UILabel!
    @IBOutlet weak var lblPackingSize: UILabel!
    @IBOutlet weak var offerTypeHeight: NSLayoutConstraint!
    
    
    //MARK: - Variable
    
    var container: UIView{
        return self.scrollView
    }
    
    lazy var numberFormatter:NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    
    var selectedFarmer:Farmer?
    var publishedBid:PublishedBid! //Passed from previous vc
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications(shouldRegister: true)
        self.screenName = ScreenNames.inititateBid
        
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
        setTitle(publishedBid.id.uppercased(), color: .black, backbuttonTint: Utility.appThemeColor)
        
        loadPublishedBid(publishedBid)
        toggleCounterSelection(false)
        txfDeliveryFrom.inputView = datePickerWithTag(0)
        txfDeliveryFrom.addDoneToolBarButton()
        txfDeliveryTo.inputView = datePickerWithTag(1)
        txfDeliveryTo.addDoneToolBarButton()
        txfCounterBidPrice.addDoneToolBarButton()
        txvRemarks.addDoneToolBarButton()
        txfQuantity.addDoneToolBarButton()
        
        txfQuantity.delegate = self
        txfCounterBidPrice.delegate = self
        txfDeliveryFrom.delegate = self
        txfDeliveryTo.delegate = self
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.agentPermission.rawValue){
            self.lvFarmerDetails.isHidden = false
            FarmerDetailheight.constant = 62
            self.selectedFarmer = DataCacheManager.shared.getLastSelectedFarmer()
            if selectedFarmer != nil {
                if selectedFarmer?.externalUserId == "" {
                    self.lblFarmerName.text = selectedFarmer?.name
                }else{
                    self.lblFarmerName.text = (selectedFarmer?.name)! + "(" + (selectedFarmer?.externalUserId)! + ")"
                }
                self.lbtn_Select.setTitle(NSLocalizedString("Change", comment: ""), for: .normal)
            }
            else{
                self.lblFarmerName.text = ""
                self.lbtn_Select.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
            }
            
        }
        else{
            self.lvFarmerDetails.isHidden = true
            FarmerDetailheight.constant = 0
        }
        
        //Offer detail
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerorInfoRestricted.rawValue) == false{
            offerDetailHeight.constant = 90
        }else{
            offerDetailHeight.constant = 0
        }
        
        
        //Offer Type
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) == "basic"{
            offerTypeHeight.constant = 0
        }else{
            offerTypeHeight.constant = 90
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isQualityLock.rawValue){
            self.txfQuantity.isEnabled = false
            quantityBorderView.layer.borderColor = Utility.cellBorderColor.cgColor
        }
        else{
            self.txfQuantity.isEnabled = true
            quantityBorderView.layer.borderColor = UIColor.lightGray.cgColor
        }
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = Utility.appThemeColor
            appearance.titleTextAttributes = [.foregroundColor:Utility.appThemeColor]
            self.navigationController!.navigationBar.standardAppearance = appearance;
            self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.navigationController?.navigationBar.barTintColor = .white
        }
    }
    
    func toggleCounterSelection(_ selected:Bool){
        txfCounterBidPrice.text = nil
        if selected{
            counterPriceBorderView.layer.borderColor = UIColor.lightGray.cgColor
            txfCounterBidPrice.isEnabled = true
            lblCounterBidPriceSuffix.textColor = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1)
            btnSave.setTitle(NSLocalizedString("Send", comment: "Button title to send"), for: .normal)
        } else {
            counterPriceBorderView.layer.borderColor = Utility.cellBorderColor.cgColor
            txfCounterBidPrice.isEnabled = false
            lblCounterBidPriceSuffix.textColor = .lightGray
            btnSave.setTitle(NSLocalizedString("Accept", comment: "Button title to Accept"), for: .normal)
            
        }
    }
    
    func datePickerWithTag(_ tag:Int)->UIDatePicker{
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.tag = tag
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        if sender.tag == 0 {
            txfDeliveryFrom.text = selectedDate
        }else{
            txfDeliveryTo.text = selectedDate
        }
        
    }
    
    func loadPublishedBid(_ bid:PublishedBid){
        self.lblBidID.text = bid.id
        self.lblOfferType.text = bid.offerType
        self.lblProduct.text = NSLocalizedString(bid.product, comment: "product")
        self.lblQuality.text = NSLocalizedString(bid.quality, comment: "quality")
        self.lblTerm.text = bid.incoTerm
        self.lblBidPrice.text = numberFormatter.string(from: NSNumber(value: bid.price))! + " " + bid.pricePerUnitQuantity
        self.lblCropYear.text = bid.cropYear
        self.lblLocation.text = NSLocalizedString(bid.location, comment: "location")
        self.lblQuantityUnit.text = bid.quantityUnit
        self.lblCounterBidPriceSuffix.text = bid.pricePerUnitQuantity
        
        self.lblPaymentTerm.text = bid.paymentTerms
        self.lblPackingType.text = bid.packingType
        self.lblPackingSize.text = bid.packingSize
        
        
        if bid.offerorName.count > 0 {
            self.lblOfferName.text = bid.offerorName
        }else{
            self.lblOfferName.text = NSLocalizedString("Not Available", comment: "")
        }
        
        if bid.offerorRating.count > 0 && bid.offerorRating != "Pending"{
            self.lblOfferRating.text = "\(Double(bid.offerorRating)!)"
        }else{
            self.lblOfferRating.text = NSLocalizedString("Not Available", comment: "")
        }
        
        if bid.offerorMobileNo.count > 0 {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapFunction))
            lblOfferMobileNo.isUserInteractionEnabled = true
            lblOfferMobileNo.addGestureRecognizer(tapGesture)
            self.lblOfferMobileNo.attributedText = NSAttributedString(string: bid.offerorMobileNo, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
            self.lblOfferMobileNo.textColor = UIColor.blue
            
        }else{
            self.lblOfferMobileNo.text = NSLocalizedString("Not Available", comment: "")
        }
        
        if bid.quantity > 0 {
            self.txfQuantity.text = String(format: "%g", bid.quantity)
        }else{
            self.txfQuantity.text = ""
        }
        
        if bid.deliveryFromDateInMillis > 0{
            let date = Date(timeIntervalSince1970: (bid.deliveryFromDateInMillis/1000))
            self.txfDeliveryFrom.text = "\(dateFormatter.string(from: date))"
        }else{
            self.txfDeliveryFrom.text = "\(dateFormatter.string(from: Date()))"
        }
        
        if bid.deliveryToDateInMillis > 0{
            let date = Date(timeIntervalSince1970: (bid.deliveryToDateInMillis/1000))
            self.txfDeliveryTo.text = "\(dateFormatter.string(from: date))"
        }else{
            self.txfDeliveryTo.text = "\(dateFormatter.string(from: Date()))"
        }
        
        
        //        if bid.shipmentDateInMillis > 0{
        //            let date = Date(timeIntervalSince1970: (bid.shipmentDateInMillis/1000))
        //            self.txfShipmentDate.text = "\(dateFormatter.string(from: date))"
        //        }else{
        //            self.txfShipmentDate.text = "\(dateFormatter.string(from: Date()))"
        //        }
    }
    
    func updateBidWithStatus(_ bidStatus:BidStatus){
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
//        "yyyy-MM-dd"//'T'00:00:00"
        
        let deliveryFromString = txfDeliveryFrom.text! + " 23:45:00"
        var deliveryFromInterval:TimeInterval!
        if let date = dateFormatter.date(from: deliveryFromString){
            deliveryFromInterval = date.timeIntervalSince1970 * 1000 //We store it in milliseconds in db. but ios gives it in seconds. so multiply it by 1000 to get milliseconds
        }
        
        let deliveryToString = txfDeliveryTo.text! + " 23:45:00"
        var deliveryToInterval:TimeInterval!
        if let date = dateFormatter.date(from: deliveryToString){
            deliveryToInterval = date.timeIntervalSince1970 * 1000 //We store it in milliseconds in db. but ios gives it in seconds. so multiply it by 1000 to get milliseconds
        }
        
        
        let CurrentDateInterval = Date().timeIntervalSince1970 * 1000
        
        if CurrentDateInterval >= deliveryToInterval {
            self.showAlert(message: NSLocalizedString("Please Enter Valid Delivery period.", comment: ""))
            return
        }
        
        var bidDetails:[String:Any] = ["bidId":publishedBid.id,  "quantity":txfQuantity.text!,"deliveryFromDateInMillis":deliveryFromInterval,"deliveryToDateInMillis":deliveryToInterval,"status":bidStatus.rawValue, "remarks":txvRemarks.text]
        
        
        if bidStatus == .inProgress {
            bidDetails.updateValue(txfCounterBidPrice.text!, forKey: "price")
        }
        
        self.showActivityIndicator()
        
        BidListApiController.shared.createBids(farmerId: (selectedFarmer?.id), body: bidDetails.jsonString()) { (response) in
            
            self.hideActivityIndicator()
            
            switch response {
            case .success(_):
                self.showAlert(title: NSLocalizedString("Success", comment: "Success alert title"), message: NSLocalizedString("Bid has been placed successfully", comment: "Bid success message"), okButtonText: NSLocalizedString("Ok", comment: "Alert ok button"), cancelButtonText: nil, handler: { (success) in
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            case .failure(let error):
                //                self.showAlert(message: NSLocalizedString("Failed to place the bid. Please try again.", comment: "Bid Failed alert message"))
                self.showAlert(message: "\(error.description)")
                
            case .failureJson(_):
                break
            }
        }
        
    }
    
    @objc func callTapFunction(sender:UITapGestureRecognizer) {
        
        if let url = URL(string: "tel://\(publishedBid.offerorMobileNo)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: - TextField delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
        if (textField == self.txfQuantity) && textField.text != nil && textField.text != "" {
            
            if let validNumberString = Utility.validNumber(num: textField.text!) {
                textField.text = validNumberString
            } else {
                showAlert(message: NSLocalizedString("Please enter a valid non-zero value.", comment: "Counter price validation message"))
                textField.text = nil
            }
        } else if  textField == self.txfCounterBidPrice && textField.text != nil && btnCounter.isSelected  && textField.text != "" {
            
            if let validNumberString = Utility.validNumber(num: textField.text!) {
                textField.text = validNumberString
            } else {
                showAlert(message: NSLocalizedString("Please enter a valid non-zero value.", comment: "Counter price validation message"))
                textField.text = nil
            }
        }
        
        if textField == self.txfDeliveryFrom {
            let dateFormatter: DateFormatter = DateFormatter()
            
            // Set date format
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Apply date format
            let selectedDate: String = dateFormatter.string(from: (textField.inputView as! UIDatePicker).date)
            textField.text = selectedDate
        }
        
        if textField == self.txfDeliveryTo {
            let dateFormatter: DateFormatter = DateFormatter()
            
            // Set date format
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Apply date format
            let selectedDate: String = dateFormatter.string(from: (textField.inputView as! UIDatePicker).date)
            textField.text = selectedDate
        }
        
    }
    
    //MARK: - Farmer Select delegate
    
    func didSelectFarmer(FarmerName: Farmer) {
        //Store selected Farmer to the disk
        DataCacheManager.shared.saveLastSelectedFarmer(farmer: FarmerName)
        selectedFarmer = FarmerName
        if FarmerName.externalUserId == "" {
            self.lblFarmerName.text = FarmerName.name
        }else{
            self.lblFarmerName.text = (FarmerName.name) + "(" + (FarmerName.externalUserId) + ")"
        }
        self.lbtn_Select.setTitle("Change", for: .normal)
    }
    
    //MARK: - IBAction Function
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        
        let bidStatus:BidStatus = btnCounter.isSelected ? .inProgress : .accepted
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.agentPermission.rawValue){
            guard selectedFarmer != nil else {
                showAlert(message: NSLocalizedString("Please select a bidder.", comment: "No Farmer selected"))
                return
            }
        }
        
        guard txfQuantity.text != nil && txfQuantity.text != "" else {
            showAlert(message: NSLocalizedString("Please enter the Quantity.", comment: "Quantity validation message"))
            return
        }
        
        guard txfDeliveryFrom.text != nil && txfDeliveryFrom.text != "" else {
            showAlert(message: NSLocalizedString("Please enter Delivery from Date.", comment: ""))
            return
        }
        
        guard txfDeliveryTo.text != nil && txfDeliveryTo.text != "" else {
            showAlert(message: NSLocalizedString("Please enter the Delivery To Date.", comment: "ShipmentDate validation message"))
            return
        }
        
        guard self.txfDeliveryFrom.text! <= self.txfDeliveryTo.text! else {
            showAlert(message: NSLocalizedString("Delivery From Date must be higher than Delivery To date", comment: "ShipmentDate validation message"))
            return
        }
        
    
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.personalInfoSharingRestricted.rawValue){
            if txvRemarks.text.getEmailandPhoneValidation() == true {
                self.showAlert(title: "Warning", message: NSLocalizedString("Kindly do not enter any email ids or phone numbers.", comment: ""), okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
                })
                return
            }
        }
        
//        let dateFormatter: DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//
//        let DeliveryFrom = txfDeliveryFrom.text!
//        let currentDate = dateFormatter.string(from: NSDate() as Date)
//
//
//        if DeliveryFrom.compare(currentDate) == .orderedAscending {
//            showAlert(message: NSLocalizedString("Please enter valid Delivery From Date.", comment: "Please enter valid Shipment Date."))
//            return
//        }
        
        
        if bidStatus == .inProgress {
            guard txfCounterBidPrice.text != nil && txfCounterBidPrice.text != "" else {
                showAlert(message: NSLocalizedString("Please enter the price.", comment: "Counter price validation message"))
                return
            }
            
            self.updateBidWithStatus(bidStatus)
        }
        
        if bidStatus == .accepted { //Ask for confirmation before accepting
            self.showAlert(title: NSLocalizedString("Confirmation", comment: "Confirmation"), message: NSLocalizedString("You're accepting the bid at the price \(self.publishedBid.price) \(self.publishedBid.pricePerUnitQuantity)", comment: "Confirmation message"), okButtonText: NSLocalizedString("Accept", comment: "accept"), cancelButtonText: NSLocalizedString("Cancel", comment: "cancel"), presentOnRootVC: true) { (accepted) in
                if accepted{
                    self.updateBidWithStatus(bidStatus)
                }
            }
        }
    }
    
    @IBAction func counterTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        toggleCounterSelection(sender.isSelected)
    }
    
    @IBAction func deliveryFromoCalendarTapped(_ sender: UIButton) {
        txfDeliveryFrom.becomeFirstResponder()
    }
    
    @IBAction func deliveryTooCalendarTapped(_ sender: UIButton) {
        txfDeliveryTo.becomeFirstResponder()
    }
    
    @IBAction func btnChangeClicked(_ sender: Any) {
        let FarmerNameVC = UIStoryboard.init(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "FarmerListViewController") as! FarmerListViewController
        FarmerNameVC.delegate = self
        self.present(FarmerNameVC, animated: true, completion: nil)
    }
}

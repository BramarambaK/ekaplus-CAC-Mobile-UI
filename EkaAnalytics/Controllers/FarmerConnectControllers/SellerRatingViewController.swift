//
//  SellerRatingViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 13/11/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol sellerRatingdelegate:AnyObject{
    func UpdateRating(rating:Double)
}

class SellerRatingViewController: UIViewController,UITextViewDelegate,KeyboardObserver,HUDRenderer {
    
    //MARK: - Variable
    
    var ls_Headerlabel:String!
    
    var ls_SellerName:String!
    
    var ls_RefId:String!
    
    var container: UIView{
        return self.scrollView
    }
    
    var selectedTag:[String] = []
    var selectedRating:Double = 0
    var delegate:sellerRatingdelegate?
    
    
    //MARK: - IBOutlet
    
    
    @IBOutlet weak var lbtn_Star1: UIButton!
    
    @IBOutlet weak var lbtn_Star2: UIButton!
    
    @IBOutlet weak var lbtn_Star3: UIButton!
    
    @IBOutlet weak var lbtn_Star4: UIButton!
    
    @IBOutlet weak var lbtn_Star5: UIButton!
    
    @IBOutlet weak var lblBidRefID: UILabel!
    
    @IBOutlet weak var ltxv_Remarks: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var lbl_SellerName: UILabel!
    
    @IBOutlet weak var lv_Pricing: UIView!
    @IBOutlet weak var lbl_Pricing: UILabel!
    
    @IBOutlet weak var lv_Quantity: UIView!
    @IBOutlet weak var lbl_Quantity: UILabel!
    
    @IBOutlet weak var lv_Quality: UIView!
    @IBOutlet weak var lbl_Quality: UILabel!
    
    @IBOutlet weak var lv_Shipment: UIView!
    @IBOutlet weak var lbl_Shipment: UILabel!
    
    @IBOutlet weak var lv_All: UIView!
    @IBOutlet weak var lbl_All: UILabel!
    
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Basic Settings
        self.lblBidRefID.text = ls_Headerlabel
        self.lbl_SellerName.text = ls_SellerName
        ltxv_Remarks.text = NSLocalizedString(" Remarks", comment: "")
        ltxv_Remarks.textColor = UIColor.lightGray
        
        ltxv_Remarks.addDoneToolBarButton()
        self.registerForKeyboardNotifications(shouldRegister: true)
        
        self.basicSetup()
        self.categorySetup()
        self.addGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
    }
    
    //MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = " Remarks"
            textView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: - Local Function
    
    
    
    func basicSetup() {
        lbtn_Star1.isSelected = false
        lbtn_Star2.isSelected = false
        lbtn_Star3.isSelected = false
        lbtn_Star4.isSelected = false
        lbtn_Star5.isSelected = false
    }
    
    func categorySetup(){
        lv_All.backgroundColor = UIColor.white
        lv_Pricing.backgroundColor = UIColor.white
        lv_Quantity.backgroundColor = UIColor.white
        lv_Quality.backgroundColor = UIColor.white
        lv_Shipment.backgroundColor = UIColor.white
    }
    
    func addGesture(){
        let pricingTapGesture = UITapGestureRecognizer(target: self, action: #selector(pricingTapFunction))
        lv_Pricing.addGestureRecognizer(pricingTapGesture)
        let quantityTapGesture = UITapGestureRecognizer(target: self, action: #selector(quantityTapFunction))
        lv_Quantity.addGestureRecognizer(quantityTapGesture)
        let qualityTapGesture = UITapGestureRecognizer(target: self, action: #selector(qualityTapFunction))
        lv_Quality.addGestureRecognizer(qualityTapGesture)
        let shipmentTapGesture = UITapGestureRecognizer(target: self, action: #selector(shipmentTapFunction))
        lv_Shipment.addGestureRecognizer(shipmentTapGesture)
        let allTapGesture = UITapGestureRecognizer(target: self, action: #selector(allTapFunction))
        lv_All.addGestureRecognizer(allTapGesture)
    }
    
    @objc func pricingTapFunction(){
        if lv_Pricing.backgroundColor == UIColor(hex: "276AAE")!.withAlphaComponent(0.3){
            lv_Pricing.backgroundColor = UIColor.white
            lv_Pricing.borderColor = UIColor.lightGray
            lbl_Pricing.textColor = UIColor.darkGray
            lv_All.backgroundColor = UIColor.white
            lbl_All.textColor = UIColor.darkGray
            lv_All.borderColor = UIColor.lightGray
            if let index = selectedTag.firstIndex(of: "Pricing") {
                selectedTag.remove(at: index)
            }
        }else{
            lv_Pricing.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Pricing.borderColor = UIColor(hex: "276AAE")!
            lbl_Pricing.textColor = UIColor(hex: "276AAE")!
            selectedTag.append("Pricing")
        }
    }
    
    @objc func quantityTapFunction(){
        if lv_Quantity.backgroundColor == UIColor(hex: "276AAE")!.withAlphaComponent(0.3)    {
            lv_Quantity.backgroundColor = UIColor.white
            lv_Quantity.borderColor = UIColor.lightGray
            lbl_Quantity.textColor = UIColor.darkGray
            lv_All.backgroundColor = UIColor.white
            lbl_All.textColor = UIColor.darkGray
            lv_All.borderColor = UIColor.lightGray
            if let index = selectedTag.firstIndex(of: "Quantity") {
                selectedTag.remove(at: index)
            }
        }else{
            lv_Quantity.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Quantity.borderColor = UIColor(hex: "276AAE")!
            lbl_Quantity.textColor = UIColor(hex: "276AAE")!
            selectedTag.append("Quantity")
        }
    }
    
    
    @objc func qualityTapFunction(){
        if lv_Quality.backgroundColor == UIColor(hex: "276AAE")!.withAlphaComponent(0.3){
            lv_Quality.backgroundColor = UIColor.white
            lv_Quality.borderColor = UIColor.lightGray
            lbl_Quality.textColor = UIColor.darkGray
            lv_All.backgroundColor = UIColor.white
            lbl_All.textColor = UIColor.darkGray
            lv_All.borderColor = UIColor.lightGray
            if let index = selectedTag.firstIndex(of: "Quality") {
                selectedTag.remove(at: index)
            }
        }else{
            lv_Quality.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Quality.borderColor = UIColor(hex: "276AAE")!
            lbl_Quality.textColor = UIColor(hex: "276AAE")!
            selectedTag.append("Quality")
        }
    }
    
    @objc func shipmentTapFunction(){
        if lv_Shipment.backgroundColor == UIColor(hex: "276AAE")!.withAlphaComponent(0.3){
            lv_Shipment.backgroundColor = UIColor.white
            lv_Shipment.borderColor = UIColor.lightGray
            lbl_Shipment.textColor = UIColor.darkGray
            lv_All.backgroundColor = UIColor.white
            lbl_All.textColor = UIColor.darkGray
            lv_All.borderColor = UIColor.lightGray
            if let index = selectedTag.firstIndex(of: "Quality") {
                selectedTag.remove(at: index)
            }
            
        }else{
            lv_Shipment.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Shipment.borderColor = UIColor(hex: "276AAE")!
            lbl_Shipment.textColor = UIColor(hex: "276AAE")!
            selectedTag.append("Shipment")
        }
    }
    
    @objc func allTapFunction(){
        if lv_All.backgroundColor == UIColor(hex: "276AAE")!.withAlphaComponent(0.3){
            lv_All.backgroundColor = UIColor.white
            lv_All.borderColor = UIColor.lightGray
            lbl_All.textColor = UIColor.darkGray
            lv_Pricing.backgroundColor = UIColor.white
            lv_Pricing.borderColor = UIColor.lightGray
            lbl_Pricing.textColor = UIColor.darkGray
            lv_Quantity.backgroundColor = UIColor.white
            lv_Quantity.borderColor = UIColor.lightGray
            lbl_Quantity.textColor = UIColor.darkGray
            lv_Quality.backgroundColor = UIColor.white
            lv_Quality.borderColor = UIColor.lightGray
            lbl_Quality.textColor = UIColor.darkGray
            lv_Shipment.backgroundColor = UIColor.white
            lv_Shipment.borderColor = UIColor.lightGray
            lbl_Shipment.textColor = UIColor.darkGray
            selectedTag.removeAll()
        }else{
            lv_All.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_All.borderColor = UIColor(hex: "276AAE")!
            lbl_All.textColor = UIColor(hex: "276AAE")!
            lv_Pricing.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Pricing.borderColor = UIColor(hex: "276AAE")!
            lbl_Pricing.textColor = UIColor(hex: "276AAE")!
            lv_Quantity.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Quantity.borderColor = UIColor(hex: "276AAE")!
            lbl_Quantity.textColor = UIColor(hex: "276AAE")!
            lv_Quality.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Quality.borderColor = UIColor(hex: "276AAE")!
            lbl_Quality.textColor = UIColor(hex: "276AAE")!
            lv_Shipment.backgroundColor = UIColor(hex: "276AAE")!.withAlphaComponent(0.3)
            lv_Shipment.borderColor = UIColor(hex: "276AAE")!
            lbl_Shipment.textColor = UIColor(hex: "276AAE")!
            selectedTag.removeAll()
            let Tagdata = ["Pricing","Quantity","Quality","Shipment"]
            selectedTag.append(contentsOf: Tagdata)
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func dismiss(_ sender:UIButton?){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func star1_Clicked(_ sender: Any) {
        if lbtn_Star1.isSelected {
            selectedRating = 0
            lbtn_Star1.isSelected = false
            lbtn_Star2.isSelected = false
            lbtn_Star3.isSelected = false
            lbtn_Star4.isSelected = false
            lbtn_Star5.isSelected = false
        }else{
            selectedRating = 1
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = false
            lbtn_Star3.isSelected = false
            lbtn_Star4.isSelected = false
            lbtn_Star5.isSelected = false
        }
    }
    
    @IBAction func star2_Clicked(_ sender: Any) {
        if lbtn_Star2.isSelected {
            selectedRating = 1
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = false
            lbtn_Star3.isSelected = false
            lbtn_Star4.isSelected = false
            lbtn_Star5.isSelected = false
        }else{
            selectedRating = 2
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = true
            lbtn_Star3.isSelected = false
            lbtn_Star4.isSelected = false
            lbtn_Star5.isSelected = false
        }
    }
    
    @IBAction func star3_Clicked(_ sender: Any) {
        if lbtn_Star3.isSelected {
            selectedRating = 2
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = true
            lbtn_Star3.isSelected = false
            lbtn_Star4.isSelected = false
            lbtn_Star5.isSelected = false
        }else{
            selectedRating = 3
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = true
            lbtn_Star3.isSelected = true
            lbtn_Star4.isSelected = false
            lbtn_Star5.isSelected = false
        }
    }
    
    @IBAction func star4_Clicked(_ sender: Any) {
        if lbtn_Star4.isSelected {
            selectedRating = 3
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = true
            lbtn_Star3.isSelected = true
            lbtn_Star4.isSelected = false
            lbtn_Star5.isSelected = false
        }else{
            selectedRating = 4
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = true
            lbtn_Star3.isSelected = true
            lbtn_Star4.isSelected = true
            lbtn_Star5.isSelected = false
        }
    }
    
    @IBAction func star5_Clicked(_ sender: Any) {
        if lbtn_Star5.isSelected {
            selectedRating = 4
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = true
            lbtn_Star3.isSelected = true
            lbtn_Star4.isSelected = true
            lbtn_Star5.isSelected = false
        }else{
            selectedRating = 5
            lbtn_Star1.isSelected = true
            lbtn_Star2.isSelected = true
            lbtn_Star3.isSelected = true
            lbtn_Star4.isSelected = true
            lbtn_Star5.isSelected = true
        }
    }
    
    @IBAction func done_Clicked(_ sender: Any) {
        if selectedRating > 0 && selectedTag.count > 0 {
            
            if ltxv_Remarks.text.getEmailandPhoneValidation() == true {
                self.showAlert(title: "Warning", message: NSLocalizedString("Kindly do not enter any email ids or phone numbers.", comment: ""), okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
                })
                return
            }
            
            self.showActivityIndicator()
            BidListApiController.shared.updateRating(remarks: ltxv_Remarks.text, ratedOn: selectedTag, rating: Int(selectedRating), refId: ls_RefId) { (result) in
                self.hideActivityIndicator()
                if result == true{
                    self.delegate?.UpdateRating(rating: self.selectedRating)
                    self.dismiss(animated: true, completion: nil)
                }else{
                     self.showAlert(message: NSLocalizedString("Unable to submit the rating.Please try again later.", comment: ""))
                    print("false")
                }
            }
        }else{
            self.showAlert(message: NSLocalizedString("Please provide your rating.", comment: ""))
        }
    }
}

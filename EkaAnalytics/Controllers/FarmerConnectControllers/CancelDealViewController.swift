//
//  CancelDealViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 26/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol CancelDealDelegate:AnyObject {
    func cancelRefreshPage()
}

class CancelDealViewController: UIViewController,UITextViewDelegate,HUDRenderer {
    
    //MARK: - IBOutlet
    @IBOutlet weak var ltxf_Remarks: UITextView!
    
    @IBOutlet weak var lbtn_CancelDeal: UIButton!
    
    //MARK: - Variable
    
    lazy var apiController:OfferApiController = {
        return OfferApiController()
    }()
    
    var ls_bidId:String = ""
    weak var delegate:CancelDealDelegate?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbtn_CancelDeal.isEnabled = false
    }
    
    
    //MARK: - textViewdelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count > 0{
            lbtn_CancelDeal.isEnabled = true
        }else{
            lbtn_CancelDeal.isEnabled = false
        }
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    //MARK: - IBAction   
    
    @IBAction func btnBack_clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCancel_Clicked(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if ltxf_Remarks.text.getEmailandPhoneValidation() == true {
            self.showAlert(title: "Warning", message: NSLocalizedString("Kindly do not enter any email ids or phone numbers.", comment: ""), okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
            })
            return
        }
        
        var larr_bodydict:[String:Any] = [:]
        
        larr_bodydict.updateValue(self.ltxf_Remarks.text!, forKey: "Body")
        
        apiController.CancelBids(BidId: ls_bidId, body: larr_bodydict.jsonString()) { (success) in
            switch success{
            case .success(_):
                self.dismiss(animated: true, completion: self.delegate?.cancelRefreshPage)
            case .failure(let error):
                print(error)
            case .failureJson(_):
                break
            }
        }
    }
    
}

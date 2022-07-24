//
//  BidRejectionViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 09/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol BidRejectionDelegate:AnyObject {
    func refreshPage()
}

class BidRejectionViewController: UIViewController, KeyboardObserver, HUDRenderer {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var txvComments:UITextView!
    
    @IBOutlet weak var containerView:UIView!
    
    @IBOutlet weak var lblLatestTraderPrice: UILabel!
    
    @IBOutlet weak var lblPriceLabel: UILabel!
    
    
    //MARK: - Variable
    
    var latestTraderPrice : Double!
    var priceUnit:String!
    var selectedFarmer:Farmer?
    
    var container: UIView{
        return containerView
    }
    
    var refId:String!
    weak var delegate:BidRejectionDelegate?
    var ls_FarmerConnectMode:String?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        self.view.addGestureRecognizer(tap)
        
        self.registerForKeyboardNotifications(shouldRegister: true)
        
        if ls_FarmerConnectMode?.uppercased() == "BID"{
             lblPriceLabel.text = NSLocalizedString("Latest Offeror Price", comment: "")
        }else{
             lblPriceLabel.text = NSLocalizedString("Latest Bidder Price", comment: "")
        }
        
        lblLatestTraderPrice.text = latestTraderPrice.description + " " + priceUnit
        self.selectedFarmer = DataCacheManager.shared.getLastSelectedFarmer()
    }


    @objc
    func tapHandler(_ sender:UITapGestureRecognizer?){
        self.view.endEditing(true)
    }
    
    //MARK: - IBAction
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rejectTapped(_ sender: UIButton) {
        
        guard txvComments.text != "" else {
            showAlert(message: NSLocalizedString("Please enter the reason for rejection.", comment: "Rejection reason."))
            return
        }
        
        if txvComments.text.getEmailandPhoneValidation() == true {
            self.showAlert(title: "Warning", message: NSLocalizedString("Kindly do not enter any email ids or phone numbers.", comment: ""), okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
            })
            return
        }
        
        
        let bidUpdate:[String:Any] = ["status":BidStatus.rejected.rawValue, "remarks":txvComments.text!]
        
        self.showActivityIndicator()
        
        var queryParam:Bool = false
        
        if ls_FarmerConnectMode?.uppercased() == "OFFER"{
            queryParam = true
        }
        
        BidListApiController.shared.updateBid(farmerId:selectedFarmer?.id , refId: refId!, bidUpdate.jsonString(), queryParam) { (response) in
            
            self.hideActivityIndicator()
            switch response {
            case .success(_):
                
                self.showAlert(title: "Rejected", message: "Your message has been sent.", okButtonText: "Ok", cancelButtonText: nil, handler: { (success) in
                    if success {
                        self.dismiss(animated: true, completion: self.delegate?.refreshPage)
                    }
                })
                
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(_):
                break
            }
        }
    }
    
}

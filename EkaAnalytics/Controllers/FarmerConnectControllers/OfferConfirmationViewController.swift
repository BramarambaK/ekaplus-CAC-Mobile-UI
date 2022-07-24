//
//  OfferConfirmationViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 20/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol OfferConfirmationdelegate {
    func popViewcontroller(screenNumber:Int,resetValue:Bool)
}

class OfferConfirmationViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var lbl_Sucess: UILabel!
    
    
    //MARK: - Variable
    
    var delegate:OfferConfirmationdelegate?
    var ls_bidID:String = ""
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Sucess.text = ls_bidID + " \(NSLocalizedString("is successfully published", comment: ""))"
    }
    
    //MARK: - IBAction
    @IBAction func btn_exitClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.popViewcontroller(screenNumber: 3, resetValue: true)
        }
    }
    
    @IBAction func btn_newOfferClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.popViewcontroller(screenNumber: 2, resetValue: true)
        }
    }
    
    @IBAction func btn_duplicateOfferClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.popViewcontroller(screenNumber: 2, resetValue: false)
        }
    }
    
}

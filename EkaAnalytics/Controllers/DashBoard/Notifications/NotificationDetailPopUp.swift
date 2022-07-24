//
//  NotificationDetailPopUp.swift
//  EkaAnalytics
//
//  Created by Nithin on 29/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class NotificationDetailPopUp: UIViewController {
    
    @IBOutlet weak var lblCollectionNameValue: UILabel!
    
    @IBOutlet weak var lblPolicyNameValue: UILabel!
    
    @IBOutlet weak var lblStatusValue: UILabel!
    
    @IBOutlet weak var lblRunDateValue: UILabel!
    
    @IBOutlet weak var lblGroupNameValue: UILabel!
    
    @IBOutlet weak var lblLimitTypeValue: UILabel!
    
    @IBOutlet weak var lblValueTypeValue: UILabel!
    
    @IBOutlet weak var lblMeasureNameValue: UILabel!
    
    @IBOutlet weak var lblBreachLimitValue: UILabel!
    
    @IBOutlet weak var lblThresholdLimitValue: UILabel!
    
    @IBOutlet weak var lblActualsValue: UILabel!
    
    
    @IBOutlet weak var groupNameKey: UILabel!
    
    var notifictionDetail : BusinessAlert!

    override func viewDidLoad() {
        super.viewDidLoad()

        lblCollectionNameValue.isHidden = true
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        setTitle("NotificationDetails")
        
        lblPolicyNameValue.text = notifictionDetail.name
        lblStatusValue.text = notifictionDetail.status
        if notifictionDetail.status.contains("Limit"){
            lblStatusValue.textColor = .red
        }
        lblRunDateValue.text = notifictionDetail.runDate
        lblLimitTypeValue.text = notifictionDetail.limitType
        lblValueTypeValue.text = notifictionDetail.valueType
        lblMeasureNameValue.text = notifictionDetail.measureName
        lblBreachLimitValue.text = notifictionDetail.breachLimit
        lblThresholdLimitValue.text = notifictionDetail.thresholdLimit
        lblActualsValue.text = notifictionDetail.actuals
        
        if notifictionDetail.groupName != "" {
            lblGroupNameValue.text = notifictionDetail.groupName
        } else {
            groupNameKey.isHidden = true
            lblGroupNameValue.isHidden = true
        }
    }

    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

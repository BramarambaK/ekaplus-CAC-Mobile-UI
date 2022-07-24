//
//  NotificationDetailViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 29/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class NotificationDetailViewController: GAITrackedViewController {

    @IBOutlet weak var borderView: UIView!
    
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
    
    @IBOutlet weak var dimensionsStackView: UIStackView!
    
    @IBOutlet weak var valueStackView: UIStackView!
    
    
    var notifictionDetail : BusinessAlert!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.notificationDetails
        
        lblCollectionNameValue.isHidden = true
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        setTitle("Notification Details")
        
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
        
        let dimension = notifictionDetail.dimensions.replacingOccurrences(of: "\r", with: "")
        
        let keyValuePairs = dimension.components(separatedBy: "\n")
        
        for keyValuePair in keyValuePairs {
            
//            let split = keyValuePair.components(separatedBy: ":")
            
            let split = keyValuePair.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false).map{String($0)}
            
            let key = split.first!
            let value = split.last!.trimmingCharacters(in: CharacterSet.init(charactersIn: " ()"))
            let keyLabel = UILabel()
            keyLabel.numberOfLines = 1
            keyLabel.text = key
            
            let valueLabel = UILabel()
            valueLabel.numberOfLines = 1
            valueLabel.text = String(value)
            valueLabel.adjustsFontSizeToFitWidth = true
            
            
            dimensionsStackView.addArrangedSubview(keyLabel)
            valueStackView.addArrangedSubview(valueLabel)
            
        }
        
    }

    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let layer = self.borderView.layer.sublayers?.filter({$0.name == "borderLayer"}).first {
            layer.removeFromSuperlayer()
            let dashedBorderLayer = Utility.dashedBorderLayerWithColor(color: UIColor.gray.cgColor, frame: borderView.bounds)
            borderView.layer.addSublayer(dashedBorderLayer)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        print("did appear size: \(borderView.frame)")
        
        let dashedBorderLayer = Utility.dashedBorderLayerWithColor(color: UIColor.gray.cgColor, frame: borderView.bounds)
        
        borderView.layer.addSublayer(dashedBorderLayer)
    }
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takeMeThere(_ sender: UIBarButtonItem) {
        
    }
    
   

}

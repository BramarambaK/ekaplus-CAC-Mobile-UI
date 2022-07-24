//
//  NotificationTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 22/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    static let identifier = "NotificationTableViewCell"
    
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var priorityIndicator: UIImageView!
    
    @IBOutlet weak var lblDateTime: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblLimitType: UILabel!
    
    @IBOutlet weak var lblMeasureName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

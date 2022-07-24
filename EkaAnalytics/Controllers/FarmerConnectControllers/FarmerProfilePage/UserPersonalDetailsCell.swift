//
//  UserPersonalDetailsCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 18/05/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class UserPersonalDetailsCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblEmail: UILabel!
    
    @IBOutlet weak var lblMobile: UILabel!
    
    @IBOutlet weak var lblFax: UILabel!
    
    @IBOutlet weak var lblWebsite: UILabel!
    
    @IBOutlet weak var lblPhone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

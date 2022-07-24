//
//  UserBankDetailsCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 18/05/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class UserBankDetailsCell: UITableViewCell {
    
    
    @IBOutlet weak var lblAccountHoldersName: UILabel!
    
    @IBOutlet weak var lblIBAN: UILabel!
    
    @IBOutlet weak var lblCurrencyName: UILabel!
    
    @IBOutlet weak var lblBankAddress: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

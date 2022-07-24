//
//  BidTransactionTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 05/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class BidTransactionTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblPublishedBidPrice: UILabel!
    
    @IBOutlet weak var lblLatestFarmerPrice: UILabel!
    
    @IBOutlet weak var lblLatestTraderPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

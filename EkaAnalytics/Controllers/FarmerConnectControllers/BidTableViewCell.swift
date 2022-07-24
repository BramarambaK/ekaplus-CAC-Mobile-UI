//
//  BidTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 19/03/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class BidTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblSite: UILabel!
    
    @IBOutlet weak var lblQuality: UILabel!
    
    @IBOutlet weak var lblCropYear: UILabel!
    
    @IBOutlet weak var lblBidId: UILabel!
    
    @IBOutlet weak var lblPaymentTerm: UILabel!
    
    @IBOutlet weak var indicatorImageView: UIImageView!
    
    @IBOutlet weak var lblOffererName: UILabel!
    
    @IBOutlet weak var lblOffererRating: UILabel!
    
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var lblShipmentDate: UILabel!
    
    @IBOutlet weak var lblCancelledBid: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

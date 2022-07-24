//
//  PublishedPriceTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 28/03/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class PublishedPriceTableViewCell: UITableViewCell {

    @IBOutlet weak var lblBidId: UILabel!
    
    @IBOutlet weak var lblExpiry: UILabel!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblQuality: UILabel!
    
    @IBOutlet weak var lblCropYear: UILabel!
    
    @IBOutlet weak var lblPublishedPrice: UILabel!
    
    @IBOutlet weak var lblTerm: UILabel!
    
    @IBOutlet weak var lblOffererName: UILabel!
    
    @IBOutlet weak var lblOffererRating: UILabel!
    
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var lblShipmentDate: UILabel!
    
    @IBOutlet weak var lblPaymentTerm: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

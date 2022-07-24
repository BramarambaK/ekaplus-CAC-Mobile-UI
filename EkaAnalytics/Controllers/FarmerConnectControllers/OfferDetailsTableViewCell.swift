//
//  OfferDetailsTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 25/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

class OfferDetailsTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lblOfferType: UILabel!
    
    @IBOutlet weak var lblOfferRefNumber: UILabel!
    
    @IBOutlet weak var lblProduct: UILabel!
    
    @IBOutlet weak var lblQuality: UILabel!
    
    @IBOutlet weak var lblCropYear: UILabel!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblPublishedPrice: UILabel!
    
    @IBOutlet weak var lblExpiryDate: UILabel!
    
    @IBOutlet weak var lblIncoTerm: UILabel!
    
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var lblDeliveryPeriod: UILabel!
    @IBOutlet weak var lblPaymentTerm: UILabel!
    @IBOutlet weak var lblPackingType: UILabel!
    @IBOutlet weak var lblPackingSize: UILabel!
    @IBOutlet weak var lv_AdvanceHeight: NSLayoutConstraint!
    

    //MARK: - View

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

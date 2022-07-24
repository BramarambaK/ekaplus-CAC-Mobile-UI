//
//  AgentBidDetailsTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 25/06/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class AgentBidDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblProduct: UILabel!
    
    @IBOutlet weak var lblQuality: UILabel!
    
    @IBOutlet weak var lblTerm: UILabel!
    
    @IBOutlet weak var lblCropYear: UILabel!
    
    @IBOutlet weak var lblLocation: UILabel!
    
    @IBOutlet weak var lblBidId: UILabel!
    
    @IBOutlet weak var lblOfferType: UILabel!
    
    @IBOutlet weak var lblRefId: UILabel!
    
    @IBOutlet weak var lblFarmerName: UILabel!
    
    @IBOutlet weak var lblFarmerID: UILabel!
    
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var lblShipmentDate: UILabel!
    
    @IBOutlet weak var lblOfferName: UILabel!
    
    @IBOutlet weak var lblOfferRating: UILabel!
    
    @IBOutlet weak var lblOfferMobileNo: UILabel!
    
    @IBOutlet weak var lblYourSellerRating: UILabel!
    
    @IBOutlet weak var lblYourSellerRating1: UILabel!
    
    @IBOutlet weak var yourRatingHeight: NSLayoutConstraint!
    
    @IBOutlet weak var yourRatingHeight1: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

//
//  FarmerNameTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 25/06/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class FarmerNameTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "FarmerNameCell"
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lblFarmerName: UILabel!
    
    @IBOutlet weak var limg_Selection: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

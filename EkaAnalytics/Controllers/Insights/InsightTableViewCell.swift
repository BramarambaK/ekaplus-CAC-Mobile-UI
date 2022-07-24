//
//  InsightTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 30/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class InsightTableViewCell: UITableViewCell {
    
    @IBOutlet weak var insightImageView: UIImageView!
    
    @IBOutlet weak var lblInsightName: UILabel!
    
    @IBOutlet weak var btnFavourite: UIButton!
    
    static let reuseIdentifier = "insightCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  MainFilterTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class MainFilterTableViewCell: UITableViewCell {
    
    static let identifier = "MainFilterTableViewCell"
    
    @IBOutlet weak var lblTitle: UILabel!
    
    
    
    @IBOutlet weak var imgCheckMark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

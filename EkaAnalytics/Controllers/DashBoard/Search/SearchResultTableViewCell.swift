//
//  SearchResultTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 19/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultTableViewCell"
    
    @IBOutlet weak var imgIcon: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblEntityTypeFlag: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

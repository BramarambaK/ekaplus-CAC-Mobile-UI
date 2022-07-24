//
//  DetailTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 22/11/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    static var reuseIdentifier = "DetailTableViewCell"
    
    //MARK: - IBOutlet
    @IBOutlet weak var lbl_Columnlabel: UILabel!
    @IBOutlet weak var lbl_ColumnValue: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

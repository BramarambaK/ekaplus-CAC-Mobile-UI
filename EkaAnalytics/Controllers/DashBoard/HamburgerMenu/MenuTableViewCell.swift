//
//  MenuTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 21/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    static var reuseIdentifier = "MenuTableViewCell"

    //MARK: - IBOutlet
    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var lv_Separator: UIView!
    @IBOutlet weak var lv_notification: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

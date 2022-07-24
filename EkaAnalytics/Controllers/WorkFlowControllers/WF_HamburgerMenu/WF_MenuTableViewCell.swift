//
//  MenuTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 04/03/21.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

final class WF_MenuTableViewCell: UITableViewCell {
    
    static var reuseIdentifier = "WF_MenuTableViewCell"

    //MARK: - IBOutlet
    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var lv_Separator: UIView!
    @IBOutlet weak var lv_notification: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

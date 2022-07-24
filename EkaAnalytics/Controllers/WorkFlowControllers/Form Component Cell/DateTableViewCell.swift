//
//  DateTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 16/07/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

final class DateTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lbl_KeyLabel: UILabel!
    @IBOutlet weak var ltxf_DataText: UITextField!
    @IBOutlet weak var img_NLP: UIImageView!
    @IBOutlet weak var imgViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var lv_BackgroundView: UIView!
    @IBOutlet weak var lv_separator: UIView!
    @IBOutlet weak var lbl_Error: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

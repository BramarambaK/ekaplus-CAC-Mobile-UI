//
//  TextTableViewCell.swift
//  Dynamic App
//
//  Created by Shreeram on 01/04/19.
//  Copyright © 2019 GWL. All rights reserved.
//

import UIKit

final class TextTableViewCell: UITableViewCell {
    
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

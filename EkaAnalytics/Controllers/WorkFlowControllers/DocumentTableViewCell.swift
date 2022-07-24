//
//  DocumentTableViewCell.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 05/08/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lbl_row0: UILabel!
    @IBOutlet weak var lbl_row1: UILabel!
    @IBOutlet weak var lbl_row2: UILabel!
    @IBOutlet weak var img_thumbnail: UIImageView!
    @IBOutlet weak var lbtn_btn1: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

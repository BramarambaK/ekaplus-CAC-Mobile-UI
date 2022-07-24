//
//  ListDataViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 08/05/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

class ListDataViewCell: UITableViewCell {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var rowWidth00: NSLayoutConstraint!
    @IBOutlet weak var rowWidth01: NSLayoutConstraint!
    @IBOutlet weak var rowWidth02: NSLayoutConstraint!
    @IBOutlet weak var rowWidth10: NSLayoutConstraint!
    @IBOutlet weak var rowWidth11: NSLayoutConstraint!
    @IBOutlet weak var rowWidth12: NSLayoutConstraint!
    @IBOutlet weak var rowWidth20: NSLayoutConstraint!
    @IBOutlet weak var rowWidth21: NSLayoutConstraint!
    @IBOutlet weak var rowWidth22: NSLayoutConstraint!
    @IBOutlet weak var rowSep10: NSLayoutConstraint!
    @IBOutlet weak var rowSep11: NSLayoutConstraint!
    @IBOutlet weak var rowSep20: NSLayoutConstraint!
    @IBOutlet weak var rowSep21: NSLayoutConstraint!
    @IBOutlet weak var rowSep00: NSLayoutConstraint!
    @IBOutlet weak var rowSep01: NSLayoutConstraint!
    
    @IBOutlet weak var img_row00: UIImageView!
    @IBOutlet weak var lbl_row01: UILabel!
    @IBOutlet weak var lbl_row02: UILabel!
    @IBOutlet weak var lbl_row10: UILabel!
    @IBOutlet weak var lbl_row11: UILabel!
    @IBOutlet weak var lbl_row12: UILabel!
    @IBOutlet weak var lbl_row20: UILabel!
    @IBOutlet weak var lbl_row21: UILabel!
    @IBOutlet weak var lbl_row22: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

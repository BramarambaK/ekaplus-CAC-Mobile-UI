//
//  ListTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 24/11/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
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
    
    static var reuseIdentifier = "ListTableViewCell"
    
}

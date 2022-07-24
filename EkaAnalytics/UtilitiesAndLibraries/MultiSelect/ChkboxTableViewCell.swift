//
//  ChkboxTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 10/03/22.
//  Copyright © 2022 Eka Software Solutions. All rights reserved.
//

import UIKit

final class ChkboxTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var btnCheckBox:UIButton!
    
    //MARK: -  Varibale
    
    static var reuseIdentifier = "ChkboxTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

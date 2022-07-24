//
//  SortNoneTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 11/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class SortNoneTableViewCell: UITableViewCell {
    
    static let identifier = "SortNoneTableViewCell"
    
    var row = 0

    weak var delegate:SortCellDelegate?
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnSortNone: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func sortNoneTapped(_ sender: UIButton) {
        sender.isSelected = true
        delegate?.didTapSortOption(.none, row: row)
    }
    

}

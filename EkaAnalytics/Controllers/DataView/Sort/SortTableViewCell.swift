//
//  SortTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 11/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class SortTableViewCell: UITableViewCell {
    
    static let identifier = "SortTableViewCell"
    
    var row = 0
    weak var delegate:SortCellDelegate?
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnSortDescending: UIButton!
    
    
    @IBOutlet weak var btnSortAscending: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func sortAscendingTapped(_ sender: UIButton) {
        sender.isSelected = true
        btnSortDescending.isSelected = false
        delegate?.didTapSortOption(.ascending, row: row)
    }
    
    @IBAction func sortDescendingTapped(_ sender: UIButton) {
        sender.isSelected = true
        btnSortAscending.isSelected = false
        delegate?.didTapSortOption(.descending, row: row)
    }
    

}

//
//  AppsListTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit


protocol FavouriteToggleDelegate:AnyObject{
    func toggleFavouriteAppAtIndex(_ index:Int, favourite:Bool)
}

class AppsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var appImageView: UIImageView!
    
    @IBOutlet weak var lblAppName: UILabel!
    
    @IBOutlet weak var btnFavourite: UIButton!
    
    
    weak var delegate:FavouriteToggleDelegate?
    var rowIndex:Int!
    
    static let reuseIdentifier = "AppsListTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func toggleFavourite(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        delegate?.toggleFavouriteAppAtIndex(rowIndex, favourite: sender.isSelected)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

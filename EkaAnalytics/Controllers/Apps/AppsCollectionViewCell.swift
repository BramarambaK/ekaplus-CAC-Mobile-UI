//
//  AppsCollectionViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 23/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class AppsCollectionViewCell: UICollectionViewCell {
    
    static var reuseIdentifier = "AppsCollectionViewCell"
    
    @IBOutlet weak var imgAppIcon: UIImageView!
    
    @IBOutlet weak var lblAppName: UILabel!
    
    @IBOutlet weak var lblAppCount: UILabel!
    
    @IBOutlet weak var lblFavouriteTypeTag: UILabel!
    
    @IBOutlet weak var lv_view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1.5
        self.layer.cornerRadius = 7
        self.layer.borderColor = Utility.cellBorderColor.cgColor
        self.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblAppCount.isHidden = true
        lblFavouriteTypeTag.isHidden = true
    }
    
}

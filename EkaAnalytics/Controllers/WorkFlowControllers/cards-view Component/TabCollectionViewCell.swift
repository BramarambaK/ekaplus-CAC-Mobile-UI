//
//  TabCollectionViewCell.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 15/03/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class TabCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TabCollectionViewCell"

    //MARK: - IBOutlet
    @IBOutlet weak var lbl_TabValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(ls_CardSelectedTab:Int){
        if self.tag == ls_CardSelectedTab {
            lbl_TabValue.backgroundColor = UIColor(red: 45/255, green: 49/255, blue: 55/255, alpha: 1)
            lbl_TabValue.textColor = .white
        }else{
            lbl_TabValue.textColor = UIColor(red: 45/255, green: 49/255, blue: 55/255, alpha: 1)
            lbl_TabValue.backgroundColor = .white
        }
    }
}

//
//  CompositeTabCollectionViewCell.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 19/05/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class CompositeTabCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CompositeTabCollectionViewCell"
    
    //MARK: - IBOutlet
    @IBOutlet weak var lbl_TabValue: UILabel!
    @IBOutlet weak var lv_TabHighlight: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func config(ls_CardSelectedTab:Int){
        if self.tag == ls_CardSelectedTab {
            lbl_TabValue.textColor = UIColor(red: 15/255, green: 113/255, blue: 46/255, alpha: 1)
            lv_TabHighlight.backgroundColor = UIColor(red: 15/255, green: 113/255, blue: 46/255, alpha: 1)
        }else{
            lbl_TabValue.textColor = .black
            lbl_TabValue.backgroundColor = .white
            lv_TabHighlight.backgroundColor = .white
        }
    }
}




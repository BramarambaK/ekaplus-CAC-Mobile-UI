//
//  ComboSlicerCollectionViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 10/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class ComboSlicerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ComboSlicerCollectionViewCell"
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var borderView:UIView!
    
    @IBOutlet weak var seperatorView: UIView!
    
    
 
    
//    override func didMoveToSuperview() {
//        super.didMoveToSuperview()
//        borderView.addBorder(toSide: .Left, withColor: UIColor.lightGray.cgColor, andThickness: 1)
//        borderView.addBorder(toSide: .Right, withColor: UIColor.lightGray.cgColor, andThickness: 1)
//
//        borderView.addBorder(toSide: .Bottom, withColor: Utility.chartListSeperatorColor.cgColor, andThickness: 0.5)
//    }
    
    
}

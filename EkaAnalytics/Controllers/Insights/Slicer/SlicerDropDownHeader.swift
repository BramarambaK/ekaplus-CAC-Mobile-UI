//
//  SlicerDropDownHeader.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol CollapsibleCollectionHeaderDelegate {
    func toggleSection(_ header: SlicerDropDownHeader?, section: Int)
}

class SlicerDropDownHeader: UICollectionReusableView {
    
    @IBOutlet weak var lblSlicerTitle: UILabel!
    
    @IBOutlet weak var lblSelectedOption: EdgeInsetLabel!
    
    @IBOutlet weak var imgArrow: UIImageView!
    
    var delegate : CollapsibleCollectionHeaderDelegate?
    var section = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHeader(_:)))
        addGestureRecognizer(tap)
    }
    
    @objc func tapHeader(_ sender:UITapGestureRecognizer){
        delegate?.toggleSection(self, section: section)
    }
    
    func setCollapsed(_ collapsed:Bool){
        if collapsed {
            imgArrow.transform = CGAffineTransform.identity
        } else {
            imgArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
        
}

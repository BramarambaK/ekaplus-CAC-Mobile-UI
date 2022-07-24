//
//  TableDropdownHeaderView.swift
//  EkaAnalytics
//
//  Created by Nithin on 02/02/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit


protocol CollapsibleTableHeaderDelegate {
    func toggleSection(_ section: Int)
}

class TableDropdownHeaderView: UIView {

    @IBOutlet weak var imgArrow: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblSelectDropdown: EdgeInsetLabel!
    
    
    var delegate : CollapsibleTableHeaderDelegate?
    var section = 0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHeader(_:)))
        addGestureRecognizer(tap)
    }
    
    @objc func tapHeader(_ sender:UITapGestureRecognizer){
        delegate?.toggleSection(section)
    }
    
    func setCollapsed(_ collapsed:Bool){
        if collapsed {
            imgArrow.transform = CGAffineTransform.identity
        } else {
            imgArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
    
}

//
//  BidCounterTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 05/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol BidCounterCellDelegate:AnyObject{
    func counterToggled(_ selected:Bool)
}

class BidCounterTableViewCell : UITableViewCell {

    
    @IBOutlet weak var lblCounterPriceSuffix: UILabel!
    
    @IBOutlet weak var counterPriceBorderView: UIView!
    
    @IBOutlet weak var txfCounterPrice: UITextField!
    
    @IBOutlet weak var btnCounterCheck: UIButton!
    
    @IBOutlet weak var txvRemarks: UITextView!
    
    weak var delegate:BidCounterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txfCounterPrice.addDoneToolBarButton()
        txvRemarks.addDoneToolBarButton()
        toggleCounter(false)
    }
    
    @IBAction func counterTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        txfCounterPrice.text = nil
        delegate?.counterToggled(sender.isSelected)
        toggleCounter(sender.isSelected)
    }
    
    func toggleCounter(_ selected:Bool){
        if selected {
            counterPriceBorderView.layer.borderColor = UIColor.lightGray.cgColor
            txfCounterPrice.isEnabled = true
            lblCounterPriceSuffix.textColor = UIColor(red: 72/255, green: 72/255, blue: 72/255, alpha: 1)
        } else {
            counterPriceBorderView.layer.borderColor = Utility.cellBorderColor.cgColor
            txfCounterPrice.isEnabled = false
            lblCounterPriceSuffix.textColor = .lightGray
        }
    }
    
}

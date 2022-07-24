//
//  CheckboxView.swift
//  EkaAnalytics
//
//  Created by Shreeram on 27/09/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class CheckboxView: UIView {
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var checkBoxOutlet:UIButton!{
        didSet{
            checkBoxOutlet.setImage(UIImage(named:"unchecked"), for: .normal)
            checkBoxOutlet.setImage(UIImage(named:"checked"), for: .selected)
            checkBoxOutlet.setTitle("", for: .normal)
            checkBoxOutlet.setTitle("", for: .selected)
        }
    }
    
    @IBOutlet weak var lbl_chkValue: UILabel!
    
    var delegate:CheckboxTableViewCellDelegate?
    var ls_keyValue:String = ""
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: CheckboxView.self), owner: self, options: nil)?.first as! CheckboxView
        return view as! Self
    }
    
    func config(chkboxDetail:JSON){
        lbl_chkValue.text = chkboxDetail["key"].stringValue
        ls_keyValue = chkboxDetail["value"].stringValue
    }
    
    @IBAction func checkbox(_ sender: UIButton){
        sender.checkboxAnimation {
            self.delegate?.updateChkValue(MyPickerData: [self.ls_keyValue:sender.isSelected])
        }
    }
    
}


//
//  TagSlicerCollectionViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 09/03/22.
//  Copyright © 2022 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol TagSlicerDelegate{
    func tagPicker(sender: UITextField,delegate:MultiSelectDelegate,dropDownValue:[String],selectedValue:[Int])
    func updateTagSlicerValue(Id:String,selectedValue:[Int])
}

final class TagSlicerCollectionViewCell: UICollectionViewCell,UITextFieldDelegate,MultiSelectDelegate {
    
    static let identifier = "TagSlicerCollectionViewCell"
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lmg_Dropdrown: UIImageView!
    @IBOutlet weak var ltxf_Dropdown:UITextField?
    
    //MARK: - Varibale
    
    var delegate:TagSlicerDelegate?
    var slicerId:String?
    var larr_dropDownValue:[String]?
    var selectedValue:[Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(){
        self.updateUI(selectedValue: selectedValue)
    }
    
    func updateUI(selectedValue:[Int]){
        var dropdown = ""
        
        for each in selectedValue {
            dropdown = dropdown + "," + (self.larr_dropDownValue![each])
        }
        
        if dropdown.count > 0 {
            dropdown.removeFirst()
        }
        
        self.ltxf_Dropdown?.text = dropdown
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.tagPicker(sender: textField, delegate: self, dropDownValue: larr_dropDownValue ?? [], selectedValue: selectedValue)
    }
    
    //MARK: -  MultiSelectDelegate
    
    func multiSelectedValue(Values: [Int]) {
        self.ltxf_Dropdown?.resignFirstResponder()
        self.selectedValue = Values
        self.updateUI(selectedValue: Values)
        delegate?.updateTagSlicerValue(Id: slicerId!, selectedValue: Values)
    }
    
}

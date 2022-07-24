//
//  CheckboxTableViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 26/09/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol CheckboxTableViewCellDelegate {
    func updateChkValue(MyPickerData:JSON)
}

final class CheckboxTableViewCell: UITableViewCell, CheckboxTableViewCellDelegate {
    
    static var reuseIdentifier = "CheckboxTableViewCell"
    
    
    @IBOutlet weak var chkSlackView: UIStackView!
    
    var delegate:crudDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func config(objectMeta:JSON){
        let keyLabel = UILabel()
        keyLabel.numberOfLines = 0
        keyLabel.text = "\(objectMeta["\(objectMeta["labelKey"])"])"
        chkSlackView.addArrangedSubview(keyLabel)
        
        for i in 0..<(Array((objectMeta["propertyKey"].dictionaryValue).values))[0].count {
            
            let chkView = CheckboxView().loadNib()
            chkView.config(chkboxDetail: (Array((objectMeta["propertyKey"].dictionaryValue).values))[0][i])
            chkView.delegate = self
            chkSlackView.addArrangedSubview(chkView)
            
        }
        
    }
    
    func updateChkValue(MyPickerData: JSON) {
        delegate?.updatebodyJson!(bodyJson: ["\(((MyPickerData.dictionaryValue).keys).first!)":"\(((MyPickerData.dictionaryValue).values).first!)"])
    }
    
}

//
//  summaryCustomView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 26/02/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class summaryCustomView: UIView {
    
    //MARK: - IBOutlet
    @IBOutlet weak var lbl_Count: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: summaryCustomView.self), owner: self, options: nil)?.first as! summaryCustomView
        return view as! Self
    }
    
    func config(label:String?,count:String?){
        self.lbl_Count.text = count
        self.lbl_Description.text = label
    }
}

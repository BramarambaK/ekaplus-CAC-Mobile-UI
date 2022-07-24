//
//  flexibleMenuView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 25/03/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class flexibleMenuView: UIView {
    
    //MARK: - IBOutlet
    @IBOutlet weak var MenuLabel: UILabel!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: flexibleMenuView.self), owner: self, options: nil)?.first as! flexibleMenuView
        return view as! Self
    }
    
}

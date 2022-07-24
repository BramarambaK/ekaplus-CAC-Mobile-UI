//
//  cardComponentView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 18/03/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class cardComponentView: UIView {
    
    @IBOutlet weak var Headinglabel01: UILabel!
    @IBOutlet weak var Headinglabel02: UILabel!
    @IBOutlet weak var Headinglabel03: UILabel!
    
    @IBOutlet weak var Headinglabel10: UILabel!
    @IBOutlet weak var Headinglabel11: UILabel!
    @IBOutlet weak var Headinglabel12: UILabel!
    @IBOutlet weak var Headinglabel13: UILabel!
    @IBOutlet weak var Headinglabel14: UILabel!
    @IBOutlet weak var Headinglabel15: UILabel!
    @IBOutlet weak var Headinglabel16: UILabel!
    @IBOutlet weak var Headinglabel17: UILabel!
    
    @IBOutlet weak var Headinglabel21: UILabel!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: cardComponentView.self), owner: self, options: nil)?.first as! cardComponentView
        return view as! Self
    }
    
}

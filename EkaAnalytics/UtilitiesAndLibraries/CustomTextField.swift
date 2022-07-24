//
//  CustomTextField.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 03/11/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

//
//  DateRangeViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 08/03/22.
//  Copyright © 2022 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol DateRangeDelegate{
    func selectedPickerValue(textField:UITextField,selectedValue:String)
}

final class DateRangeViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lbl_Hrs: UILabel!
    @IBOutlet weak var lbl_Min: UILabel!
    @IBOutlet weak var lbl_Sec: UILabel!
    @IBOutlet weak var hrsStepper: UIStepper!
    @IBOutlet weak var minStepper: UIStepper!
    @IBOutlet weak var secStepper: UIStepper!
    @IBOutlet weak var DatePicker: UIDatePicker!
    
    //MARK: - Variable
    var delegate:DateRangeDelegate?
    var activeTextField:UITextField?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - @IBAction
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        var ls_Dateformat:String? = nil
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd-MM-YYYY"
        
        ls_Dateformat = "\(dateformatter.string(from: DatePicker.date)) \(lbl_Hrs.text!):\(lbl_Min.text!):\(lbl_Sec.text!)"
        
        delegate?.selectedPickerValue(textField: activeTextField!, selectedValue: ls_Dateformat ?? "")
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        switch sender.tag {
        case 0:
            lbl_Hrs.text = String(format: "%02d", Int(sender.value))
        case 1:
            lbl_Min.text = String(format: "%02d", Int(sender.value))
        case 2:
            lbl_Sec.text = String(format: "%02d", Int(sender.value))
        default:
            print("default")
        }
    }
}

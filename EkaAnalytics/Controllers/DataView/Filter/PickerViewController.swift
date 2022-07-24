//
//  PickerViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol PickerViewSelectionDelegate : AnyObject {
    func selectedPickerValue(_ value:String, filterIndex:Int)
}

class PickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var lblPickerTitle: UILabel!
    
    
    var pickerTilte:String?
    
    var dataSource = [String]()
    
    var filterIndex:Int!
    
    weak var delegate:PickerViewSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        self.view.addGestureRecognizer(tap)
        tap.delegate = self
        
        if let title = pickerTilte {
            lblPickerTitle.text = title
        }
    
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        UIView.animate(withDuration: 0.35) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        
        UIView.setAnimationCurve(.easeIn)
    }
    
    @objc
    func tapHandler(_ sender:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view! == self.view
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func doneTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            let selectedValue = self.dataSource[self.pickerView.selectedRow(inComponent: 0)]
            self.delegate?.selectedPickerValue(selectedValue, filterIndex:self.filterIndex)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataSource[row]
    }
    
    
}

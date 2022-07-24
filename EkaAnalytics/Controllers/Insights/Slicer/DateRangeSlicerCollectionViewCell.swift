//
//  DateRangeSlicerCollectionViewCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 03/03/22.
//  Copyright © 2022 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol DateRangeSlicerDelegate{
    func dateRangePicker(sender: UITextField,delegate:DateRangeDelegate)
    func updateDateSlicerValue(Id:String,selectedValue:[String])
}

final class DateRangeSlicerCollectionViewCell: UICollectionViewCell,UITextFieldDelegate {
    
    static let identifier = "DateRangeSlicerCollectionViewCell"
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var ltxf_dropdown:UITextField!
    @IBOutlet weak var ltxf_ToDate:UITextField!
    @IBOutlet weak var ltxf_FromDate:UITextField!
    @IBOutlet weak var lbl_ToDate:UILabel!
    @IBOutlet weak var lbl_FromDate:UILabel!
    
    //MARK: - Varibale
    var slicerId:String?
    var selectedValue:[String] = []
    var delegate:DateRangeSlicerDelegate?
    var dropdownValue:[JSON] = []
    let dataPicker = UIPickerView()
    var activeTextfield : UITextField?
    
    
    func config(){
        ConnectManager.shared.getListOfDateOptions(completionhandler: { response in
            switch response {
            case .success(let json):
                self.dropdownValue = json.arrayValue
                switch self.selectedValue.count {
                case 2:
                    if let dropDownFilter = self.dropdownValue.filter({$0["id"].stringValue == "738"}).first {
                        self.ltxf_dropdown.text = dropDownFilter["name"].stringValue
                    }
                    self.ltxf_ToDate.text = self.selectedValue[0]
                    self.ltxf_FromDate.text = self.selectedValue[1]
                    self.togglefields(status: true)
                case 1:
                    self.ltxf_dropdown.text = self.selectedValue[0]
                default:
                    break
                }
                print(json)
            case .failure(let error):
                self.dropdownValue = []
                print(error)
            case .failureJson(let errJson):
                self.dropdownValue = []
                print(errJson)
            }
        })
        
        self.togglefields(status: false)
        
        
        
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField{
        case ltxf_ToDate,ltxf_FromDate:
            delegate?.dateRangePicker(sender: textField, delegate: self)
        case ltxf_dropdown:
            activeTextfield = textField
            let toolbarDone = UIToolbar.init()
            toolbarDone.sizeToFit()
            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                                  target: self, action: #selector(doneButtonAction))
            let barBtnCancel = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel,
                                                    target: self, action:#selector(cancelButtonAction))
            toolbarDone.items = [barBtnCancel,spaceButton,barBtnDone] // You can even add cancel button too
            
            dataPicker.delegate = self
            textField.inputView = dataPicker
            
            switch selectedValue.count {
            case 2:
                let Index = dropdownValue.firstIndex(of: dropdownValue.filter({$0["id"].stringValue == "738"}).first!)!
                dataPicker.selectRow(Index, inComponent: 0, animated: true)
            case 1:
                let Index = dropdownValue.firstIndex(of: dropdownValue.filter({$0["name"].stringValue == selectedValue[0]}).first!)!
                dataPicker.selectRow(Index, inComponent: 0, animated: true)
            default:
                break
            }
            
            textField.inputAccessoryView = toolbarDone
            if textField.text!.isEmpty {
                textField.text! = dropdownValue[0].dictionaryValue["name"]?.string ?? ""
                selectedValue.append(textField.text!)
            }
            
        default:
            break
        }
    }
    
    @objc func doneButtonAction()
    {
        self.ltxf_dropdown.resignFirstResponder()
        if self.ltxf_ToDate.isUserInteractionEnabled == true {
            self.selectedValue.removeAll()
            self.selectedValue.append(ltxf_ToDate.text!)
            self.selectedValue.append(ltxf_FromDate.text!)
        }
        delegate?.updateDateSlicerValue(Id: slicerId!, selectedValue: selectedValue)
    }
    
    @objc func cancelButtonAction()
    {
        self.ltxf_dropdown.resignFirstResponder()
    }
    
    private func togglefields(status:Bool){
        switch status {
        case true:
            self.ltxf_ToDate.isUserInteractionEnabled = true
            self.ltxf_FromDate.isUserInteractionEnabled = true
            self.ltxf_FromDate.textColor = .black
            self.ltxf_ToDate.textColor = .black
            self.lbl_ToDate.textColor = .black
            self.lbl_FromDate.textColor = .black
            
        case false:
            self.ltxf_ToDate.isUserInteractionEnabled = false
            self.ltxf_FromDate.isUserInteractionEnabled = false
            self.ltxf_FromDate.textColor = .lightGray
            self.ltxf_ToDate.textColor = .lightGray
            self.lbl_ToDate.textColor = .lightGray
            self.lbl_FromDate.textColor = .lightGray
        }
    }
}

//MARK: - Picker Delegate

extension DateRangeSlicerCollectionViewCell:UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dropdownValue.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dropdownValue[row].dictionaryValue["name"]?.stringValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activeTextfield?.text = dropdownValue[row].dictionaryValue["name"]?.stringValue
        switch dropdownValue[row].dictionaryValue["id"]?.stringValue {
        case "738":
            self.togglefields(status: true)
            self.selectedValue.removeAll()
            self.selectedValue.append(ltxf_ToDate.text!)
            self.selectedValue.append(ltxf_FromDate.text!)
        default:
            self.togglefields(status: false)
            self.selectedValue.removeAll()
            self.selectedValue.append(activeTextfield?.text ?? "")
        }
    }
    
}

//MARK: - DateRange Slicer

extension DateRangeSlicerCollectionViewCell:DateRangeDelegate {
    func selectedPickerValue(textField: UITextField, selectedValue: String) {
        textField.text = selectedValue
        if self.ltxf_ToDate.isUserInteractionEnabled == true {
            self.selectedValue.removeAll()
            self.selectedValue.append(ltxf_ToDate.text!)
            self.selectedValue.append(ltxf_FromDate.text!)
        }
        delegate?.updateDateSlicerValue(Id: slicerId!, selectedValue: self.selectedValue)
    }
}

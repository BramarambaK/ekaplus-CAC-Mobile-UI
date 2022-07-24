//
//  WF_MainFilterViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 19/03/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol WF_MainFilterScreenDelegate:AnyObject{
    func selectedFilters(_ filter:[Any])
}

class WF_MainFilterViewController: GAITrackedViewController, HUDRenderer {
    
    //MARK: - Variable
    var ls_appName:String = ""
    var larr_FilterList = [JSON]()
    var FilterValues = [JSON]()
    var filtersSelected = [String:[String]]()
    var layoutJson:JSON?
    var ls_taskName:String?
    let dataPicker = UIPickerView()
    weak var delegate:WF_MainFilterScreenDelegate?
    var myPickerData:[JSON] = []
    var activeTextfield : UITextField?
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView:UITableView!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.listOfFilters
        
        tableView.tableFooterView = UIView()
        setTitle(NSLocalizedString("Filters", comment: ""), color: .black, backbuttonTint: Utility.appThemeColor)
        getFilterDropDowndata()
        tableView.reloadData()
    }
    
    @IBAction func removeAllTapped(_ sender: UIButton?) {
        self.showAlert(title: NSLocalizedString("Confirmation", comment: "Confirmation"), message: NSLocalizedString("Do you want to Reset filter?", comment: "Confirmation message"), okButtonText: NSLocalizedString("Ok", comment: "accept"), cancelButtonText: NSLocalizedString("Cancel", comment: "cancel")) { (accepted) in
            if accepted{
                self.filtersSelected.removeAll()
                let selectedFiltersArray = [JSON]()
                self.delegate?.selectedFilters(selectedFiltersArray)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func applyTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if filtersSelected.count > 0 {
            delegate?.selectedFilters([filtersSelected])
        }else{
            delegate?.selectedFilters([])
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension WF_MainFilterViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return larr_FilterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch layoutJson!["objectMeta"]["fields"][larr_FilterList[indexPath.row]["key"].stringValue]["type"] {
        case "String":
            let cell = tableView.dequeueReusableCell(withIdentifier: WF_FilterTableViewCell.identifier, for: indexPath) as! WF_FilterTableViewCell
            
            cell.lblTitle.text = getLableValue(field: larr_FilterList[indexPath.row])
            
            if filtersSelected[larr_FilterList[indexPath.row]["key"].stringValue] != nil {
                cell.ltxf_Condition.text = filtersSelected[larr_FilterList[indexPath.row]["key"].stringValue]![0]
            }
            
            cell.ltxf_Condition.tag = indexPath.row
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: WF_FilterTableViewCell.identifier, for: indexPath) as! WF_FilterTableViewCell
            
            cell.lblTitle.text = getLableValue(field: larr_FilterList[indexPath.row])
            
            if filtersSelected[larr_FilterList[indexPath.row]["key"].stringValue] != nil {
                cell.ltxf_Condition.text = filtersSelected[larr_FilterList[indexPath.row]["key"].stringValue]![0]
            }
            
            cell.ltxf_Condition.tag = indexPath.row
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
}

extension WF_MainFilterViewController:UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            self.filtersSelected[larr_FilterList[textField.tag]["key"].stringValue] = [textField.text!]
        }else if (self.filtersSelected[larr_FilterList[textField.tag]["key"].stringValue] != nil) {
            self.filtersSelected.removeValue(forKey: larr_FilterList[textField.tag]["key"].stringValue)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextfield = textField
        let toolbarDone = UIToolbar.init()
        toolbarDone.sizeToFit()
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtnDone = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done,
                                              target: self, action: #selector(doneButtonAction))
        
        toolbarDone.items = [spaceButton,barBtnDone] // You can even add cancel button too
        
        dataPicker.delegate = self
        textField.inputView = dataPicker
        textField.inputAccessoryView = toolbarDone
        
        myPickerData = self.FilterValues[0][self.larr_FilterList[textField.tag]["key"].stringValue].arrayValue
        
        if activeTextfield?.text! == "" {
            activeTextfield?.text! = myPickerData[0].stringValue
        }
        
        return true
        
    }
    
    @objc func doneButtonAction()
    {
        self.view.endEditing(true)
    }
    
    
}

extension WF_MainFilterViewController {
    
    func getLableValue(field:JSON)->String{
        
        if field["label"] != nil {
            return field["label"].stringValue
        }else{
            return layoutJson!["objectMeta"]["fields"][field["key"].stringValue][field["key"].stringValue].stringValue
        }
    }
    
    func getFilterDropDowndata() {
        
        var larr_filter:[String] = []
        
        for i in 0..<larr_FilterList.count {
            larr_filter.append(larr_FilterList[i]["key"].stringValue)
        }
        
        self.showActivityIndicator()
     
        var dataBodyDictionary:[String : Any] = [:]
        
        dataBodyDictionary = ["appId":"\(self.ls_appName)", "workFlowTask":"\(self.ls_taskName!)","distinctColumns":larr_filter,"operation":["distinctColumns"],"totalCount":10000,"deviceType":"mobile"] as [String : Any]
        
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) {  (dataResponse) in
            self.hideActivityIndicator()
            
            switch dataResponse {
            case .success(let dataJson):
                if  dataJson["totalCount"] == -1{
                    self.getFilterDropDowndata()
                    return
                }
                self.FilterValues = dataJson["data"].arrayValue
            case .failure(let error):
                print(error)
            case .failureJson(let errorJson):
                print(errorJson)
                
            }
        }
    }
}

//MARK: - Picker Delegate

extension WF_MainFilterViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return myPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var Data = ""
        Data = myPickerData[row].stringValue
        if (activeTextfield!.text! == Data) {
            pickerView.selectRow(row, inComponent: 0, animated: true)
        }
        return Data
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if myPickerData.count > 0 {
            activeTextfield?.text = "\(myPickerData[row])"
        }
        
    }
    
}

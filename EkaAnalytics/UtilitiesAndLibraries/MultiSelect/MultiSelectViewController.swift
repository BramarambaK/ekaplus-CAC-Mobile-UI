//
//  MultiSelectViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 10/03/22.
//  Copyright © 2022 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol MultiSelectDelegate{
    func multiSelectedValue(Values:[Int])
}

final class MultiSelectViewController: UIViewController {
    
    //MARK: - Variable
    var dropdownValue:[String] = []
    var selectedValue:[Int] = []
    let dataPicker = UIPickerView()
    var activeTextfield : UITextField?
    var delegate:MultiSelectDelegate?
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView:UITableView!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ChkboxTableViewCell", bundle: nil), forCellReuseIdentifier: ChkboxTableViewCell.reuseIdentifier)
    }
    
    
    //MARK: - IBAction
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        delegate?.multiSelectedValue(Values: self.selectedValue)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension MultiSelectViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropdownValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChkboxTableViewCell.reuseIdentifier, for: indexPath) as! ChkboxTableViewCell
        cell.lblTitle.text = dropdownValue[indexPath.row]
        cell.btnCheckBox.isSelected = selectedValue.contains(indexPath.row)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChkboxTableViewCell
        cell.btnCheckBox.isSelected = !cell.btnCheckBox.isSelected
        
        if cell.btnCheckBox.isSelected == true && !selectedValue.contains(indexPath.row) {
            selectedValue.append(indexPath.row)
        }else{
            if let index = selectedValue.firstIndex(of: indexPath.row) {
                selectedValue.remove(at: index)
            }
        }
    }
}

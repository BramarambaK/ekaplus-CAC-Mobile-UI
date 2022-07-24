//
//  FarmeUserProfileViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 18/05/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class FarmeUserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HUDRenderer {
    
    @IBOutlet weak var tableView:UITableView!
    
    var farmerProfile:FarmerUserProfile! {
        didSet{
            tableView.reloadData()
        }
    }
    
    lazy var apiController:UserProfileApiController = {
        return UserProfileApiController()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        
        
//        let profile = FarmerUserProfile(firstName: "Nithin", lastName: "Krishna", fullName: "Nithin Krishna", mobile: "9176657947", phone: "", website: "www.facebook.com", accountHolderName: "Nithin", bankAddress: "102, North street \n Bengaluru \n India", postalAddress: "102, North street \n Bengaluru \n India", currencyName: "INR", iban: "12345667", fax: "--", email: "nithin91491@gmail.com", username: "nithin91491", farmAddresses: ["102, North street \n Bengaluru \n India","102, North street \n Bengaluru \n India"])
//
//        farmerProfile = profile
        
        self.showActivityIndicator()
        apiController.getUserProfileDetails { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let profile):
                self.farmerProfile = profile
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(_):
                break
            }
        }
        
    }


    //MARK: - Tableview datasource and delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return farmerProfile == nil ? 0 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return farmerProfile.farmAddresses.count
        case 2: return 1
            
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailsCell" , for: indexPath) as! UserPersonalDetailsCell
            
            cell.lblName.text = farmerProfile.fullName
            cell.lblEmail.text = farmerProfile.email
            cell.lblMobile.text = farmerProfile.mobile
            cell.lblPhone.text = farmerProfile.phone
            cell.lblFax.text = farmerProfile.fax
            cell.lblWebsite.text = farmerProfile.website
            
            cell.selectionStyle = .none
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserAddressCell" , for: indexPath) as! UserAddressCell
            
            if indexPath.row == 0 {
                cell.lblAddressTypeHeader.text = NSLocalizedString("Postal Address", comment: "")
                cell.lblAddress.text = farmerProfile.postalAddress
            } else {
                cell.lblAddressTypeHeader.text = NSLocalizedString("Farm Address", comment: "") + "\(indexPath.row)"
                cell.lblAddress.text = farmerProfile.farmAddresses[indexPath.row - 1]
            }
            
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserBankDetailsCell" , for: indexPath) as! UserBankDetailsCell
            
            cell.lblAccountHoldersName.text = farmerProfile.accountHolderName
            cell.lblIBAN.text = farmerProfile.iban
            cell.lblCurrencyName.text = farmerProfile.currencyName
            cell.lblBankAddress.text = farmerProfile.bankAddress
            
            cell.selectionStyle = .none
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }


    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = EdgeInsetLabel()
        label.frame.size = CGSize(width: tableView.frame.size.width, height: 40)
        label.font = UIFont.systemFont(ofSize: 20)
        label.backgroundColor = .white
        label.leftTextInset = 25
        
        
        switch section {
        case 0: label.text = NSLocalizedString("Personal Details:", comment: "")
        case 1: label.text = NSLocalizedString("Addresses:", comment: "")
        case 2: label.text = NSLocalizedString("Bank Details:", comment: "")
            
        default: break
        }
        
        return label
    }
    
    @IBAction func dismiss(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }

}

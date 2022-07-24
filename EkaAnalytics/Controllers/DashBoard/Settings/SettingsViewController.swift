//
//  SettingsViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 02/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

enum SettingsMode {
    case Settings
    case AboutUs
}

final class SettingsViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate, HUDRenderer
{
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var sectionHeader:UIView!
    
    //MARK: - Variable
    
    var mode:SettingsMode  = .Settings
    
    
    var sections = [NSLocalizedString("Account", comment: "Account")]
    
    var dataSource = [[NSLocalizedString("Change Password", comment: "settings options"), NSLocalizedString("Logout", comment: "settings options")]]
    
    var aboutUs = ["Eka Analytics","What's New", "License","Privacy & Policy"]
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.settings
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
            self.navigationController!.navigationBar.standardAppearance = appearance;
            self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
        }else{
            self.navigationController?.navigationBar.barTintColor = UIColor.white
        }
        
        if mode == .Settings {
            setTitle(NSLocalizedString("Settings", comment: "settings title"), color: .black, backbuttonTint: Utility.appThemeColor)
        } else {
            setTitle("About Us", color: .black, backbuttonTint: Utility.appThemeColor)
        }
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSSOMobile.rawValue) && UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "azure"  {
            dataSource = [[NSLocalizedString("Logout", comment: "settings options")]]
        }else if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSSOMobile.rawValue) && UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "okta" {
            dataSource = [[NSLocalizedString("Logout", comment: "settings options")]]
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    func logout(){
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Logout", action: "Logout", label: "General", value: nil).build() as? [AnyHashable : Any])
        }
        
        showAlert(title: NSLocalizedString("Confirmation", comment: "confirmation"), message: NSLocalizedString("You won't be able to access any notification after logout", comment: "Logout confirmation"), okButtonText: NSLocalizedString("Logout", comment: "logout button title"), cancelButtonText: NSLocalizedString("Cancel", comment: "Cancel button title")) { (success) in
            if success { //Logout
                self.logOutApiHit()
            } else {
                //Cancel
            }
        }
        
    }
    
    
    func logOutApiHit(){
        AppUtility.lockOrientation(.portrait)
        
        self.showActivityIndicator()
        LoginApiController.logout({ (response) in
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.signOut.rawValue)
            self.hideActivityIndicator()
            switch response {
            case .success(_):
                self.dismiss(animated: true, completion: {
                    ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: true)
                })
                
            case .failure(let error):
                print(error)
                self.dismiss(animated: true, completion: {
                    ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: true)
                })
            case .failureJson(_):
                break
            }
        })
    }
    
    
    //Delegate method to log out after changing password
    func logTheUserOut() {
        logOutApiHit()
    }
    
    //MARK: - Tableview datasource and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return  1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mode == .Settings ? dataSource[section].count : aboutUs.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return mode == .Settings ? 60 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.sectionHeader
        if let label = header?.viewWithTag(1) as? UILabel {
            label.text = sections[section]
        }
        header?.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60)
        return mode == .Settings ? header : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell")  ?? UITableViewCell(style: .value1, reuseIdentifier: "SettingsCell")
        
        if mode == .Settings {
            let row = dataSource[indexPath.section][indexPath.row]
            cell.textLabel?.text = row
            
            //Logout is the last row, we use disclosure indicator for all rows except for the logout
            if indexPath.row != dataSource[indexPath.section].count - 1{
                cell.accessoryType = .disclosureIndicator
            }
            cell.backgroundColor = Utility.chartListSeperatorColor
            
        } else {
            
            let row = aboutUs[indexPath.row]
            cell.textLabel?.text = row
            
            if indexPath.row == 0 {
                cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
                cell.detailTextLabel?.text = "Version \(Bundle.main.releaseVersionNumber!)"
                cell.backgroundColor = .white
            } else {
                cell.accessoryType = .disclosureIndicator
                cell.backgroundColor = Utility.chartListSeperatorColor
            }
            
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mode == .Settings {
            
            switch indexPath.row {
                
            case 0:
                if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSSOMobile.rawValue) && UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "azure"  {
                    logout()
                }else if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSSOMobile.rawValue) && UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "okta" {
                    logout()
                }
                else{
                    let CurrentPwdVc = self.storyboard?.instantiateViewController(withIdentifier: "CurrentPwdViewController") as! CurrentPwdViewController
                    CurrentPwdVc.modalPresentationStyle = .overFullScreen
                    self.present(CurrentPwdVc, animated: true)
                }
                
            case 1: logout()
                
            default:
                return
                
            }
            
        }
    }
}

//
//  MenuViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 04/03/21.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import Intercom

protocol WF_HamburgerMenuDelegate : AnyObject {
    func WF_SelectedMenu(_ menu: String)
    func WF_ConnectselectedMenu(handler:String,queryparameter:String?)
}

final class WF_MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var ClientLogoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ClientLogo: UIView!
    
    @IBOutlet weak var img_ClientLogo: UIImageView!
    
    @IBOutlet weak var btnUserName: UIButton!
    
    @IBOutlet weak var btnUserInitial: UIButton!
    
    @IBOutlet weak var ekaLogo: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnSettings: UIButton!
    
    @IBOutlet var tableViewFooter: UIView!
    
    @IBOutlet weak var lbl_version: UILabel!
    @IBOutlet weak var lbl_copyRights: UILabel!
    
    //MARK: - Variable
    
    weak var delegate:WF_HamburgerMenuDelegate?
    
    var currentSelectedMenu:MenuList! = .Favourites //Default selected Menu upon app launch
    
    var menuState:MenuState = .close
    
    var larr_MenuDatasource:[[JSON]] = []
    
    var larr_ConnectedMenu:JSON?
    
    var bgView:UIView?
    
    var li_rowCount:Int = 0
    
    var ls_appName:String?
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: Date())
        
        self.tableView.register(UINib(nibName:"WF_TableViewHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier:"WF_TableViewHeaderView")
        
        //Default MenuList
        larr_MenuDatasource = [[["label":"Favourites"],["label":"Switch Corporate"],["label":"Apps"]]]
        
        if larr_ConnectedMenu!["navbar"][0]["apiMenuData"][0]["menu"] != nil{
            larr_MenuDatasource.append(larr_ConnectedMenu!["navbar"][0]["apiMenuData"][0]["menu"].arrayValue)
        }else{
            larr_MenuDatasource.append(larr_ConnectedMenu!["navbar"][0]["apiMenuData"][0]["menuItems"][0]["items"].arrayValue)
        }
        
        larr_MenuDatasource.append([[],["label":"About us"],["label":"Need Help?"]])
        
        self.lbl_version.text = "Version \(Bundle.main.releaseVersionNumber!)"
        self.lbl_copyRights.text = "© 2017-\(yearString) \(NSLocalizedString("Eka Software Solutions Pvt. Ltd. All rights reserved.", comment: ""))"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableViewFooter.sizeToFit()
        
        tableView.tableFooterView = tableViewFooter
        tableView.separatorStyle = .none
        
        //If current user is farmer, we add an underline to show its tappable, and it opens profile page of farmer
        if UserDefaults.standard.integer(forKey: UserDefaultsKeys.userType.rawValue) == 3{
            btnUserName.setAttributedTitle(NSAttributedString(string: UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue) ?? "User", attributes:[.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor:Utility.appThemeColor]), for: .normal)
            
            //Add target to open farmer profile
            btnUserName.addTarget(self, action: #selector(userProfileTapped(_:)), for: .touchUpInside)
            btnUserInitial.addTarget(self, action: #selector(userProfileTapped(_:)), for: .touchUpInside)
            
        } else {
            btnUserName.setTitle(UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue) ?? "User", for: .normal)
        }
        
        btnUserInitial.setTitle(UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)?.first?.description.capitalized ?? "U", for: .normal)
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let filename = paths[0].appendingPathComponent("ClientLogo.png")
        
        if UIImage(contentsOfFile: filename.path) != nil {
            
            if UIDevice.current.orientation.isLandscape {
                self.ClientLogoHeight.constant = 44
            } else {
                self.ClientLogoHeight.constant = 64
            }
            self.ekaLogo.isHidden = true
            self.ClientLogo.isHidden = false
            self.img_ClientLogo.image = UIImage(contentsOfFile: filename.path)
            
        } else {
            self.ekaLogo.isHidden = false
            self.ClientLogoHeight.constant = 0
            self.img_ClientLogo.image = nil
            
            self.ClientLogo.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUnreadCount),
                                               name: NSNotification.Name.IntercomUnreadConversationCountDidChange,
                                               object: nil)
        tableView.reloadData()
    }
    
    //Animation functions
    @objc func hamburgerClicked(_ sender: UIButton){
        
        guard let menuView = self.view else {return}
        
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "App Menu", label: "General", value: nil).build() as? [AnyHashable : Any])
        }
        
        //        menuView.layer.shadowColor = UIColor.black.cgColor
        //        menuView.layer.shadowOpacity = 0.6
        //        menuView.layer.shadowOffset = CGSize(width: 100, height: 20)
        //        menuView.layer.shadowRadius = 30
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window!
        
        let moveRight = CGAffineTransform(translationX: -window.frame.width*0.20, y: 0)
        let moveLeft = CGAffineTransform(translationX: -window.frame.width*1.35, y: 0)
        
        menuView.frame.size = UIScreen.main.bounds.size
        menuView.transform = moveLeft
        
        bgView = UIView()
        bgView!.backgroundColor = UIColor.black.withAlphaComponent(0)
        bgView!.frame.size = UIScreen.main.bounds.size
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissHamburgerMenu))
        bgView!.addGestureRecognizer(tap)
        
        window.addSubview(bgView!)
        window.addSubview(menuView)
        
        tableViewFooter.sizeToFit()
        
        UIView.animate(withDuration: 0.35, animations: {
            menuView.transform = moveRight
            self.bgView!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }, completion : { _ in
            self.menuState = .open
        })
    }
    
    @objc func dismissHamburgerMenu(){
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window!
        let moveLeft = CGAffineTransform(translationX: -window.frame.width*1.35, y: 0)
        UIView.animate(withDuration: 0.35, animations: {
            self.view.transform = moveLeft
            self.bgView!.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            self.view.removeFromSuperview()
            self.bgView?.removeFromSuperview()
            self.menuState = .close
        }
    }
    
    func willTransitionToSize(_ size:CGSize, coordinator:UIViewControllerTransitionCoordinator){
        let moveRight = CGAffineTransform(translationX: -size.width*0.20, y: 0)
        self.view.transform = moveRight
        coordinator.animate(alongsideTransition: { (_) in
            self.bgView?.frame.size = size
        }, completion: { _ in
            self.bgView?.frame = UIScreen.main.bounds
        })
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        delegate?.WF_SelectedMenu("Settings")
    }
    
    
    @objc func userProfileTapped(_ sender: UIButton) {
        delegate?.WF_SelectedMenu("UserProfile")
    }
    
    //MARK: - Tableview datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return larr_MenuDatasource.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != larr_MenuDatasource.count {
            li_rowCount += larr_MenuDatasource[section].count
            return larr_MenuDatasource[section].count
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
//        return 0
        switch section {
        case 0,larr_MenuDatasource.count-1 :
            return 0
        case larr_MenuDatasource.count:
            //In Landscape, return a max of 30
            //44 is the height of each row and 70 is the height of tableViewFooter in storyboard
            return max(30, tableView.frame.size.height - CGFloat(li_rowCount)*44 - 80)
            
        default:
            return 51
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == larr_MenuDatasource.count {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: max(30, tableView.frame.size.height - CGFloat(MenuList.count)*44 - 80)))
            header.backgroundColor = .clear//Utility.appThemeColor
            return header
        }else if section == larr_MenuDatasource.count-1 {
            return nil
        }
        else{
            
            guard let view = tableView.dequeueReusableHeaderFooterView(
                    withIdentifier: "WF_TableViewHeaderView")
                    as? WF_TableViewHeaderView
            else {
                return nil
            }
            
            view.backgroundColor = .white
            view.lbl_MenuTitle.text = larr_ConnectedMenu!["navbar"][0]["apiMenuData"][0]["label"].string ?? ls_appName
            return view
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:WF_MenuTableViewCell.reuseIdentifier, for: indexPath) as! WF_MenuTableViewCell
        
        cell.lblMenu.textColor = Utility.appThemeColor
        cell.lv_Separator.isHidden = true
        cell.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        
        switch indexPath.section {
        
        case 0,larr_MenuDatasource.count-1 :
            if larr_MenuDatasource[indexPath.section][indexPath.row]["label"].stringValue == "" {
                cell.lblMenu.text = ""
                cell.lv_Separator.isHidden = false
                cell.isUserInteractionEnabled = false
            }else{
                cell.lv_Separator.isHidden = true
                cell.isUserInteractionEnabled = true
                cell.lblMenu.text = larr_MenuDatasource[indexPath.section][indexPath.row]["label"].stringValue
            }
           
        default:
            cell.lblMenu.text = "    \(larr_MenuDatasource[indexPath.section][indexPath.row]["text"].stringValue)"
        }
        
        return cell
    }
    
    
    //MARK: - TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
            
        case 0,larr_MenuDatasource.count-1 :
            delegate?.WF_SelectedMenu("\(larr_MenuDatasource[indexPath.section][indexPath.row]["label"].stringValue)")
            
        default:
            delegate?.WF_ConnectselectedMenu(handler: "\(larr_MenuDatasource[indexPath.section][indexPath.row]["handler"])", queryparameter: nil)
        }
    }
    
    @objc func updateUnreadCount(){
        tableView.reloadData()
    }
}

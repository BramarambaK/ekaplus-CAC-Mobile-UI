//
//  MenuViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 21/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import Intercom

enum MenuList:Int {
    case Favourites = 0
    case SwitchCorp
    case Apps
    case Divider
    case AboutUs
    case NeedHelp
    
    case MenuCountPlaceholder
    
    case Settings //Settings and profile is a button outside tableview
    case UserProfile
    
    var text:String {
        switch self {
        case .Favourites:
            return NSLocalizedString("Favourites", comment: "Menu option")
        case .SwitchCorp:
            return NSLocalizedString("Switch Corporate", comment: "Menu option")
        case .Apps:
            return NSLocalizedString("Apps", comment: "Menu option")
        case .Divider:
            return NSLocalizedString("", comment: "Menu option")
        case .AboutUs:
            return NSLocalizedString("About us", comment: "Menu option")
        case .NeedHelp:
            return NSLocalizedString("Need Help?", comment: "Menu option")
            
        default:
            return ""
        }
    }
    
    static var count : Int {  return MenuList.MenuCountPlaceholder.rawValue }
}

enum MenuState{
    case open
    case close
}

protocol HamburgerMenuDelegate : AnyObject {
    func selectedMenu(_ menu: MenuList)
}

final class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
    
    weak var delegate:HamburgerMenuDelegate?
    
    var currentSelectedMenu:MenuList! = .Favourites //Default selected Menu upon app launch
    
    var menuState:MenuState = .close 
    
    var bgView:UIView?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: Date())
        
        self.lbl_version.text = "Version \(Bundle.main.releaseVersionNumber!)"
        self.lbl_copyRights.text = "© 2017-\(yearString) \(NSLocalizedString("Eka Software Solutions Pvt. Ltd. All rights reserved.", comment: ""))"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableViewFooter.sizeToFit()
        
        tableView.tableFooterView = tableViewFooter
        tableView.separatorStyle = .none
        
        //If current user is farmer, we add an underline to show its tappable, and it opens profile page of farmer
        if UserDefaults.standard.integer(forKey: UserDefaultsKeys.userType.rawValue) == 3{
            btnUserName.setAttributedTitle(NSAttributedString(string: UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue) ?? "User", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .foregroundColor:Utility.appThemeColor]), for: .normal)
            
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
        let selectedMenu:MenuList = .Settings
        delegate?.selectedMenu(selectedMenu)
    }
    
    
    @objc func userProfileTapped(_ sender: UIButton) {
        let selectedMenu:MenuList = .UserProfile
        delegate?.selectedMenu(selectedMenu)
    }
    
    //MARK: - Tableview datasource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? MenuList.count : 0
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            //In Landscape, return a max of 30
            //44 is the height of each row and 70 is the height of tableViewFooter in storyboard
            return max(30, tableView.frame.size.height - CGFloat(MenuList.count)*44 - 80)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: max(30, tableView.frame.size.height - CGFloat(MenuList.count)*44 - 80)))
            header.backgroundColor = .clear//Utility.appThemeColor
            return header
        }
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier:MenuTableViewCell.reuseIdentifier, for: indexPath) as! MenuTableViewCell
            
            guard let menuItem = MenuList(rawValue: indexPath.row) else  {
                fatalError("Unexpected menu item")
            }
            
            cell.lblMenu.text = menuItem.text
            cell.selectionStyle = .none
            
            if indexPath.row == currentSelectedMenu.rawValue{
                cell.backgroundColor = Utility.appThemeColor
                cell.lblMenu.textColor = .white
            } else {
                cell.backgroundColor = .white
                cell.lblMenu.textColor = Utility.appThemeColor
            }
            
            if menuItem.text == ""  {
                cell.lv_Separator.isHidden = false
                cell.isUserInteractionEnabled = false
            }else{
                cell.lv_Separator.isHidden = true
                cell.isUserInteractionEnabled = true
            }
            
            if menuItem == .NeedHelp {
                let unreadMessageCount = Intercom.unreadConversationCount()
                if unreadMessageCount > 0 {
                    cell.lv_notification.isHidden = false
                }else{
                    cell.lv_notification.isHidden = true
                }
            }
            
            return cell
            
        case 1:
            break
            
        default: return UITableViewCell()
            
        }
        
        return UITableViewCell()
    }
    
    
    //MARK: - TableView delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedMenu = MenuList(rawValue: indexPath.row) else{
            return
        }
        
        if selectedMenu == .Apps || selectedMenu == .Favourites {
            self.currentSelectedMenu = selectedMenu
        }
        
        tableView.reloadData()
        delegate?.selectedMenu(selectedMenu)
    }
    
    @objc func updateUnreadCount(){
      tableView.reloadData()
    }
}

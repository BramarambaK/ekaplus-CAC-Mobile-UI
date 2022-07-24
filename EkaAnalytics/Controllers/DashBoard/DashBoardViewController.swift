//
//  DashBoardViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 20/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import Intercom

final class DashBoardViewController: UIViewController, HamburgerMenuDelegate, HUDRenderer {
    
    //MARK: - Variable
    
    var searchController:UISearchController!
    var menuVC:MenuViewController!
    
    var appCategoryVC:AppsCategoryViewController{
        return self.children.first as! AppsCategoryViewController
    }
    
    lazy var apiController:PermCodeAPIController = {
        return PermCodeAPIController()
    }()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        SecurityUtilities().ExitOnJailbreak()
        
        menuVC =  UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        menuVC.delegate = self
        
        appCategoryVC.delegate = self
        getFavourites { (result) in
            self.appCategoryVC.isShowingFavourites = result
            if result == true{
                self.menuVC.currentSelectedMenu = .Favourites
                self.setNavigationBarWithSideMenu(NSLocalizedString("Favourites", comment: ""))
            }else{
                self.menuVC.currentSelectedMenu = .Apps
                self.setNavigationBarWithSideMenu(NSLocalizedString("Apps", comment: ""))
            }
        }
        
        //To Open Chat view based on permission code.
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.supportChatView.rawValue){
            let swipeRight = UISwipeGestureRecognizer(target: self, action:  #selector(respondToSwipeGesture(_:)))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.left
            self.appCategoryVC.view.addGestureRecognizer(swipeRight)
        }
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            let app = UINavigationBarAppearance()
            app.configureWithOpaqueBackground()
            app.backgroundColor = Utility.appThemeColor
            self.navigationController?.navigationBar.standardAppearance = app
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        }else{
            self.navigationController?.navigationBar.barTintColor = Utility.appThemeColor
        }
        
        setRightBarButtons()
        
        NotificationAPIController.shared.getNotifications ({ (response) in
            switch response {
            case .success(let notifications):
                DataCacheManager.shared.notifications = notifications
                
            case .failure(_):
                break
            case .failureJson(_):
                break
            }
        }){ unseenCount in
            
            if let bellButton = self.navigationItem.rightBarButtonItems!.filter({$0.tag == 5656}).first , let count = unseenCount{
                bellButton.badgeString = count > 0 ? count.description : nil
                
            }
        }
        
        AppUtility.lockOrientation(.all) //Once user lands in dashboard after logging in, app should support both portrait and landscape orientations.
        
        //        DataCacheManager.shared.getFarmerConnectFilter()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //Due to status bar visible and invisible.Customer logo View in Hamberger menu will be changed based on screen orientation.
        //        if UIDevice.current.orientation.isLandscape {
        //            menuVC.ClientLogoHeight.constant = 44
        //        } else {
        //            menuVC.ClientLogoHeight.constant = 64
        //        }
        super.viewWillTransition(to: size, with: coordinator)
        menuVC.willTransitionToSize(size, coordinator:coordinator)
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.navigationController?.navigationBar.barTintColor =  Utility.appThemeColor
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setRightBarButtons(){
        
        let notification = UIBarButtonItem.init(badge: "", image: #imageLiteral(resourceName: "Notification"), target: self, action: #selector(didClickNotificationButton(_:)))
        notification.tag = 5656
        notification.badgeString = nil
        
        let search = UIBarButtonItem(image: #imageLiteral(resourceName: "Search"), style: .plain, target: self, action: #selector(didClickSearchButton(_:)))
        notification.tintColor = .white
        search.tintColor = .white
        
        let chat = UIBarButtonItem(image: #imageLiteral(resourceName: "Messenger"), style: .plain, target: self, action: #selector(didChatButton(_:)))
        chat.tintColor = .white
        
        //Space has been added to provide space between the Bar Button
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 18
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.messengerView.rawValue){
            self.navigationItem.rightBarButtonItems = [search,space,notification,space,chat]
        }
        else{
            self.navigationItem.rightBarButtonItems = [search,space,notification]
        }
        
    }
    
    
    @objc
    func didClickNotificationButton(_ sender:UIBarButtonItem){
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "Notifications", label: "Notifications", value: nil).build() as? [AnyHashable : Any])
        }
        
        let notificationNavVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationListNav") as! UINavigationController
        notificationNavVC.modalPresentationStyle = .fullScreen
        self.present(notificationNavVC, animated: true, completion: nil)
    }
    
    @objc
    func didClickSearchButton(_ sender:UIBarButtonItem){
        
        self.performSegue(withIdentifier: "searchSegue", sender: self)
    }
    
    func setNavigationBarWithSideMenu(_ titleText : String)
    {
        self.navigationController?.isNavigationBarHidden = false
        
        let sideMenuBtn = UIButton(type: UIButton.ButtonType.system)
        sideMenuBtn.tintColor = .white
        sideMenuBtn.setImage(UIImage.init(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        sideMenuBtn.frame = CGRect(x: 0, y: 0, width: 45, height: 45)
        sideMenuBtn.addTarget(menuVC, action: #selector(menuVC.hamburgerClicked(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: sideMenuBtn)
        self.navigationItem.leftBarButtonItems = [customBarItem]
        setTitle(titleText)
    }
    
    @objc func didChatButton(_ sender:UIBarButtonItem){
        
        self.showActivityIndicator()
        apiController.getPermCode(appId: "-1") { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let permCodes):
                if permCodes.contains("MESSENGER_VIEW"){
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.messengerView.rawValue)
                    let MessengerVC = self.storyboard?.instantiateViewController(withIdentifier:"MessengerViewController") as! MessengerViewController
                    // View need to be pushed because chat has to access gallery and camera.
                    self.navigationController?.pushViewController(MessengerVC, animated: true)
                }else{
                    self.showAlert(message: NSLocalizedString("Permission has been revoked. Please contact admin.", comment: ""))
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.messengerView.rawValue)
                }
                
            case .failure(let error):
                print(error.description)
                
            case .failureJson(_):
                break
                
            }
        }
    }
    
    
    //Delegate Method
    func selectedMenu(_ menu: MenuList) {
        
        menuVC.dismissHamburgerMenu()
        
        switch  menu {
        case .Favourites:
            appCategoryVC.isShowingFavourites = true
            
        case .Apps:
            appCategoryVC.isShowingFavourites = false
            
        case .SwitchCorp:
            let SwitchCorpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SwitchCorpViewController") as! SwitchCorpViewController
            SwitchCorpVC.modalPresentationStyle = .overCurrentContext
            self.present(SwitchCorpVC, animated: true, completion: nil)
            return
            
        case .Settings:
            let settingsNavVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationVC") as! UINavigationController
            let settingsVC = settingsNavVC.viewControllers[0] as! SettingsViewController
            settingsVC.mode = .Settings
            settingsNavVC.modalPresentationStyle = .fullScreen
            self.present(settingsNavVC, animated: true, completion: nil)
            return
            
        case .UserProfile:
            
            let farmerProfile = UIStoryboard.init(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "FarmeUserProfileViewController") as! FarmeUserProfileViewController
             farmerProfile.modalPresentationStyle = .fullScreen
            self.present(farmerProfile, animated: true, completion: nil)
            return
            
        case .AboutUs:
            
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "About us", label: "General", value: nil).build() as? [AnyHashable : Any])
            }
            
            let aboutUsVc = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
            aboutUsVc.modalPresentationStyle = .fullScreen
            self.present(aboutUsVc, animated: true, completion: nil)
            return
            
        case .NeedHelp:
            
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "Need help?", label: "General", value: nil).build() as? [AnyHashable : Any])
            }
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.supportChatView.rawValue){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    Intercom.presentMessenger()
                }
                return
            }
            else{
                let helpVC = self.storyboard?.instantiateViewController(withIdentifier:"HelpViewController") as! HelpViewController
                helpVC.modalPresentationStyle = .fullScreen
                self.present(helpVC, animated: true, completion: nil)
                return
            }
            
        default:
            break
        }
        
        setTitle(menu.text)
        
    }
    
    //MARK: - Local Function
    
    @objc func respondToSwipeGesture(_ sender:UISwipeGestureRecognizer?){
        Intercom.presentMessenger()
    }
    
    func getFavourites(completionhandler:@escaping(Bool)->()){
        self.showActivityIndicator()
        AppListAPIController.shared.getFavouriteApps { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let apps):
                if apps.count > 0 {
                    completionhandler(true)
                }else{
                    completionhandler(false)
                }
            case .failure( _):
                completionhandler(false)
            case .failureJson(_):
                break
            }
        }
    }
}

extension DashBoardViewController :AppsCategoryDelegate {
    func selectedMenu(menu: String) {
        switch menu {
        case "Favourites" :
            appCategoryVC.isShowingFavourites = true
            self.menuVC.currentSelectedMenu = .Favourites
            self.setNavigationBarWithSideMenu(NSLocalizedString("Favourites", comment: ""))
        case "Apps" :
            appCategoryVC.isShowingFavourites = false
            self.menuVC.currentSelectedMenu = .Apps
            self.setNavigationBarWithSideMenu(NSLocalizedString("Apps", comment: ""))
        case "Switch Corporate" :
            let SwitchCorpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SwitchCorpViewController") as! SwitchCorpViewController
            SwitchCorpVC.modalPresentationStyle = .overCurrentContext
            self.present(SwitchCorpVC, animated: true, completion: nil)
            return
        default:
            break
        }
        
        
    }
}

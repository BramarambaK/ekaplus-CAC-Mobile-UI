//
//  AppDelegate.swift
//  EkaAnalytics
//
//  Created by GoodWorkLabs Services Private Limited on 15/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import CoreData
import Intercom
import UserNotifications
import Firebase
import Bagel
import TrustKit
import MSAL
import FirebaseMessaging
import OktaOidc


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    
    var window: UIWindow?
    var oktaOidc: OktaOidc?
    var activityIndicatorView:UIView?
    var rootNavVC:UINavigationController!
    var orientationLock = UIInterfaceOrientationMask.portrait
    let notificationCenter = UNUserNotificationCenter.current()
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
#if DEBUG
        Bagel.start()
#endif
        
        sslPinningSetup()
        
        LoginApiController.getWebConfig()
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isFirstLaunchCompleted.rawValue){//This is not the first launch, so show login page if user didn't login previously
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            
            rootNavVC = storyBoard.instantiateViewController(withIdentifier: "RootNavigationController") as? UINavigationController
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isUserLoggedIn.rawValue) { //User has already logged in, so take him to dashboard directly
                
                //load previously used baseURL from userdefaults
                baseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!
                
                let dashboard = storyBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                rootNavVC.pushViewController(dashboard, animated: false)
            }else if UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) == nil {
                let domainVC = storyBoard.instantiateViewController(withIdentifier: "DomainViewController") as! DomainViewController
                rootNavVC.pushViewController(domainVC, animated: false)
            }else{
                let LoginVC = storyBoard.instantiateViewController(withIdentifier: "LoginOptionViewController") as! LoginOptionViewController
                rootNavVC.pushViewController(LoginVC, animated: false)
            }
            
            window?.rootViewController = rootNavVC
            window?.makeKeyAndVisible()
            
        } else { // This is the first launch, so leave it as it is and just set the flag to true
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isFirstLaunchCompleted.rawValue)
        }
        
        HIChartView.preload()
//        print(Obfuscator().reveal(key: ObfuscatedConstants.GoogleAnalytickey))
        
        //Google Analytics config
        if let gai = GAI.sharedInstance() {
            gai.tracker(withTrackingId: Obfuscator().reveal(key: ObfuscatedConstants.GoogleAnalytickey))
            gai.logger.logLevel = .error
            gai.trackUncaughtExceptions = false
            gai.dispatchInterval = 5
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isUserLoggedIn.rawValue){
                guard let userName = UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue), let clientName = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) else {return true}
                gai.defaultTracker.send(GAIDictionaryBuilder.createScreenView().set(clientName, forKey: GAIFields.customDimension(for: 1)).build() as? [AnyHashable : Any])
                
                gai.defaultTracker.send(GAIDictionaryBuilder.createScreenView().set(userName, forKey: GAIFields.customDimension(for: 2)).build() as? [AnyHashable : Any])
            }
            
        } else {
            assertionFailure("Google Analytics not configured correctly")
        }
        
        Intercom.setApiKey(Obfuscator().reveal(key: ObfuscatedConstants.IntercomApiKey), forAppId:Obfuscator().reveal(key: ObfuscatedConstants.IntercomAppId))
        
#if QA
#else
#if DEBUG
#else
        needsUpdate()
#endif
#endif
        self.configureRemoteNotification()
        
        //Configure Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        return true
    }
    
    
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        window!.isHidden = true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        window!.isHidden = false
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if  SecurityUtilities().isJailbroken() ==  true {
            //Display an alert for the failure
            let alert = UIAlertController(title: nil, message:"Security Error (000). Contact System Administrator", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            DispatchQueue.main.async {
                // show the alert
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }else{
            SettingsBundleHelper().configureDefaultSettingsBundle()
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataStack.sharedInstance.saveContext()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return MSALPublicClientApplication.handleMSALResponse(url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String)
    }
    
    //MARK: - Local Function
    
    private func needsUpdate() -> Bool {
        let infoDictionary = Bundle.main.infoDictionary
        let appID = infoDictionary!["CFBundleIdentifier"] as! String
        let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")
        let data = try? Data(contentsOf: url!)
        
        if data == nil {
            return false
        }
        else{
            let lookup = (try? JSONSerialization.jsonObject(with: data! , options: [])) as? [String: Any]
            if let resultCount = lookup!["resultCount"] as? Int, resultCount == 1 {
                if let results = lookup!["results"] as? [[String:Any]] {
                    if let appStoreVersion = results[0]["version"] as? String{
                        let currentVersion = infoDictionary!["CFBundleShortVersionString"] as! String
                        if !(appStoreVersion == currentVersion) {
                            
                            let alert = UIAlertController(title: "New Version Available", message: "There is a newer version available for download! Please update the app by visiting the App Store.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Update", style: UIAlertAction.Style.default, handler: { alertAction in
                                UIApplication.shared.open(NSURL(string : "itms-apps://itunes.apple.com/us/app/eka/id1326137979?ls=1&mt=8")! as URL)
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                            
                            print("Need to update [\(appStoreVersion) != \(String(describing: currentVersion))]")
                            return true
                        }
                    }
                }
            }
            return false
        }
    }
    
    // Push Notification Configuration
    func configureRemoteNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        UNUserNotificationCenter.current().delegate = self
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken!)")
        
        UserDefaults.standard.set(fcmToken, forKey: UserDefaultsKeys.Firebasetoken.rawValue)
        
        let dataDict:[String: String] = ["token": fcmToken!]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isUserLoggedIn.rawValue){
            LoginApiController().RegisterFirebaseToken(token: fcmToken!)
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Intercom.setDeviceToken(deviceToken)
        
        Messaging.messaging().apnsToken = deviceToken
        
        // 1. Convert device token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        // 2. Print device token to use for PNs payloads
        print("APNs device token: \(deviceTokenString)")
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("APNs registration failed: \(error)")
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        updateBadgeCount(IsRead: false)
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch  response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss")
        default:
            print("Default")
        }
        
        let notificationIdentifier = response.notification.request.identifier
        
        if notificationIdentifier.uppercased() == "Local Notification".uppercased() {
            print("Local Notification.")
        }else{
            let userInfo = response.notification.request.content.userInfo
            
            let targetUrl = "\(userInfo["target"]!)".components(separatedBy: "/")
            
            let state : UIApplication.State = UIApplication.shared.applicationState
            switch state {
            case UIApplication.State.active:
                updateBadgeCount(IsRead: true)
                print("If needed notify user about the message")
            default:
                updateBadgeCount(IsRead: false)
                print("Run code to download content")
            }
            
            rootNavVC.dismiss(animated: false, completion: nil)
            
            let biddingVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "BiddingViewController") as! BiddingViewController
            biddingVC.bidRefID = targetUrl[targetUrl.count-1]
            rootNavVC.pushViewController(biddingVC, animated: true)
            
            completionHandler()
        }
    }
    
    //Update the Notification Badge number.
    func updateBadgeCount(IsRead:Bool)
    {
        var badgeCount = UIApplication.shared.applicationIconBadgeNumber
        
        if IsRead == true{
            badgeCount = 0
            //            if badgeCount > 0 {
            //                badgeCount = badgeCount-1
            //            }else{
            //                badgeCount = 0
            //            }
        }else{
            badgeCount = 1
        }
        UIApplication.shared.applicationIconBadgeNumber = badgeCount
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification
                     userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let state = application.applicationState
        switch state {
            
        case .inactive:
            print("Inactive")
            
        case .background:
            self.updateBadgeCount(IsRead: false)
            
        case .active:
            print("Active")
            
        @unknown default:
            print("unknow feature")
        }
    }
    
    //Local Notification
    func ShowLocalNotification(title:String,body:String) {
        
        let content = UNMutableNotificationContent()
        let categoryIdentifire = "Local Notification category"
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        //        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        //Change the time interval to delat the notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        //Can add action for LOcal Notification
        //        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        //        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        //        let category = UNNotificationCategory(identifier: categoryIdentifire,
        //                                              actions: [snoozeAction, deleteAction],
        //                                              intentIdentifiers: [],
        //                                              options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifire, actions: [], intentIdentifiers: [], options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
    private func sslPinningSetup(){
        
        TrustKit.setLoggerBlock { (message) in
            //Print the Log of Trust Kit
            print("TrustKit log: \(message)")
            
            //Check for the Pinning Failure
            if message.contains("Pin validation failed") {
                //Display an alert for the failure
                let alert = UIAlertController(title: nil, message:"Security Error (001). Contact System Administrator", preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { alertAction in
                    //Hide the activity indicator if any
                    DispatchQueue.main.async {
                        let delegate = (UIApplication.shared.delegate as! AppDelegate)
                        if delegate.activityIndicatorView != nil {
                            delegate.activityIndicatorView?.removeFromSuperview()
                            delegate.activityIndicatorView = nil
                        }
                    }
                }))
                DispatchQueue.main.async {
                    // show the alert
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        let trustKitConfig = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "ekaplus.com": [
                    kTSKIncludeSubdomains: true,
                    kTSKEnforcePinning:true,
                    kTSKPublicKeyHashes: [
                        Obfuscator().reveal(key: ObfuscatedConstants.PublicKeyHashes1),
                        Obfuscator().reveal(key: ObfuscatedConstants.PublicKeyHashes2),
                        Obfuscator().reveal(key: ObfuscatedConstants.PublicKeyHashes3)
                    ],]]] as [String : Any]
        
        TrustKit.initSharedInstance(withConfiguration:trustKitConfig)
    }
}

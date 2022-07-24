//
//  SettingsBundleHelper.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 05/12/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import Foundation

class SettingsBundleHelper {

    func configureSettingsBundle() {
        
        //Base URL
        if UserDefaults.standard.value(forKeyPath: "Base_URL") != nil && (UserDefaults.standard.value(forKeyPath: "Base_URL") as! String).count > 0 {
            DynamicbaseURL = UserDefaults.standard.value(forKeyPath: "Base_URL") as? String ?? ""
        }else{
            DynamicbaseURL = baseURL + "/connect/api"
        }
        
        //NLP URL
        if  UserDefaults.standard.value(forKeyPath: "NLP_URL") != nil && (UserDefaults.standard.value(forKeyPath: "NLP_URL") as! String).count > 0 {
            NLPbaseURL = UserDefaults.standard.value(forKeyPath: "NLP_URL") as? String ?? ""
        }else{
            NLPbaseURL = baseURL + "/connect/api"
        }
        
        //Tenant ID
        if UserDefaults.standard.value(forKeyPath: UserDefaultsKeys.TenantID.rawValue) != nil && (UserDefaults.standard.value(forKeyPath:  UserDefaultsKeys.TenantID.rawValue) as! String).count > 0 {
            BaseTenantID = UserDefaults.standard.value(forKeyPath:  UserDefaultsKeys.TenantID.rawValue) as? String ?? ""
        }else{
            let Tenant = baseURL[baseURL.range(of: "://")!.upperBound...].components(separatedBy: ".")
            BaseTenantID = Tenant[0]
        }
        
        //UI Base URL
        if  UserDefaults.standard.value(forKeyPath: "UI_URL") != nil && (UserDefaults.standard.value(forKeyPath: "UI_URL") as! String).count > 0 {
            UIbaseURL = UserDefaults.standard.value(forKeyPath: "UI_URL") as? String ?? ""
        }else{
            UIbaseURL = ""
        }
        
         guard let settingsBundle = Bundle.main.url(forResource: "Settings", withExtension:"bundle") else {
            print("Settings.bundle not found")
            return;
        }
        
        guard let settings = NSDictionary(contentsOf: settingsBundle.appendingPathComponent("Root.plist")) else {
            print("Root.plist not found in settings bundle")
            return
        }
        
        guard (settings.object(forKey: "PreferenceSpecifiers") as? [[String: AnyObject]]) != nil else {
            print("Root.plist has invalid format")
            return
        }
       
    }
    
    func configureDefaultSettingsBundle(){
        if UserDefaults.standard.bool(forKey: "clear_cache") == true {
            
            //Reset the settings
            UserDefaults.standard.set(false, forKey: "clear_cache")
            
            //Delete the core data value
            RequestManager.shared.deleteAllData(entity: "ApiDetails")
            RequestManager.shared.deleteAllData(entity: "DraftApiDetails")
            
            //Remove the Downloaded file
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            do {
              
                let filePaths = try FileManager.default.contentsOfDirectory(atPath: paths)
                for filePath in filePaths {
                    if filePath != "ClientLogo.png"{
                        try FileManager.default.removeItem(atPath: paths + "/" + filePath)
                    }
                }
            } catch {
                print("Could not clear temp folder: \(error)")
            }
        }
    }
    
}

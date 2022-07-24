//
//  LoginAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 28/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation
import Intercom
import JWTDecode

struct LoginApiController {
    static func loginWithCredentials(userName:String,password:String,domain:String, completion:@escaping (ServiceResponse<Bool>)->()){
        
        //Set baseURL and try to hit it. If it succeeds, we'll get response for login hit, then we store it in user defaults. From next time when we take user directly to dashboard(because user loggedin previously), we load the baseURL from userdefaults.
        
        baseURL = domain
        
        let queryParams = "?grant_type=cloud_credentials&client_id=2"
//        let body = ["userName":userName,"pwd":password,"activityType":"create"].jsonString()
        let authString =   "\(userName):\(password)".data(using: .utf8)?.base64EncodedString()
        
        
        
        let header = ["Authorization":"Basic \(authString!)", "Device-Id":Utility.getVendorID(),"Tenant-Domain": domain,"sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
       
        RequestManager.shared.request(.post, apiPath: .login, queryParameters: queryParams, httpBody: nil, headers:  header) { (response) in
            
            switch response {
            case .success(let json):
                
                //registerForRemoteNotifications
                UIApplication.shared.registerForRemoteNotifications()
                
                //              print(json)
                //Store access token, refresh token, LoginTimeStamp, sessionTimeOutTime and user details in UserDefaults
                
                let tokenDetails = json["tokenResponse"]["auth2AccessToken"]
                let accessToken = tokenDetails["access_token"].stringValue
                let refreshToken = tokenDetails["refresh_token"].stringValue
                let sessionTimeOutSeconds = json["tokenResponse"]["sessionTimeoutInSeconds"].intValue
                
                //User Details
                let userName = json["userInfo"]["firstName"].stringValue
                let clientID = json["userInfo"]["clientId"].intValue
                let userID = json["userInfo"]["userId"].intValue
                let tenantShortName = json["userInfo"]["tenantShortName"].stringValue
                let userType = json["userInfo"]["userType"].intValue
                let email = json["userInfo"]["email"].stringValue
                let clientName = json["userInfo"]["clientName"].stringValue
                let user = json["userInfo"]["userName"].stringValue
                
                let defaults = UserDefaults.standard
                defaults.set(accessToken, forKey: UserDefaultsKeys.accessToken.rawValue)
                defaults.set(refreshToken, forKey: UserDefaultsKeys.refreshToken.rawValue)
                defaults.set(sessionTimeOutSeconds, forKey: UserDefaultsKeys.sessionTimeOutInSeconds.rawValue)
                defaults.set(userName, forKey: UserDefaultsKeys.userName.rawValue)
                defaults.set(clientID, forKey: UserDefaultsKeys.clientID.rawValue)
                defaults.set(userID, forKey: UserDefaultsKeys.userID.rawValue)
                
                defaults.set(userType, forKey: UserDefaultsKeys.userType.rawValue)
                defaults.set(tenantShortName, forKey: UserDefaultsKeys.tenantShortName.rawValue)
                defaults.set(email, forKey: UserDefaultsKeys.email.rawValue)
                defaults.set(true, forKey: UserDefaultsKeys.refreshTokenValidation.rawValue)
                
                //                defaults.set("f0rQlaqWVmE:APA91bELzFW1Yx-m4SB3xu7SjcuR_fbzwtG4AdIplIK74bSgKjhK8trNqBQBKR3ieDCZEwcVJNt2O4DUH_NEWZzjQEOYRRIIdTxwz5nETK99gYtM4TfW4f3XwUm_a_HnxD2YDAwEnIk7",forKey: UserDefaultsKeys.Firebasetoken.rawValue)
                
                //On successful log in, we store the domain
                //Set domain value on user defaults, it'll be used in the request method of request manager. will be used for the header value of Tenant-Domain.  Also, it'll be used to preload in domain field, when user logs in for the next time
                defaults.setValue(domain, forKey: UserDefaultsKeys.tenantDomain.rawValue)
                defaults.setValue(user, forKey: UserDefaultsKeys.user.rawValue)
                
                //Set the logged in flag 
                defaults.set(true, forKey: UserDefaultsKeys.isUserLoggedIn.rawValue)
                
                //Add username and password to keychain
                Keychain.set(userName, forKey: UserDefaultsKeys.userName.rawValue)
//                Keychain.set(password, forKey: UserDefaultsKeys.password.rawValue)
                
                
                //Register FCM Token
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue) != nil {
                    LoginApiController().RegisterFirebaseToken(token: UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue)!)
                }
                
                
                if let gaiTracker = GAI.sharedInstance().defaultTracker{
                    
                    gaiTracker.set(kGAIUserId, value: tenantShortName+"/"+userName)
                    gaiTracker.send(GAIDictionaryBuilder.createScreenView().set(tenantShortName, forKey: GAIFields.customDimension(for: 1)).build() as? [AnyHashable : Any])
                    
                    gaiTracker.send(GAIDictionaryBuilder.createScreenView().set(userName, forKey: GAIFields.customDimension(for: 2)).build() as? [AnyHashable : Any])
                }
                
                //Get webserver url everytime user logs in
                self.getWebServerUrl()
                
                //Intercom implementation
                Intercom.registerUser(withEmail: email)
                
                //Intercom UserAttribute
                let userAttributes = ICMUserAttributes()
                userAttributes.name = userName
                userAttributes.email = email
                userAttributes.customAttributes = ["client_Name":clientName]
                Intercom.updateUser(userAttributes)
                
                
                RequestManager.shared.request(.get, apiPath: .getPermCode("-1"), httpBody: nil) { (response) in
                    
                    switch response {
                        
                    case .success(let json):
                        let permCodes = json["permCodes"].arrayValue.map{$0.stringValue}
                        
                        //Perm Code for Messenger Icon
                        if permCodes.contains("MESSENGER_VIEW"){
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.messengerView.rawValue)
                        }else{
                            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.messengerView.rawValue)
                        }
                        
                        //Perm Code for InterCom
                        if permCodes.contains("SUPPORT_CHAT_VIEW"){
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        }else{
                            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        }
                        
                        
                        completion(.success(true))
                        
                    case .failure(let error):
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.messengerView.rawValue)
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        completion(.failure(error))
                    case .failureJson(_):
                        break
                    }
                }
                
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
            }
        }
        
    }
    
    static func logout(_ completion:@escaping (ServiceResponse<Bool>)->()){
        
        //Delete the core data value
        RequestManager.shared.deleteAllData(entity: "ApiDetails")
        RequestManager.shared.deleteAllData(entity: "DraftApiDetails")
        
        //UnregisterForRemoteNotifications
        UIApplication.shared.unregisterForRemoteNotifications()
        
        //Register FCM Token
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue) != nil {
            LoginApiController().UnRegisterFirebaseToken(token: UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue)!)
        }
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")","refresh_token":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.refreshToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        RequestManager.shared.request(.post, apiPath: .logout, requestURL: nil, queryParameters: nil, httpBody: nil, headers: header, shouldCacheWithDiskUrl: nil, bodyData: nil) { (response) in
            
            //Remove Client logo if it's present
            do{
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let filename = paths[0].appendingPathComponent("ClientLogo.png")
                try FileManager.default.removeItem(at:filename)
            }catch{
                print(error.localizedDescription)
            }
            
            //                print(json)
            
            let defaults = UserDefaults.standard
            //Remove all keys except firstLaunch used to show the walkthrough screens after app install
            defaults.removeObject(forKey: UserDefaultsKeys.accessToken.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.refreshToken.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.sessionTimeOutInSeconds.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.userName.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.clientID.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.userID.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.agentPermission.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.tenantShortName.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.messengerView.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.supportChatView.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.refreshTokenValidation.rawValue)
            //we need to retain domain to prepopulate in login screen
            //                defaults.removeObject(forKey: UserDefaultsKeys.tenantDomain.rawValue)
            
            defaults.removeObject(forKey: UserDefaultsKeys.webServerUrl.rawValue)
            defaults.removeObject(forKey:UserDefaultsKeys.notificationCount.rawValue)
            defaults.removeObject(forKey: UserDefaultsKeys.user.rawValue)
            
            //Remove keychain items
            Keychain.removeValue(forKey: UserDefaultsKeys.userName.rawValue)
//            Keychain.removeValue(forKey: UserDefaultsKeys.password.rawValue)
            
            //Remove File in the Disk
            DataCacheManager.shared.clearFarmerAndSearchDetails()
            DataCacheManager.shared.clearEntireCache()
            
            //Set login flag to false
            defaults.setValue(false, forKey: UserDefaultsKeys.isUserLoggedIn.rawValue)
            defaults.set(false, forKey: UserDefaultsKeys.isQualityLock.rawValue)
            
            //Logout from the Intercom
            Intercom.logout()
            
            //unregister the Firebase token
            
            switch response {
                
            case .success( _):
                completion(.success(true))
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
                
            }
        }
    }
    
    
    static func getWebConfig(){
        
        //Fallback - if request fail, we'll use the default values
        UserDefaults.standard.set("https://info.ekaplus.com/service-request", forKey: UserDefaultsKeys.contactUsUrl.rawValue)
        UserDefaults.standard.set("https://info.ekaplus.com/sign-up-free-software", forKey: UserDefaultsKeys.registrationUrl.rawValue)
        
        //Check if the api returns updated urls
        RequestManager.shared.request(.get, apiPath: .webConfig, httpBody: nil, headers:nil) { (response) in
            switch response {
            case .success(let json):
                let contactUsUrl = json["contactusURL"].stringValue
                let registrationUrl = json["registrationURL"].stringValue
                
                UserDefaults.standard.set(contactUsUrl, forKey: UserDefaultsKeys.contactUsUrl.rawValue)
                UserDefaults.standard.set(registrationUrl, forKey: UserDefaultsKeys.registrationUrl.rawValue)
                
            case .failure(let error):
                print(error)
            case .failureJson(_):
                break
            }
        }
        
    }
    
    
    //called after user logs in
    private static func getWebServerUrl(){
        
        RequestManager.shared.request(.get, apiPath: .webServerUrl, httpBody: nil) { (response) in
            switch response {
            case .success(let json):
                
                
                //This is the url used for loading pivot and timeline charts which are webview based
                let defaults = UserDefaults.standard
                defaults.set(json["url"].stringValue, forKey: UserDefaultsKeys.webServerUrl.rawValue)
                
            case .failure(let error):
                print(error.description)
            case .failureJson(_):
                break
            }
        }
    }
    
    func RegisterFirebaseToken(token:String){
        
        let body:[String:Any] = ["deviceToken":token,"deviceType":"iOS"]
        
        RequestManager.shared.request(.put, apiPath: .FirebaseToken, queryParameters: nil, httpBody: body.jsonString(), shouldCacheWithDiskUrl: nil, bodyData: nil) { (response) in
            
            switch response {
            case .success(_):
                break
            case .failure(let error):
                print(error.localizedDescription)
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func UnRegisterFirebaseToken(token:String){
        
        let body:[String:Any] = ["deviceToken":token,"deviceType":"iOS"]
        
        RequestManager.shared.request(.delete, apiPath: .FirebaseToken, queryParameters: nil, httpBody: body.jsonString(), shouldCacheWithDiskUrl: nil, bodyData: nil) { (response) in
            
            switch response {
            case .success(_):
                break
            case .failure(let error):
                print(error.localizedDescription)
            case .failureJson(_):
                break
            }
        }
        
    }
    
    static func refreshAccessToken(accessToken:String,refreshToken:String,completion:@escaping (ServiceResponse<Bool>)->()){
        
        let requestURL:String = baseURL + "/cac-security/api/oauth/refreshToken"
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "User-Id":UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "", "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","client_id":"2","access_token":"\(accessToken)","refresh_token":"\(refreshToken)","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        
        RequestManager.shared.request(.post, apiPath: nil, requestURL: requestURL, queryParameters: nil, httpBody: nil, headers: header, shouldCacheWithDiskUrl: nil, bodyData: nil) { (response) in
            
            switch response {
            case .success(let json):
                let accessToken = json["access_token"].stringValue
                UserDefaults.standard.set(accessToken, forKey: UserDefaultsKeys.accessToken.rawValue)
                
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
                
            }
                
        }
        
    }
    
    static func getTenantSettings(_ completion:@escaping (ServiceResponse<JSON>)->()){
        
        baseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!
        
        let queryParams = "?type=mobile_identity_provider_settings"
        let header = ["sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString(),"Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!]
        
        RequestManager.shared.request(.get, apiPath: .tenantDetails, queryParameters: queryParams, httpBody: nil, headers:  header) { (response) in
            
            switch response {
            
            case .success(let json):
                completion(.success(json))
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(let errormsg):
                completion(.failureJson(errormsg))
                
            }
        }
    }
    
    static func getVerification(userName:String,password:String, completion:@escaping (ServiceResponse<JSON>)->()){
        
        baseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!
        
        let queryParams = "?grant_type=cloud_credentials&client_id=2"
        let authString =   "\(userName):\(password)".data(using: .utf8)?.base64EncodedString()
        
        UserDefaults.standard.set("Basic \(authString!)", forKey: UserDefaultsKeys.authString.rawValue)
        
        let header = ["Authorization":"Basic \(authString!)", "Device-Id":Utility.getVendorID(),"verifymfa": "true","Tenant-Domain": "\(baseURL!)","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        UserDefaults.standard.set(userName, forKey: UserDefaultsKeys.userName.rawValue)
        
        RequestManager.shared.request(.post, apiPath: .token, queryParameters: queryParams, httpBody: nil, headers:  header) { (response) in
            
            switch response {
            case .success(let json):
                completion(.success(json))
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
            }
        }
    }
    
    static func verifyOTP(userName:String,OTP:String, completion:@escaping (ServiceResponse<Bool>)->()){
        
        baseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!
        
        let queryParams = "?grant_type=cloud_credentials&client_id=2"
        let authString =   "\(userName):\(OTP)".data(using: .utf8)?.base64EncodedString()
        
        let header = ["Authorization":"OTP Basic \(authString!)", "Device-Id":Utility.getVendorID(),"verifymfa": "true","otp-token":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.uniqueToken.rawValue)!)","Tenant-Domain": "\(baseURL!)","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        RequestManager.shared.request(.post, apiPath: .userInfo, queryParameters: queryParams, httpBody: nil, headers:  header) { (response) in
            
            switch response {
            case .success(let json):
                
                //registerForRemoteNotifications
                UIApplication.shared.registerForRemoteNotifications()
                
                //Store access token, refresh token, LoginTimeStamp, sessionTimeOutTime and user details in UserDefaults
                
                let tokenDetails = json["tokenResponse"]["auth2AccessToken"]
                let accessToken = tokenDetails["access_token"].stringValue
                let refreshToken = tokenDetails["refresh_token"].stringValue
                let sessionTimeOutSeconds = json["tokenResponse"]["sessionTimeoutInSeconds"].intValue
                
                //User Details
                let userName = json["userInfo"]["firstName"].stringValue
                let clientID = json["userInfo"]["clientId"].intValue
                let userID = json["userInfo"]["userId"].intValue
                let tenantShortName = json["userInfo"]["tenantShortName"].stringValue
                let userType = json["userInfo"]["userType"].intValue
                let email = json["userInfo"]["email"].stringValue
                let clientName = json["userInfo"]["clientName"].stringValue
                let user = json["userInfo"]["userName"].stringValue
                
                let defaults = UserDefaults.standard
                defaults.set(accessToken, forKey: UserDefaultsKeys.accessToken.rawValue)
                defaults.set(refreshToken, forKey: UserDefaultsKeys.refreshToken.rawValue)
                defaults.set(sessionTimeOutSeconds, forKey: UserDefaultsKeys.sessionTimeOutInSeconds.rawValue)
                defaults.set(userName, forKey: UserDefaultsKeys.userName.rawValue)
                defaults.set(clientID, forKey: UserDefaultsKeys.clientID.rawValue)
                defaults.set(userID, forKey: UserDefaultsKeys.userID.rawValue)
                
                defaults.set(userType, forKey: UserDefaultsKeys.userType.rawValue)
                defaults.set(tenantShortName, forKey: UserDefaultsKeys.tenantShortName.rawValue)
                defaults.set(email, forKey: UserDefaultsKeys.email.rawValue)
                defaults.set(true, forKey: UserDefaultsKeys.refreshTokenValidation.rawValue)
                
                defaults.setValue(baseURL, forKey: UserDefaultsKeys.tenantDomain.rawValue)
                defaults.setValue(user, forKey: UserDefaultsKeys.user.rawValue)
                
                //Set the logged in flag
                defaults.set(true, forKey: UserDefaultsKeys.isUserLoggedIn.rawValue)
                
                //Add username and password to keychain
                Keychain.set(userName, forKey: UserDefaultsKeys.userName.rawValue)
                
                //Register FCM Token
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue) != nil {
                    LoginApiController().RegisterFirebaseToken(token: UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue)!)
                }
                
                
                if let gaiTracker = GAI.sharedInstance().defaultTracker{
                    
                    gaiTracker.set(kGAIUserId, value: tenantShortName+"/"+userName)
                    gaiTracker.send(GAIDictionaryBuilder.createScreenView().set(tenantShortName, forKey: GAIFields.customDimension(for: 1)).build() as? [AnyHashable : Any])
                    
                    gaiTracker.send(GAIDictionaryBuilder.createScreenView().set(userName, forKey: GAIFields.customDimension(for: 2)).build() as? [AnyHashable : Any])
                }
                
                //Get webserver url everytime user logs in
                self.getWebServerUrl()
                
                //Intercom implementation
                Intercom.registerUser(withEmail: email)
                
                //Intercom UserAttribute
                let userAttributes = ICMUserAttributes()
                userAttributes.name = userName
                userAttributes.email = email
                userAttributes.customAttributes = ["client_Name":clientName]
                Intercom.updateUser(userAttributes)
                
                
                RequestManager.shared.request(.get, apiPath: .getPermCode("-1"), httpBody: nil) { (response) in
                    
                    switch response {
                        
                    case .success(let json):
                        let permCodes = json["permCodes"].arrayValue.map{$0.stringValue}
                        
                        //Perm Code for Messenger Icon
                        if permCodes.contains("MESSENGER_VIEW"){
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.messengerView.rawValue)
                        }else{
                            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.messengerView.rawValue)
                        }
                        
                        //Perm Code for InterCom
                        if permCodes.contains("SUPPORT_CHAT_VIEW"){
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        }else{
                            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        }
                        
                        
                        completion(.success(true))
                        
                    case .failure(let error):
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.messengerView.rawValue)
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        completion(.failure(error))
                        
                    case .failureJson(_):
                        break
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
            }
        }
    }
    
    static func resendOTP(userName:String, completion:@escaping (ServiceResponse<JSON>)->()){
        
        baseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!
        
        let queryParams = "?grant_type=cloud_credentials&client_id=2"
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.authString.rawValue)!)", "Device-Id":Utility.getVendorID(),"verifymfa": "true","Tenant-Domain": "\(baseURL!)","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        let body:[String:Any] = ["userName":userName,"uniqueToken":UserDefaults.standard.string(forKey: UserDefaultsKeys.uniqueToken.rawValue)!]
        
        RequestManager.shared.request(.post, apiPath: .resendOTP, queryParameters: queryParams, httpBody: body.jsonString(), headers: header) { (response) in
            
            switch response {
            case .success(_):
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func AzureandoktaLogin(id_Token:String,medium:String, completion:@escaping (ServiceResponse<Bool>)->()){
        
        let baseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!
        
        var queryParams = ""
        if medium == "okta" {
            do {
                let jwt = try decode(jwt: id_Token)
                queryParams = "?grant_type=cloud_credentials&client_id=2&id_token=\(id_Token)&nonce=\(jwt.body["nonce"]!)"
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }else{
            queryParams = "?grant_type=cloud_credentials&client_id=2&id_token=\(id_Token)"
        }
       
        
        let header = ["Device-Id":Utility.getVendorID(),"sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        RequestManager.shared.request(.post, apiPath: nil, requestURL: "\(baseURL)/cac-security/callback/api/oauth/token/\(medium)", queryParameters: queryParams, httpBody: nil, headers: header) { (response) in
            
            switch response {
            case .success(let json):
                //registerForRemoteNotifications
                UIApplication.shared.registerForRemoteNotifications()
                
                //Store access token, refresh token, LoginTimeStamp, sessionTimeOutTime and user details in UserDefaults
                
                let accessToken = json["auth2AccessToken"]["access_token"].stringValue
                let refreshToken = json["auth2AccessToken"]["refresh_token"].stringValue
                let sessionTimeOutSeconds = json["tokenResponse"]["sessionTimeoutInSeconds"].intValue
                
                let defaults = UserDefaults.standard
                defaults.set(accessToken, forKey: UserDefaultsKeys.accessToken.rawValue)
                defaults.set(refreshToken, forKey: UserDefaultsKeys.refreshToken.rawValue)
                defaults.set(sessionTimeOutSeconds, forKey: UserDefaultsKeys.sessionTimeOutInSeconds.rawValue)
                
                let baseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)!
                
                let queryParams = "?filter=all"
                
                let header = ["Authorization":accessToken,"Device-Id":Utility.getVendorID(),"sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
                
                RequestManager.shared.request(.get, apiPath: nil, requestURL: "\(baseURL)/cac-security/api/userinfo", queryParameters: queryParams, httpBody: nil, headers: header) { (userinfo) in
                    
                    switch userinfo {
                    case .success(let userinfojson):
                        //User Details
                        let userName = userinfojson["firstName"].stringValue
                        let clientID = userinfojson["tenantInfo"]["clientId"].intValue
                        let userID = userinfojson["id"].intValue
                        let tenantShortName = userinfojson["tenantInfo"]["tenantShortName"].stringValue
                        let userType = userinfojson["userType"].intValue
                        let email = userinfojson["email"].stringValue
                        let clientName = userinfojson["tenantInfo"]["clientName"].stringValue
                        let user = userinfojson["userName"].stringValue
                        
                        let defaults = UserDefaults.standard
                        defaults.set(userName, forKey: UserDefaultsKeys.userName.rawValue)
                        defaults.set(clientID, forKey: UserDefaultsKeys.clientID.rawValue)
                        defaults.set(userID, forKey: UserDefaultsKeys.userID.rawValue)
                        
                        defaults.set(userType, forKey: UserDefaultsKeys.userType.rawValue)
                        defaults.set(tenantShortName, forKey: UserDefaultsKeys.tenantShortName.rawValue)
                        defaults.set(email, forKey: UserDefaultsKeys.email.rawValue)
                        defaults.set(true, forKey: UserDefaultsKeys.refreshTokenValidation.rawValue)
                        
                        //On successful log in, we store the domain
                        //Set domain value on user defaults, it'll be used in the request method of request manager. will be used for the header value of Tenant-Domain.  Also, it'll be used to preload in domain field, when user logs in for the next time
                        defaults.setValue(user, forKey: UserDefaultsKeys.user.rawValue)
                        
                        //Set the logged in flag
                        defaults.set(true, forKey: UserDefaultsKeys.isUserLoggedIn.rawValue)
                        
                        //Add username and password to keychain
                        Keychain.set(userName, forKey: UserDefaultsKeys.userName.rawValue)
                        
                        //Register FCM Token
                        if UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue) != nil {
                            LoginApiController().RegisterFirebaseToken(token: UserDefaults.standard.string(forKey: UserDefaultsKeys.Firebasetoken.rawValue)!)
                        }
                        
                        if let gaiTracker = GAI.sharedInstance().defaultTracker{
                            
                            gaiTracker.set(kGAIUserId, value: tenantShortName+"/"+userName)
                            gaiTracker.send(GAIDictionaryBuilder.createScreenView().set(tenantShortName, forKey: GAIFields.customDimension(for: 1)).build() as? [AnyHashable : Any])
                            
                            gaiTracker.send(GAIDictionaryBuilder.createScreenView().set(userName, forKey: GAIFields.customDimension(for: 2)).build() as? [AnyHashable : Any])
                        }
                        
                        //Get webserver url everytime user logs in
                        LoginApiController.getWebServerUrl()
                        
                        //Intercom implementation
                        Intercom.registerUser(withEmail: email)
                        
                        //Intercom UserAttribute
                        let userAttributes = ICMUserAttributes()
                        userAttributes.name = userName
                        userAttributes.email = email
                        userAttributes.customAttributes = ["client_Name":clientName]
                        Intercom.updateUser(userAttributes)
                        
                        let permCodes = userinfojson["permCodes"].arrayValue
                        
                        //Perm Code for Messenger Icon
                        if permCodes.contains("MESSENGER_VIEW"){
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.messengerView.rawValue)
                        }else{
                            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.messengerView.rawValue)
                        }
                        
                        //Perm Code for InterCom
                        if permCodes.contains("SUPPORT_CHAT_VIEW"){
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        }else{
                            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        }
                        
                        completion(.success(true))
                        
                    case .failure(let error):
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.messengerView.rawValue)
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.supportChatView.rawValue)
                        completion(.failure(error))
                        
                    case .failureJson(_):
                        break
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
   
    
    
}

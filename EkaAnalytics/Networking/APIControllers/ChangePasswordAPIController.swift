//
//  ChangePasswordAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 09/05/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation


class ChangePasswordAPIController {
    
    func validateExistingPassword(_ password:String, _ completion: @escaping (Bool)->()) {
        
        let body = ["pwd":password].jsonString()
        
        RequestManager.shared.request(.post, apiPath: .validateExistingPassword, httpBody: body) { (response) in
            switch response {
            case .success(let json):
                let success = json["success"].boolValue
                completion(success)
            case .failure:
                completion(false)
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func validateNewPassword(_ password:String, _ completion: @escaping (Bool)->()) {
        
        let body = ["pwd":password].jsonString()
        
        RequestManager.shared.request(.post, apiPath: .validateNewPassword, httpBody: body) { (response) in
            switch response {
            case .success(let json):
                let success = json["success"].boolValue
                completion(success)
            case .failure:
                completion(false)
            case .failureJson(_):
                break
            }
        }
    }
    
    
    //    func changeNewPassword(userId:Int, _ password:String, _ completion: @escaping (Bool)->()) {
    //
    //        getUserDetails(userId) { (json) in
    //            if json != nil {
    //
    //                guard var body = json!.dictionaryObject else{
    //                    completion(false)
    //                    return
    //                }
    //
    //                body = body["data"] as! [String:Any]
    //
    //                body.updateValue(userId, forKey: "userInternalId")
    //                body.updateValue("modify", forKey: "activityType")
    //                body.updateValue(password, forKey: "password")
    //
    //                let bodyString = ["dataObj":body].jsonString()
    //
    //
    //                RequestManager.shared.request(.post, apiPath: .changePassword, httpBody: bodyString, block: { (response) in
    //                    switch response {
    //                    case .success(let json):
    //                        let success = json["success"].boolValue
    //                        completion(success)
    //                    case .failure:
    //                        completion(false)
    //                    }
    //                })
    //            }
    //        }
    //
    //    }
    
    //    func getUserDetails(_ userId:Int, _ completion:@escaping (JSON?)->()){
    //        RequestManager.shared.request(.get, apiPath: .getUserDetails(userId), httpBody: nil) { (response) in
    //            switch response {
    //            case .success(let json):
    //                completion(json)
    //            case .failure:
    //                completion(nil)
    //            }
    //        }
    //    }
    
    
    func changePassword(oldPassword:String, newPassword:String,_ completion: @escaping (Bool)->()){
        
        let body = ["oldPassword": "\(oldPassword)","newPassword": "\(newPassword)","confirmNewPassword": "\(newPassword)"].jsonString()
        
        RequestManager.shared.request(.post, apiPath: .changePassword, httpBody: body) { (response) in
            switch response {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func getPasswordPolicy(_ completion: @escaping ([String]?,NSMutableAttributedString?)->() ){
        
        RequestManager.shared.request(.get, apiPath: .getPasswordPolicy) { (response) in
            switch response {
            case .success(let resultJson):
                
                if resultJson.count  == 0 {
                    completion(nil,nil)
                }else{
                    let policy:[String] = resultJson.rawValue as! [String]
                    
                    let policyString = NSMutableAttributedString(string: "")
                    
                    for i in 0..<resultJson.count {
                        switch i {
                        case 0 :
                            policyString.append(NSMutableAttributedString(string: "\(resultJson[i])"))
                        default:
                            policyString.append(NSMutableAttributedString(string: "\n   \(resultJson[i])"))
                        }
                    }
                    completion(policy,policyString)
                }
            case .failure:
                completion(nil,nil)
            case .failureJson(_):
                completion(nil,nil)
            }
        }
        
    }
    
    func passwordValidator(_ password:String,_ completion: @escaping (JSON)->() ){
        
        let body = ["userName": UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue),"password":password].jsonString()
        
        RequestManager.shared.request(.post, apiPath: .passwordValidator, httpBody: body) { (response) in
            
            switch response {
            case .success(let resultJson):
                completion(resultJson)
            case .failure:
                completion(nil)
            case .failureJson(_):
                completion(nil)
            }
        }
        
    }
}

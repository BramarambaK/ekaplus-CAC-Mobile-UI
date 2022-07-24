//
//  PermCodeAPIController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 27/06/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

class PermCodeAPIController {
    
    func getPermCode(appId:String, completion:@escaping (ServiceResponse<[String]>)->()){
        
        RequestManager.shared.request(.get, apiPath: .getPermCode(appId), httpBody: nil) { (response) in
            switch response {
                
            case .success(let json):
                let permCodes = json["permCodes"].arrayValue.map{$0.stringValue}
                completion(.success(permCodes))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func getGeneralSetting(_ completion :@escaping (ServiceResponse<JSON>)->()){
        
        RequestManager.shared.request(.get, apiPath: .Generalsettings, httpBody: nil) { (response) in
            
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
    
}


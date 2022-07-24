//
//  AppFavouriteAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 29/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

class AppFavouriteAPIController {
    
    public static var shared = AppFavouriteAPIController()
    private init(){}
    
    
    func toggleAppFavourite(_ appID:String, appType:AppType, isFavourite:Bool, completion:@escaping (ServiceResponse<JSON>)->()){
        
        
        var appTypeParam = ""
    
        if appType == .MyApps{
            appTypeParam = "Custom_Apps"
        } else {
            appTypeParam = "Std_App"
        }
        
        let body = ["isFavourite":isFavourite].jsonString()
        
//        print(body)
        
        RequestManager.shared.request(.post, apiPath: .toggleAppFavourite(appType: appTypeParam, appId: appID) , httpBody: body, shouldCacheWithDiskUrl: nil) { (response) in
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

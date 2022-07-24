//
//  AppListAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

class AppListAPIController {
    
    public static var shared = AppListAPIController()
    private init(){}

    func getAppsForCategory(_ categoryID:Int, completion:@escaping (ServiceResponse<[App]>)->()){
        
        var cacheURL:URL?
        
        if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheURL = url.appendingPathComponent("appsForCategory\(categoryID).json")
        }
        
        let queryParam = "/\(categoryID)"
       
        RequestManager.shared.request(.get, apiPath: .listOfAppsForCategory, queryParameters: queryParam, httpBody: nil, shouldCacheWithDiskUrl: cacheURL) { (response) in
            switch response {
            case .success(let json):
//                print(json)
                let apps = self.mapModelWithJson(json)
                completion(.success(apps))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
        
    }
    
    
    func getFavouriteApps(_ completion:@escaping (ServiceResponse<[App]>)->()) {
        
        var cacheURL:URL?
        
        if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            cacheURL = url.appendingPathComponent("favouriteApps.json")
        }
       
        RequestManager.shared.request(.get, apiPath: .favouriteApps, httpBody: nil, shouldCacheWithDiskUrl: cacheURL) { (response) in
            switch response {
            case .success(let json):
//                print(json)
                let apps = self.mapModelWithJson(json)
                completion(.success(apps))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    private func mapModelWithJson(_ json:JSON) -> [App] {
        var apps = [App]()
        for appRaw in json.arrayValue {
            do {
                let app:App = try JSONDecoder.decode(json: appRaw)
                apps.append(app)
            } catch {
                print(error.localizedDescription)
            }
        }
        return apps
    }
}

//
//  AppCategoryAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

class AppCategoryAPIController {
    
    public static var shared = AppCategoryAPIController()
    private init(){}
    
    private var cacheURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("appCategories.json")
        } else {
            return nil
        }
    }()
    
    func getAppCategories(_ completion:@escaping (ServiceResponse<[AppCategory]>)->()){
        
        RequestManager.shared.request(.get, apiPath: .appCategories, httpBody: nil, shouldCacheWithDiskUrl : cacheURL) { (response) in
            switch response {
            case .success(let json):
                
                let appCategories = self.mapModelWithJson(json)
                completion(.success(appCategories))
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
                
            }
        }
    }
    
    
   private func mapModelWithJson(_ json:JSON) -> [AppCategory] {
        
        var appCategories = [AppCategory]()
        
        for categoryRaw in json.arrayValue {
            do{
                let appCategory:AppCategory = try JSONDecoder.decode(json: categoryRaw)
                appCategories.append(appCategory)
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return appCategories
    }
}

//
//  InsightListAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 30/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

class InsightListAPIController {
    
    public static var shared = InsightListAPIController()
    private init(){}
    
    private var insightListCacheURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("insightsList.json")
        } else {
            return nil
        }
    }()
    
    private var dataViewNamesMapCacheURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("dvNamesMap.json")
        } else {
            return nil
        }
    }()
    
    func getListOfInsights(onlyFavourites:Bool = false, forAppID:String?, insightIDs:[String]?, _ completion: @escaping (ServiceResponse<[Insight]>)->()){
        
        var queryParams = "" //"/\(onlyFavourites)"
        
        if let appID = forAppID {
            queryParams += "?linkedAppIds=\(appID)"
        } else if let insightIDs = insightIDs {
            
            queryParams += "?insightIds="
            for insightID in insightIDs {
                queryParams += "\(insightID),"
            }
            
            queryParams = String(queryParams.dropLast())
        }
        
        queryParams += "&isMobileClient=true"
        
        RequestManager.shared.request(.get, apiPath: .insightsList, queryParameters: queryParams, httpBody: nil, shouldCacheWithDiskUrl : insightListCacheURL) { (response) in
            
//            print(response)
            switch response {
                
            case .success(let json):
//                print(json)
                var insights = [Insight]()
                
                for insightRaw in json.arrayValue{
                    do{
                    let insight:Insight = try JSONDecoder.decode(json: insightRaw)
                    insights.append(insight)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                completion(.success(insights))
                
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
            }
        }
    }
    
    func getDataViewIdAndNamesMapForInsight(_ insightID:String, _ completion:@escaping (ServiceResponse<JSON>)->()){
        
         RequestManager.shared.request(.get, apiPath: .dataViewNamesMap(insightID), httpBody: nil, shouldCacheWithDiskUrl : dataViewNamesMapCacheURL) { (response) in
            
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

//
//  SearchApiController.swift
//  EkaAnalytics
//
//  Created by Nithin on 19/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

protocol SearchResult : Serializable {
    var entityType:String {get set}
}

class SearchApiController{
    
    static let shared = SearchApiController()
    private init(){}
    
    func searchWithText(_ searchText:String, completion:@escaping (ServiceResponse<[SearchResult]>)->()) {
        
        RequestManager.shared.request(.get, apiPath: .search(searchText) , httpBody: nil, shouldCacheWithDiskUrl: nil) { (response) in
//            print(response)
            switch response {
            case .success(let json):
                
                
                var searchResults = [SearchResult]()
                for result in json.arrayValue {
                    do {
                        if result["entityType"] == "app"{
                            let app:App = try JSONDecoder.decode(json: result)
                            searchResults.append(app)
                        } else {
                             let insight:Insight = try JSONDecoder.decode(json: result)
                            searchResults.append(insight)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                completion(.success(searchResults))
                
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
            }
        }
        
    }
    
}

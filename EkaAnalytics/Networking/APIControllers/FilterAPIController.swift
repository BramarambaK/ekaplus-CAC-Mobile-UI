//
//  FilterAPIController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 21/08/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class FilterAPIController {
    
    func getFilterColumnvalue(dataViewJson:JSON,columnId:String,Selectedfilter:[String:JSON?], completion:@escaping (ServiceResponse<NSDictionary>)->()){
        
        var basicFilter:[String] = []
        
        var bodyJson:JSON = dataViewJson
        
        if  dataViewJson["dataSource"]["sourceType"].stringValue == "Joined" || dataViewJson["dataSource"]["sourceType"].stringValue == "Realtime"{
            
            bodyJson["inMemoryCollection"] = true
        }
        
        if Selectedfilter.count > 0 {
            let filterArray = dataViewJson["visualizations"]["filters"].arrayValue
            var filterValue:[NSDictionary] = []
            for index in 0 ..< filterArray.count {
                if filterArray[index]["columnId"].stringValue != columnId {
                    let data = Selectedfilter["\(filterArray[index]["columnId"])"]
                    
                    if data != nil {
                        if data! != nil {
                            filterValue.append(data!!.dictionary! as NSDictionary)
                        }else{
                            filterValue.append(filterArray[index].dictionary! as NSDictionary)
                        }
                        
                    }else{
                        filterValue.append(filterArray[index].dictionary! as NSDictionary)
                    }
                }else{
                    filterValue.append(filterArray[index].dictionary! as NSDictionary)
                }
                
            }
            bodyJson["visualizations"]["filters"] = JSON.init(filterValue)
        }
        
        
        
        bodyJson["visualizations"]["configuration"]["basicFilterColumn"] = JSON.init(columnId)
        
        let jsonData =  try? JSONSerialization.data(withJSONObject: bodyJson.object, options: .prettyPrinted)
        
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! Dictionary<String, Any>
        
        let body:[String:Any] =  ["dataViewJson":jsonObject!]
        
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        RequestManager.shared.request(.post, apiPath: .columnValues, queryParameters: nil, httpBody: nil, bodyData: bodyData!) { (columnresponse) in
            
            switch columnresponse
            {
                
            case .success(let json):
                let columnValue = json.dictionaryValue["data"]!
                
                for index in 0 ..< columnValue.count {
                    basicFilter.append(columnValue[index]["name"].stringValue)
                }
                
                let Test:NSDictionary = ["Json": bodyJson,"basicFilter":basicFilter]
                
                completion(.success(Test))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
        
        
    }
    
    
}

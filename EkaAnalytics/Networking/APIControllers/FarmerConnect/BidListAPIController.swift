//
//  BidListAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 06/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

class BidListApiController {
    public static var shared = BidListApiController()
    private init(){}
    
    func getMyBids(farmerId:String?,apiType:String,sort:[String:Any]? = nil, filter: [JSON]? = nil, pageNo:Int = 0, pageSize:Int,tapFilter:String? = nil, _ completion :@escaping (ServiceResponse<[MyBid]>)->()){
        
        //page limit
        var queryParam = "?requestParams="
        
        var requestParams = [String:Any]()
        
        if let sortParam = sort{
            requestParams.updateValue(sortParam, forKey: "sortBy")
        }
        
        var filterparams:[JSON]? = []
        
        if let filterParam = filter{
            filterparams = filterParam
        }
        
        // Tab Filter
        let TabFilter = JSON(["columnId" : "status",
                             "operator" : "in",
                             "type" : "basic",
                             "value" : [
                                "\(tapFilter ?? "")"]
            ])
        
        filterparams?.append(TabFilter)
        let filters = filterparams!.compactMap{return $0.dictionaryObject}
        requestParams.updateValue(filters, forKey: "filters")
        
        let pagination = ["page":pageNo, "limit":pageSize]
        
        requestParams.updateValue(pagination , forKey: "pagination")
        
        queryParam += requestParams.jsonString().replacingOccurrences(of: "&", with: "%26")
        
        RequestManager.shared.request(.get, apiPath: .myBids(farmerId, apiType), queryParameters: queryParam, httpBody: nil) { (response) in
            
            switch response {
            case .success(let json):
                
                var myBids = [MyBid]()
                for bid in json.arrayValue {
                    do{
                        let myBid:MyBid = try JSONDecoder.decode(json: bid)
                        myBids.append(myBid)
                    } catch{
                        print(error.localizedDescription)
                    }
                }
                
                completion(.success(myBids))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
            
        }
    }
    
    func getPublishedBids(sort:[String:Any]? = nil, filter:[JSON]? = nil, pageNo:Int = 0, pageSize:Int, _ completion:@escaping (ServiceResponse<[PublishedBid]>)->()){
        
        var queryParam = "?requestParams="
        
        var requestParams = [String:Any]()
        
        if let sortParam = sort{
            requestParams.updateValue(sortParam, forKey: "sortBy")
        }
        
        if let filterParam = filter{
            let filters = filterParam.compactMap{return $0.dictionaryObject}
            requestParams.updateValue(filters, forKey: "filters")
        }
        
        let pagination = ["page":pageNo, "limit":pageSize]

        requestParams.updateValue(pagination , forKey: "pagination")
        
        
        queryParam += requestParams.jsonString().replacingOccurrences(of: "&", with: "%26")
        
        RequestManager.shared.request(.get, apiPath: .publishedBids, queryParameters:queryParam, httpBody: nil) { (response) in
            switch response {
            case .success(let json):
                
                var publishedBids = [PublishedBid]()
                for bid in json.arrayValue {
                    do{
                        let publishedBid:PublishedBid = try JSONDecoder.decode(json: bid)
                        publishedBids.append(publishedBid)
                    } catch{
                        print(error.localizedDescription)
                    }
                }
                
                completion(.success(publishedBids))
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func createBids(farmerId:String?, body:String, _ completion :@escaping (ServiceResponse<Bool>)->()){
        
        RequestManager.shared.request(.post, apiPath: .createBids(farmerId), httpBody: body) { (response) in
            
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
    
    func updateBid(farmerId:String?,refId:String, _ body:String,_ queryParameters:Bool = false, _ completion :@escaping (ServiceResponse<Bool>)->()){
        
        var param:String = ""
        
        if farmerId != nil {
            param = "/\(refId)/\(farmerId!)"
        }else{
            param = "/\(refId)"
        }
        
        if queryParameters {
             param = param + "?byOfferor=true"
        }
       
        
        //pass status, remarks and price to update
        RequestManager.shared.request(.put, apiPath: .updateBids, queryParameters: param, httpBody: body) { (response) in
            
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
    
    func getDetailsForMyBid(farmerId:String?, refId:String, completion:@escaping (ServiceResponse<MyBid>)->()){
        
        let param = "/\(refId)"
        
        RequestManager.shared.request(.get, apiPath: .getBidDetails, queryParameters: param, httpBody: nil) { (response) in
            
            switch response {
            case .success(let json):
                
                do{
                    let myBid:MyBid = try JSONDecoder.decode(json: json)
                    completion(.success(myBid))
                } catch{
                    print(error.localizedDescription)
                }
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func getBidLogs(_ refId:String, _ completion :@escaping (ServiceResponse<JSON>)->()){
        
        RequestManager.shared.request(.get, apiPath: .bidLogs(refId), httpBody: nil) { (response) in
            
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
    
    func getFiltersForColumn(columnName:String, _ completion: @escaping (ServiceResponse<[String]>)->()){
        RequestManager.shared.request(.get, apiPath: .basicBidFilterValuesForColumnName(columnName), httpBody: nil) { (response) in
            switch response {
            case .success(let filterValues):
                completion(.success(filterValues.arrayValue.map{$0.stringValue}))
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func getMyBidFiltersForColumn(farmerId:String?,columnName:String, _ completion: @escaping (ServiceResponse<[String]>)->()){
        RequestManager.shared.request(.get, apiPath: .basicMyBidFilterValuesForColumnName(farmerId, columnName), httpBody: nil) { (response) in
            switch response {
            case .success(let filterValues):
                completion(.success(filterValues.arrayValue.map{$0.stringValue}))
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func updateRating(remarks:String? = "",ratedOn:[String]?,rating:Int,refId:String, _ completion: @escaping (Bool)->()) {
        
        let body = ["ratedOn":ratedOn!,"remarks":remarks!].jsonString()
        
//        let body = ["ratedOn":password].jsonString()
        
        RequestManager.shared.request(.post, apiPath: .updateSellerRating(refId, rating), httpBody: body) { (response) in
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
}


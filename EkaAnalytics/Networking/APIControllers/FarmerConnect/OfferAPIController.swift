//
//  OfferAPIController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 22/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import Foundation

class OfferApiController {
    
    func publishBids(body:String, _ completion :@escaping (ServiceResponse<JSON>)->()) {
        
        RequestManager.shared.request(.post, apiPath: .PublishOffer(nil), httpBody: body) { (response) in
            
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
    
    func updatePublishBids(BidId:String,body:String,_ completion :@escaping (ServiceResponse<Bool>)->()){
        
        RequestManager.shared.request(.put, apiPath: .PublishOffer(BidId), httpBody: body) { (response) in
            
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
    
    func deletePublishBids(BidId:String?,_ completion :@escaping (ServiceResponse<Bool>)->()){
        
        RequestManager.shared.request(.delete, apiPath: .PublishOffer(BidId), httpBody: nil) { (response) in
            
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
    
    
    func getDropdownData(fieldData:String, _ completion :@escaping (ServiceResponse<JSON>)->()) {
        
        RequestManager.shared.request(.get, apiPath: .FieldData(fieldData), httpBody: nil) { (response) in
            
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
    
    func CancelBids(BidId:String,body:String,_ completion :@escaping (ServiceResponse<Bool>)->()){
        
        RequestManager.shared.request(.post, apiPath: .CancelBid(BidId), httpBody: body) { (response) in
            
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
    
}

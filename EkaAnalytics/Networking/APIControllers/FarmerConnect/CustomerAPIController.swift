//
//  CustomerAPIController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 27/06/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

class CustomerAPIController {
    
    func getListofFarmers(_ completion:@escaping (ServiceResponse<[Farmer]>)->()){
        
        RequestManager.shared.request(.get, apiPath: .getFarmerList, httpBody: nil) { (response) in
            switch response {
                
            case .success(let json):
                
                do {
                    var farmerList = [Farmer]()
                    for farmerRaw in json["customers"].arrayValue {
                        let farmer:Farmer = try JSONDecoder.decode(json: farmerRaw)
                        farmerList.append(farmer)
                    }
                    
                    completion(.success(farmerList))
                    
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
        
    }
    
}

//
//  UserProfileApiController.swift
//  EkaAnalytics
//
//  Created by Nithin on 18/05/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

class UserProfileApiController {

    func getUserProfileDetails(_ completion:@escaping (ServiceResponse<FarmerUserProfile>)->()){
        
        RequestManager.shared.request(.get, apiPath: .getFarmerProfile, httpBody: nil) { (response) in
            switch response {
                
            case .success(let json):
                
                do {
                    let farmerProfile:FarmerUserProfile = try JSONDecoder.decode(json: json)
                    completion(.success(farmerProfile))
                    
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

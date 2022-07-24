//
//  NotificationAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 22/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

class NotificationAPIController{
    
    public static let shared = NotificationAPIController()
    
    private init(){}
    
    func getNotifications(_ completion:@escaping (ServiceResponse<[BusinessAlert]>)->(), _ unSeenCount:@escaping (Int?)->()) {
        
        RequestManager.shared.request(.get, apiPath: .notifications, httpBody: nil) { (response) in
            
            switch response {
                
            case .success(let json):
                
                var notifications = [BusinessAlert]()
                
                for notificationRaw in json["data"].arrayValue{
                    do{
                        let notification:BusinessAlert = try JSONDecoder.decode(json: notificationRaw)
                        notifications.append(notification)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
                completion(.success(notifications))
                
                let unseenCount = json["unseenCount"].int
                unSeenCount(unseenCount)
                
            case .failure(let error):
                completion(.failure(error))
                
            case .failureJson(_):
                break
                
            }
            
        }
        
    }
    
}

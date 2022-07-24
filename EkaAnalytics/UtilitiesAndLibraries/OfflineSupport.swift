//
//  OfflineSupport.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 16/09/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import Foundation

class OfflineSupport {
    
    var nonOfflineAPI:[String] = ["/cac-mobile-app/settings?type=mobile_identity_provider_settings",
    "/cac-mobile-app/login?grant_type=cloud_credentials&client_id=2",
    "/cac-mobile-app/notifications/business-alerts",
    "/workflow"]
    
    var draftAPI:[String] = ["/workflow"]
    
}

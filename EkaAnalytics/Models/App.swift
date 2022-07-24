//
//  App.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

enum AppType : String{
    case StandardApps =  "Standard Apps"
    case MyApps = "My Apps"
}


protocol Serializable {
    var underlyingJSON:JSON{get}
}

//SearchResult protocol inherits Serilizable protocol also
struct App : SearchResult {
    var id : String
    var name : String
    var description : String
    var appType : AppType
    var selectedInsightIDs : [String]
    var isFavourite : Bool
    var categoryName:String
    var isWorkFlowApp : Bool
    //To distinguish between an app and insight in search result
    var entityType: String
    var underlyingJSON: JSON // used to get raw json to write it to a file on disk
}



extension App : JSONDecodable {
    
    init(decoder: JSONDecoder) throws {
        
        self.underlyingJSON = decoder.underlyingJSONData
        self.id = decoder.valueForKeyPath("_id").stringValue
        self.name = decoder.valueForKeyPath("name").stringValue
        self.description = decoder.valueForKeyPath("description").stringValue
        
        let apptype = decoder.valueForKeyPath("apptype").stringValue
        self.appType = AppType(rawValue: apptype)!
        
        self.selectedInsightIDs = decoder.valueForKeyPath("selectedInsightIds").arrayValue.map{$0.stringValue}
        self.isFavourite = decoder.valueForKeyPath("isFavourite").boolValue
        self.categoryName = decoder.valueForKeyPath("category").stringValue
        self.entityType = decoder.valueForKeyPath("entityType").stringValue
        self.isWorkFlowApp = decoder.valueForKeyPath("isWorkFlowApp").boolValue
    }
    
}

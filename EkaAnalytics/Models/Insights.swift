//
//  Insights.swift
//  EkaAnalytics
//
//  Created by Nithin on 30/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation


struct Insight : SearchResult{
    
    var isUnderlyingPermissionDefined : Bool
    var permCodes : [String]
    var description : String
    var timeZone : String
    var updatedDate : TimeInterval
    var version : Double
    var createdBy : String
    var createdDate : TimeInterval
    var underlyingEntityPermissionMap : JSON
    var selectedDataviewIds : [String]
    var name : String
    var chartType : String
    var updatedBy : String
    var id : String
    var securityEnabled : Bool
    var slicerPresent : Bool
    var actions: [JSON]!
    
    var contents:JSON!// This might contain default selected values for a slicer.
    
    
    //To distinguish between an app and insight in search result
    var entityType: String
    
    var underlyingJSON: JSON
    
}

extension Insight:JSONDecodable {
    
    init(decoder: JSONDecoder) throws {
        
        self.underlyingJSON = decoder.underlyingJSONData
        
        self.isUnderlyingPermissionDefined = decoder.valueForKeyPath("isUnderlyingPermissionDefined").boolValue
        self.permCodes = decoder.valueForKeyPath("permCodes").arrayValue.map{$0.stringValue}
        self.description = decoder.valueForKeyPath("description").stringValue
        self.timeZone = decoder.valueForKeyPath("timeZone").stringValue
        self.updatedDate = decoder.valueForKeyPath("updatedDate").doubleValue
        self.version = decoder.valueForKeyPath("version").doubleValue
        self.createdBy = decoder.valueForKeyPath("created_by").stringValue
        self.createdDate = decoder.valueForKeyPath("createdDate").doubleValue
        self.underlyingEntityPermissionMap = decoder.valueForKeyPath("underlyingEntityPermissionMap")
        self.selectedDataviewIds = decoder.valueForKeyPath("selectedDataviewIds").arrayValue.map{$0.stringValue}
        self.name = decoder.valueForKeyPath("name").stringValue
        self.chartType = decoder.valueForKeyPath("chartType").stringValue
        self.updatedBy = decoder.valueForKeyPath("updated_by").stringValue
        self.id = decoder.valueForKeyPath("_id").stringValue
        self.securityEnabled = decoder.valueForKeyPath("securityEnabled").boolValue
        //        self.slicerPresent = decoder.valueForKeyPath("slicerPresent").boolValue
        self.actions = decoder.valueForKeyPath("actions").arrayValue
        self.entityType = decoder.valueForKeyPath("entityType").stringValue
        self.contents = decoder.valueForKeyPath("contents")
        
        let slicerPresent =  self.contents["dataviews"].arrayValue.filter{$0["chartType"].stringValue == ChartType.RadioSlicer.rawValue || $0["chartType"].stringValue == ChartType.ComboSlicer.rawValue || $0["chartType"].stringValue == ChartType.CheckSlicer.rawValue || $0["chartType"].stringValue == ChartType.TagSlicer.rawValue || $0["chartType"].stringValue == ChartType.DateRangeSlicer.rawValue}.count > 0
        
        self.slicerPresent = slicerPresent
        
    }
}

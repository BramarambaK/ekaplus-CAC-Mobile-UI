//
//  Notification.swift
//  EkaAnalytics
//
//  Created by Nithin on 24/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

struct BusinessAlert{
    var name:String
    var status:String
    var runDate:String
    var groupName:String
    var limitType:String
    var valueType:String
    var measureName:String
    var breachLimit:String
    var thresholdLimit:String
    var actuals:String
    var dimensions:String
}


extension BusinessAlert:JSONDecodable{
    init(decoder: JSONDecoder) throws {
        self.name = decoder.valueForKeyPath("Name").stringValue
        self.status = decoder.valueForKeyPath("Status").stringValue
        self.runDate = decoder.valueForKeyPath("Run Date").stringValue
        self.groupName = decoder.valueForKeyPath("Group Name").stringValue
        self.limitType = decoder.valueForKeyPath("Limit Type").stringValue
        self.valueType = decoder.valueForKeyPath("Value Type").stringValue
        self.measureName = decoder.valueForKeyPath("Measure Name").stringValue
        self.breachLimit = decoder.valueForKeyPath("Breach Limit").stringValue
        self.thresholdLimit = decoder.valueForKeyPath("Threshold Limit").stringValue
        self.actuals = decoder.valueForKeyPath("Actuals").stringValue
        self.dimensions = decoder.valueForKeyPath("Dimensions").stringValue
    }
}

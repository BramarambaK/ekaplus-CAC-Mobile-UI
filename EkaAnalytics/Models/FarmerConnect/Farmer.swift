//
//  Farmer.swift
//  EkaAnalytics
//
//  Created by Shreeram on 27/06/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

struct Farmer:Serializable {
    var id:String
    var name:String
    var externalUserId:String
    
    var underlyingJSON: JSON
}


extension Farmer:JSONDecodable{
    init(decoder: JSONDecoder) throws {
        self.id = decoder.valueForKeyPath("id").stringValue
        self.externalUserId = decoder.valueForKeyPath("externalUserId").stringValue
        self.name = decoder.valueForKeyPath("name").stringValue
        self.underlyingJSON = decoder.underlyingJSONData
    }
}

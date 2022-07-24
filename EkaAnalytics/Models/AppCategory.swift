//
//  AppCategory.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

struct AppCategory {
    var name : String
    var id   : Int
    var appsCount:Int
}

extension AppCategory:JSONDecodable {
    init(decoder: JSONDecoder) throws {
        self.name = decoder.valueForKeyPath("name").stringValue
        self.id = decoder.valueForKeyPath("_id").intValue
        self.appsCount = decoder.valueForKeyPath("appsCount").intValue
    }
}


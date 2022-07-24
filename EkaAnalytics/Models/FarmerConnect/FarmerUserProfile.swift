//
//  FarmerUserProfile.swift
//  EkaAnalytics
//
//  Created by Nithin on 18/05/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

struct FarmerUserProfile{
    var firstName:String!
    var lastName:String!
    var fullName:String!
    var mobile:String!
    var phone:String!
    var website:String!
    var accountHolderName:String!
    var bankAddress:String!
    var postalAddress:String!
    var currencyName:String!
    var iban:String!
    var fax:String!
    var email:String!
    var username:String!
    var farmAddresses:[String]!
}

extension FarmerUserProfile:JSONDecodable {
    init(decoder: JSONDecoder) throws {
        self.firstName = decoder.valueForKeyPath("firstName").stringValue
        self.lastName = decoder.valueForKeyPath("lastName").stringValue
        self.fullName = self.firstName + " " + self.lastName
        self.mobile = decoder.valueForKeyPath("mobile").stringValue
        self.phone = decoder.valueForKeyPath("phone").stringValue
        self.website = decoder.valueForKeyPath("website").string
        self.accountHolderName = decoder.valueForKeyPath("accountHolderName").stringValue
        self.bankAddress = decoder.valueForKeyPath("bankAddress").stringValue
        self.postalAddress = decoder.valueForKeyPath("postalAddress").stringValue
        self.currencyName = decoder.valueForKeyPath("currencyName").stringValue
        self.iban = decoder.valueForKeyPath("iban").stringValue
        self.fax = decoder.valueForKeyPath("fax").stringValue
        self.email = decoder.valueForKeyPath("email").stringValue
        self.username = decoder.valueForKeyPath("username").stringValue
        self.farmAddresses = decoder.valueForKeyPath("farmAddresses").arrayValue.map{$0.stringValue}
        
    }
}

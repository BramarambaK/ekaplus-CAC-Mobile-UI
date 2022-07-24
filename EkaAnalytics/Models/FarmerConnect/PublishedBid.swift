//
//  PublishedBid.swift
//  EkaAnalytics
//
//  Created by Nithin on 05/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation


struct PublishedBid {
    var id:String
    var location:String
    var quality:String
    var cropYear:String
    var price:Double
    var expiry:String
    var product:String
    var priceUnit:String
    var quantityUnit:String
    var pricePerUnitQuantity:String
    var incoTerm:String
    var deliveryFromDateInMillis:TimeInterval
    var deliveryToDateInMillis:TimeInterval
    var quantity:Double
    var offerorName:String
    var offerorMobileNo:String
    var offerorRating:String
    var userName:String
    var offerType:String
    var expiryDate:String
    var deliveryFromDate:String
    var deliveryToDate:String
    var paymentTerms:String
    var packingType:String
    var packingSize:String
}

extension PublishedBid:JSONDecodable{
    init(decoder: JSONDecoder) throws {
        self.id = decoder.valueForKeyPath("bidId").stringValue
        self.location = decoder.valueForKeyPath("location").stringValue
        self.quality = decoder.valueForKeyPath("quality").stringValue
        self.cropYear = decoder.valueForKeyPath("cropYear").stringValue
        self.price = decoder.valueForKeyPath("publishedPrice").doubleValue
        self.expiry = decoder.valueForKeyPath("expiresIn").stringValue
        self.product = decoder.valueForKeyPath("product").stringValue
        self.incoTerm = decoder.valueForKeyPath("incoTerm").stringValue
        self.pricePerUnitQuantity = decoder.valueForKeyPath("priceUnit").stringValue
        
        let components = self.pricePerUnitQuantity.components(separatedBy: "/")
        self.priceUnit = components.first ?? ""
        
        if decoder.valueForKeyPath("quantityUnit").stringValue != "" {
            self.quantityUnit = decoder.valueForKeyPath("quantityUnit").stringValue
        }else{
            self.quantityUnit = components.last ?? ""
        }
        
        self.deliveryFromDateInMillis = decoder.valueForKeyPath("deliveryFromDateInMillis").doubleValue
        self.deliveryToDateInMillis = decoder.valueForKeyPath("deliveryToDateInMillis").doubleValue
        self.quantity = decoder.valueForKeyPath("quantity").doubleValue
        self.offerorName = decoder.valueForKeyPath("offerorName").stringValue
        self.offerorMobileNo = decoder.valueForKeyPath("offerorMobileNo").stringValue
        self.offerorRating = decoder.valueForKeyPath("rating").stringValue
        self.userName = decoder.valueForKeyPath("username").stringValue
        self.offerType = decoder.valueForKeyPath("offerType").string ?? "Purchase"
        self.expiryDate = decoder.valueForKeyPath("expiryDate").stringValue
        self.deliveryFromDate = decoder.valueForKeyPath("deliveryFromDate").stringValue
        self.deliveryToDate = decoder.valueForKeyPath("deliveryToDate").stringValue
        self.paymentTerms = decoder.valueForKeyPath("paymentTerms").string ?? ""
        self.packingType = decoder.valueForKeyPath("packingType").string ?? ""
        self.packingSize = decoder.valueForKeyPath("packingSize").string ?? ""
    }
    
}

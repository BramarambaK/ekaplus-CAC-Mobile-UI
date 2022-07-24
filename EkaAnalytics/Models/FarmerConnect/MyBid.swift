//
//  MyBid.swift
//  EkaAnalytics
//
//  Created by Nithin on 05/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

enum BidStatus:String{
    case inProgress = "In-Progress"
    case accepted = "Accepted"
    case rejected = "Rejected"
    case cancelled = "Cancelled"
}

enum BidPendingOn:String{
    case trader = "Offeror"
    case farmer = "Bidder"
    case agent = "Agent"
    case none = "None"
}

struct MyBid {
    var id:String
    var refId:String
    var location:String
    var quality:String
    var quantity:Double
    var cropYear:String
    var status:BidStatus
    var updatedDate:Double
    var clientId:String
    var deliveryFromDateInMillis:TimeInterval
    var deliveryToDateInMillis:TimeInterval
    var publishedPrice:Double
    var product:String
    var pendingOn:BidPendingOn
    var remarks:String
    var latestBidderPrice:Double
    var latestOfferorPrice:Double
    var pricePerUnitQuantity:String
    var quantityUnit:String
    var priceUnit:String
    var lastBidActivityBy:String
    var incoTerm:String
    var offerorName:String
    var offerorMobileNo:String
    var offerorRating:String
    var currentBidRating:String
    var userName:String
    var offerType:String
    var paymentTerms:String
    var packingType:String
    var packingSize:String
}

extension MyBid:JSONDecodable{
    init(decoder: JSONDecoder) throws {
        self.id = decoder.valueForKeyPath("bidId").stringValue
        self.refId = decoder.valueForKeyPath("refId").stringValue
        self.location = decoder.valueForKeyPath("location").stringValue
        self.quality = decoder.valueForKeyPath("quality").stringValue
        self.cropYear = decoder.valueForKeyPath("cropYear").stringValue
        self.status = BidStatus(rawValue: decoder.valueForKeyPath("status").stringValue)!
        self.quantity = decoder.valueForKeyPath("quantity").doubleValue
        self.updatedDate = decoder.valueForKeyPath("updatedDate").doubleValue
        self.clientId = decoder.valueForKeyPath("client_id").stringValue
        self.deliveryFromDateInMillis = decoder.valueForKeyPath("deliveryFromDateInMillis").doubleValue
        self.deliveryToDateInMillis = decoder.valueForKeyPath("deliveryToDateInMillis").doubleValue
        self.publishedPrice = decoder.valueForKeyPath("publishedPrice").doubleValue
        self.product = decoder.valueForKeyPath("product").stringValue
        self.pendingOn = BidPendingOn(rawValue:decoder.valueForKeyPath("pendingOn").stringValue)!
        self.remarks = decoder.valueForKeyPath("latestRemarks").stringValue
        self.latestBidderPrice = decoder.valueForKeyPath("latestBidderPrice").doubleValue
        self.latestOfferorPrice = decoder.valueForKeyPath("latestOfferorPrice").doubleValue
        self.pricePerUnitQuantity = decoder.valueForKeyPath("priceUnit").stringValue
        self.incoTerm = decoder.valueForKeyPath("incoTerm").stringValue
        
        let components = self.pricePerUnitQuantity.components(separatedBy: "/")
        
        self.priceUnit = components.first ?? ""
        self.quantityUnit = components.last ?? ""
        self.lastBidActivityBy = decoder.valueForKeyPath("updatedBy").stringValue
        self.offerorName = decoder.valueForKeyPath("offerorName").stringValue
        self.offerorMobileNo = decoder.valueForKeyPath("offerorMobileNo").stringValue
        self.offerorRating = decoder.valueForKeyPath("rating").stringValue
        self.currentBidRating = decoder.valueForKeyPath("currentBidRating").stringValue
        self.userName = decoder.valueForKeyPath("username").stringValue
        self.offerType = decoder.valueForKeyPath("offerType").string ?? "Purchase"
        self.paymentTerms = decoder.valueForKeyPath("paymentTerms").string ?? ""
        self.packingType = decoder.valueForKeyPath("packingType").string ?? ""
        self.packingSize = decoder.valueForKeyPath("packingSize").string ?? ""
    }
}

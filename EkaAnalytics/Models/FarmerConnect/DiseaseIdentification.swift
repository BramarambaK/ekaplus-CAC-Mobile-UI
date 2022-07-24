//
//  DiseaseIdentification.swift
//  EkaAnalytics
//
//  Created by Shreeram on 10/10/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation


struct DiseaseIdentification {
    var status:String
    var thumb_imageURL:String
    var imageName:String
    var createdDate:TimeInterval
    var analysisResult:String
    var DiseaseType:String
    var InfectionStatus:String
    var requestId:String
    var feedback:String
    var imageURL:String
}


extension DiseaseIdentification:JSONDecodable{
    init(decoder: JSONDecoder) throws {
        self.status = decoder.valueForKeyPath("status").stringValue
        self.thumb_imageURL = decoder.valueForKeyPath("tn_image_url").stringValue
        self.imageName = decoder.valueForKeyPath("imageName").stringValue
        self.createdDate = decoder.valueForKeyPath("createdDate").doubleValue
        self.requestId = decoder.valueForKeyPath("requestId").stringValue
        self.feedback = decoder.valueForKeyPath("feedback").stringValue
        self.imageURL = decoder.valueForKeyPath("image_url").stringValue
        self.analysisResult = (decoder.valueForKeyPath("responseInfo").arrayValue[0].dictionaryValue["message"]?.stringValue ?? "")
        self.InfectionStatus = (decoder.valueForKeyPath("responseInfo").arrayValue[0].dictionaryValue["category"]?.stringValue ?? "")
        self.DiseaseType = (decoder.valueForKeyPath("responseInfo").arrayValue[0].dictionaryValue["processName"]?.stringValue ?? "")
    }
}

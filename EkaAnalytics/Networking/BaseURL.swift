//
//  BaseURL.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation



//class DynamicURL {
//    private var domain:String
//    var url:String!
//
//    init(domain:String) {
//        self.domain = domain
//        self.url = "http://\(domain).integ2.ekaanalytics.com:3017/cac-mobile-app/"
//
//    }
//}
//
//var dynamicURL : DynamicURL?


//struct Environments{
//    static var local = "http://172.16.1.47:7979/cac-mobile-app/"
//
//    static var QA = "http://reference.qa2.ekaanalytics.com:3017/cac-mobile-app/"
//
//    static var Integ = "http://reference.integ2.ekaanalytics.com:3017/cac-mobile-app/"
//
//    static var Pre_Prod = "https://reference.ekaplus.com/cac-mobile-app/"
//
//    static var performance = "http://reference.perf.ekaanalytics.com:8080/cac-mobile-app/"
//}
//
//
//class BaseURL {
//    #if QA      //QA App points to this
//        let url = Environments.Integ
//    #else
//        let url = Environments.Pre_Prod
//    #endif
//}


//User enters the url, to which he wants to connect to
//This base url is set in Login api controller just before hitting login api
var baseURL:String!
var DynamicbaseURL:String = ""
var NLPbaseURL:String = ""
var UIbaseURL:String = ""
var BaseTenantID:String = ""


enum ApiPath : CustomStringConvertible {
    
    
    case appCategories
    case listOfAppsForCategory
    case favouriteApps
    case dataViews
    case visualize
    case collectionHeaderMap(String)  // collectionId/column-map
    case quickEditInfo(String)
    case toggleAppFavourite(appType:String, appId:String)
    case logout
    case search(String)
    case notifications
    case dataViewNamesMap(String)
    case webServerUrl
    case webConfig
    case myBids(String?,String)
    case publishedBids
    case bidLogs(String)
    case basicBidFilterValuesForColumnName(String)
    case login
    case insightsList
    case validateExistingPassword
    case validateNewPassword
    case changePassword
//    case getUserDetails(Int)
    case getFarmerProfile
    case getFarmerList
    case getPermCode(String)
    case createBids(String?)
    case getBidDetails
    case updateBids
    case basicMyBidFilterValuesForColumnName(String?,String)
    case updateSellerRating(String,Int)
    case columnValues
    case getBalanceCount
    case getDiseaseList
    case deleteImage(String)
    case analysisResult(String)
    case updateFeedback(String)
    case validateFileName
    case FirebaseToken
    case PublishOffer(String?)
    case FieldData(String)
    case CancelBid(String)
    case Generalsettings
    case tenantDetails
    case token
    case resendOTP
    case userInfo
    case dateSlicerOptions
    case getPasswordPolicy
    case passwordValidator
    
    var description: String{
        switch self{
        case .login:
            return "login"
        case .insightsList:
            return "insights/"
        case .appCategories:
            return "apps/categoryinfo"
        case .listOfAppsForCategory:
            return  "apps"
        case .favouriteApps:
            return "apps/favourite"
        case .dataViews:
            return "dataviews"
        case .visualize:
            return "dataviews/visualize"
        case .collectionHeaderMap(let collectionId):
            return "collections/\(collectionId)/column-map"
        case .quickEditInfo(let collectionId):
            return "collections/\(collectionId)/quick-edit-info"
        case .toggleAppFavourite(let appType, let appId):
            return "entities/\(appType)/\(appId)/toggle-favourite"
        case .logout:
            return "logout"
        case .search(let searchText):
            return "search?searchBy=\(searchText)"
        case .notifications:
            return "notifications/business-alerts"
        case .dataViewNamesMap(let insightId):
            return "insights/\(insightId)/dataview-name-map"
        case .webServerUrl:
            return "web-view-url"
        case .webConfig:
            return "web-config"
        case .myBids(let farmerId,let apiType):
            if farmerId != nil {
                return "bids/\(apiType)/\(farmerId!)"
            }
            else{
                return "bids/\(apiType)"
            }
        case .publishedBids:
            return "published-bids"
        case .bidLogs(let refId):
            return "bids/logs/\(refId)"
        case .basicBidFilterValuesForColumnName(let columnName):
            return "published-bids/values/\(columnName)"
        case .basicMyBidFilterValuesForColumnName(let farmerId,let columnName):
            if farmerId != nil {
                return "bids/values/\(columnName)/\(farmerId!)"
            }else{
                return "bids/values/\(columnName)"
            }
        case .validateExistingPassword:
            return "validatePassword"
        case .validateNewPassword:
            return "validateNewPassword"
//        case .getUserDetails(let userId):
//            return "user/\(userId)"
        case .changePassword:
            return "change-password"
        case .getFarmerProfile:
            return "customers/my-profile"
        case .getFarmerList:
            return "customers/"
        case .getPermCode(let appId):
            return "permcodes/\(appId)"
        case .createBids(let farmerId):
            if farmerId != nil {
                return "bids/\(farmerId!)"
            }
            else{
                return "bids"
            }
        case .getBidDetails:
            return "bids"
        case .updateBids:
            return "bids"
        case .columnValues:
            return "dataviews/column-values"
        case .getBalanceCount:
            return "analytics/count"
        case .getDiseaseList:
            return "analytics"
        case .deleteImage(let requestId):
            return "analytics/\(requestId)"
        case .analysisResult(let requestId):
            return "analytics/\(requestId)"
        case .updateFeedback(let requestId):
            return "analytics/\(requestId)"
        case .validateFileName:
            return "analytics/validate"
        case .updateSellerRating(let refId,let rating):
            return "bids/ratings/\(refId)/\(rating)"
        case .FirebaseToken:
            return "device-mappings"
        case .PublishOffer(let BidsId):
            if BidsId != nil {
                return "offers/\(BidsId!)"
            }
            else{
                return "offers"
            }
        case .FieldData(let fieldIds):
            return "offers/fields/\(fieldIds)/values"
        case .CancelBid(let BidID):
            return "bids/cancel/\(BidID)"
        case .Generalsettings:
            return "farmerconnect/general-settings"
        case .tenantDetails:
            return "settings"
        case .token:
            return "unique-token"
        case .resendOTP:
            return "regenerate-otp"
        case .userInfo:
            return "userinfo"
        case .dateSlicerOptions:
            return "dataviews/dateSlicerOptions"
        case .getPasswordPolicy:
            return "getPasswordPolicy"
        case .passwordValidator:
            return "passwordValidator"
        }
    }
    
}

enum ConnectApiPath : CustomStringConvertible {
    case none
    case UserInfo
    case MdmApi
    case DataApi
    case LayoutApi
    case SubmitApi
    case MenuApi(String)
    case MetaApi(String)
    case NLPApi
    case RecommendationApi
    case ListofLayoutApi(String)
    case ListofObjectApi
    case userCorpDetails
    case listCorporate
    case switchCorporate
    case policiesDetailApi
    
    var description: String{
        switch self{
        case .UserInfo:
            return DynamicbaseURL + "/userInfo/data"
        case .MdmApi:
            return DynamicbaseURL + "/workflow/mdm"
        case .DataApi:
            return DynamicbaseURL + "/workflow/data"
        case .LayoutApi:
            return DynamicbaseURL + "/workflow/layout"
        case .SubmitApi:
            return DynamicbaseURL + "/workflow"
        case .MenuApi(let appId):
            return DynamicbaseURL + "/meta/menuObject/\(appId)?deviceType=mobile"
        case .MetaApi(let appId):
            return DynamicbaseURL + "/meta/app/\(appId)"
        case .NLPApi:
            return NLPbaseURL + "/workflow/aws-api/process-sentence-v2"
        case .RecommendationApi:
            return DynamicbaseURL + "/workflow/recommendation"
        case .ListofLayoutApi(let appId):
            return DynamicbaseURL + "/meta/workflow/\(appId)"
        case .ListofObjectApi:
            return DynamicbaseURL + "/meta/object"
        case .userCorpDetails:
            return baseURL + "/mdmapi/user/userLoginDetails"
        case .listCorporate:
            return baseURL + "/mdmapi/taglist"
        case .switchCorporate:
            return baseURL + "/mdmapi/masterdatas/switchCorporate"
        case .policiesDetailApi:
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)! + "/spring/policies/detail"
        case .none:
            return DynamicbaseURL
        }
    }
}

//
//  Constants.swift
//  EkaAnalytics
//
//  Created by Nithin on 28/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

enum UserDefaultsKeys:String {
    case accessToken
    case refreshToken
    case sessionTimeOutInSeconds
    case userName
    case clientID
    case userID
    case isFirstLaunchCompleted
    case isUserLoggedIn
    case tenantDomain
    case notificationCount
    case webServerUrl
    case contactUsUrl
    case registrationUrl
    case userType
    case baseURL
    case agentPermission
    case selectedFarmer
    case tenantShortName
    case messengerView
    case supportChatView
    case email
    case clientName
    case user
    case Firebasetoken
    case isQualityLock
    case cancelPermission
    case personalInfoSharingRestricted
    case offerType
    case offerorInfoRestricted
    case offerRatingAllowed
    case refreshTokenValidation
    case identityProviderType
    case enabledSSOMobile
    case ssoClientId
    case isMFAEnabled
    case showEkaLogin
    case uniqueToken
    case authString
    case accountIdentifier
    case signOut
    case disbaleResendOtp
    //OKTA Details
    case redirecturi
    case issuer
    case logoutRedirectUri
    case TenantID
}

enum Segues:String {
    case login
    case domain
    case changedomain
}

enum ObfuscatedConstants {
    
    //Google Analytics Key
#if QA
    //Dev - "UA-116574050-1"
    static let GoogleAnalytickey: [UInt8] = [20, 49, 93, 117, 84, 90, 80, 80, 85, 68, 80, 126, 126, 126]
#else
#if DEBUG
    //Dev - "UA-116574050-1"
    static let GoogleAnalytickey: [UInt8] = [20, 49, 93, 117, 84, 90, 80, 80, 85, 68, 80, 126, 126, 126]
#else
    //Prod - "UA-116607645-1"
    static let GoogleAnalytickey: [UInt8] = [20, 49, 93, 117, 84, 90, 83, 87, 86, 66, 81, 123, 126, 126]
#endif
#endif
    
    //SSL Public hashkey
    static let PublicKeyHashes1:[UInt8] = [52, 35, 58, 124, 21, 93, 31, 95, 2, 21, 17, 57, 58, 59, 16, 82, 63, 91, 36, 22, 73, 17, 20, 21, 36, 93, 30, 22, 30, 7, 30, 36, 54, 1, 35, 60, 4, 7, 51, 36, 6, 32, 22, 81]
    static let PublicKeyHashes2:[UInt8] = [21, 53, 51, 8, 19, 11, 34, 82, 32, 25, 50, 27, 37, 45, 21, 8, 9, 82, 44, 32, 72, 38, 22, 28, 15, 60, 37, 52, 44, 92, 27, 100, 11, 81, 32, 84, 21, 22, 34, 1, 19, 60, 32, 81]
    static let PublicKeyHashes3:[UInt8] = [35, 28, 59, 38, 19, 5, 31, 54, 86, 3, 14, 34, 18, 62, 42, 65, 28, 52, 30, 38, 95, 24, 49, 51, 22, 55, 46, 83, 70, 47, 30, 20, 120, 33, 61, 1, 13, 23, 13, 9, 71, 17, 81, 81]
    
    //Intercom API Key
#if QA
    //QA - Intercom.setApiKey("ios_sdk-8d5fbdfd4acf7742b87a0202ad31b17c38370786", forAppId:"xviunhu8")
    static let IntercomApiKey:[UInt8] = [40, 31, 3, 27, 22, 8, 14, 74, 89, 16, 80, 40, 49, 43, 4, 14, 81, 2, 23, 39, 71, 71, 112, 87, 14, 93, 80, 0, 68, 87, 126, 97, 46, 6, 89, 84, 1, 69, 118, 19, 67, 124, 86, 91, 85, 80, 89, 66]
    static let IntercomAppId:[UInt8] = [57, 6, 25, 49, 11, 4, 16, 95]
#else
#if DEBUG
//    Intercom.setApiKey("ios_sdk-8d5fbdfd4acf7742b87a0202ad31b17c38370786", forAppId:"xviunhu8")
    static let IntercomApiKey:[UInt8] = [40, 31, 3, 27, 22, 8, 14, 74, 89, 16, 80, 40, 49, 43, 4, 14, 81, 2, 23, 39, 71, 71, 112, 87, 14, 93, 80, 0, 68, 87, 126, 97, 46, 6, 89, 84, 1, 69, 118, 19, 67, 124, 86, 91, 85, 80, 89, 66]
    static let IntercomAppId:[UInt8] = [57, 6, 25, 49, 11, 4, 16, 95]
#else
//    Intercom.setApiKey("ios_sdk-a0228013a60e9b03d1660f98b445f505450b93c3", forAppId:"nz59z1ge")
    static let IntercomApiKey:[UInt8] = [40, 31, 3, 27, 22, 8, 14, 74, 0, 68, 87, 124, 107, 127, 83, 89, 4, 85, 68, 36, 73, 18, 116, 86, 8, 84, 81, 87, 68, 3, 119, 107, 45, 86, 94, 80, 5, 65, 113, 69, 68, 113, 85, 14, 92, 84, 2, 71]
    static let IntercomAppId:[UInt8] = [47, 10, 69, 125, 31, 93, 2, 2]
#endif
#endif
    
}

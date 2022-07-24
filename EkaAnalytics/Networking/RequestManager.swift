//
//  RequestManager.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation
import TrustKit
import CoreData

enum RequestType:String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum ServiceResponse<T> {
    case success(T)
    case failure(NetworkingError)
    case failureJson(T)
}

enum NetworkingError:Error, CustomStringConvertible{
    
    case custom(message:String)
    case noInternetConnection
    case generic
    case tokenRefresh
    case tokenExpired
    case invalidJsonResponse
    case failedWithStatusCode(statusCode:Int)
    case unsupportedChart(chartType:String)
    case invalidDomain
    case genericMessage
    case userUnauthorized
    
    var description: String{
        switch self {
        case .noInternetConnection:
            return NSLocalizedString("Please check your internet connectivity.", comment: "")
        case .custom(let message):
            return message
        case .generic:
            return NSLocalizedString("There is a technical issue. Please contact us if the issue persists.", comment: "")
        case .tokenRefresh:
            return NSLocalizedString("The token has been refreshed", comment: "")
        case .tokenExpired:
            return NSLocalizedString("The token has been expired. please login again.", comment: "")
        case .invalidJsonResponse:
            return NSLocalizedString("The response is not in a valid json format.", comment: "")
        case .failedWithStatusCode(let code):
            return NSLocalizedString("Failed with status code", comment: "") + " \(code)"
            
        case . unsupportedChart(_):
            return NSLocalizedString("Dataview not supported on mobile currently.", comment: "")
            
        case .invalidDomain:
            return NSLocalizedString("Either the domain is invalid or service is unavailable. Please try again later.", comment: "invalid domain entered by user")
            
        case .genericMessage:
            return NSLocalizedString("Something went wrong please try again after some time.", comment: "")
        case .userUnauthorized:
            return NSLocalizedString("User Unauthorized.", comment: "")
        }
    }
    //Could not contact the server. Please try after some time.
}

class RequestManager:NSObject,URLSessionDelegate{
    
    static let shared = RequestManager()
    private override init(){}
    
    private var cacheQueue : OperationQueue?
    
    func request(_ type:RequestType,apiPath:ApiPath? = nil,connectApiPath:ConnectApiPath? = nil,requestURL:String? = nil,queryParameters:String? = nil, httpBody:String? = nil , headers:([String:String])? = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "User-Id":UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "", "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()],connectHeaders:([String:String])? = ["Content-Type":"application/json","X-TenantID":BaseTenantID,"Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")","X-ObjectAction":"CREATE","X-Locale":"en-US","Device-Id":Utility.getVendorID(),"sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()],shouldCacheWithDiskUrl:URL? = nil, bodyData:Data? = nil, block:@escaping (ServiceResponse<JSON>) -> ()){
        
//        print(headers)

        //We give default value because, in appdelegate we fire webconfig request, by that time, we would not have any url entered by user, so baseURL would be nil.
        
        var urlString:String = ""
        
        if apiPath != nil {
            urlString = (baseURL ?? "https://reference.ekaplus.com" ) + "/cac-mobile-app/" + apiPath!.description + (queryParameters ?? "")
        }else if connectApiPath != nil {
            urlString = connectApiPath!.description +  (queryParameters ?? "")
        }else{
            urlString = requestURL! +  (queryParameters ?? "")
        }
        
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url:URL = URL(string: urlString)!
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
           
        
        var request = URLRequest(url: url)
        request.httpMethod = type.rawValue
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        request.timeoutInterval = 30
        
        print(urlString)
        
        if (type == .post || type == .put || type == .delete){
            request.httpBody = httpBody?.data(using: String.Encoding.utf8)  ?? bodyData  ?? nil
        }
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if apiPath != nil || requestURL != nil{
            if let headers = headers {
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
        }else {
            if let headers = connectHeaders{
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
            }
        }
        
        //        print(request.url?.absoluteString)
        
        guard  Reachability.isConnectedToNetwork() else {
            
            if baseURL != nil && OfflineSupport().draftAPI.contains(request.url!.absoluteString.replacingOccurrences(of: DynamicbaseURL, with: "")){
                self.saveDraftApiDetails(Url: "\(request.url!.absoluteString)", requestHeader: (headers?.jsonString(true)),requestBody:httpBody)
                block(.failure(.custom(message: "No Internet Connection.So Data stored offline.")))
            }else if  let resultJson = self.fetchData(Url: "\(request.url!.absoluteString)",requestBody:httpBody) {
                block(.success(resultJson))
            }else{
                //If cache is enabled, return the cached data if any, in offline mode.
                if let cacheUrl = shouldCacheWithDiskUrl, let stream = InputStream(url: cacheUrl) {
                    stream.open()
                    defer {stream.close()}
                    if let cachedJson = try? JSONSerialization.jsonObject(with: stream, options: []), let unwrappedJson = JSON.init(rawValue: cachedJson) {
                        
                        block(.success(unwrappedJson))
                        
                    } else {
                        block(.failure(.noInternetConnection))
                    }
                } else {
                    block(.failure(.noInternetConnection))
                }
            }
            return
        }
        
        session.dataTask(with: request){
            (data, response, error) in
            
            guard let data:Data = data, let _:URLResponse = response  , error == nil else {
                DispatchQueue.main.async {
                    
                    let errorCode = (error! as NSError).code
                    
                    switch errorCode{
                    case -1202, -1200, -1004, -1003 :
                        block(.failure(.invalidDomain))
                        
                    case -999:
                        print(error?.localizedDescription ?? "Error")
                        
                    default:
                        block(.failure(.custom(message: error?.localizedDescription ?? "Error")))
                    }
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
                
            }
            
            
            
            if let httpResponse = response as? HTTPURLResponse {
                
                switch httpResponse.statusCode {
                    
                case 200 :
                    
                    DispatchQueue.main.async{
                        
                        guard let json =  try? JSON(data:data) else {
                            DispatchQueue.main.async{
                                if let jsonString  = String(decoding: data, as: UTF8.self).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
                                    
                                    guard let json1 =  try? JSON(parseJSON: (jsonString.replacingOccurrences(of: "%EF%BF%BD", with: "%C2%B0")).removingPercentEncoding!) else {
                                        DispatchQueue.main.async{
                                            block(.failure(.generic))
                                        }
                                        return
                                    }
                                    block(.success(json1))
                                    
                                }else{
                                    block(.failure(.generic))
                                }
                                
                                
                            }
                            return
                        }
                        
                        if baseURL != nil && !OfflineSupport().nonOfflineAPI.contains(request.url!.absoluteString.replacingOccurrences(of: baseURL, with: "")){
                            self.saveApiDetails(Url: "\(request.url!.absoluteString)", requestHeader: (headers?.jsonString(true)),requestBody:httpBody, responseBody: String(data: data, encoding: String.Encoding.utf8))
                        }
                        
                      
 
                        //On success callback completion handler
                        block(.success(json))
                        
                        //If response should be cacahed, write it to a file on disk
                        if let cacheUrl = shouldCacheWithDiskUrl {
                            self.cacheQueue = OperationQueue()
                            self.cacheQueue?.addOperation {
                                if let stream = OutputStream(url: cacheUrl, append: false) {
                                    stream.open()
                                    defer {stream.close()}
                                    JSONSerialization.writeJSONObject(json.rawValue, to: stream, options: [], error: nil)
                                }
                            }
                            
                        }
                    }
                    
                    
                case 401:
                    
                    guard let json =  try? JSON(data:data) else {
                        DispatchQueue.main.async{
                            block(.failure(.generic))
                        }
                        return
                    }
                    
                    if UserDefaults.standard.bool(forKey: UserDefaultsKeys.refreshTokenValidation.rawValue){
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.refreshTokenValidation.rawValue)
                        //Token expired, fire login api again to get a new token
                        guard let access_token = UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue), let refresh_token = UserDefaults.standard.string(forKey: UserDefaultsKeys.refreshToken.rawValue) else{
                            return
                        }

                        LoginApiController.refreshAccessToken(accessToken: access_token, refreshToken: refresh_token) { (response) in
                            switch response {
                            case .success(_):
                                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.refreshTokenValidation.rawValue)
                                block(.failure(.tokenRefresh))

                            case .failure(let error):

                                block(.failure(error))
                            case .failureJson(_):
                                break
                            }
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            DispatchQueue.main.async {
                                
                                if  json["error_description"].string == nil {
                                    
                                    if  json["localizedMessage"].string != nil {
                                        
                                        block(.failure(.custom(message: json["localizedMessage"].stringValue)))
                                        
                                        /*
                                         // Load Data
                                         let data = Data(json["localizedMessage"].stringValue.utf8)
                                         
                                         
                                         // Deserialize JSON
                                         let cachedJson = try! JSONSerialization.jsonObject(with: data, options: [])
                                         
                                         let metaJson = JSON.init(rawValue: cachedJson)
                                         
                                         block(.failure(.custom(message: metaJson!["error_description"].stringValue)))
                                         */
                                    }else if  json["msg"].string != nil{
                                        // Load Data
                                        let data = Data(json["msg"].stringValue.utf8)
                                        
                                        
                                        // Deserialize JSON
                                        let cachedJson = try! JSONSerialization.jsonObject(with: data, options: [])
                                        
                                        let metaJson = JSON.init(rawValue: cachedJson)
                                        
                                        block(.failure(.custom(message: metaJson!["error_description"].stringValue)))
                                    }else{
                                        block(.failure(.genericMessage))
                                    }
                                }
                                else{
                                    block(.failure(.custom(message: json["error_description"].stringValue)))
                                }
                            }
                        }
                    }
                    
                    
                    
                    
                    /*
                    
                   
                    
                    DispatchQueue.main.async {
                        
                        if  json["error_description"].string == nil {
                            
                            if  json["localizedMessage"].string != nil {
                                
                                 block(.failure(.custom(message: json["localizedMessage"].stringValue)))
                                
                                /*
                                // Load Data
                                let data = Data(json["localizedMessage"].stringValue.utf8)
                                
                                
                                // Deserialize JSON
                                let cachedJson = try! JSONSerialization.jsonObject(with: data, options: [])
                                
                                let metaJson = JSON.init(rawValue: cachedJson)
                                
                                block(.failure(.custom(message: metaJson!["error_description"].stringValue)))
 */
                            }else if  json["msg"].string != nil{
                                // Load Data
                                let data = Data(json["msg"].stringValue.utf8)
                                
                                
                                // Deserialize JSON
                                let cachedJson = try! JSONSerialization.jsonObject(with: data, options: [])
                                
                                let metaJson = JSON.init(rawValue: cachedJson)
                                
                                block(.failure(.custom(message: metaJson!["error_description"].stringValue)))
                            }else{
                                block(.failure(.genericMessage))
                            }
                        }
                        else{
                            block(.failure(.custom(message: json["error_description"].stringValue)))
                        }
                    }
                    */
                    
                case 406:
                    
                    //Token expired, fire login api again to get a new token
                    guard let access_token = UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue), let refresh_token = UserDefaults.standard.string(forKey: UserDefaultsKeys.refreshToken.rawValue) else{
                        return
                    }
                    
                    LoginApiController.refreshAccessToken(accessToken: access_token, refreshToken: refresh_token) { (response) in
                        switch response {
                        case .success(_):
                            
                            block(.failure(.tokenRefresh))
                            
                        case .failure(let error):
                            
                            block(.failure(error))
                        case .failureJson(_):
                            break
                        }
                    }
                    
                    
                    /*
                    //Token expired, fire login api again to get a new token
                    guard let userName:String = Keychain.value(forKey: UserDefaultsKeys.userName.rawValue), let domain:String = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue),
                        let password:String = Keychain.value(forKey: UserDefaultsKeys.password.rawValue) else {
                            DispatchQueue.main.async {
                                block(.failure(.tokenExpired))
                            }
                            return
                    }
                    
                    LoginApiController.loginWithCredentials(userName: userName, password: password, domain:domain, completion: { (response) in
                        
                        switch response {
                        case .success(_):
                            
                            block(.failure(.tokenRefresh))
                            
                        case .failure(let error):
                            
                            block(.failure(error))
                        }
                        
                    })
                    */
                case 204:
                    //No content
                    DispatchQueue.main.async {
                        block(.failure(.failedWithStatusCode(statusCode:204)))
                    }
                    
                case 201:
                    //                    //Content created
                    //                    DispatchQueue.main.async {
                    //                        block(.success(JSON(["success":true])))
                    //                    }
                    
                    DispatchQueue.main.async{
                        
                        guard let json =  try? JSON(data:data) else {
                            DispatchQueue.main.async{
                                if let jsonString  = String(decoding: data, as: UTF8.self).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed){
                                    
                                    guard let json1 =  try? JSON(parseJSON: (jsonString.replacingOccurrences(of: "%EF%BF%BD", with: "%C2%B0")).removingPercentEncoding!) else {
                                        DispatchQueue.main.async{
                                            block(.failure(.generic))
                                        }
                                        return
                                    }
                                    block(.success(json1))
                                    
                                }else{
                                    block(.failure(.generic))
                                }
                                
                                
                            }
                            return
                        }
                        
                        //On success callback completion handler
                        block(.success(json))
                        
                        //If response should be cacahed, write it to a file on disk
                        if let cacheUrl = shouldCacheWithDiskUrl {
                            self.cacheQueue = OperationQueue()
                            self.cacheQueue?.addOperation {
                                if let stream = OutputStream(url: cacheUrl, append: false) {
                                    stream.open()
                                    defer {stream.close()}
                                    JSONSerialization.writeJSONObject(json.rawValue, to: stream, options: [], error: nil)
                                }
                            }
                            
                        }
                    }
                    
                case 503:
                    
                    //This occurs because user might have entered an invalid domain when loging in
                    DispatchQueue.main.async {
                        block(.failure(.invalidDomain))
                    }
                    
                case 400:
                    
                    DispatchQueue.main.async{
                        guard let json =  try? JSON(data:data) else {
                            DispatchQueue.main.async{
                                block(.failure(.generic))
                            }
                            return
                        }
                        
                        var msg = "Failed with status code:\(httpResponse.statusCode)"
                        
                        if let msgFromServer = json["errorMessage"].string {
                            msg = msgFromServer
                            block(.failureJson(json))
                            return
                        }else  if let msgFromServer = json["msg"].string {
                            msg = msgFromServer
                        }
                        
                        block(.failure(.custom(message:msg)))
                    }

                case 403:
                    
                    DispatchQueue.main.async{
                        guard (try? JSON(data:data)) != nil else {
                            DispatchQueue.main.async{
                                block(.failure(.userUnauthorized))
                            }
                            return
                        }
                        
                        block(.failure(.failedWithStatusCode(statusCode: httpResponse.statusCode)))
                    }
                    
                case 500 :
                    DispatchQueue.main.async{
                        guard (try? JSON(data:data)) != nil else {
                            DispatchQueue.main.async{
                                block(.failure(.generic))
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            block(.failure(.genericMessage))
                        }
                    }
                    
                default:
                    
                    DispatchQueue.main.async{
                        guard let json =  try? JSON(data:data) else {
                            DispatchQueue.main.async{
                                block(.failure(.generic))
                            }
                            return
                        }
                        
                        var msg = "Failed with status code:\(httpResponse.statusCode)"
                        
                        if let msgFromServer = json["errorMessage"].string {
                            msg = msgFromServer
                            block(.failureJson(json))
                            return
                        }else if let msgFromServer = json["msg"].string {
                            msg = msgFromServer
                        }
                        
                        block(.failure(.custom(message:msg)))
                    }
                    
                    
                }//Switch closing
                
            } //If let closing
            
            session.finishTasksAndInvalidate()
            
            }.resume()
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
       // Call into TrustKit here to do pinning validation
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            // TrustKit did not handle this challenge: perhaps it was not for server trust
            // or the domain was not pinned. Fall back to the default behavior
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    //Save Value to CoreData
    
    func saveApiDetails(Url: String,requestHeader:String?,requestBody:String?,responseBody:String?) {
        
        if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {             print("Documents Directory: \(directoryLocation)Application Support")         }
        
        
        let appDelegate = CoreDataStack.sharedInstance
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ApiDetails")
        if requestBody == nil {
            fetchRequest.predicate = NSPredicate(format: "url = %@",Url )
        }else{
            fetchRequest.predicate = NSPredicate(format: "url = %@ AND requestBody = %@",argumentArray:[Url,requestBody!] )
        }
        
        
        do{
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                let  entityData = results![0]
                entityData.setValue(Url, forKeyPath: "url")
                if requestHeader != nil {
                    entityData.setValue(requestHeader, forKey: "requestHeader")
                }
                if requestBody != nil {
                    entityData.setValue(requestBody, forKey: "requestBody")
                }
                if responseBody != nil {
                    entityData.setValue(responseBody, forKey: "responseBody")
                }
                entityData.setValue(Date(), forKey: "updatedDate")
            }else{
                let entity = NSEntityDescription.entity(forEntityName: "ApiDetails",in: managedContext)!
                let entityData = NSManagedObject(entity: entity,insertInto: managedContext)
                entityData.setValue(Url, forKeyPath: "url")
                if requestHeader != nil {
                    entityData.setValue(requestHeader, forKey: "requestHeader")
                }
                if requestBody != nil {
                    entityData.setValue(requestBody, forKey: "requestBody")
                }
                if responseBody != nil {
                    entityData.setValue(responseBody, forKey: "responseBody")
                }
                entityData.setValue(Date(), forKey: "createdDate")
                entityData.setValue(Date(), forKey: "updatedDate")
            }
        }catch{
            print("Fetch Failed: \(error)")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveDraftApiDetails(Url: String,requestHeader:String?,requestBody:String?) {
        
        if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {             print("Documents Directory: \(directoryLocation)Application Support")         }
        
        let appDelegate = CoreDataStack.sharedInstance
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "DraftApiDetails",in: managedContext)!
        let entityData = NSManagedObject(entity: entity,insertInto: managedContext)
        entityData.setValue(Date(), forKey: "createdDate")
        entityData.setValue(JSON.init(parseJSON: requestBody!)["task"].stringValue, forKey: "task")
        entityData.setValue(requestBody, forKey: "responseBody")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchDraftData(taskId: String)->[JSON]?{
        let appDelegate = CoreDataStack.sharedInstance
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DraftApiDetails")
        
        fetchRequest.predicate = NSPredicate(format: "task = %@",taskId)
        
        do{
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                var responseJson:[JSON] = []
                for data in results!{
                    let Json = JSON.init(parseJSON: "\(data.value(forKeyPath: "responseBody")!)")["output"][taskId]
                    responseJson.append(Json)
                }
                return responseJson
            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func fetchData(Url: String,requestBody:String?)->JSON?{
        let appDelegate = CoreDataStack.sharedInstance
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ApiDetails")
        if requestBody == nil {
            fetchRequest.predicate = NSPredicate(format: "url = %@",Url )
        }else{
            fetchRequest.predicate = NSPredicate(format: "url = %@ AND requestBody = %@",argumentArray:[Url,requestBody!] )
        }
        
        
        do{
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if results?.count != 0 {
                for data in results!{
                    return JSON.init(parseJSON: "\(data.value(forKeyPath: "responseBody")!)")
                }
            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func deleteAllData(entity: String)
    {
        let appDelegate =  CoreDataStack.sharedInstance
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entity))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
        }
    }
    
    func jsonToString(json: AnyObject){
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            let convertedString = String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
            print(convertedString ?? "") // <-- here is ur string
            
        } catch let myJSONError {
            print(myJSONError)
        }
    }
    
}


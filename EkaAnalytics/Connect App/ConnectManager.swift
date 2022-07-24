//
//  ConnectManager.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 13/04/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit
import CoreData
import JavaScriptCore

class ConnectManager: NSObject {
    static let shared = ConnectManager()
    
    //Evaluate the Java Expression and returns the result.
    func evaluateJavaExpression(expression:String,data:JSON?,_ dataType:String? = nil)->Any{
        
        if expression != "" {
            
            var ExpressionString:String = expression
            
            if data != nil {
                for _ in 0 ..< expression.count {
                    if ExpressionString.contains("${") == true {
                        ExpressionString = self.getExpressionString(expression: ExpressionString, data: data)
                    }else{
                        break
                    }
                }
            }
            
            if ExpressionString.first == "'" && ExpressionString.last == "'" {
                ExpressionString = "return \(ExpressionString)"
            }
            
            let jsSource = "var javascriptFunc = function() {\(ExpressionString)}"
            
            let context = JSContext()
            context?.evaluateScript(jsSource)
            
            let javaFunction = context?.objectForKeyedSubscript("javascriptFunc")
            let result = javaFunction?.call(withArguments: [])
            
            switch dataType {
            case "detailsArray":
                return result!.toArray() ?? ""
            default:
                return result!.toString() ?? ""
            }
        }
        
        return ""
    }
    
    //Get the string from Expression
    private func getExpressionString(expression:String,data:JSON?)->String{
        
        var expressionString:String = ""
        
        let expressionStartIndex =  expression.range(of: "${")?.upperBound
        let expressionEndIndex =  expression.range(of: "}")?.lowerBound
        
        if expressionStartIndex != nil && expressionEndIndex != nil {
            var tempString = ""
            if expression.contains("'${") == true {
                tempString = String(expression[(expression.range(of: "'${"))!.lowerBound..<expression.endIndex])
            }else{
                tempString = String(expression[(expression.range(of: "${"))!.lowerBound..<expression.endIndex])
            }
            let expressionSubstring = tempString[(tempString.range(of: "${"))!.upperBound..<(tempString.range(of: "}"))!.lowerBound]
            let expressionReplaceSubstring = tempString[(tempString.range(of: "${"))!.lowerBound ..< (tempString.range(of: "}"))!.upperBound]
            if data != nil {
                if data!["\(expressionSubstring)"].string != nil {
                    expressionString =  expression.replacingOccurrences(of: expressionReplaceSubstring, with: data!["\(expressionSubstring)"].stringValue)
                }else{
                    expressionString =  expression.replacingOccurrences(of: expressionReplaceSubstring, with: data!["\(expressionSubstring)"].rawString()!)
                }
            }
        }
        
        return expressionString
    }
    
    //Get User Info
    func getConnectUserInfo(completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        let dataBodyDictionary:[String:Any] = ["userName":UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]
        
        RequestManager.shared.request(.post,connectApiPath: .UserInfo, httpBody: dataBodyDictionary.jsonString()) { (result) in
            switch result {
            case .success(let jsonData):
                completionhandler(.success(jsonData))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
        
    }
    
    //get MDMValue
    func getMdmData(bodyObject:[String : Any],completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        RequestManager.shared.request(.post, connectApiPath: .MdmApi, bodyData: bodyData) { (result) in
            switch result {
            case .success(let jsonData):
                completionhandler(.success(jsonData))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
        
    }
    
    //Get ScreenData
    func getScreenData(dataBodyDictionary:[String : Any],completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.post, connectApiPath: .DataApi,httpBody: dataBodyDictionary.jsonString(true).replacingOccurrences(of: "\\", with: "")) { (result) in
            switch result {
            case .success(let jsonData):
                completionhandler(.success(jsonData))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
    }
    
    //Submit API Call
    func submitRecord(type:RequestType,dataBodyDictionary:[String : Any],completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(type, connectApiPath: .SubmitApi,httpBody: dataBodyDictionary.jsonString(true).replacingOccurrences(of: "\\", with: "")) { (result) in
            switch result {
            case .success(let jsonData):
                completionhandler(.success(jsonData))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
    }
    
    // NavBarDetails
    func getNavBarDetails(app_Id:String,completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.get, connectApiPath: .MenuApi(app_Id)) { (result) in
            switch result {
            case .success(let jsonData):
                completionhandler(.success(jsonData))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
    }
    
    func getConnectDetails(app_Id:String,completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.post, connectApiPath: .MetaApi(app_Id)) { (result) in
            switch result {
            case .success(let jsonData):
                completionhandler(.success(jsonData))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
        
    }
    
    //Get layout Details
    func getWorkFlowDetails(dataBodyDictionary:[String : Any],completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.post, connectApiPath: .LayoutApi,httpBody: dataBodyDictionary.jsonString(true)) { (result) in
            switch result {
            case .success(let jsonData):
                completionhandler(.success(jsonData))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
    }
    
    func getProcessedString(dataBodyDictionary:[String : Any],completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.post, connectApiPath: .NLPApi,httpBody: dataBodyDictionary.jsonString(true)) { (response) in
            switch response {
            case .success(let json):
                completionhandler(.success(json))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
    }
    
    func getRecommendationString(dataBodyDictionary:[String : Any],completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.post, connectApiPath: .RecommendationApi,httpBody: dataBodyDictionary.jsonString(true)) { (response) in
            switch response {
            case .success(let json):
                completionhandler(.success(json))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
    }
    
    func getAndSavelistoflayout(appId:String){
        
        let header:[String:String] = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "User-Id":UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "", "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString(),"deviceType":"mobile"]
        
        RequestManager.shared.request(.get, connectApiPath: .ListofLayoutApi(appId),connectHeaders: header) { (response) in
            switch response {
            case .success(let json):
                
                if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {             print("Documents Directory: \(directoryLocation)Application Support")         }
                
                let appDelegate = CoreDataStack.sharedInstance
                let managedContext = appDelegate.persistentContainer.viewContext
                
                let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "OfflineLayout")
                
                for i in 0..<json.count {
                    if json[i]["layout"]["offlineSupport"].boolValue == true {
                        fetchRequest.predicate = NSPredicate(format: "taskId = %@ AND layoutDetails = %@",argumentArray:[json[i]["taskId"].stringValue,json[i].stringValue] )
                        
                        do{
                            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
                            if results?.count == 0 {
                                fetchRequest.predicate = NSPredicate(format: "taskId = %@",json[i]["taskId"].stringValue)
                                let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
                                if results?.count != 0 {
                                    let  entityData = results![0]
                                    entityData.setValue(json[i]["taskId"].stringValue, forKeyPath: "taskId")
                                    entityData.setValue(json[i].stringValue, forKey: "layoutDetails")
                                    entityData.setValue(Date(), forKey: "updatedDate")
                                }else{
                                    let entity = NSEntityDescription.entity(forEntityName: "OfflineLayout",in: managedContext)!
                                    let entityData = NSManagedObject(entity: entity,insertInto: managedContext)
                                    entityData.setValue(json[i]["taskId"].stringValue, forKeyPath: "taskId")
                                    entityData.setValue(json[i].stringValue, forKey: "layoutDetails")
                                    entityData.setValue(Date(), forKey: "createdDate")
                                    entityData.setValue(Date(), forKey: "updatedDate")
                                }
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
                }
            case .failure(let error):
                print(error)
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
    
    func getlistofObject(completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.get, connectApiPath: .ListofObjectApi) { (response) in
            switch response {
            case .success(let json):
                completionhandler(.success(json))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
        
    }
    
    func getListOfDateOptions(completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        RequestManager.shared.request(.get, apiPath: .dateSlicerOptions) { response in
            switch response {
            case .success(let json):
                completionhandler(.success(json))
            case .failure(let error):
                completionhandler(.failure(error))
            case .failureJson(let errorJson):
                completionhandler(.failureJson(errorJson))
            }
        }
    }
    
    //Append Dynamic Data
    func appendDynamicData(Meta:[JSON],Data:[JSON],completionhandler:@escaping ([JSON]) -> ()){
        var resultData:[JSON] = []
        var dynamicValue:[JSON] = []
        
        if Data.count > 0 {
            for individualMeta in Meta {
                if individualMeta["valueExpression"] != nil {
                    dynamicValue.append(individualMeta)
                }
            }
            
            for each in Data {
                var tempData = each.dictionaryObject
                for individualMeta in dynamicValue{
                    let result = self.evaluateJavaExpression(expression: individualMeta["valueExpression"].stringValue, data: each)
                    tempData![individualMeta["key"].stringValue] = result
                }
                resultData.append(JSON(tempData!))
            }
        }
        
        completionhandler(resultData)
    }
    
    func DeleteDataFromCoredata(task:String,responseBody:String?){
        
        //Print the Documents Directory
        if let directoryLocation = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last {             print("Documents Directory: \(directoryLocation)Application Support")         }
        
        let appDelegate = CoreDataStack.sharedInstance
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "DraftApiDetails")
        
        fetchRequest.predicate = NSPredicate(format: "task = %@",task)
        
        do{
            let results = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            
            if results?.count != 0 {
                for data in results!{
                    let Json = JSON.init(parseJSON: "\(data.value(forKeyPath: "responseBody")!)")["output"][task]
                    if Json == JSON.init(parseJSON: responseBody!){
                        managedContext.delete(data)
                        return
                    }
                }
            }
            
        }catch{
            print("Delete Data Error: \(error)")
        }
        
    }
    
    //Below Function is used to load a JSON file from a file
    func loadJSONfromfile(filename:String)->JSON{
        if let path = Bundle.main.path(forResource: filename, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonObj = try JSON(data: data)
                return jsonObj
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            print("Invalid filename/path.")
        }
        return JSON.init(parseJSON: "{}")
    }
    
}

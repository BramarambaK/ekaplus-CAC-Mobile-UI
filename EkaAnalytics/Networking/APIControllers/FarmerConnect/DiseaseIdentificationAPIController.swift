//
//  DiseaseIdentificationAPIController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 08/10/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

class DiseaseIdentificationAPIController {
    
    func getBalanceCount(_ completion:@escaping (ServiceResponse<JSON>)->()){
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        print(header)
        
        RequestManager.shared.request(.get, apiPath: .getBalanceCount, httpBody: nil, headers: header) { (response) in
            
            switch response {
            case .success(let json):
                completion(.success(json))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func getIdentifiedList(_ completion:@escaping (ServiceResponse<[DiseaseIdentification]>)->()){
        
        let queryParam = "?count=20&orderby=desc&format=Summary"
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        RequestManager.shared.request(.get, apiPath: .getDiseaseList, queryParameters: queryParam, httpBody: nil, headers: header) { (response) in
            switch response {
            case .success(let json):
                
                do {
                    var DiseaseList = [DiseaseIdentification]()
                    for DiseaseRaw in json["response"].arrayValue {
                        let individulaDisease:DiseaseIdentification  = try JSONDecoder.decode(json: DiseaseRaw)
                        DiseaseList.append(individulaDisease)
                    }
                    
                    completion(.success(DiseaseList))
                    
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func deleteInvalidImage(requestId:String, completion:@escaping (ServiceResponse<Bool>)->()) {
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        RequestManager.shared.request(.delete, apiPath: .deleteImage(requestId), httpBody: nil, headers: header) { (response) in
            
            switch response {
            case .success( _):
                completion(.success(true))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func getAnalysisresult(requestId:String, completion:@escaping (ServiceResponse<DiseaseIdentification>)->()){
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        let queryParam = "?format=details"
        
        RequestManager.shared.request(.get, apiPath: .analysisResult(requestId), queryParameters: queryParam, httpBody: nil, headers: header) { (response) in
            switch response {
            case .success(let json):
                
                do {
                    let DiseaseRaw = json["response"].arrayValue[0]
                    let individulaDisease:DiseaseIdentification  = try JSONDecoder.decode(json: DiseaseRaw)
                    completion(.success(individulaDisease))
                    
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
    }
    
    func updateFeedBack(requestId:String?,feedback:String){
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","Content-Type":"application/json","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        let body:[String:Any] = ["feedback":feedback]
        
        
        RequestManager.shared.request(.put, apiPath: .updateFeedback(requestId!), queryParameters: nil, httpBody: body.jsonString(), headers: header, shouldCacheWithDiskUrl: nil, bodyData: nil) { (response) in
            
            switch response {
            case .success(_):
                break
            case .failure(let error):
                print(error.localizedDescription)
            case .failureJson(_):
                break
            }
        }
        
    }
    
    func validateFileName(FileName:String, completion:@escaping (ServiceResponse<Bool>)->()){
        
        let header = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "","sourceDeviceId":Utility.getVendorID(),"requestId":Utility.getRandomString()]
        
        let queryParam = "?imageName=\(FileName)"
        
        
        RequestManager.shared.request(.get, apiPath: .validateFileName, requestURL: nil, queryParameters: queryParam, httpBody: nil, headers: header, shouldCacheWithDiskUrl: nil, bodyData: nil) { (response) in
            switch response {
            case .success(let json):
                let validationResult = json["isDuplicateName"].boolValue
                completion(.success(validationResult))
                
            case .failure(let error):
                completion(.failure(error))
            case .failureJson(_):
                break
            }
        }
        
    }
    
    
    func uploadImage(uploadImage:UIImage,fileName:String, completion:@escaping (ServiceResponse<String>)->()){
        
        guard  Reachability.isConnectedToNetwork() else {
            completion(.failure(.noInternetConnection))
            return
        }
        
        let UploadImageUrl = URL(string: "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "")/spring/analytics/upload?access_token=\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")");
        
        let request = NSMutableURLRequest(url:UploadImageUrl!);
        request.httpMethod = "POST";
        
        let headers = ["Authorization":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")", "Device-Id":Utility.getVendorID(), "Tenant-Domain": UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? ""]
        
        let param: [String:Any] = ["requestJSON" : [
            "user":"\(UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue) ?? "")","imageName":["\(fileName)"], "processTypes":["coffee_wsb_disease"]]]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = uploadImage.jpegData(compressionQuality: 1)
        
        //        let imageData = selectedImage.jpegData(compressionQuality: 1)
        
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "files", imageDataKey: imageData!, fileName: fileName, boundary: boundary) as Data
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let data:Data = data, let _:URLResponse = response  , error == nil else {
                DispatchQueue.main.async {
                    
                    let errorCode = (error! as NSError).code
                    
                    switch errorCode{
                    case -1202, -1200, -1004, -1003 :  completion(.failure(.invalidDomain))
                        
                    default:
                        completion(.failure(.custom(message: error?.localizedDescription ?? "Error")))
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
                                completion(.failure(.generic))
                            }
                            return
                        }
                        
                        //On success callback completion handler
                        completion(.success("True"))
                        
                    }
                    
                    
                case 401:
                    
                    guard let json =  try? JSON(data:data) else {
                        DispatchQueue.main.async{
                            completion(.failure(.generic))
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion(.failure(.custom(message: json["error_description"].stringValue)))
                    }
                    
                    
                case 406:
                    
                    //Token expired, fire login api again to get a new token
                    guard let access_token = UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue), let refresh_token = UserDefaults.standard.string(forKey: UserDefaultsKeys.refreshToken.rawValue) else{
                        return
                    }
                    
                    LoginApiController.refreshAccessToken(accessToken: access_token, refreshToken: refresh_token) { (response) in
                        switch response {
                        case .success(_):
                            
                            completion(.failure(.tokenRefresh))
                            
                        case .failure(let error):
                            
                            completion(.failure(error))
                        case .failureJson(_):
                            break
                        }
                    }
                    
                case 204:
                    //No content
                    DispatchQueue.main.async {
                        completion(.failure(.failedWithStatusCode(statusCode:204)))
                    }
                    
                    
                default:
                    
                    DispatchQueue.main.async{
                        guard let json =  try? JSON(data:data) else {
                            DispatchQueue.main.async{
                                completion(.failure(.generic))
                            }
                            return
                        }
                        
                        var msg = "Failed with status code:\(httpResponse.statusCode)"
                        
                        if let msgFromServer = json["msg"].string {
                            msg = msgFromServer
                        }
                        completion(.failure(.custom(message:msg)))
                    }
                    
                    
                }//Switch closing
                
            } //If let closing
            
        }
        
        task.resume()
        
        
        
    }
    
    private func createBodyWithParameters(parameters: [String: Any]?, filePathKey: String?, imageDataKey: Data,fileName: String, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                
                let dictionary = value
                if let theJSONData = try?  JSONSerialization.data(
                    withJSONObject: dictionary,
                    options: .prettyPrinted
                    ),
                    let theJSONText = String(data: theJSONData,
                                             encoding: String.Encoding.ascii) {
                    print("JSON string = \n\(theJSONText)")
                    body.appendString("\(theJSONText)\r\n")
                }
                
                //                body.appendString("\(theJSONText)\r\n")
            }
        }
        
        let filename = "\(fileName).jpg"
        let mimetype = "image/jpeg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        //        body.appendString(imageDataKey)
        body.append(imageDataKey)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    private func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
}


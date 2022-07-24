//
//  DynamicAppAPIController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 11/06/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import Foundation

class DynamicAppApiController:NSObject,URLSessionDelegate
{
    func DataObjectMapping(DataJson:[JSON],FieldsJson:[JSON],ObjectJson:[String:JSON],DropDownData:JSON? = nil,completionhandler:@escaping (ServiceResponse<[[[NSMutableAttributedString]]]>) -> ()){
        
        var listdata:[[[NSMutableAttributedString]]] = []
        
        var row1Img1Fields:[JSON] = []
        var row1Col1Fields:[JSON] = []
        var row1Fields:[JSON] = []
        var row2Fields:[JSON] = []
        var row3Fields:[JSON] = []
        var row2temp:[JSON] = []
        var row3temp:[JSON] = []
        
        //Finds the place where the value to be placed.
        for eachField in FieldsJson {
            switch eachField["placement"].stringValue.uppercased() {
            case "ROW1IMG1":
                row1Img1Fields.append(eachField)
            case "ROW1COL1":
                row1Col1Fields.append(eachField)
            case "ROW1":
                row1Fields.append(eachField)
            case "ROW2":
                row2Fields.append(eachField)
            case "ROW3":
                row3Fields.append(eachField)
            default:
                if row2temp.count < 3 {
                    row2temp.append(eachField)
                }else if row3temp.count < 3{
                    row3temp.append(eachField)
                }
            }
        }
        
        if row2Fields.count == 0 && row2temp.count > 0 {
            row2Fields = row2temp
        }
        
        if row3Fields.count == 0 && row3temp.count > 0 {
            row3Fields = row3temp
        }
        
        //Loop the Value
        var row1Data:[NSMutableAttributedString] = []
        var row2Data:[NSMutableAttributedString] = []
        var row3Data:[NSMutableAttributedString] = []
        var listRowData:[[NSMutableAttributedString]] = []
        
        if DataJson.count > 0{
            for n in 0...DataJson.count-1 {
                let InvidualData:JSON = DataJson[n]
                
                //reset the value
                row1Data = []
                row2Data = []
                row3Data = []
                listRowData = []
                
                if row1Col1Fields.count > 0 || row1Fields.count > 0 ||  row1Img1Fields.count > 0 {
                    
                    if row1Img1Fields.count > 0 {
                        row1Data.append(getFieldsValueOnly(ObjectJson: ObjectJson, FieldJson: row1Img1Fields, Data: InvidualData, DropDownData: DropDownData))
                    }else{
                        row1Data.append(NSMutableAttributedString(string: ""))
                    }
                    
                    if row1Col1Fields.count > 0 {
                        row1Data.append(getFieldsValueOnly(ObjectJson: ObjectJson, FieldJson: row1Col1Fields, Data: InvidualData, DropDownData: DropDownData))
                    }
                    
                    if row1Fields.count > 0{
                        if row1Col1Fields.count > 0 {
                            row1Data.append(getFieldsValueOnly(ObjectJson: ObjectJson, FieldJson: [row1Fields[0]], Data: InvidualData, DropDownData: DropDownData))
                        }else{
                            if row1Fields.count > 2{
                                for i in 0..<2 {
                                    row1Data.append(getFieldsValueOnly(ObjectJson: ObjectJson, FieldJson: [row1Fields[i]], Data: InvidualData, DropDownData: DropDownData))
                                }
                            }else{
                                for i in 0..<row1Fields.count {
                                    row1Data.append(getFieldsValueOnly(ObjectJson: ObjectJson, FieldJson: [row1Fields[i]], Data: InvidualData, DropDownData: DropDownData))
                                }
                            }
                        }
                    }
                }
                
                if row2Fields.count > 0 {
                    for row2Field in row2Fields {
                        row2Data.append(getFieldsValue(ObjectJson: ObjectJson[row2Field["key"].stringValue]!, Field: row2Field, Data: InvidualData[row2Field["key"].stringValue].stringValue, DropDownData: DropDownData))
                        
                    }
                }
                
                if row3Fields.count > 0 {
                    for row3Field in row3Fields {
                        row3Data.append(getFieldsValue(ObjectJson: ObjectJson[row3Field["key"].stringValue]!, Field: row3Field, Data: InvidualData[row3Field["key"].stringValue].stringValue, DropDownData: DropDownData))
                    }
                }
                
                if row1Data.count > 0 {
                    listRowData.append(row1Data)
                }else{
                    listRowData.append([])
                }
                
                if row2Data.count > 0 {
                    listRowData.append(row2Data)
                }else{
                    listRowData.append([])
                }
                
                if row3Data.count > 0 {
                    listRowData.append(row3Data)
                }else{
                    listRowData.append([])
                }
                
                listdata.append(listRowData)
            }
        }
        completionhandler(.success(listdata))
    }
    
    func getFieldsValueOnly (ObjectJson:[String:JSON],FieldJson:[JSON],Data:JSON,DropDownData:JSON?)-> NSMutableAttributedString{
        
        let DataString = NSMutableAttributedString(string: "")
        
        if FieldJson.count == 1{
            if ObjectJson[FieldJson[0]["key"].stringValue]!["dropdownValue"] != JSON.null {
                DataString.append(NSAttributedString(string: ObjectJson[FieldJson[0]["key"].stringValue]!["dropdownValue"].stringValue, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
            }else{
                DataString.append(NSAttributedString(string: Data[FieldJson[0]["key"].stringValue].stringValue, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
            }
        }else{
            var ls_DataString:String = ""
            for each in FieldJson {
                if ObjectJson[FieldJson[0]["key"].stringValue]!["dropdownValue"] != JSON.null {
                    if ls_DataString == "" {
                        ls_DataString = ObjectJson[FieldJson[0]["key"].stringValue]!["dropdownValue"].stringValue
                    }else{
                        ls_DataString = ls_DataString + " | " + ObjectJson[FieldJson[0]["key"].stringValue]!["dropdownValue"].stringValue
                    }
                }else{
                    if ls_DataString == "" {
                        ls_DataString = Data[each["key"].stringValue].stringValue
                    }else{
                        ls_DataString = ls_DataString + " | " + Data[each["key"].stringValue].stringValue
                    }
                }
            }
            DataString.append(NSAttributedString(string: ls_DataString, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
        }
        return DataString
    }
    
    
    func getFieldsValue (ObjectJson:JSON,Field:JSON,Data:String,DropDownData:JSON?)-> NSMutableAttributedString{
        
        let labelkey = ObjectJson["labelKey"].stringValue
        
        let DataString = NSMutableAttributedString(string: "")
        
        if Field["label"] != nil {
            DataString.append(NSAttributedString(string: "\(Field["label"].stringValue)\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(hex: "999999")!]))
        }else{
            DataString.append(NSAttributedString(string: "\(ObjectJson[labelkey].stringValue)\n", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(hex: "999999")!]))
        }
        
        if  ObjectJson[Field["key"].stringValue] == nil {
            DataString.append(NSAttributedString(string: "\(Data)", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
        }else if Field["roundoff"] != nil {
            DataString.append(NSAttributedString(string: "\(String(format: "%.\(Field["roundoff"].stringValue)f", Double("\(Data)")!))", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
        }else if ObjectJson["type"] == "dropdown" {
            if ObjectJson["dropdownValue"] != nil {
                DataString.append(NSAttributedString(string: "\(Data)", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
            }else if ObjectJson["serviceKey"] == nil {
                if DropDownData?["\(Field["key"])"] != nil {
                    for i in 0..<DropDownData!["\(Field["key"])"].count {
                        if DropDownData!["\(Field["key"])"][i]["key"].stringValue == Data{
                            DataString.append(NSAttributedString(string: "\(DropDownData!["\(Field["key"])"][i]["value"])", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
                        }
                    }
                }else if DropDownData?["\(ObjectJson[Field["key"].stringValue]["serviceKey"])"] != nil {
                    for i in 0..<DropDownData!["\(ObjectJson[Field["key"].stringValue]["serviceKey"])"].count {
                        if DropDownData!["\(ObjectJson[Field["key"].stringValue]["serviceKey"])"][i]["key"].stringValue == Data {
                            DataString.append(NSAttributedString(string: "\(DropDownData!["\(ObjectJson[Field["key"].stringValue]["serviceKey"])"][i]["value"])", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
                        }
                    }
                }
            }
        }else{
            if let dateformat = Field["dateformat"].string{
                var ls_datavalue:String = " "
                if let TimeInter = Double(Data) {
                    let date = Date(timeIntervalSince1970: TimeInter/1000)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
                    dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                    dateFormatter.timeZone = .current
                    ls_datavalue = dateFormatter.string(from: date)
                }else{
                    ls_datavalue = (Data).components(separatedBy: "T")[0]
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateformat
                if dateFormatter.date(from: ls_datavalue) != nil {
                    DataString.append(NSAttributedString(string: "\(dateFormatter.string(from: dateFormatter.date(from: ls_datavalue)!))", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
                }else{
                    DataString.append(NSAttributedString(string: "\(Data)", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
                }
                
            }else{
                DataString.append(NSAttributedString(string: "\(Data)", attributes: [NSAttributedString.Key.font:  UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor(hex: "333333")!]))
            }
        }
        return DataString
    }
    
    func downloadDocumentUrl(decision:JSON,selectedRow:JSON,tenantId:String,completionhandler:@escaping (ServiceResponse<JSON>) -> ()){
        
        var header = ["Content-Type":"application/json","X-Locale":"en-US","X-TenantID":tenantId,"Authorization":UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue)!,"sourceDeviceId":Utility.getVendorID(),"Device-Id":Utility.getVendorID(),"requestId":Utility.getRandomString(),"storageType" : "awsS3","folderInS3" : "generalDocs","forceDownload" : "false"]
        
        for each in decision["outcomes"][0]["headers"].dictionaryValue{
            header["\(each.key)"] = "\(each.value)"
        }
        
        let bodyString = ["id": selectedRow["id"].stringValue,"refObjectId": selectedRow["refObjectId"].stringValue,
                          "refObject": selectedRow["refObject"].stringValue,
                          "fileContentType": selectedRow["refObject"].string,
                          "fileName": selectedRow["fileName"].string]
        
        RequestManager.shared.request(.post, apiPath: nil, requestURL: "\(UIbaseURL)/connect/api/download/", queryParameters: nil, httpBody: bodyString.jsonString(), headers: header) { (response) in
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
    
    
    func downloadDocumentBLOB(decision:JSON,selectedRow:JSON,tenantId:String,platformId:String,completionhandler:@escaping (ServiceResponse<URL>) -> ()){
        
        var header = ["Content-Type":"application/json","X-Locale":"en-US","X-TenantID":tenantId,"Authorization":UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue)!,"sourceDeviceId":Utility.getVendorID(),"Device-Id":Utility.getVendorID(),"requestId":Utility.getRandomString(),"forceDownload" : "true"]

        
        for each in decision["outcomes"][0]["headers"].dictionaryValue{
            header["\(each.key)"] = "\(each.value)"
        }
        
        
        let bodyString = ["id": selectedRow["id"].stringValue,"refObjectId": selectedRow["refObjectId"].stringValue,
                          "refObject": selectedRow["refObject"].stringValue,
                          "fileContentType": selectedRow["refObject"].string,
                          "fileName": selectedRow["fileName"].string].jsonString()
        
        var urlString:String = "\(UIbaseURL)/connect/api/download/"
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let url:URL = URL(string: urlString)!
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        
        request.httpBody = bodyString.data(using: String.Encoding.utf8) ?? nil
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        
        for (key, value) in header {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    DispatchQueue.main.async() {
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let dataPath = documentsDirectory.appendingPathComponent("\(tenantId)_\(UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "")_\(platformId)")
                        
                        do {
                            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                        } catch let error as NSError {
                            print("Error creating directory: \(error.localizedDescription)")
                        }
                        let filename = dataPath.appendingPathComponent("\(selectedRow["fileName"].stringValue)")
                        try? data.write(to: filename)
                        completionhandler(.success(filename))
                    }
                    
                default:
                    
                    DispatchQueue.main.async{
                        guard let json =  try? JSON(data:data) else {
                            DispatchQueue.main.async{
                                completionhandler(.failure(.generic))
                            }
                            return
                        }
                        
                        var msg = "Failed with status code:\(httpResponse.statusCode)"
                        
                        if let msgFromServer = json["msg"].string {
                            msg = msgFromServer
                        }
                        completionhandler(.failure(.custom(message:msg)))
                    }
                }
            }
            
            
        }.resume()
        
    }
    
}

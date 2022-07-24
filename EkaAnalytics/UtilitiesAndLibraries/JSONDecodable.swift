//
//  JSONDecodable.swift
//  EkaAnalytics
//
//  Created by Nithin on 30/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//


import Foundation

protocol JSONDecodable {
    
    init(decoder:JSONDecoder) throws
    
}

enum JSONDecoderError:Error{
    case invalidData
    case keyNotFound(String)
}


struct JSONDecoder {
    
    private let jsonData:JSON
    
    public var underlyingJSONData:JSON {
        get{
            return jsonData
        }
    }
    
    //MARK: - Initializers
    init(data:Data) throws {
        
        do {
            self.jsonData = try JSON(data: data)
        } catch {
            throw JSONDecoderError.invalidData
        }
    }
    
    private init(json:JSON){
        self.jsonData = json
    }
    
    
    //MARK: - Public methods
    public static func decode<T: JSONDecodable>(data: Data) throws -> T {
        let decoder = try JSONDecoder(data: data)
        return try T(decoder: decoder)
    }
    
    public static func decode<T: JSONDecodable>(json: JSON) throws -> T {
        let decoder = JSONDecoder(json: json)
        return try T(decoder: decoder)
    }
    
    func valueForKeyPath(_ keyPath:String) -> JSON {
        
        if keyPath.contains(".") {
            var json = self.jsonData
            let arr = keyPath.components(separatedBy: ".")
            for key in arr {
               json = valueForKey(key, inJson: json)
            }
            return json
        }
        return valueForKey(keyPath, inJson: self.jsonData)
    }
    
    private func valueForKey(_ key:String, inJson:JSON) -> JSON {
        return inJson[key]
    }
    
}


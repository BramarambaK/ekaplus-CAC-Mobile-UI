//
//  DataCacheManager.swift
//  EkaAnalytics
//
//  Created by Nithin on 18/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import Foundation

///Used to temporarily cache user selected options like sort and filters
class DataCacheManager {
    
    static let shared = DataCacheManager()
    
    private var cacheQueue:OperationQueue = OperationQueue()
    
    private var cacheURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("recentSearch.json")
        } else {
            return nil
        }
    }()
    
    private var selectedFarmerURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("selectedFarmer.json")
        } else {
            return nil
        }
    }()
    
    private var recentFarmerURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("recentFarmer.json")
        } else {
            return nil
        }
    }()
    
    //CacheURL for Farmer Connect Filter
    private var FarmerConnectFilterURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("farmerConnectFilter.json")
        } else {
            return nil
        }
    }()
    
    //CacheURL for Farmer Connect Offer Filter
    private var FarmerConnectOfferFilterURL:URL? = {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent("farmerConnectOfferFilter.json")
        } else {
            return nil
        }
    }()
    
    private init(){
        //Get any cached search results from disk and populate it to instance varaible
        if let cacheUrl = self.cacheURL, let stream = InputStream(url: cacheUrl) {
            stream.open()
            defer {stream.close()}
            if let cachedJson = try? JSONSerialization.jsonObject(with: stream, options: []), let unwrappedJson = JSON.init(rawValue: cachedJson) {
                
                
                for result in unwrappedJson.arrayValue {
                    do {
                        if result["entityType"] == "app"{
                            let app:App = try JSONDecoder.decode(json: result)
                            recentSearchedItems.append(app)
                        } else {
                            let insight:Insight = try JSONDecoder.decode(json: result)
                            recentSearchedItems.append(insight)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
        
        if let cacheUrl = self.recentFarmerURL, let stream = InputStream(url: cacheUrl) {
            stream.open()
            defer {stream.close()}
            if let cachedJson = try? JSONSerialization.jsonObject(with: stream, options: []), let unwrappedJson = JSON.init(rawValue: cachedJson) {
                
                
                for result in unwrappedJson.arrayValue {
                    do {
                        let farmer:Farmer = try JSONDecoder.decode(json: result)
                        recentSearchedFarmer.append(farmer)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
        
        if let cacheUrl = self.FarmerConnectFilterURL, let stream = InputStream(url: cacheUrl) {
            stream.open()
            defer {stream.close()}
            if let cachedJson = try? JSONSerialization.jsonObject(with: stream, options: []), let unwrappedJson = JSON.init(rawValue: cachedJson) {
                
                
                
                if unwrappedJson.count > 0 {
                    farmerConnectFilter = unwrappedJson.dictionaryValue
                }
                
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue) != nil && farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!] != nil {
                    
                    filterOptions.removeAll()
                    
                    for i in 0..<(farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]!.arrayValue).count {
                        filterOptions.append((farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]!.arrayValue)[i].dictionaryValue)
                    }
                    
                    
                    print(filterOptions)
                    
                    if farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![0] != JSON.null{
                        
                        for result in farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![0].dictionaryValue {
                            let jsonRawData:JSON = JSON(result.value)
                            self.publishedBidsFilter.append(jsonRawData)
                        }
                    }
                    
                    if farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![1] != JSON.null{
                        
                        for result in farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![1].dictionaryValue {
                            let jsonRawData:JSON = JSON(result.value)
                            self.myBidsFilter.append(jsonRawData)
                        }
                    }
                    
                }
                
            }
        }
        
        if let cacheUrl = self.FarmerConnectOfferFilterURL, let stream = InputStream(url: cacheUrl) {
            stream.open()
            defer {stream.close()}
            if let cachedJson = try? JSONSerialization.jsonObject(with: stream, options: []), let unwrappedJson = JSON.init(rawValue: cachedJson) {
                
                if unwrappedJson.count > 0 {
                    farmerConnectOfferFilter = unwrappedJson.dictionaryValue
                }
                
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue) != nil && farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!] != nil {
                    
                    filterOptions.removeAll()
                    
                    for i in 0..<(farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]!.arrayValue).count {
                        filterOptions.append((farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]!.arrayValue)[i].dictionaryValue)
                    }
                    
                    
                    print(filterOptions)
                    
                    if farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![0] != JSON.null{
                        
                        for result in farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![0].dictionaryValue {
                            let jsonRawData:JSON = JSON(result.value)
                            self.publishedBidsFilter.append(jsonRawData)
                        }
                    }
                    
                    if farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![1] != JSON.null{
                        
                        for result in farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!]![1].dictionaryValue {
                            let jsonRawData:JSON = JSON(result.value)
                            self.myBidsFilter.append(jsonRawData)
                        }
                    }
                    
                }
                
            }
        }
    }
    
    var sortOptions = Array<(row:Int, option:SortOptions)?>(repeating: nil, count: 2)
    var filterOptions =  Array<[String:JSON?]?>(repeating: nil, count: 2)
    var selectedSlicerFiltersCache:[String:[Int]]?
    var selectedDateFilterCache:[String:[String]]?
    
    var notifications = [BusinessAlert]()
    
    private var recentSearchedItems = [SearchResult]()
    private var recentSearchedFarmer = [Farmer]()
    private var farmerConnectFilter =  [String:JSON]()
    private var farmerConnectOfferFilter =  [String:JSON]()
    
    //Sort and Filters for bids page in Farmer connect
    var myBidsSort : [String:Any]?
    var myBidsFilter = [JSON]()
    
    var publishedBidsSort : [String:Any]?
    var publishedBidsFilter = [JSON]()
    //-------------------------------------------------------
    
    func clearEntireCache(){
        
        (0..<filterOptions.count).forEach{ index in
            filterOptions[index] = nil
        }
        
        (0..<sortOptions.count).forEach{ index in
            sortOptions[index] = nil
        }
        
        myBidsSort = nil
        myBidsFilter  = []
        
        publishedBidsSort = nil
        publishedBidsFilter.removeAll()
        //        publishedBidsFilter  = []
        
    }
    
    func clearFilterCache(at index:Int){
        if  index < filterOptions.count {
            filterOptions[index] = nil
        }
    }
    
    func clearSlicerCache(){
        selectedSlicerFiltersCache = nil //[Int:[Int]]()
        selectedDateFilterCache = nil
    }
    
    func clearFarmerAndSearchDetails(){
        do{
            if selectedFarmerURL != nil {
                try FileManager.default.removeItem(at: selectedFarmerURL!)
            }
            
        }catch{
            print(error.localizedDescription)
        }
        
        do{
            if recentFarmerURL != nil {
                recentSearchedFarmer = [Farmer]()
                try FileManager.default.removeItem(at: recentFarmerURL!)
            }
        }catch{
            print(error.localizedDescription)
        }
        
        do{
            if  cacheURL != nil {
                recentSearchedItems = [SearchResult]()
                try FileManager.default.removeItem(at: cacheURL!)
            }
        }catch{
            print(error.localizedDescription)
        }
    }
    
    func saveRecentlySearched(results:SearchResult){
        
        //Check does recently search result contains results.
        let contains = recentSearchedItems.contains { (Data) -> Bool in
            if "\((Data.underlyingJSON.dictionaryValue as NSDictionary).value(forKey: "_id")!)" == "\((results.underlyingJSON.dictionaryValue as NSDictionary).value(forKey: "_id")!)" {
                return true
            }
            return false
        }
        
        guard !contains else {
            return
        }
        
        if recentSearchedItems.count == 5 {
            recentSearchedItems.remove(at: 0)
            recentSearchedItems.append(results)
        } else {
            recentSearchedItems.append(results)
        }
        
        guard let cacheUrl = self.cacheURL else {return}
        
        
        let recentSearchedItemsRaw = JSON(recentSearchedItems.map{$0.underlyingJSON})
        
        //        print(recentSearchedItemsRaw)
        
        self.cacheQueue.addOperation {
            if let stream = OutputStream(url: cacheUrl, append: false) {
                stream.open()
                defer {stream.close()}
                JSONSerialization.writeJSONObject(recentSearchedItemsRaw.rawValue, to: stream, options: [], error: nil)
            }
        }
    }
    
    func getRecentSearchedItems() -> [SearchResult] {
        return recentSearchedItems
    }
    
    
    func saveLastSelectedFarmer(farmer:Farmer){
        
        guard let cacheUrl = self.selectedFarmerURL else {return}
        
        self.cacheQueue.addOperation {
            if let stream = OutputStream(url: cacheUrl, append: false) {
                stream.open()
                defer {stream.close()}
                JSONSerialization.writeJSONObject(farmer.underlyingJSON.rawValue, to: stream, options: [], error: nil)
            }
        }
    }
    
    
    func getLastSelectedFarmer()->Farmer?{
        if let cacheUrl = self.selectedFarmerURL, let stream = InputStream(url: cacheUrl) {
            stream.open()
            defer {stream.close()}
            if let cachedJson = try? JSONSerialization.jsonObject(with: stream, options: []), let unwrappedJson = JSON.init(rawValue: cachedJson) {
                
                do{
                    let farmer:Farmer = try JSONDecoder.decode(json: unwrappedJson)
                    return farmer
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        return nil
    }
    
    func saveRecentlySearchedFarmer(results:Farmer){
        
        // Check does recently search farmer has selected farmer.
        let contains = recentSearchedFarmer.contains { (Data) -> Bool in
            if Data.id == results.id {
                return true
            }
            return false
        }
        
        guard !contains else {
            return
        }
        
        if recentSearchedFarmer.count == 5 {
            recentSearchedFarmer.remove(at: 0)
            recentSearchedFarmer.append(results)
        } else {
            recentSearchedFarmer.append(results)
        }
        
        guard self.recentFarmerURL != nil else {return}
        
        let recentSearchedItemsRaw = JSON(recentSearchedFarmer.map{$0.underlyingJSON})
        
        
        self.cacheQueue.addOperation {
            if let stream = OutputStream(url: self.recentFarmerURL!, append: false) {
                stream.open()
                defer {stream.close()}
                JSONSerialization.writeJSONObject(recentSearchedItemsRaw.rawValue, to: stream, options: [], error: nil)
            }
        }
        
    }
    
    func getRecentSearchedFarmer() -> [Farmer] {
        return recentSearchedFarmer
    }
    
    func saveFarmerConnectFilter(offerType:String){
        
        if offerType == "BID"{
            guard let cacheUrl = self.FarmerConnectFilterURL else {return}
            
            print(cacheUrl)
            
            farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!] = JSON(filterOptions)
            
            //        let farmerConnectFilterRaw = JSON([UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!:filterOptions])
            
            let farmerConnectFilterRaw = JSON(farmerConnectFilter)
            
            self.cacheQueue.addOperation {
                if let stream = OutputStream(url: self.FarmerConnectFilterURL!, append: false) {
                    stream.open()
                    defer {stream.close()}
                    JSONSerialization.writeJSONObject(farmerConnectFilterRaw.rawValue, to: stream, options: [], error: nil)
                }
            }
            
            //only 5 user farmer connect filter will be saved.
            if farmerConnectFilter.count > 5 {
                farmerConnectFilter.remove(at: farmerConnectFilter.startIndex)
            }
        }else{
            guard let cacheUrl = self.FarmerConnectOfferFilterURL else {return}
            
            print(cacheUrl)
            
            farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!] = JSON(filterOptions)
            
            //        let farmerConnectFilterRaw = JSON([UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!:filterOptions])
            
            let farmerConnectOfferFilterRaw = JSON(farmerConnectOfferFilter)
            
            self.cacheQueue.addOperation {
                if let stream = OutputStream(url: self.FarmerConnectOfferFilterURL!, append: false) {
                    stream.open()
                    defer {stream.close()}
                    JSONSerialization.writeJSONObject(farmerConnectOfferFilterRaw.rawValue, to: stream, options: [], error: nil)
                }
            }
            
            //only 5 user farmer connect filter will be saved.
            if farmerConnectFilter.count > 5 {
                farmerConnectFilter.remove(at: farmerConnectFilter.startIndex)
            }
        }
    }
    
    func getFarmerConnectFilter(offerType:String){
        if offerType == "BID"{
            if UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue) != nil && farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!] != nil {
                
                filterOptions.removeAll()
                
                for i in 0..<(farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]!.arrayValue).count {
                    filterOptions.append((farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]!.arrayValue)[i].dictionaryValue)
                }
                
                
                print(filterOptions)
                
                self.publishedBidsFilter = []
                self.myBidsFilter = []
                
                if farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![0] != JSON.null{
                    
                    for result in farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![0].dictionaryValue {
                        let jsonRawData:JSON = JSON(result.value)
                        self.publishedBidsFilter.append(jsonRawData)
                    }
                }
                
                if farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![1] != JSON.null{
                    
                    for result in farmerConnectFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![1].dictionaryValue {
                        let jsonRawData:JSON = JSON(result.value)
                        self.myBidsFilter.append(jsonRawData)
                    }
                }
                
            }
        }
        else{
            
            if UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue) != nil && farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!] != nil {
                
                filterOptions.removeAll()
                
                for i in 0..<(farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]!.arrayValue).count {
                    filterOptions.append((farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]!.arrayValue)[i].dictionaryValue)
                }
                
                
                print(filterOptions)
                
                self.publishedBidsFilter = []
                self.myBidsFilter = []
                
                if farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![0] != JSON.null{
                    
                    for result in farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![0].dictionaryValue {
                        let jsonRawData:JSON = JSON(result.value)
                        self.publishedBidsFilter.append(jsonRawData)
                    }
                }
                
                if farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![1] != JSON.null{
                    
                    for result in farmerConnectOfferFilter[UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!]![1].dictionaryValue {
                        let jsonRawData:JSON = JSON(result.value)
                        self.myBidsFilter.append(jsonRawData)
                    }
                }
            }
        }
    }
    
}

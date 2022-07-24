//
//  DataViewAPIController.swift
//  EkaAnalytics
//
//  Created by Nithin on 14/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation


class DataViewApiConroller {
    
    typealias Parameters = (dataViewJson:JSON,visualizeJson:JSON,headers:JSON)
    
    public static var shared = DataViewApiConroller()
    private init(){}
    
    private let responseParsingQueue:OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 5
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    private func cacheUrlWithpath(_ path:String) -> URL? {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            return cacheURL.appendingPathComponent(path)
        } else {
            return nil
        }
    }
    
    func getDataViewDetails(_ dataViewID:String, _ completion: @escaping (ServiceResponse<JSON>)->()){
        
        let queryParams = "/\(dataViewID)"
        
        let dataViewCacheUrl = cacheUrlWithpath("dataViewDetails\(dataViewID).json")
        
        RequestManager.shared.request(.get, apiPath: .dataViews, queryParameters: queryParams, httpBody: nil, shouldCacheWithDiskUrl : dataViewCacheUrl) { (response) in
            
            switch response {
                
            case .success(let json):
                //                print(json)
                completion(.success(json))
                
            case .failure(let error):
                switch error {
                case .failedWithStatusCode(let code):
                    completion(.failure(.failedWithStatusCode(statusCode: code)))
                default:
                    completion(.failure(error))
                }
               
            case .failureJson(_):
                break
            }
        }
    }
    
    private func visualizeDataView(_ data:JSON, dataViewId:String, calculatedMeasures:JSON?, completion:@escaping (ServiceResponse<JSON>) -> () ) {
        
        let jsonData =  try? JSONSerialization.data(withJSONObject: data.object, options: .prettyPrinted)
        
        let jsonObject = try? JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! Dictionary<String, Any>
        
        
        let chartType = data["visualizations"]["chartType"].stringValue
        
        var parseData = false
        
        if chartType == ChartType.Bubble.rawValue || chartType == ChartType.Heatmap.rawValue {
            parseData = true
        }
        
        var body:[String:Any] =  ["dataViewJson":jsonObject!, "parseData":parseData]
        
        if calculatedMeasures != nil {
            
            let jsonData =  try? JSONSerialization.data(withJSONObject: calculatedMeasures!.object, options: .prettyPrinted)
            
            let calculatedMeasuresJsonObject = try? JSONSerialization.jsonObject(with: jsonData!, options: .allowFragments) as! [Dictionary<String, Any>]
            
            body.updateValue(calculatedMeasuresJsonObject!, forKey: "calculatedMeasures")
        }
        
        
        
        let bodyData = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        let visualizeDataCacheUrl = cacheUrlWithpath("visualizeData\(dataViewId).json")
        
        RequestManager.shared.request(.post, apiPath: .visualize, queryParameters: nil, httpBody: nil, shouldCacheWithDiskUrl : visualizeDataCacheUrl, bodyData: bodyData!) { (response) in
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
    
    private func getMetaHeaders(_ collectionId:String, completion:@escaping (ServiceResponse<JSON>)->()){
        
        
        
        let headersMapCacheUrl = cacheUrlWithpath("headersMap\(collectionId).json")
        
        RequestManager.shared.request(.get, apiPath: .collectionHeaderMap(collectionId), httpBody: nil, shouldCacheWithDiskUrl: headersMapCacheUrl, bodyData: nil) { (response) in
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
    
    private func getCollectionMeta(_ collectionId:String, completion:@escaping (ServiceResponse<JSON>)->()) {
        
        RequestManager.shared.request(.get, apiPath: .quickEditInfo(collectionId), httpBody: nil) { (response) in
            
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
    
    
    
    //Final chained api request to be used
    //Final chained api request to be used
    public func chainedApiRequestForDataView(_ dataViewID:String, slicerFilters:[JSON]? = nil , sortOptions:JSON? = nil, filterOptions:[JSON]? = nil,drillDownOptions:NSDictionary? = nil, completion: @escaping (ServiceResponse<ChartOptionsModel>)->()){
        
        getDataViewDetails(dataViewID) { (response) in
            
            
            guard case var .success(dataViewJson) = response  else {
                guard case .failure(.failedWithStatusCode(statusCode: 403)) = response else{
                    completion(.failure(.custom(message:"Failed in dataview api")))
                    return
                }
                completion(.failure(.failedWithStatusCode(statusCode: 403)))
                return
            }
            
            if  dataViewJson["dataSource"]["sourceType"].stringValue == "Joined" || dataViewJson["dataSource"]["sourceType"].stringValue == "Realtime"{
                
                dataViewJson["inMemoryCollection"] = true
            }
            
            if drillDownOptions != nil && drillDownOptions!.count != 0  {
                dataViewJson["visualizations"]["configuration"]["drillDownInfo"]["level"] = drillDownOptions!["level"] as! JSON
                dataViewJson["visualizations"]["configuration"]["drillDownInfo"]["drillDownAll"] = JSON.init(drillDownOptions!["drillDownAll"]!)
                dataViewJson["visualizations"]["configuration"]["drillDown"] = JSON.init(drillDownOptions!["drillDown"]!)
                dataViewJson["visualizations"]["configuration"]["drillDownInfo"]["filters"] = JSON.init(drillDownOptions!["filters"]!)
                
            }
            
            let collectionID = dataViewJson["dataSource"]["collectionId"].stringValue
            
            let chartType = dataViewJson["visualizations"]["chartType"].stringValue
            
            
            //If chart type is any of the below, we skip the subsequent api calls, because, we dont need the data as we render these below charts in a webview.
            if chartType == ChartType.Pivot.rawValue || chartType == ChartType.AreaTime.rawValue || chartType == ChartType.LineTime.rawValue || chartType == ChartType.PointTime.rawValue || chartType == ChartType.ColumnTime.rawValue || chartType == ChartType.SplineTime.rawValue || chartType == ChartType.AreaSplineTime.rawValue || chartType == ChartType.DotMap.rawValue {
                
                var chartOptions = ChartOptionsModel()
                chartOptions.name = dataViewJson["name"].stringValue
                chartOptions.dataViewID = dataViewID
                chartOptions.type = ChartType(rawValue: chartType)
                
                DispatchQueue.main.async {
                    completion(.success(chartOptions))
                }
                return
            }
            
            
            if let filters = slicerFilters { //this is for slicer filters
                
                //There might be predefined filters already. shouldn't override them. just append to it
                
                var existingFilters = dataViewJson["dataSource"]["filters"].arrayValue
                existingFilters.removeAll()
                existingFilters.append(contentsOf: filters)
                
                dataViewJson["dataSource"]["filters"] = JSON(existingFilters)
            }
            
            if let sortOptions = sortOptions {
                dataViewJson["visualizations"]["configuration"]["sortBy"] = sortOptions
            }
            
            if let filterOptions = filterOptions {
                let existingFilters = dataViewJson["visualizations"]["filters"].arrayValue
                
                var updatedFilters = [JSON]()
                
                //Update the filters with the user selected ones
                //Filters can be applied on each column.
                
                for existingFilter in existingFilters {
                    //For each existing filter(for a column), if user has selectd some filters, update the filter json else leave it as it is.
                    if let userSelectedFilter = filterOptions.filter({$0["columnId"].stringValue == existingFilter["columnId"].stringValue}).first {
                        updatedFilters.append(userSelectedFilter)
                    } else {
                        updatedFilters.append(existingFilter)
                    }
                }
                dataViewJson["visualizations"]["filters"].arrayObject = updatedFilters
            }
            
#if DEBUG
            print("DataviewDetails", dataViewJson)
#endif
            
            //This is used to get calculated measures if any
            self.getCollectionMeta(collectionID) { (response) in
                guard case var .success(collectionMeta) = response  else {
                    completion(.failure(.custom(message:"Failed in collectionMeta api")))
                    return
                }
                
                var calculatedMeasures:JSON? = nil
                if !collectionMeta["data"]["calculatedMeasures"].isEmpty{
                    calculatedMeasures = collectionMeta["data"]["calculatedMeasures"]
                }
                
                //If there are any calculated measures, pass it to visualize api
                self.visualizeDataView(dataViewJson, dataViewId: dataViewID, calculatedMeasures: calculatedMeasures){ (visualizeResponse) in
                    
                    guard case let .success(visualizeJson) = visualizeResponse else {
                        
                        if case let .failure(error) = visualizeResponse {
                            if case let .failedWithStatusCode(code) = error{
                                completion(.failure(.failedWithStatusCode(statusCode: code)))
                            } else {
                                completion(.failure(.custom(message:"Failed in  visualize api")))
                            }
                        }
                        return
                    }
                    
#if DEBUG
                    print("visualizeJson", visualizeJson)
#endif
                    
                    //This headers api is used to get a map of column id and its name. We use it to display column names in filters and sort.
                    self.getMetaHeaders(collectionID, completion: { (headerResponse) in
                        guard case let .success(headerJson) = headerResponse else {
                            completion(.failure(.custom(message:"Failed in meta api")))
                            return}
                        
#if DEBUG
                        //                    print("headerJson", headerJson)
#endif
                        
                        self.responseParsingQueue.addOperation {
                            
                            let headers = headerJson//headerJson["data"]
                            
                            guard let chartType = ChartType(rawValue: dataViewJson["visualizations"]["chartType"].stringValue) else {
                                
                                DispatchQueue.main.async {
                                    print("Unsupported chart type \(dataViewJson["visualizations"]["chartType"].stringValue)")
                                    completion(.failure(.unsupportedChart(chartType: dataViewJson["visualizations"]["chartType"].stringValue)))
                                }
                                return
                            }
                            
                            print(chartType)
                            
                            let parameters:Parameters = (dataViewJson, visualizeJson, headers)
                            
                            switch chartType {
                                
                            case .Card :
                                var cardOptions = self.getCardOptions(parameters)
                                if case .success(var options) = cardOptions{
                                    options.dataViewID = dataViewID
                                    cardOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(cardOptions)
                                }
                                
                            case .Table:
                                var tableOptions = self.getTableChartOptions(parameters)
                                if case .success(var options) = tableOptions{
                                    options.dataViewID = dataViewID
                                    tableOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(tableOptions)
                                }
                                
                            case .Bubble:
                                var bubbleOptions = self.getBubbleOptions(parameters)
                                if case .success(var options) = bubbleOptions{
                                    options.dataViewID = dataViewID
                                    bubbleOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(bubbleOptions)
                                }
                                
                            case .Bar, .Column, .Line, .Scatter, .StackedPercentageBar, .StackedPercentageColumn, .StackedBar, .StackedColumn, .Bar3D, .Column3D, .Polar, .Spline, .Area, .AreaSpline, .StackedArea, .StackedPercentageArea:
                                
                                var chartOptions = self.getChartOptionsForBasicChartTypes(parameters)
                                if case .success(var options) = chartOptions{
                                    options.dataViewID = dataViewID
                                    chartOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(chartOptions)
                                }
                                
                            case .Pie, .Pie3D, .SemiPie:
                                var pieOptions = self.getPieOptions(parameters)
                                if case .success(var options) = pieOptions{
                                    options.dataViewID = dataViewID
                                    pieOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(pieOptions)
                                }
                                
                            case .LineArea:
                                var lineAreaOptions = self.getLineAreaOptions(parameters)
                                if case .success(var options) = lineAreaOptions{
                                    options.dataViewID = dataViewID
                                    lineAreaOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(lineAreaOptions)
                                }
                                
                            case .LineColumn:
                                var lineColumnOptions = self.getLineColumnOptions(parameters)
                                if case .success(var options) = lineColumnOptions{
                                    options.dataViewID = dataViewID
                                    lineColumnOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(lineColumnOptions)
                                }
                                
                            case .LineAreaStacked:
                                var lineAreaStackedOptions = self.getLineAreaStacked(parameters)
                                if case .success(var options) = lineAreaStackedOptions{
                                    options.dataViewID = dataViewID
                                    lineAreaStackedOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(lineAreaStackedOptions)
                                }
                                
                            case .LineLine:
                                var lineLineOptions = self.getLineLineOptions(parameters)
                                if case .success(var options) = lineLineOptions{
                                    options.dataViewID = dataViewID
                                    lineLineOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(lineLineOptions)
                                }
                                
                            case .LineColumnStacked:
                                var lineColumnStackedOptions = self.getLineColumnStacked(parameters)
                                if case .success(var options) = lineColumnStackedOptions{
                                    options.dataViewID = dataViewID
                                    lineColumnStackedOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(lineColumnStackedOptions)
                                }
                                
                            case .Heatmap:
                                var heatMapOptions = self.getHeatMapOptions(parameters)
                                if case .success(var options) = heatMapOptions{
                                    options.dataViewID = dataViewID
                                    heatMapOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(heatMapOptions)
                                }
                                
                            case .ComboSlicer, .CheckSlicer, .RadioSlicer, .TagSlicer,.DateRangeSlicer:
                                var slicerOptions = self.getSlicerOptions(parameters)
                                if case .success(var options) = slicerOptions{
                                    options.dataViewID = dataViewID
                                    slicerOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(slicerOptions)
                                }
                                
                                //                case .Pivot, .PointTime, .SplineTime, .AreaTime, .AreaSplineTime, .LineTime, .ColumnTime:
                                //
                                //                        var chartOptions = self.getCommonChartOptions(parameters)
                                //                        chartOptions.type = chartType
                                //                        chartOptions.dataViewID = dataViewID
                                //                        DispatchQueue.main.async {
                                //                            completion(.success(chartOptions))
                                //                        }
                                //
                                
                            case .Donut, .Donut3D:
                                var donutOptions = self.getDonutChartOptions(parameters)
                                if case .success(var options) = donutOptions{
                                    options.dataViewID = dataViewID
                                    donutOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(donutOptions)
                                }
                                
                            case .ScatterPlot:
                                
                                var scatterPlotOptions = self.getScatterPlotOptions(parameters)
                                if case .success(var options) = scatterPlotOptions{
                                    options.dataViewID = dataViewID
                                    scatterPlotOptions = .success(options)
                                }
                                DispatchQueue.main.async {
                                    completion(scatterPlotOptions)
                                }
                                
                                
                            default:
                                completion(.failure(.unsupportedChart(chartType: "unsupported chart")))
                                
                            }
                            
                        }
                    })//MetaHeaders api end
                }//Visualize api end
            }//CollectionMeta Api end
        }//Dataview details api end
    }
    
    
    func getCommonChartOptions(_ parameters:Parameters)->ChartOptionsModel{
        
        let chartName = parameters.dataViewJson["name"].stringValue
        
        let format = parameters.dataViewJson["visualizations"]["format"]["format"].arrayValue
        let xAxisTitle = format.filter{$0["type"] == "xaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        let yAxisTitle = format.filter{$0["type"] == "yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        let drillDown = parameters.dataViewJson["visualizations"]["configuration"]["drillDown"].boolValue
        
        
        var sortColumns = [JSON]()
        
        for each in parameters.dataViewJson["visualizations"]["filters"].arrayValue {
            if each["configZone"] == "axis" {
                sortColumns.append(each)
            }
        }
        
//        let sortColumns = parameters.dataViewJson["visualizations"]["filters"].arrayValue
        
        //we can have other filters because of slicer. slicer filters have source as "actions" and predefined filters has source as "collectionFilter"
        let preDefinedFilters = parameters.dataViewJson["dataSource"]["filters"].arrayValue.filter{$0["source"].stringValue == "collectionFilter"}
        
        
        //using the columnId, get the corresponding column name and add it to json against the new key "columnName"
        var modifiedSortColumns = [JSON]()
        
        for var sortColumn in sortColumns{
            sortColumn["columnName"] = parameters.headers[sortColumn["columnId"].stringValue]
            modifiedSortColumns.append(sortColumn)
        }
        
        var modifiedPreDefinedFilters = [JSON]()
        
        for var preDefinedFilter in preDefinedFilters {
            preDefinedFilter["columnName"] = parameters.headers[preDefinedFilter["columnId"].stringValue]
            modifiedPreDefinedFilters.append(preDefinedFilter)
        }
        
        
        var chartOptions = ChartOptionsModel()
        chartOptions.name = chartName
        chartOptions.drilldown = drillDown
        chartOptions.xAxisTitle = xAxisTitle
        chartOptions.yAxisTitle = yAxisTitle
        chartOptions.type = ChartType(rawValue: parameters.dataViewJson["visualizations"]["chartType"].stringValue)
        chartOptions.sortOptions = modifiedSortColumns
        chartOptions.preDefinedFilters = modifiedPreDefinedFilters
        return chartOptions
    }
    
    
    private func getCardOptions(_ parameters:Parameters) -> ServiceResponse<ChartOptionsModel> {
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        
        var numberFormatMap = [String:JSON]()
        
        if let valueConfig = config.filter({$0["zone"] == "values-card"}).first, let columns = valueConfig["columns"].array {
            
            var cardData = [(key:String, value:Double, columnId:String)]()
            
            for column in columns {
                let columnID = column["columnId"].stringValue
                let columnName = parameters.headers[columnID].stringValue
                let row = (key:columnName, value:dataPoints.first?[columnID].doubleValue ?? 0.0, columnId:columnID)
                
                cardData.append(row)
                //                cardData[columnName] = dataPoints.first?[columnID].doubleValue ?? 0.0
                numberFormatMap[columnID] = column["numberFormat"]
            }
            
            chartOptions.cardValues = cardData
            
            chartOptions.numberFormatMap = numberFormatMap.count > 0 ? JSON(numberFormatMap) : JSON.null
            
            return  .success(chartOptions)
        } else {
            return .failure(.custom(message:"Unable to load card"))
        }
    }
    
    
    private func getBubbleOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        //        let visualizeJson = parameters.visualizeJson
        
        guard let valuesConfig = config.filter({$0["zone"] == "values"}).first, let leftAxisConfig =  config.filter({$0["zone"] == "rows"}).first, let topAxisConfig = config.filter({$0["zone"] == "columns"}).first else {
            return   .failure(.custom(message:"Failed to get one of the zones in Bubble"))
        }
        
        guard let valueId = valuesConfig["columns"].arrayValue.first?["columnId"].stringValue, let leftAxisId = leftAxisConfig["columns"].arrayValue.first?["columnId"].stringValue,let topAxisId = topAxisConfig["columns"].arrayValue.first?["columnId"].stringValue  else {
            return .failure(.custom(message:"Failed to get one of the column Id in bubble"))
        }
        
        /*
         let topAxisArray = visualizeJson["topAxis"].arrayValue.map{$0["value"].stringValue}
         let leftAxisArray = visualizeJson["leftAxis"].arrayValue.map{$0["value"].stringValue}
         
         //To remove duplicates in leftAxis, using a Set
         var leftAxis =  Array(Set(leftAxisArray))
         var topAxis = Array(Set(topAxisArray))
         
         
         let leftAxisFormatType = leftAxisConfig["columns"].arrayValue.first?["columnType"].intValue
         
         let topAxisFormatType = topAxisConfig["columns"].arrayValue.first?["columnType"].intValue
         
         
         var filterValuesForColumn = [String:[String]]()
         
         //Basic filters should only show vales for column that is of string type
         //columnType - 1=String, 2=Number, 3=Date
         
         if leftAxisFormatType == 1{
         filterValuesForColumn[leftAxisId] = leftAxis
         }
         if topAxisFormatType == 1 {
         filterValuesForColumn[topAxisId] = topAxis
         }
         
         
         
         //To fix an issue with highcharts which shows numbers, append empty strings
         leftAxis.insert("", at: 0)
         leftAxis.append("")
         
         topAxis.insert("", at: 0)
         topAxis.append("")
         
         //Filter out grandTotal values as we don't need them
         let results = visualizeJson["results"].arrayValue.filter({$0["leftKey"].stringValue != "grandtotal"})
         
         var dataPointsLookup = [String:[String:Double]]()
         
         
         for result in results{
         
         let leftKey = result["leftKey"].stringValue
         let topKey = result["topKey"].stringValue
         let zvalue = result["values"][valueId].doubleValue
         
         //            if var val = dataPointsLookup[leftKey]{
         //                val.updateValue(zvalue, forKey: topKey)
         //
         //            }
         if dataPointsLookup[leftKey] == nil {
         dataPointsLookup.updateValue([topKey:zvalue], forKey: leftKey)
         } else {
         dataPointsLookup[leftKey]?.updateValue(zvalue, forKey: topKey)
         }
         
         }
         
         
         var dataPoints = [Any]()
         
         for (yIndex, leftKey) in leftAxis.enumerated() {
         
         for (xIndex,topKey) in topAxis.enumerated() {
         
         if let zvalue = dataPointsLookup[leftKey]?[topKey], zvalue > 0 {
         let point:[String : Any] = ["x":xIndex, "y":yIndex, "z":zvalue]
         dataPoints.append(point)
         }
         }
         }
         
         */
        
        let xaxis = parameters.visualizeJson["xFieldData"].arrayValue.map{$0.stringValue}
        let yaxis = parameters.visualizeJson["yFieldData"].arrayValue.map{$0.stringValue}
        
        let dataPoints = parameters.visualizeJson["seriesData"][0]["data"].arrayObject!
        
        
        
        let leftAxisFormatType = leftAxisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        let topAxisFormatType = topAxisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        
        var filterValuesForColumn = [String:[String]]()
        
        //Basic filters should only show values for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        
        if leftAxisFormatType == 1{
            filterValuesForColumn[leftAxisId] = yaxis
        }
        if topAxisFormatType == 1 {
            filterValuesForColumn[topAxisId] = xaxis
        }
        
        chartOptions.xaxis =  xaxis//topAxis
        chartOptions.yaxis = yaxis//leftAxis
        chartOptions.series = [dataPoints]
        chartOptions.leftAxisColumnName = parameters.headers[leftAxisId].stringValue
        chartOptions.topAxisColumnName = parameters.headers[topAxisId].stringValue
        chartOptions.valuesColumnName = parameters.headers[valueId].stringValue
        chartOptions.filterValuesForColumn = filterValuesForColumn
        return .success(chartOptions)
        
    }
    
    
    private func getLineAreaOptions(_ parameters:Parameters) -> ServiceResponse<ChartOptionsModel>{
        
        var area1ValueId:String = ""
        var area1YAxisTitle:String = ""
        var allareaValues:[[Double]] = []
        var areaSeriesName:[String] = []
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        let format = parameters.dataViewJson["visualizations"]["format"]["format"].arrayValue
        
        guard let axisConfig = config.filter({$0["zone"] == "axis"}).first,
              let lineValuesConfig = config.filter({$0["zone"] == "values-line"}).first,
              let areaValuesConfig = config.filter({$0["zone"] == "values-area"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in LineArea"))
            
        }
        
        
        let axisId = axisConfig["columns"].arrayValue.first?["columnId"].stringValue
        let lineValueId = lineValuesConfig["columns"].arrayValue.first?["columnId"].stringValue
        let areaValueId = areaValuesConfig["columns"].arrayValue.first?["columnId"].stringValue
        
        if areaValuesConfig["columns"].arrayValue.count == 2{
            area1ValueId = areaValuesConfig["columns"].arrayValue[1]["columnId"].stringValue
            area1YAxisTitle = format.filter{$0["type"] == "area2-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        }
        
        //        else {
        //            return .failure(.custom(message:"Failed to get one of the column Id in LineArea"))
        //
        //        }
        
        
        let lineYAxisTitle = format.filter{$0["type"] == "line-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        let areaYAxisTitle = format.filter{$0["type"] == "area1-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        var xCategories = [String]()
        var lineValues = [Double]()
        var areaValues = [Double]()
        var area1Values = [Double]()
        
        let lineSeriesName = parameters.headers[lineValueId ?? ""].stringValue
        
        let areaValue = areaValuesConfig["columns"].arrayValue
        
        for index in 0..<areaValue.count {
            areaSeriesName.append(parameters.headers[areaValue[index]["columnId"].stringValue].stringValue)
        }
        
        for dataPoint in dataPoints{
            
            let category = dataPoint["_id"][axisId ?? ""].stringValue
            let lineValue = dataPoint[lineValueId ?? ""].doubleValue
            let areaValue = dataPoint[areaValueId ?? ""].doubleValue
            
            if areaValuesConfig["columns"].arrayValue.count == 2{
                area1Values.append(dataPoint[area1ValueId].doubleValue)
            }
            
            if !xCategories.contains(category){
                xCategories.append(category)
            }
            
            if lineValueId != nil {
                lineValues.append(lineValue)
            }
            
            if areaValueId != nil {
                areaValues.append(areaValue)
            }
            
        }
        
        if area1Values.count > 0 {
            allareaValues = [areaValues, area1Values]
        }else if areaValues.count > 0 {
            allareaValues = [areaValues]
        }
        
        
        var filterValuesForColumn = [String:[String]]()
        let axisFormatType = axisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        
        if axisFormatType == 1 {
            filterValuesForColumn[axisId ?? ""] = xCategories
        }
        
        chartOptions.xaxis = xCategories
        
        var combiData = CombinationData()
        combiData.lineData = lineValues
        combiData.areaData = allareaValues
        combiData.leftYaxisTitle = lineYAxisTitle
        combiData.rightYaxisTitle = areaYAxisTitle
        combiData.right1YaxisTitle = area1YAxisTitle
        combiData.lineSeriesNames = [lineSeriesName]
        combiData.areaSeriesNames = areaSeriesName
        
        chartOptions.combinationData = combiData
        chartOptions.filterValuesForColumn = filterValuesForColumn
        
        return .success(chartOptions)
        
    }
    
    private func getLineAreaStacked(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        let format = parameters.dataViewJson["visualizations"]["format"]["format"].arrayValue
        
        
        guard let axisConfig = config.filter({$0["zone"] == "axis"}).first,
              let lineValuesConfig = config.filter({$0["zone"] == "values-line"}).first,
              let areaValuesConfig = config.filter({$0["zone"] == "values-area"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in LineAreaStacked"))
            
        }
        
        //        guard
        let axisId = axisConfig["columns"].arrayValue.first?["columnId"].stringValue
        let lineValueId = lineValuesConfig["columns"].arrayValue.first?["columnId"].stringValue
        //        else {
        //            return .failure(.custom(message:"Failed to get one of the column Id in LineAreaStacked"))
        //
        //        }
        
        let areaValueIds = areaValuesConfig["columns"].arrayValue.map({$0["columnId"].string}).filter{$0 != nil}
        
        let lineYAxisTitle = format.filter{$0["type"] == "line-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        let areaYAxisTitle = format.filter{$0["type"] == "area1-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        
        var xCategories = [String]()
        var lineValues = [Double]()
        var areaValues = [[Double]]()
        
        let lineSeriesName = parameters.headers[lineValueId ?? ""].stringValue
        
        let areaSeriesNames = areaValueIds.map{ areaValueId in
            parameters.headers[areaValueId!].stringValue
        }
        
        
        for dataPoint in dataPoints{
            
            let category = dataPoint["_id"][axisId ?? ""].stringValue
            let lineValue = dataPoint[lineValueId ?? ""].doubleValue
            
            if !xCategories.contains(category){
                xCategories.append(category)
            }
            
            if lineValueId != nil {
                lineValues.append(lineValue)
            }
            
        }
        
        areaValues = areaValueIds.map{ areaValueId in
            
            dataPoints.map{$0[areaValueId!].doubleValue}
        }
        
        var filterValuesForColumn = [String:[String]]()
        let axisFormatType = axisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        
        if axisFormatType == 1 {
            filterValuesForColumn[axisId ?? ""] = xCategories
        }
        
        
        chartOptions.xaxis = xCategories
        
        var combiData = CombinationData()
        combiData.lineData = lineValues
        combiData.areaData = areaValues
        combiData.leftYaxisTitle = lineYAxisTitle
        combiData.rightYaxisTitle = areaYAxisTitle
        combiData.lineSeriesNames = [lineSeriesName]
        combiData.areaSeriesNames = areaSeriesNames
        
        chartOptions.combinationData = combiData
        chartOptions.filterValuesForColumn = filterValuesForColumn
        
        return .success(chartOptions)
        
    }
    
    private func getLineLineOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var rightLine1ValueId:String = ""
        var line2YAxisTitle:String = ""
        var lineValues:[[Double]] = []
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        let format = parameters.dataViewJson["visualizations"]["format"]["format"].arrayValue
        
        guard let axisConfig = config.filter({$0["zone"] == "axis"}).first,
              let leftLineValuesConfig = config.filter({$0["zone"] == "values-line"}).first,
              let rightLineValuesConfig = config.filter({$0["zone"] == "values-line-right"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in LineLine"))
        }
        
        let axisId = axisConfig["columns"].arrayValue.first?["columnId"].stringValue
        let leftLineValueId = leftLineValuesConfig["columns"].arrayValue.first?["columnId"].stringValue
        let rightLineValueId = rightLineValuesConfig["columns"].arrayValue.first?["columnId"].stringValue
        
        if rightLineValuesConfig["columns"].arrayValue.count == 2{
            rightLine1ValueId = rightLineValuesConfig["columns"].arrayValue[1]["columnId"].stringValue
            line2YAxisTitle = format.filter{$0["type"] == "line2-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        }
        
        
        //Get Line Seriess Name
        let leftLineValue = leftLineValuesConfig["columns"].arrayValue
        let rightLineValue = rightLineValuesConfig["columns"].arrayValue
        
        var LineSeriesName:[String] = []
        
        if leftLineValue.count == 0 {
            LineSeriesName.append("")
        }else{
            for index in 0..<leftLineValue.count {
                LineSeriesName.append(parameters.headers[leftLineValue[index]["columnId"].stringValue].stringValue)
            }
        }
        
        for index in 0..<rightLineValue.count {
            LineSeriesName.append( parameters.headers[rightLineValue[index]["columnId"].stringValue].stringValue)
        }
        
        //Special case where user adds only one type of chart in combination charts. so one of the valueId might be nil.
        
        //        else {
        //            return .failure(.custom(message:"Failed to get one of the column Id in LineLine"))
        //
        //        }
        
        let lineYAxisTitle = format.filter{$0["type"] == "line-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        let line1YAxisTitle = format.filter{$0["type"] == "line1-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        
        var xCategories = [String]()
        var leftLine = [Double]()
        var rightLine = [Double]()
        var rightLine1 = [Double]()
        
        for dataPoint in dataPoints{
            
            let category = dataPoint["_id"][axisId ?? ""].stringValue
            let leftLineValue = dataPoint[leftLineValueId ?? ""].doubleValue
            let rightLineValue = dataPoint[rightLineValueId ?? ""].doubleValue
            
            if rightLineValuesConfig["columns"].arrayValue.count == 2{
                rightLine1.append(dataPoint[rightLine1ValueId].doubleValue)
            }
            
            if !xCategories.contains(category){
                xCategories.append(category)
            }
            
            if leftLineValueId != nil {
                leftLine.append(leftLineValue)
            }
            if rightLineValueId != nil {
                rightLine.append(rightLineValue)
            }
            
        }
        
        if rightLine1.count > 0 {
            lineValues = [leftLine, rightLine,rightLine1]
        }else{
            lineValues = [leftLine, rightLine]
        }
        
        
        var filterValuesForColumn = [String:[String]]()
        let axisFormatType = axisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        
        if axisFormatType == 1 {
            filterValuesForColumn[axisId ?? ""] = xCategories
        }
        
        
        chartOptions.xaxis = xCategories
        
        var combiData = CombinationData()
        combiData.lineData = lineValues
        combiData.leftaxisTitle = [lineYAxisTitle,line1YAxisTitle,line2YAxisTitle]
        combiData.lineSeriesNames = LineSeriesName
        chartOptions.combinationData = combiData
        chartOptions.filterValuesForColumn = filterValuesForColumn
        
        
        return .success(chartOptions)
        
    }
    
    private func getLineColumnOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var lineValueId = [String]()
        var lineYAxisTitle = [String]()
        var lineSeriesName = [String]()
        var columnValueId = [String]()
        var columnYAxisTitle = [String]()
        var columnSeriesName = [String]()
        var allLineValues:[[Double]] = []
        var allColumnValues:[[Double]] = []
        
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        let format = parameters.dataViewJson["visualizations"]["format"]["format"].arrayValue
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        
        guard let axisConfig = config.filter({$0["zone"] == "axis"}).first,
              let lineValuesConfig = config.filter({$0["zone"] == "values-line"}).first,
              let columnValuesConfig = config.filter({$0["zone"] == "values-column"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in LineColumn"))
        }
        
        let axisId = axisConfig["columns"].arrayValue.first?["columnId"].stringValue
        
        for index in 0..<lineValuesConfig["columns"].arrayValue.count {
            lineValueId.append( lineValuesConfig["columns"].arrayValue[index]["columnId"].stringValue)
            lineYAxisTitle.append(format.filter{$0["type"] == JSON("line\(index+1)-yaxistitle")}.first?["options"].arrayValue.first?["value"].stringValue ?? "")
            lineSeriesName.append(parameters.headers[lineValuesConfig["columns"][index]["columnId"].stringValue].stringValue)
        }
        
        for index in 0..<columnValuesConfig["columns"].arrayValue.count {
            columnValueId.append( columnValuesConfig["columns"].arrayValue[index]["columnId"].stringValue)
            columnYAxisTitle.append(format.filter{$0["type"] == JSON("column\(index+1)-yaxistitle")}.first?["options"].arrayValue.first?["value"].stringValue ?? "")
            columnSeriesName.append(parameters.headers[ columnValuesConfig["columns"][index]["columnId"].stringValue].stringValue)
        }
        
        var xCategories = [String]()
        
        for dataPoint in dataPoints{
            let category = dataPoint["_id"][axisId ?? ""].stringValue
            
            if !xCategories.contains(category){
                xCategories.append(category)
            }
            
            for index in 0..<lineValueId.count {
                let lineValue = dataPoint[lineValueId[index]].doubleValue
                if allLineValues.count == lineValueId.count {
                    var arrayvalue = allLineValues[index]
                    arrayvalue.append(lineValue)
                    allLineValues.insert(arrayvalue, at: index)
                    allLineValues.remove(at: index+1)
                }else{
                    allLineValues.append([lineValue])
                }
            }
            
            for index in 0..<columnValueId.count {
                let columnValue = dataPoint[columnValueId[index]].doubleValue
                if allColumnValues.count == columnValueId.count {
                    var arrayvalue = allColumnValues[index]
                    arrayvalue.append(columnValue)
                    allColumnValues.insert(arrayvalue, at: index)
                    allColumnValues.remove(at: index+1)
                }else{
                    allColumnValues.append([columnValue])
                }
            }
            
        }
        
        var filterValuesForColumn = [String:[String]]()
        let axisFormatType = axisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        
        if axisFormatType == 1 {
            filterValuesForColumn[axisId ?? ""] = xCategories
        }
        
        
        chartOptions.xaxis = xCategories
        
        
        var combiData = CombinationData()
        combiData.lineData = allLineValues
        combiData.columnData = allColumnValues
        combiData.lineSeriesNames = lineSeriesName
        combiData.columnSeriesNames = columnSeriesName
        combiData.leftaxisTitle = lineYAxisTitle
        combiData.rightaxisTitle = columnYAxisTitle
        chartOptions.combinationData = combiData
        chartOptions.filterValuesForColumn = filterValuesForColumn
        
        return .success(chartOptions)
    }
    
    
    private func getLineColumnStacked(_ parameters: Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var line1ValueId:String = ""
        var line1YAxisTitle:String = ""
        var lineValues:[[Double]] = []
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        let format = parameters.dataViewJson["visualizations"]["format"]["format"].arrayValue
        
        guard let axisConfig = config.filter({$0["zone"] == "axis"}).first,
              let lineValuesConfig = config.filter({$0["zone"] == "values-line"}).first,
              let columnValuesConfig = config.filter({$0["zone"] == "values-column"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in LineColumnStacked"))
            
        }
        
        //        guard
        let axisId  = axisConfig["columns"].arrayValue.first?["columnId"].stringValue
        //        let axisId = parameters.dataViewJson["visualizations"]["configuration"]["drillDownInfo"]["level"].string
        let lineValueId = lineValuesConfig["columns"].arrayValue.first?["columnId"].stringValue
        
        
        if lineValuesConfig["columns"].arrayValue.count == 2{
            line1ValueId = lineValuesConfig["columns"].arrayValue[1]["columnId"].stringValue
            line1YAxisTitle = format.filter{$0["type"] == "line1-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        }
        
        //        else {
        //            return .failure(.custom(message:"Failed to get one of the column Id in LineColumnStacked"))
        //
        //        }
        
        let columnValueIds = columnValuesConfig["columns"].arrayValue.map({$0["columnId"].string}).filter{$0 != nil}
        
        
        let lineYAxisTitle = format.filter{$0["type"] == "line-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        let columnYAxisTitle = format.filter{$0["type"] == "area1-yaxistitle"}.first?["options"].arrayValue.first?["value"].stringValue ?? ""
        
        
        var xCategories = [String]()
        var columnValues = [[Any]]()
        var leftLine = [Double]()
        var leftLine1 = [Double]()
        var lineSeriesName:[String] = []
        
        if lineValuesConfig["columns"].arrayValue.count == 2{
            lineSeriesName.append(parameters.headers[lineValueId ?? ""].stringValue)
            lineSeriesName.append(parameters.headers[line1ValueId].stringValue)
        }
        else{
            lineSeriesName.append(parameters.headers[lineValueId ?? ""].stringValue)
        }
        
        let columnSeriesNames = columnValueIds.map{ columnValueId in
            parameters.headers[columnValueId!].stringValue
        }
        
        for dataPoint in dataPoints{
            
            let category = dataPoint["_id"][axisId ?? ""].stringValue
            let leftlineValue = dataPoint[lineValueId ?? ""].doubleValue
            
            if !xCategories.contains(category){
                xCategories.append(category)
            }
            
            if lineValueId != nil {
                leftLine.append(leftlineValue)
            }
            
            if lineValuesConfig["columns"].arrayValue.count == 2{
                leftLine1.append(dataPoint[line1ValueId].doubleValue)
            }
        }
        
        if leftLine1.count > 0 {
            lineValues = [leftLine,leftLine1]
        }else{
            lineValues = [leftLine]
        }
        
        columnValues = columnValueIds.map{ columnValueId in
            dataPoints.map{
                let value:Any = $0[columnValueId!].double ?? NSNull()
                return value
            }
        }
        
        var filterValuesForColumn = [String:[String]]()
        
        let axisFormatType = axisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        
        if axisFormatType == 1 {
            filterValuesForColumn[axisId ?? ""] = xCategories
        }
        
        
        
        chartOptions.xaxis = xCategories
        
        var combiData = CombinationData()
        combiData.lineData = lineValues
        combiData.columnData = columnValues
        combiData.leftYaxisTitle = lineYAxisTitle
        combiData.right1YaxisTitle = line1YAxisTitle
        combiData.rightYaxisTitle = columnYAxisTitle
        combiData.lineSeriesNames = lineSeriesName
        combiData.columnSeriesNames = columnSeriesNames
        
        chartOptions.combinationData = combiData
        chartOptions.filterValuesForColumn = filterValuesForColumn
        
        return .success(chartOptions)
        
    }
    
    
    private func getHeatMapOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        //        let visualizeJson = parameters.visualizeJson
        
        
        let format = parameters.dataViewJson["visualizations"]["format"]["format"].arrayValue
        
        let colorAxisOptions = format.filter{$0["type"] == "colorAxis"}.first?["options"].arrayValue
        
        var minColor =  colorAxisOptions?.filter{$0["type"]=="minColor"}.first?["value"].stringValue
        
        var maxColor = colorAxisOptions?.filter{$0["type"]=="maxColor"}.first?["value"].stringValue
        
        if minColor != nil && maxColor != nil  && (!minColor!.contains("#") && !maxColor!.contains("#")){
            minColor =  "#" + minColor!
            maxColor =  "#" + maxColor!
        }
        
        guard let valuesConfig = config.filter({$0["zone"] == "values"}).first, let leftAxisConfig =  config.filter({$0["zone"] == "rows"}).first, let topAxisConfig = config.filter({$0["zone"] == "columns"}).first else {
            return   .failure(.custom(message:"Failed to get one of the zones in HeatMap"))
            
        }
        
        guard let valueId = valuesConfig["columns"].arrayValue.first?["columnId"].stringValue, let leftAxisId = leftAxisConfig["columns"].arrayValue.first?["columnId"].stringValue,let topAxisId = topAxisConfig["columns"].arrayValue.first?["columnId"].stringValue  else {
            return .failure(.custom(message:"Failed to get one of the column Id in HeatMap"))
            
        }
        
        /*
         let topAxisArray = visualizeJson["topAxis"].arrayValue.map{$0["value"].stringValue}
         let leftAxisArray = visualizeJson["leftAxis"].arrayValue.map{$0["value"].stringValue}
         
         //To remove duplicates in leftAxis, using a Set
         var leftAxis =  Array(Set(leftAxisArray))
         var topAxis = Array(Set(topAxisArray))
         
         if let index = leftAxis.index(of: "(Blank)"){
         leftAxis.remove(at: index)
         }
         
         let leftAxisFormatType = leftAxisConfig["columns"].arrayValue.first?["columnType"].intValue
         
         let topAxisFormatType = topAxisConfig["columns"].arrayValue.first?["columnType"].intValue
         
         
         var filterValuesForColumn = [String:[String]]()
         
         //Basic filters should only show vales for column that is of string type
         //columnType - 1=String, 2=Number, 3=Date
         
         if leftAxisFormatType == 1{
         filterValuesForColumn[leftAxisId] = leftAxis
         }
         if topAxisFormatType == 1 {
         filterValuesForColumn[topAxisId] = topAxis
         }
         
         //To fix an issue with highcharts which shows numbers, append empty strings
         leftAxis.insert("", at: 0)
         leftAxis.append("")
         
         topAxis.insert("", at: 0)
         topAxis.append("")
         
         //Filter out grandTotal values as we don't need them
         let results = visualizeJson["results"].arrayValue.filter({$0["leftKey"].stringValue != "grandtotal"})
         
         
         var dataPoints = [Any]()
         
         for (yIndex, leftKey) in leftAxis.enumerated() {
         
         for (xIndex,topKey) in topAxis.enumerated() {
         
         if let result = results.filter({$0["leftKey"].stringValue == leftKey && $0["topKey"].stringValue == topKey}).first {
         let zvalue = result["values"][valueId].floatValue
         //left axis(yaxis) and topAxis(xaxis) are given category strings. but the point should have a coordinate like ("x":value,"y":value,"z":value) because highcharts expects points to be in numerical values to plot it. so x and y coordinates are formed by giving index of categories in corresponding axis and z is given the actual value corresponding to an x and y category.
         let point:[Float] = [Float(xIndex), Float(yIndex), zvalue]
         
         dataPoints.append(point)
         
         }
         }
         }
         
         */
        
        let topAxis = parameters.visualizeJson["xFieldData"].arrayValue.map{$0.stringValue}
        let leftAxis = parameters.visualizeJson["yFieldData"].arrayValue.map{$0.stringValue}
        
        let dataPoints = parameters.visualizeJson["seriesData"][0]["data"].arrayObject!
        
        
        
        let leftAxisFormatType = leftAxisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        let topAxisFormatType = topAxisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        
        var filterValuesForColumn = [String:[String]]()
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        
        if leftAxisFormatType == 1{
            filterValuesForColumn[leftAxisId] = leftAxis
        }
        if topAxisFormatType == 1 {
            filterValuesForColumn[topAxisId] = topAxis
        }
        
        chartOptions.xaxis = topAxis
        chartOptions.yaxis = leftAxis
        chartOptions.series = [dataPoints]
        chartOptions.heatMapMaxColor = maxColor
        chartOptions.heatMapMinColor = minColor
        chartOptions.leftAxisColumnName = parameters.headers[leftAxisId].stringValue
        chartOptions.topAxisColumnName = parameters.headers[topAxisId].stringValue
        chartOptions.valuesColumnName = parameters.headers[valueId].stringValue
        chartOptions.filterValuesForColumn = filterValuesForColumn
        
        return .success(chartOptions)
        
    }
    
    private func getSlicerOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel> {
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        
        guard let column = config.filter({$0["zone"] == "column"}).first?["columns"].arrayValue.first else {
            return .failure(.custom(message:"Failed to get one of the zones in Slicer"))
        }
        
        let columnID = column["columnId"].stringValue
        let columnType = column["columnType"].intValue
        let dateFormat = column["dateFormat"].string
        let customDateFormat = column["customDateFormat"].string
        var slicerValues:[String] = []
        
        if dataPoints.count > 0 && dataPoints[0]["_id"] != nil {
            slicerValues = dataPoints.map{$0["_id"][columnID].stringValue}
        }else{
            slicerValues = dataPoints.map{$0[columnID].stringValue}
        }
        
        var slicerOptions = JSON()
        slicerOptions["columnId"].stringValue = columnID
        slicerOptions["columnType"].intValue = columnType
        if let dateFormatString = dateFormat{
            slicerOptions["dateFormat"].stringValue = dateFormatString
        }
        
        if let customDateString = customDateFormat {
            slicerOptions["customDateFormat"].stringValue = customDateString
        }
        
        slicerOptions["values"] = JSON(slicerValues)
        
        let chartName = parameters.dataViewJson["name"].stringValue
        var chartOptions = ChartOptionsModel()
        chartOptions.name = chartName
        chartOptions.type = ChartType(rawValue: parameters.dataViewJson["visualizations"]["chartType"].stringValue)
        
        chartOptions.slicerOptions = slicerOptions
        
        return .success(chartOptions)
    }
    
    
    private func getPieOptions(_ parameters:Parameters) -> ServiceResponse<ChartOptionsModel>{
        var chartOptions = getCommonChartOptions(parameters)
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        
        guard let sliceConfig = config.filter({$0["zone"] == "slice"}).first,
              let valuesConfig = config.filter({$0["zone"] == "values"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in \(chartOptions.type.rawValue)"))
        }
        
        guard let sliceColumnId = sliceConfig["columns"].arrayValue.first?["columnId"].stringValue, let valueId = valuesConfig["columns"].arrayValue.first?["columnId"].stringValue else {
            return .failure(.custom(message:"Failed to get one of the columns in \(chartOptions.type.rawValue)"))
        }
        
        var sliceNames = [String]()
        var seriesData = [[String:Any]]()
        
        for dataPoint in dataPoints{
            let sliceName = dataPoint["_id"][sliceColumnId].stringValue
            let value = dataPoint[valueId].doubleValue
            let point:[String : Any] = ["name":sliceName, "y":value]   //Highcharts expects in this format
            
            sliceNames.append(sliceName)
            seriesData.append(point)
        }
        
        let seriesName = parameters.headers[valueId].stringValue
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        let slicerColumnType = sliceConfig["columns"].arrayValue.first!["columnType"].intValue
        
        var filterValuesForColumn = [String:[String]]()
        if slicerColumnType == 1{
            filterValuesForColumn[sliceColumnId] = sliceNames
        }
        
        chartOptions.series = seriesData
        chartOptions.seriesNames = [seriesName]
        chartOptions.filterValuesForColumn = filterValuesForColumn
        return .success(chartOptions)
        
    }
    
    private func getDonutChartOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var chartOptions = getCommonChartOptions(parameters)
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        
        guard let data = parameters.visualizeJson["data"].arrayValue.first else {
            return .failure(.custom(message:"Failed to visualise response in \(chartOptions.type.rawValue)"))
        }
        
        guard let sliceConfig = config.filter({$0["zone"] == "slice"}).first,
              let valuesConfig = config.filter({$0["zone"] == "values"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in \(chartOptions.type.rawValue)"))
        }
        
        guard  let valueId = valuesConfig["columns"].arrayValue.first?["columnId"].stringValue else {
            return .failure(.custom(message:"Failed to get one of the columns in \(chartOptions.type.rawValue)"))
        }
        
        let sliceColumnIds = sliceConfig["columns"].arrayValue.map({$0["columnId"].stringValue})
        
        let outerSliceColumnId = parameters.dataViewJson["outerSliceId"].stringValue //child slice columnId
        let innerSliceColumnId = sliceColumnIds.filter{$0 != outerSliceColumnId}.first!
        
        
        //Parent pie is the inner pie and child is the outer pie
        let parentPieSliceNames = data["categories"].arrayValue.map{$0.stringValue}
        
        let dataPoints = data["data"].arrayValue
        
        var parentPies = [Any]()
        var childPies = [Any]()
        
        for parentPie in parentPieSliceNames{
            let parent = dataPoints.filter{$0["drilldown"]["parent"].stringValue == parentPie}.first!
            let parentPiePoint:[String:Any] = ["name":parentPie, "y":parent["y"].doubleValue, "color":parent["color"].stringValue]
            
            parentPies.append(parentPiePoint)
            
            //            let childName = parent["drilldown"]["name"].stringValue
            let childDataPoints = parent["drilldown"]["data"].arrayValue.map{$0.doubleValue}
            let childCategories = parent["drilldown"]["categories"].arrayValue.map{$0.stringValue}
            
            for (index, childCategory) in childCategories.enumerated(){
                let childPiePoint:[String:Any] = ["name":parentPie, "y":childDataPoints[index], "color":parent["color"].stringValue, "category":childCategory]
                childPies.append(childPiePoint)
            }
            
        }
        
        let seriesName = parameters.headers[valueId].stringValue
        
        //Basic filters should only show vales for column that is of string type
        //columnType - 1=String, 2=Number, 3=Date
        let outerSliceColumnType = sliceConfig["columns"].arrayValue.filter{$0["columnId"].stringValue == outerSliceColumnId}[0]["columnType"].intValue
        
        let innerSliceColumnType = sliceConfig["columns"].arrayValue.filter{$0["columnId"].stringValue == innerSliceColumnId}[0]["columnType"].intValue
        
        var filterValuesForColumn = [String:[String]]()
        if innerSliceColumnType == 1 {
            filterValuesForColumn[innerSliceColumnId] = parentPieSliceNames
        }
        
        let uniqueChildCategories = Array(Set(childPies.map{($0 as! [String:Any])["category"] as! String}))
        
        if outerSliceColumnType == 1{
            filterValuesForColumn[outerSliceColumnId] = uniqueChildCategories
        }
        
        chartOptions.series = [parentPies, childPies]
        chartOptions.seriesNames = [seriesName]
        chartOptions.filterValuesForColumn = filterValuesForColumn
        return .success(chartOptions)
    }
    
    
    private func getScatterPlotOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel> {
        
        //Scatter plot not fully implemented... its in progress
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        //        let visualizeJson = parameters.visualizeJson
        
        guard
            let yAxisConfig =  config.filter({$0["zone"] == "yaxis"}).first,
            let xAxisConfig = config.filter({$0["zone"] == "xaxis"}).first
                
        else {
            return   .failure(.custom(message:"Failed to get one of the zones in ScatterPlot"))
        }
        
        let sizeConfig = config.filter({$0["zone"] == "size"}).first
        let legendConfig = config.filter({$0["zone"] == "legend"}).first
        
        
        
        guard
            let yAxisId = yAxisConfig["columns"].arrayValue.first?["columnId"].stringValue,
            let xAxisId = xAxisConfig["columns"].arrayValue.first?["columnId"].stringValue  else {
            return .failure(.custom(message:"Failed to get one of the column Id in ScatterPlot"))
        }
        
        
        var legendsPresent = false
        
        let sizeId = sizeConfig?["columns"].arrayValue.first?["columnId"].stringValue
        
        let legendId = legendConfig?["columns"].arrayValue.first?["columnId"].stringValue
        
        if legendId != nil {
            legendsPresent = true
        }
        
        let yAxisFormatType = yAxisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        let xAxisFormatType = xAxisConfig["columns"].arrayValue.first?["columnType"].intValue
        
        //        let sizeColumnFormatType = sizeConfig?["columns"].arrayValue.first?["columnType"].intValue
        
        //        let legendColumnType = legendConfig?["columns"].arrayValue.first?["columnType"].intValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        
        
        if legendsPresent {
            var legendNames = [String]()
            for point in dataPoints {
                let legendName = point[legendId!].stringValue
                if !legendNames.contains(legendName) {
                    legendNames.append(legendName)
                }
            }
            
            //For each legend, get xaxis values and yaxis values and size of bubble if any.
            
            //for Each legend, we make a series
            var series = [Any]()
            
            for legend in legendNames {
                
                var seriesData = [Any]()
                
                for dataPoint in dataPoints {
                    if dataPoint[legendId!].stringValue == legend {
                        
                        let xvalue = dataPoint[xAxisId].intValue
                        let yvalue = dataPoint[yAxisId].intValue
                        let sizeValue = dataPoint[sizeId ?? ""].int ?? 0
                        
                        let xname = parameters.headers[xAxisId].stringValue
                        let yname = parameters.headers[yAxisId].stringValue
                        let sizeName = parameters.headers[sizeId ?? ""].stringValue
                        
                        let pointCoordinate = ["x":xvalue, "y":yvalue, "z":sizeValue, "xname":xname, "yname":yname, "sizeName":sizeName, "legendName":legend] as [String : Any]
                        seriesData.append(pointCoordinate)
                        
                    }
                }
                
                series.append(seriesData)
                
            }
            
            
            
            
            let xaxis = dataPoints.map{$0[xAxisId].stringValue}
            let yaxis = dataPoints.map{$0[yAxisId].stringValue}
            
            
            
            var filterValuesForColumn = [String:[String]]()
            
            //        Basic filters should only show vales for column that is of string type
            //        columnType - 1=String, 2=Number, 3=Date
            
            if yAxisFormatType == 1{
                filterValuesForColumn[yAxisId] = xaxis
            }
            if xAxisFormatType == 1 {
                filterValuesForColumn[xAxisId] = yaxis
            }
            //            if sizeColumnFormatType == 1 {
            //                filterValuesForColumn[sizeId!]
            //            }
            //
            
            
            
            chartOptions.seriesNames = legendNames
            chartOptions.xaxis = xaxis
            chartOptions.yaxis = yaxis
            chartOptions.series = series
            chartOptions.leftAxisColumnName = parameters.headers[yAxisId].stringValue
            chartOptions.topAxisColumnName = parameters.headers[xAxisId].stringValue
            chartOptions.valuesColumnName = parameters.headers[sizeId ?? ""].stringValue
            chartOptions.filterValuesForColumn = filterValuesForColumn
            
            return .success(chartOptions)
            
            
        } else {
            
            
            var seriesData = [Any]()
            
            for dataPoint in dataPoints {
                
                let xvalue = dataPoint[xAxisId].intValue
                let yvalue = dataPoint[yAxisId].intValue
                let sizeValue = dataPoint[sizeId ?? ""].int ?? 0
                
                let xname = parameters.headers[xAxisId].stringValue
                let yname = parameters.headers[yAxisId].stringValue
                let sizeName = parameters.headers[sizeId ?? ""].stringValue
                
                let pointCoordinate = ["x":xvalue, "y":yvalue, "z":sizeValue, "xname":xname, "yname":yname, "sizeName":sizeName] as [String : Any]
                seriesData.append(pointCoordinate)
                
            }
            
            
            let xaxis = dataPoints.map{$0[xAxisId].stringValue}
            let yaxis = dataPoints.map{$0[yAxisId].stringValue}
            
            var filterValuesForColumn = [String:[String]]()
            
            //        Basic filters should only show values for column that is of string type
            //        columnType - 1=String, 2=Number, 3=Date
            
            if yAxisFormatType == 1{
                filterValuesForColumn[yAxisId] = xaxis
            }
            if xAxisFormatType == 1 {
                filterValuesForColumn[xAxisId] = yaxis
            }
            
            //                chartOptions.seriesNames = legendNames
            chartOptions.xaxis = xaxis
            chartOptions.yaxis = yaxis
            chartOptions.series = [seriesData]
            chartOptions.leftAxisColumnName = parameters.headers[yAxisId].stringValue
            chartOptions.topAxisColumnName = parameters.headers[xAxisId].stringValue
            chartOptions.valuesColumnName = parameters.headers[sizeId ?? ""].stringValue
            chartOptions.filterValuesForColumn = filterValuesForColumn
            
            return .success(chartOptions)
            
        }
        
    }
    
    
    private func getTableChartOptions(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        
        guard let tableConfig = config.filter({$0["zone"] == "columns-table"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in \(chartOptions.type.rawValue)"))
        }
        
        let columnIds = tableConfig["columns"].arrayValue.map{$0["columnId"].stringValue}
        
        var tableStructure = Array(repeating: [String](), count: columnIds.count)
        
        //Get names for each column id that goes in as headers of table
        var tableHeaders = columnIds.map{parameters.headers[$0].stringValue}
        
        for point in dataPoints{
            var li_columnIndex:Int = 0
            for (index,columnId) in columnIds.enumerated() {
                if tableConfig["columns"][li_columnIndex]["columnType"] != 2 {
                    let value = point[columnId].stringValue
                    li_columnIndex += 1
                    tableStructure[index].append(value)
                }else{
                    let li_decimalPlaces:Int = tableConfig["columns"][li_columnIndex]["numberFormat"]["decimalPlaces"].intValue
                    li_columnIndex += 1
                    let value = String(format: "%.\(li_decimalPlaces)f",  point[columnId].doubleValue.nextUp)
                    tableStructure[index].append(value)
                }
            }
        }
        
        //Check Does the Table chart is Transposed or not. Default value for Transposed is False
        var isTransposed:Bool = false
        
        if let transposed = (parameters.dataViewJson["visualizations"]["configuration"]["tabularInfo"].dictionary!)["isTransposed"]{
            isTransposed = transposed.boolValue
        }
        
        chartOptions.transposed = isTransposed
        
        if isTransposed == true {
            //Interchange Row and Column of table chart
            for index in 0..<tableHeaders.count {
                tableStructure[index].insert(tableHeaders[index], at: 0)
            }
            
            tableHeaders = tableStructure[0]
            tableStructure.remove(at: 0)
            
            if tableHeaders.count > 6 {
                tableHeaders.removeLast(tableHeaders.count-6)
            }
            
            var tableStructure1:[[String]] = []
            
            for index in 0..<tableHeaders.count {
                var TableValue:[String] = []
                for index1 in 0..<tableStructure.count {
                    TableValue.append(tableStructure[index1][index])
                }
                tableStructure1.append(TableValue)
            }
            chartOptions.tableHeaders = tableHeaders
            chartOptions.tableValues = tableStructure1
        }else{
            chartOptions.tableHeaders = tableHeaders
            chartOptions.tableValues = tableStructure
        }
        
        return .success(chartOptions)
        
    }
    
    
    
    
    private func getChartOptionsForBasicChartTypes(_ parameters:Parameters)->ServiceResponse<ChartOptionsModel>{
        
        var chartOptions = getCommonChartOptions(parameters)
        
        let config = parameters.dataViewJson["visualizations"]["configuration"]["config"].arrayValue
        
        let dataPoints = parameters.visualizeJson["data"].arrayValue
        
        guard let axisConfig = config.filter({$0["zone"] == "axis"}).first,
              let valuesConfig = config.filter({$0["zone"] == "values"}).first,
              let legendConfig = config.filter({$0["zone"] == "legend"}).first else {
            return .failure(.custom(message:"Failed to get one of the zones in \(chartOptions.type.rawValue)"))
            
        }
        
        //If there are any legends, only single measure or value is allowed
        if let legendColumns = legendConfig["columns"].array, legendColumns.count > 0 {
            
            /*
             guard let legendId = legendColumns.first?["columnId"].stringValue, let valueId = valuesConfig["columns"].arrayValue.first?["columnId"].stringValue, let axisId = axisConfig["columns"].arrayValue.first?["columnId"].stringValue else {
             return .failure(.custom(message:"Failed to get one of the columns"))
             
             }
             */
            
            guard let legendId = legendColumns.first?["columnId"].stringValue, let valueId = valuesConfig["columns"].arrayValue.first?["columnId"].stringValue, let axisId = parameters.dataViewJson["visualizations"]["configuration"]["drillDownInfo"]["level"].string else {
                return .failure(.custom(message:"Failed to get one of the columns"))
                
            }
            
            
            var numberFormatMap : JSON? = nil
            
            if let numberFormat = valuesConfig["columns"].arrayValue.first?["numberFormat"]{
                numberFormatMap = JSON([valueId:numberFormat])
            }
            
            //Each series will have a legend, so series can have the same name as legend
            
            
            var legendNames = [String]() //legendNames and series are same
            var xaxisCategories = [String]()
            var series = [Any]()
            
            var columnIdsForTooltipFormatter = [String]()
            
            var filterValuesForColumn = [String:[String]]()
            
            //Prepare a lookup for easy access in the following format
            //            {legendName: {
            //                              xCategory:yValue
            //                          }
            //            }
            var dataPointsLookup = JSON()
            
            
            for dataPoint in dataPoints {
                
                let legend = dataPoint["_id"][legendId].stringValue
                let category = dataPoint["_id"][axisId].stringValue
                
                //Get the unique legends
                if !legendNames.contains(legend){
                    legendNames.append(legend)
                }
                
                //Get the unique xaxis categories
                if !xaxisCategories.contains(category) {
                    xaxisCategories.append(category)
                }
                
                if dataPointsLookup[legend].dictionary == nil {
                    dataPointsLookup[legend] = [category:dataPoint[valueId].double as Any]
                } else {
                    
                    var dict = dataPointsLookup[legend].dictionaryValue
                    dict.updateValue((dataPoint[valueId]), forKey: category)
                    dataPointsLookup[legend] = JSON(dict)
                }
                
            }
            
            let axisFormatType = axisConfig["columns"].arrayValue.first?["columnType"].intValue
            let legendFormatType = legendConfig["columns"].arrayValue.first?["columnType"].intValue
            
            
            //Basic filters should only show vales for column that is of string type
            //columnType - 1=String, 2=Number, 3=Date
            
            if axisFormatType == 1 {
                filterValuesForColumn[axisId] = xaxisCategories
            }
            if legendFormatType == 1 {
                filterValuesForColumn[legendId] = legendNames
            }
            
            //Check for any visual filters apart from axis, values, legends zones
            
            if let filters = chartOptions.sortOptions{
                let visualFilters = filters.filter({$0["configZone"].string == nil})
                
                for visualFilter in visualFilters where visualFilter["type"].stringValue == "basic" {
                    
                    if let columnId = visualFilter["columnId"].string, visualFilter["columnType"].intValue == 1 {
                        filterValuesForColumn[columnId] = visualFilter["value"].arrayValue.map{$0.stringValue}
                        
                    }
                }
            }
            
            for legend in legendNames {
                //Get yValues for each series or legend
                var yValues = [Any]()
                for category in xaxisCategories {
                    
                    //For a particular legend or series, yValue is extracted for each xaxis category
                    
                    let y:Any = dataPointsLookup[legend][category].double ?? NSNull()
                    yValues.append(y)
                    
                }
                //Append yValues of each series to a series' array
                series.append(yValues)
                
                //Append columnId of measure for each legend: i.e, value id. As this case has legends, only one measure is allowed. so we have only one value id.
                
                columnIdsForTooltipFormatter.append(valueId)
            }
            
            
            
            //            let result = parameters.visualizeJson
            //
            //            let xaxis = result["xFieldData"].arrayValue.map{$0.stringValue}
            //            let series = result["seriesData"].arrayValue
            
            //            var legendNames = [String]()
            //            var seriesData = [Any]()
            //
            //            for val in series{
            //                let legend = val["name"].stringValue
            //                let data = val["data"].arrayObject
            //                legendNames.append(legend)
            //                seriesData.append(data)
            //            }
            
            chartOptions.xaxis = xaxisCategories//xaxis
            chartOptions.series = series //seriesData
            chartOptions.seriesNames = legendNames
            chartOptions.filterValuesForColumn = filterValuesForColumn
            chartOptions.columnIdsForTooltipFormatter = columnIdsForTooltipFormatter
            chartOptions.numberFormatMap = numberFormatMap
            return .success(chartOptions)
            
        } else {
            //If there is no legend, there might be multiple measures or values (ex: multiple lines in a line chart)
            
            var valuesIds = [String]()
            var xaxisCategories = [String]()
            var series = [Any]()
            var seriesNames = [String]()
            var filterValuesForColumn = [String:[String]]()
            
            
            for  column in valuesConfig["columns"].arrayValue {
                valuesIds.append(column["columnId"].stringValue)
            }
            
            //            guard  let axisId = axisConfig["columns"].arrayValue.first?["columnId"].stringValue else {
            //                return .failure(.custom(message:"Failed to get column"))
            //
            //            }
            
            guard  let axisId = parameters.dataViewJson["visualizations"]["configuration"]["drillDownInfo"]["level"].string else {
                return .failure(.custom(message:"Failed to get column"))
                
            }
            
            
            var numberFormatMap = JSON()
            
            for column in valuesConfig["columns"].arrayValue {
                let numberFormat = column["numberFormat"]
                let valueId = column["columnId"].stringValue
                
                if numberFormat.count > 0 {
                    numberFormatMap[valueId] = numberFormat
                }
            }
            
            for valueID in valuesIds {
                
                var yValues = [Any]()
                
                for dataPoint in dataPoints{
                    
                    let y:Any = dataPoint[valueID].double ?? NSNull()
                    yValues.append(y)
                    
                    var category = ""
                    
                    if parameters.dataViewJson["dataSource"]["sourceType"] == "Joined" ||  parameters.dataViewJson["dataSource"]["sourceType"] == "Realtime" {
                        category = dataPoint[axisId].stringValue
                    }else{
                        category = dataPoint["_id"][axisId].stringValue
                    }
                    
                    if !xaxisCategories.contains(category) {
                        xaxisCategories.append(category)
                    }
                }
                series.append(yValues)
                let seriesName = parameters.headers[valueID].stringValue
                seriesNames.append(seriesName)
            }
            
            let axisFormatType = axisConfig["columns"].arrayValue.first?["columnType"].intValue
            
            //Basic filters should only show valUes for column that is of string type
            //columnType - 1=String, 2=Number, 3=Date
            
            if axisFormatType == 1 {
                filterValuesForColumn[axisId] = xaxisCategories
            }
            
            
            //Check for any visual filters apart from axis, values, legends zones
            //Visual filters doesn't have any zone. so check for nil
            if let filters = chartOptions.sortOptions{
                let visualFilters = filters.filter({$0["configZone"].string == nil})
                
                for visualFilter in visualFilters where visualFilter["type"].stringValue == "basic" {
                    
                    if let columnId = visualFilter["columnId"].string, visualFilter["columnType"].intValue == 1 {
                        filterValuesForColumn[columnId] = visualFilter["value"].arrayValue.map{$0.stringValue}
                        
                    }
                }
            }
            
            
            //            let result = parameters.visualizeJson
            //
            //            let xaxis = result["xFieldData"].arrayValue.map{$0.stringValue}
            //            let data = result["seriesData"][0]["data"].arrayObject!
            
            chartOptions.xaxis =  xaxisCategories //xaxis//
            chartOptions.series = series //[data]
            chartOptions.seriesNames =  seriesNames //xaxis
            
            chartOptions.filterValuesForColumn = filterValuesForColumn
            chartOptions.columnIdsForTooltipFormatter = valuesIds
            chartOptions.numberFormatMap = numberFormatMap.count > 0 ? numberFormatMap : JSON.null
            return .success(chartOptions)
        }
        
    }
    
}

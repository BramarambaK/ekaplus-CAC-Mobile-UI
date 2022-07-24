//
//  ChartOptionsModel.swift
//  EkaAnalytics
//
//  Created by Nithin on 15/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

enum ChartType:String{
    case Bar
    case Column
    case Line
    case Spline
    case Area
    case AreaSpline
    case StackedArea
    case StackedPercentageArea
    case Pie
    case Pie3D
    case Donut
    case Donut3D
    case SemiPie
    case Polar
    case Card
    case Scatter
    case ScatterPlot
    case Bubble
    case LineArea
    case LineColumn
    case LineAreaStacked
    case LineLine
    case LineColumnStacked
    case Heatmap
    case StackedPercentageBar
    case StackedPercentageColumn
    case StackedColumn
    case StackedBar
    case Bar3D
    case Column3D
    case CheckSlicer
    case ComboSlicer
    case RadioSlicer
    case TagSlicer
    case DateRangeSlicer
    case Pivot
    case PointTime
    case SplineTime
    case AreaTime
    case AreaSplineTime
    case LineTime
    case ColumnTime
    case Table
    case DotMap
}

struct CombinationData{
    var lineData:[Any]! //Can be [Double] if it has single line or [[Double]] for more than one line series
    var areaData:[Any]!
    
    var columnData:[Any]!
    
    var leftYaxisTitle:String!
    var left1YaxisTitle:String!
    var rightYaxisTitle:String!
    var right1YaxisTitle:String!
    
    var lineSeriesNames:[String]!
    var areaSeriesNames:[String]!
    var columnSeriesNames:[String]!
    var leftaxisTitle:[String]!
    var rightaxisTitle:[String]!
}

struct ChartOptionsModel { //For each dataView, i.e, chart, we prepare a chartoptions model
    
    var dataViewID:String!
    var name:String!
    var type:ChartType!
    var xaxis : [String]!
    var yaxis:[String]!
    var series : [Any]!
    var drilldown:Bool!
    var xAxisTitle:String!
    var yAxisTitle:String!
    var seriesNames:[String]!
    var cardValues: [(key:String,value:Double,columnId:String)]!
    var combinationData:CombinationData!
    var heatMapMinColor:String!
    var heatMapMaxColor:String!
    var slicerOptions:JSON!
    var slicerAffectedDataViewIds:[String]!
    var sortOptions:[JSON]!
    var preDefinedFilters:[JSON]!
    var filterValuesForColumn:[String:[String]]?
    
    //For tool tip formatter
    var columnIdsForTooltipFormatter : [String]!
    var numberFormatMap:JSON?
    
    //For Table chart
    var tableHeaders:[String]!
    var tableValues:[[String]]!
    var transposed:Bool!
    
    
    //For Heatmap and Bubble, we have following fields
    var leftAxisColumnName:String!
    var topAxisColumnName:String!
    var valuesColumnName:String!
    
    init(){
        
    }
    
}

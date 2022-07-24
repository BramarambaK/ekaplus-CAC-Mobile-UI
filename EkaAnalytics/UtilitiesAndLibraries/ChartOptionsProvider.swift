//
//  ChartOptionsProvider.swift
//  EkaAnalytics
//
//  Created by Nithin on 19/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation

public protocol ChartPointSelectDelegate : AnyObject {
    func didPointSelected(context:HIChartContext)
}

//Provides highcharts options 
class OptionProvider {
    
    weak var delegate:ChartPointSelectDelegate?
    
    func hiOptions(for options:ChartOptionsModel) -> HIOptions{
        
        let hioptions = HIOptions()
        
        let chart = HIChart()
        hioptions.chart = chart
        chart.zoomType = "xy"
        
        let exporting = HIExporting()
        exporting.enabled = false
        hioptions.exporting = exporting
        
        let credits = HICredits()
        credits.enabled = false
        hioptions.credits = credits
        
        let plotOptions = HIPlotOptions()
        
        //        if options.type != .Table || options.type != .Card || options.type != .Pie {
        
        if options.type == .Line || options.type == .Spline || options.type == .Scatter || options.type == .Bar || options.type == .Bar3D || options.type == .StackedBar || options.type == .StackedPercentageBar || options.type == .Column || options.type == .Column3D || options.type == .StackedColumn || options.type == .StackedPercentageColumn || options.type == .Area || options.type == .AreaSpline || options.type == .StackedArea || options.type == .StackedPercentageArea  {
            
            let chartFunction = HIFunction(closure: { (chartContext) in
                self.delegate?.didPointSelected(context: chartContext!)
            }, properties: ["this.x", "this.y","this.index","this.category"])
            
            let chartSeries = HISeries()
            plotOptions.series = chartSeries
            
            let chartPoint = HIPoint()
            plotOptions.series.point = chartPoint
            
            let chartEvents = HIEvents()
            plotOptions.series.point.events = chartEvents
            
            plotOptions.series.point.events.click = chartFunction
        }
        
        let title = HITitle()
        title.text = options.name
        title.align = "center"
        hioptions.title = title
        
        let legend = HILegend()
        legend.verticalAlign = "bottom"
        legend.align = "center"
        legend.layout = "horizontal"
        legend.enabled = false
        hioptions.legend = legend
        
        let xaxis = HIXAxis()
        xaxis.tickColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.0)
        xaxis.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
        xaxis.title = HITitle()
        xaxis.title.text = options.xAxisTitle
        xaxis.categories = options.xaxis
        hioptions.xAxis = [xaxis]
        
        let yaxis = HIYAxis()
        yaxis.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
        yaxis.categories = options.yaxis
        yaxis.title = HITitle()
        yaxis.title.text = options.yAxisTitle
        hioptions.yAxis = [yaxis]
        
        //        print(options.type.rawValue)
        switch options.type {
            
        case .Bar?, .StackedPercentageBar?, .StackedBar?, .Bar3D?:
            plotOptions.bar = HIBar()
            
            let tooltip = HITooltip()
            tooltip.headerFormat = ""
            hioptions.tooltip = tooltip
            
            if options.type == .StackedPercentageBar{
                plotOptions.bar.stacking = "percent"
                tooltip.shared = true
                tooltip.pointFormat = "<span style=\"color:{series.color}\">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>"
            } else if options.type == .StackedBar {
                plotOptions.bar.stacking = "normal"
            }
            
            if options.type == .Bar3D{
                chart.type = "bar"
                chart.options3d = HIOptions3d()
                chart.options3d.enabled = true
                chart.options3d.alpha = 15
                chart.options3d.beta = 15
                chart.options3d.depth = 40
                chart.options3d.viewDistance = 25
            }
            
            hioptions.plotOptions = plotOptions
            plotOptions.bar.depth = 25
            
            var bars = [HIBar]()
            let series = options.series!
            
            for i in 0 ..< series.count {
                let bar = HIBar()
                bar.data = series[i] as? [Any]
                bar.name = options.seriesNames[i]
                bar.id = options.columnIdsForTooltipFormatter[i]
                bar.connectNulls = true
                bars.append(bar)
            }
            
            hioptions.series = bars
            return hioptions
            
        case .Column?, .StackedPercentageColumn?, .StackedColumn?, .Column3D?:
            
            plotOptions.column = HIColumn()
            
            let tooltip = HITooltip()
            tooltip.headerFormat = ""
            
            tooltip.useHTML = true
            
            hioptions.tooltip = tooltip
            
            if options.type == .StackedPercentageColumn{
                plotOptions.column.stacking = "percent"
                tooltip.shared = true
                tooltip.pointFormat = "<span style=\"color:{series.color}\">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>"
            } else if options.type == .StackedColumn{
                plotOptions.column.stacking = "normal"
            }
            
            if options.type == .Column3D{
                chart.type = "column"
                chart.options3d = HIOptions3d()
                chart.options3d.enabled = true
                chart.options3d.alpha = 15
                chart.options3d.beta = 15
                chart.options3d.depth = 40
                chart.options3d.viewDistance = 25
            }
            
            hioptions.plotOptions = plotOptions
            var columns = [HIColumn]()
            let series = options.series!
            
            for i in 0 ..< series.count {
                let column = HIColumn()
                column.data = series[i] as? [Any]
                column.name = options.seriesNames[i]
                column.id = options.columnIdsForTooltipFormatter[i]
                column.connectNulls = true
                columns.append(column)
            }
            
            hioptions.series = columns
            return hioptions
            
        case .Line?, .Polar?:
            
            if options.type == .Polar{
                chart.polar = true
                let pane = HIPane()
                pane.startAngle = 0
                pane.endAngle = 360
                hioptions.pane = pane
            } else {
                plotOptions.line = HILine()
            }
            
            
            let tooltip = HITooltip()
            tooltip.headerFormat = ""
            hioptions.tooltip = tooltip
            
            var lines = [HILine]()
            
            let series = options.series!
            
            for i in 0 ..< series.count {
                
                let line = HILine()
                line.data = series[i] as? [Any]
                line.name = options.seriesNames[i]
                //                    line.id = options.columnIdsForTooltipFormatter[i]
                line.connectNulls = true
                lines.append(line)
                
            }
            
            hioptions.plotOptions = plotOptions
            hioptions.series = lines
            return hioptions
            
            
        case .Spline?:
            
            plotOptions.spline = HISpline()
            
            let tooltip = HITooltip()
            tooltip.headerFormat = ""
            hioptions.tooltip = tooltip
            
            var splines = [HISpline]()
            
            let series = options.series!
            
            for i in 0 ..< series.count {
                
                let spline = HISpline()
                spline.data = series[i] as? [Any]
                spline.name = options.seriesNames[i]
                spline.id = options.columnIdsForTooltipFormatter[i]
                spline.connectNulls = true
                splines.append(spline)
                
            }
            
            hioptions.plotOptions = plotOptions
            hioptions.series = splines
            return hioptions
            
        case .Area?, .StackedArea?, .StackedPercentageArea?:
            
            plotOptions.area = HIArea()
            
            if options.type == .StackedArea {
                plotOptions.area.stacking = "normal"
            } else if options.type == .StackedPercentageArea{
                plotOptions.area.stacking = "percent"
            }
            
            
            
            let tooltip = HITooltip()
            hioptions.tooltip = tooltip
            
            var areas = [HIArea]()
            
            let series = options.series!
            
            for i in 0 ..< series.count {
                
                let area = HIArea()
                area.data = series[i] as? [Any]
                area.name = options.seriesNames[i]
                area.id = options.columnIdsForTooltipFormatter[i]
                area.connectNulls = true
                areas.append(area)
                
            }
            
            hioptions.plotOptions = plotOptions
            hioptions.series = areas
            return hioptions
            
            
        case .AreaSpline?:
            plotOptions.areaspline = HIAreaspline()
            
            let tooltip = HITooltip()
            tooltip.headerFormat = ""
            hioptions.tooltip = tooltip
            
            var areas = [HIAreaspline]()
            
            let series = options.series!
            
            for i in 0 ..< series.count {
                
                let area = HIAreaspline()
                area.data = series[i] as? [Any]
                area.name = options.seriesNames[i]
                area.connectNulls = true
                areas.append(area)
                
            }
            
            hioptions.plotOptions = plotOptions
            hioptions.series = areas
            return hioptions
        case .Pie?, .Pie3D?, .SemiPie?:
            
            plotOptions.pie = HIPie()
            
            let tooltip = HITooltip()
            hioptions.tooltip = tooltip
            
            let pieSeries = options.series!
            //                let sliceNames = options.seriesNames!
            
            
            //                var pieData = [HIPie]()
            
            //                for (i,slice) in sliceNames.enumerated(){
            //                    let pieDataPoint = ["name":slice, "y":series[i]]
            //                    pieData.append(pieDataPoint)
            //                }
            
            let pie = HIPie()
            pie.data = pieSeries
            pie.name = options.seriesNames.first!
            hioptions.series = [pie]
            
            if options.type == .SemiPie{
                plotOptions.pie.center = ["50%", "75%"]
                plotOptions.pie.startAngle = -90
                plotOptions.pie.endAngle = 90
                pie.innerSize = "50%"
            }
            
            if options.type == .Pie3D{
                chart.options3d = HIOptions3d()
                chart.options3d.enabled = true
                chart.options3d.alpha = 45
                chart.options3d.beta = 0
                
                plotOptions.pie.depth = 35
            }
            
            hioptions.plotOptions = plotOptions
            
            return hioptions
            
            
        case .Donut?, .Donut3D?:
            
            plotOptions.pie = HIPie()
            plotOptions.pie.center = ["50%", "50%"]
            
            let tooltip = HITooltip()
            //            tooltip.headerFormat = "<b>{point.key}: {point.category}</b>"
            tooltip.pointFormat = "<b>{point.category} {series.name}</b>:{point.y}"
            hioptions.tooltip = tooltip
            
            let series = options.series!
            let seriesName = options.seriesNames.first!
            
            let parentPieData = series[0] as! [Any]
            let childPieData = series[1] as! [Any]
            
            let parentPie = HIPie()
            parentPie.size = "60%"
            parentPie.name = seriesName
            let dataLabels = HIDataLabels()
//            let dataLabels = HIDataLabelsOptionsObject()
            dataLabels.enabled = false
            parentPie.dataLabels = [dataLabels]
            parentPie.data = parentPieData
            
            
            let childPie = HIPie()
            childPie.data = childPieData
            childPie.size = "80%"
            childPie.name = seriesName
            childPie.innerSize = "60%"
            let childdataLabels = HIDataLabels()
            childdataLabels.enabled = true
            childdataLabels.format = "<b>{point.category}: </b>{point.y}"
            childPie.dataLabels = [childdataLabels]
            
            hioptions.series = [parentPie, childPie]
            
            if options.type == .Donut3D{
                chart.options3d = HIOptions3d()
                chart.options3d.enabled = true
                chart.options3d.alpha = 45
                chart.options3d.beta = 0
                
                plotOptions.pie.depth = 35
            }
            
            hioptions.plotOptions = plotOptions
            
            return hioptions
            
        case .Scatter?:
            
            plotOptions.scatter = HIScatter()
            plotOptions.scatter.marker = HIMarker()
            plotOptions.scatter.marker.radius = 3
            hioptions.plotOptions = plotOptions
            
            let tooltip = HITooltip()
            tooltip.pointFormat = "{point.category}: <b>value:{point.y:.1f}</b>"
            hioptions.tooltip = tooltip
            
            var scatters = [HIScatter]()
            let series = options.series!
            
            for i in 0..<series.count{
                let scatter = HIScatter()
                scatter.data = series[i] as? [Any]
                scatter.name = options.seriesNames[i]
                scatters.append(scatter)
            }
            
            hioptions.series = scatters
            return hioptions
            
        case .Bubble?:
            
            plotOptions.bubble = HIBubble()
            hioptions.plotOptions = plotOptions
            
            let tooltip = HITooltip()
            tooltip.pointFormat = "{point.category}: <b>value:{point.z:.1f}</b>"
            hioptions.tooltip = tooltip
            
            var bubbles = [HIBubble]()
            let series = options.series!
            
            for i in 0..<series.count{
                let bubble = HIBubble()
                let dataPointsArray = series[i] as! [Any]
                bubble.data = dataPointsArray
                bubble.name = options.valuesColumnName
                bubbles.append(bubble)
            }
            
            hioptions.series = bubbles
            return hioptions
            
        case .ScatterPlot?:
            
            plotOptions.bubble = HIBubble()
            hioptions.plotOptions = plotOptions
            
            let tooltip = HITooltip()
            tooltip.useHTML = true;
            tooltip.headerFormat = "<table>";
            tooltip.pointFormat = "<tr><th colspan=\"1\"><h3>{point.legendName}</h3></th></tr><tr><th>{point.xname}:</th><td>{point.x}</td></tr><tr><th>{point.yname}:</th><td>{point.y}</td></tr><tr><th>{point.sizeName}:</th><td>{point.z}</td></tr>";
            tooltip.footerFormat = "</table>";
            
            hioptions.tooltip = tooltip
            
            var bubbles = [HIBubble]()
            let series = options.series!
            
            for i in 0..<series.count{
                let bubble = HIBubble()
                let dataPointsArray = series[i] as! [Any]
                bubble.data = dataPointsArray
                if options.seriesNames != nil && i < options.seriesNames.count {
                    bubble.name = options.seriesNames[i]
                }
                bubbles.append(bubble)
            }
            
            hioptions.series = bubbles
            return hioptions
            
            
        case .LineArea?:
            
            let combiData = options.combinationData
            let lineData = combiData!.lineData
            let areaData = combiData!.areaData
            
            var seriesData = [HISeries]()
            var yaxisArray = [HIYAxis]()
            
            if let areaData = areaData, areaData.count > 0{
                let area = HIArea()
                area.data = areaData[0] as? [Any]
                area.connectNulls = true
                area.name = combiData!.areaSeriesNames[0]
                seriesData.append(area)
                
                let yaxis2 = HIYAxis()
                yaxis2.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis2.labels = HILabels()
                yaxis2.labels.style = HICSSObject()
                
                yaxis2.labels.style.color = "#7cb5ec"
                yaxis2.labels.format = "{value}"
                yaxis2.title = HITitle()
                yaxis2.title.text = combiData!.rightYaxisTitle
                
                if lineData != nil && lineData!.count>0{
                    yaxis2.opposite = true
                    area.yAxis = 1
                }
                
                yaxisArray.append(yaxis2)
            }
            
            if areaData?.count == 2 {
                let area = HIArea()
                area.data = areaData![1] as? [Any]
                area.connectNulls = true
                area.name = combiData!.areaSeriesNames[1]
                seriesData.append(area)
                
                let yaxis2 = HIYAxis()
                yaxis2.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis2.labels = HILabels()
                yaxis2.labels.style = HICSSObject()
                if areaData?.count == 2 && lineData!.count>0 {
                    yaxis2.labels.style.color = "#434348"
                }else{
                    yaxis2.labels.style.color = "#434348"
                }
                yaxis2.labels.format = "{value}"
                yaxis2.title = HITitle()
                yaxis2.title.text = combiData!.right1YaxisTitle
                yaxis2.opposite = true
                if lineData!.count>0 {
                    area.yAxis = 2
                }else{
                    area.yAxis = 1
                }
                
                
                yaxisArray.append(yaxis2)
            }
            
            if let lineData = lineData, lineData.count>0{
                let line = HILine()
                line.data = lineData
                line.yAxis = 0
                line.connectNulls = true
                line.name = combiData!.lineSeriesNames[0]
                seriesData.append(line)
                
                let yaxis1 = HIYAxis()
                yaxis1.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis1.labels = HILabels()
                yaxis1.labels.style = HICSSObject()
                if areaData!.count > 1 {
                    yaxis1.labels.style.color = "#58B546"
                }else{
                    yaxis1.labels.style.color = "#434348"
                }
                yaxis1.labels.format = "{value}"
                yaxis1.title = HITitle()
                yaxis1.title.text = combiData!.leftYaxisTitle //left is line , right is column
                
                
                yaxis1.opposite = false
                
                yaxisArray.insert(yaxis1, at: 0)
            }
            
            let tooltip = HITooltip()
            tooltip.shared = true
            hioptions.tooltip = tooltip
            hioptions.yAxis = yaxisArray//[yaxis1,yaxis2]
            hioptions.series = seriesData //[area, line]
            
            return hioptions
            
        case .LineAreaStacked?:
            
            let combiData = options.combinationData
            let lineData = combiData!.lineData
            let areaData = combiData!.areaData as? [[Any]]
            var series = [HISeries]()
            var yAxisArray = [HIYAxis]()
            
            plotOptions.area = HIArea()
            plotOptions.area.stacking = "normal"
            hioptions.plotOptions = plotOptions
            
            if let areaData = areaData, areaData.count > 0{
                
                let yaxis2 = HIYAxis()
                yaxis2.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis2.labels = HILabels()
                yaxis2.labels.style = HICSSObject()
                yaxis2.labels.style.color = "#7cb5ec"
                //                    yaxis2.labels.format = "{value}"
                yaxis2.title = HITitle()
                yaxis2.title.text = combiData!.rightYaxisTitle
                
                for (i,areaSeries) in areaData.enumerated(){
                    let area = HIArea()
                    area.data = areaSeries
                    area.name = combiData!.areaSeriesNames[i]
                    area.connectNulls = true
                    series.append(area)
                    
                    if lineData != nil && lineData!.count>0{
                        yaxis2.opposite = true
                        area.yAxis = 1
                    }
                }
                yAxisArray.append(yaxis2)
            }
            
            if let lineData = lineData, lineData.count>0{
                let line = HILine()
                line.data = lineData
                line.yAxis = 0
                line.connectNulls = true
                line.name = combiData!.lineSeriesNames[0]
                series.append(line)
                
                let yaxis1 = HIYAxis()
                yaxis1.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis1.labels = HILabels()
                yaxis1.labels.style = HICSSObject()
                yaxis1.labels.style.color = "#434348"
                //                    yaxis1.labels.format = "{value}"
                yaxis1.title = HITitle()
                yaxis1.title.text = combiData!.leftYaxisTitle //left is line , right is column
                
                yaxis1.opposite = false
                yAxisArray.insert(yaxis1, at: 0)
            }
            
            
            let tooltip = HITooltip()
            tooltip.shared = true
            hioptions.tooltip = tooltip
            hioptions.yAxis = yAxisArray //[yaxis1,yaxis2]
            hioptions.series = series
            
            return hioptions
            
        case .LineLine?:
            
            let combiData = options.combinationData
            let lineData = combiData!.lineData
            var seriesData = [HISeries]()
            var yaxisArray = [HIYAxis]()
            
            
            for index in 0..<lineData!.count {
                if (lineData![index] as! NSArray).count > 0 {
                    let line = HILine()
                    line.data = lineData?[index] as? [Any]
                    line.yAxis = index
                    line.connectNulls = true
                    line.name = combiData!.lineSeriesNames[index]
                    seriesData.append(line)
                    
                    let yaxis1 = HIYAxis()
                    yaxis1.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                    yaxis1.labels = HILabels()
                    yaxis1.labels.style = HICSSObject()
                    
                    if lineData!.count == 2 {
                        if (lineData![1] as! NSArray).count == 0 {
                            yaxis1.labels.style.color = Utility.colourforChart(1)
                        }else{
                            yaxis1.labels.style.color = Utility.colourforChart(index)
                        }
                        
                    }else{
                        yaxis1.labels.style.color = Utility.colourforChart(index)
                    }
                    
                    yaxis1.labels.format = "{value}"
                    yaxis1.title = HITitle()
                    yaxis1.title.text = combiData!.leftaxisTitle[index] //left is line , right is column
                    
                    
                    
                    if index == 0 {
                        yaxis1.opposite = false
                        yaxisArray.insert(yaxis1, at: 0)
                    }else{
                        yaxis1.opposite = true
                        yaxisArray.append(yaxis1)
                    }
                }
            }
            
            let tooltip = HITooltip()
            tooltip.shared = true
            hioptions.tooltip = tooltip
            hioptions.yAxis = yaxisArray
            hioptions.series = seriesData
            
            return hioptions
            
        case .LineColumn?:
            
            let combiData = options.combinationData
            let lineData = combiData!.lineData
            let columnData = combiData!.columnData
            
            var seriesData = [HISeries]()
            var yaxisArray = [HIYAxis]()
            
            
            for index in 0..<columnData!.count {
                let column = HIColumn()
                column.data = columnData![index] as? [Any]
                column.connectNulls = true
                column.name = combiData!.columnSeriesNames[index]
                
                if lineData!.count > 0 {
                    column.yAxis = index + 1
                }else{
                    column.yAxis = index
                }
                
                seriesData.append(column)
                
                let yaxis2 = HIYAxis()
                yaxis2.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis2.labels = HILabels()
                yaxis2.labels.style = HICSSObject()
                
                if columnData!.count == 1 && lineData!.count == 0 {
                    yaxis2.labels.style.color = Utility.colourforChart(1)
                }else if lineData!.count == 0  {
                    if columnData!.count == index+1 {
                        yaxis2.labels.style.color =  Utility.colourforChart(columnData!.count-1)
                    }else if columnData!.count == index+2 {
                        yaxis2.labels.style.color =  Utility.colourforChart(columnData!.count-2)
                    }else if columnData!.count == index+3 {
                        yaxis2.labels.style.color =  Utility.colourforChart(columnData!.count-3)
                    }else if columnData!.count == index+4 {
                        yaxis2.labels.style.color =  Utility.colourforChart(columnData!.count-4)
                    }else if columnData!.count == index+5 {
                        yaxis2.labels.style.color =  Utility.colourforChart(columnData!.count-5)
                    }else
                    {
                        yaxis2.labels.style.color =  Utility.colourforChart(6)
                    }
                }else{
                    yaxis2.labels.style.color =  Utility.colourforChart(index)
                }
                
                yaxis2.labels.format = "{value}"
                yaxis2.title = HITitle()
                yaxis2.title.text = combiData!.rightaxisTitle[index]
                
                if lineData != nil && lineData!.count>0{
                    yaxis2.opposite = true
                }else{
                    if index == 0 {
                        yaxis2.opposite = false
                    }else{
                        yaxis2.opposite = true
                    }
                }
                
                yaxisArray.append(yaxis2)
            }
            
            for index in 0..<lineData!.count {
                let line = HILine()
                line.data = lineData?[index] as? [Any]
                if index == 0 {
                    line.yAxis = 0
                }else{
                    line.yAxis = columnData!.count+1
                }
                line.connectNulls = true
                line.name = combiData!.lineSeriesNames[index]
                seriesData.append(line)
                
                let yaxis1 = HIYAxis()
                yaxis1.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis1.labels = HILabels()
                yaxis1.labels.style = HICSSObject()
                
                
                if columnData!.count == 0 && lineData!.count == 1 {
                    yaxis1.labels.style.color = Utility.colourforChart(1)
                }else{
                    yaxis1.labels.style.color = Utility.colourforChart((lineData!.count + columnData!.count) - (lineData!.count-index))
                }
                
                yaxis1.labels.format = "{value}"
                yaxis1.title = HITitle()
                yaxis1.title.text = combiData!.leftaxisTitle[index] //left is line , right is column
                
                yaxis1.opposite = false
                
                if index == 0 {
                    yaxisArray.insert(yaxis1, at: 0)
                }else{
                    yaxisArray.append(yaxis1)
                }
                
            }
            
            let tooltip = HITooltip()
            tooltip.shared = true
            hioptions.tooltip = tooltip
            hioptions.yAxis = yaxisArray
            hioptions.series = seriesData
            
            return hioptions
            
        case .LineColumnStacked?:
            
            let combiData = options.combinationData
            let lineData = combiData!.lineData
            let columnData = combiData!.columnData as? [[Any]]
            
            var series = [HISeries]()
            var yAxisArray = [HIYAxis]()
            
            plotOptions.column = HIColumn()
            plotOptions.column.stacking = "normal"
            plotOptions.column.connectNulls = true
            
            hioptions.plotOptions = plotOptions
            
            
            if let columnData = columnData, columnData.count > 0{
                
                
                let yaxis2 = HIYAxis()
                yaxis2.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis2.labels = HILabels()
                yaxis2.labels.style = HICSSObject()
                yaxis2.labels.style.color = "#7cb5ec"
                yaxis2.title = HITitle()
                yaxis2.title.text = combiData!.rightYaxisTitle
                
                for (i,columnSeries) in columnData.enumerated(){
                    let column = HIColumn()
                    column.data = columnSeries
                    column.name = combiData!.columnSeriesNames[i]
                    column.connectNulls = true
                    series.append(column)
                    
                    if lineData != nil && lineData!.count>0{
                        yaxis2.opposite = true
                        column.yAxis = 1
                    }
                }
                
                yAxisArray.append(yaxis2)
            }
            
            
            for index in 0..<lineData!.count {
                let line = HILine()
                line.data = lineData?[index] as? [Any]
                line.yAxis = index
                line.connectNulls = true
                line.name = combiData!.lineSeriesNames[index]
                series.append(line)
                
                let yaxis1 = HIYAxis()
                yaxis1.lineColor = HIColor(rgba: 255, green: 255, blue: 255, alpha: 0.3)
                yaxis1.labels = HILabels()
                yaxis1.labels.style = HICSSObject()
                if columnData!.count == 0 && lineData!.count == 1 {
                    yaxis1.labels.style.color = Utility.colourforChart(1)
                }else{
                    yaxis1.labels.style.color = Utility.colourforChart((lineData!.count + columnData!.count) - (index+1))
                }
                yaxis1.title = HITitle()
                yaxis1.title.text = combiData!.leftYaxisTitle
                
                yaxis1.opposite = false
                yAxisArray.insert(yaxis1, at: 0)
                
            }
            
            let tooltip = HITooltip()
            tooltip.shared = true
            hioptions.tooltip = tooltip
            hioptions.yAxis = yAxisArray//[yaxis1,yaxis2]
            hioptions.series = series
            
            return hioptions
            
        case  .Heatmap?:
            
            plotOptions.heatmap = HIHeatmap()
            plotOptions.heatmap.turboThreshold = 0
            hioptions.plotOptions = plotOptions
            chart.type = "heatmap"
            let tooltip = HITooltip()
            
            
            hioptions.tooltip = tooltip
            var heatMaps = [HIHeatmap]()
            
            let series = options.series!
            
            for i in 0..<series.count{
                let heatMap = HIHeatmap()
                let dataPointsArray = series[i] as! [Any]
                heatMap.data = dataPointsArray
                heatMap.name = options.valuesColumnName
                heatMaps.append(heatMap)
            }
            
            let legend = HILegend()
            legend.verticalAlign = "top"
            legend.align = "right"
            legend.layout = "vertical"
            legend.enabled = false
            hioptions.legend = legend
            hioptions.series = heatMaps
            hioptions.additionalOptions = ["colorAxis":
                [
                    "min":0,
                    "minColor": options.heatMapMinColor ?? "",
                    "maxColor": options.heatMapMaxColor ?? ""
                ]
            ]
            
            return hioptions
            
        default:    return HIOptions()
            
        }
    }
}


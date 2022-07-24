//
//  Utility.swift
//  EkaAnalytics
//
//  Created by Nithin on 21/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    
    class var appThemeColor : UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "BlueTheme")!
        } else {
            return UIColor(hex: "002D49")!
        }
    }
    
    class var cellBorderColor : UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "BorderColor")!
        } else {
            return UIColor(red: 213.0/255.0, green: 226.0/255.0, blue: 235.0/255.0, alpha: 1)
        }
    }
    
    class var chartBGColor : UIColor {
        return UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1)
    }
    
    class var cardBGColor :  UIColor {
        return UIColor(red: 255.0/255.0, green: 212.0/255.0, blue: 111.0/255.0, alpha: 1)
    }
    
    class var chartListSeperatorColor:UIColor{
        return UIColor(hex: "F7F8F8")!
    }
    
    class func colorForCategory(_ name:String)->UIColor{
        switch name {
        case "Connectors" :
            return UIColor(hex: "#002D49")!
        case "Risk & Compliance":
            return UIColor(hex: "#002D49")!
        case "Supply Chain & Operations":
            return UIColor(hex: "#002D49")!
        case "Grower Services":
            return UIColor(hex: "#002D49")!
        case "Finance":
            return UIColor(hex: "#002D49")!
        case "Trade" :
            return UIColor(hex: "#002D49")!
        default :
            return Utility.appThemeColor
        }
    }
    
    class func getVendorID()->String{
        return UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    class func dashedBorderLayerWithColor(color:CGColor, frame:CGRect) -> CAShapeLayer {
        
        let  borderLayer = CAShapeLayer()
        borderLayer.name  = "borderLayer"
        let frameSize = frame.size
        let shapeRect =  CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        borderLayer.bounds=shapeRect
        borderLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color
        borderLayer.lineWidth=1
        borderLayer.lineJoin=CAShapeLayerLineJoin.round
        borderLayer.lineDashPattern = NSArray(array: [NSNumber(value: 8),NSNumber(value:4)]) as? [NSNumber]
        
        let path = UIBezierPath.init(roundedRect: shapeRect, cornerRadius: 0)
        
        borderLayer.path = path.cgPath
        
        return borderLayer
        
    }
    
    class func validNumber(num:String)->String?{
        
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.usesGroupingSeparator = false
        
        //Get the number from string in the current Locale
        if let currentLocaleNumber = formatter.number(from: num){
            
            //Change the number to US Locale
            formatter.locale = Locale(identifier: "en_US")
            if let usLocaleNumberString = formatter.string(from: currentLocaleNumber){
                
                if let correctedNumber = Double(usLocaleNumberString), correctedNumber != 0 {
                    
                    formatter.locale = Locale.current
                    let currentLocaleNumberString = formatter.string(from: NSNumber(value: correctedNumber))
                    
                    return currentLocaleNumberString
                } else {
                    return nil
                }
                
            } else {
                return nil
            }
        }
        return nil
    }
    
    class func colourforChart(_ index:Int)->String{
        
        switch index {
        case 0 :
            return "#7CB5EC"
        case 1:
            return "#434348"
        case 2:
            return "#58B546"
        case 3:
            return "#D78444"
        case 4:
            return "#8188e6"
        case 5 :
            return "#ef5e81"
        case 6 :
            return "#e3d25e"
            
            
        default :
            return "#434348"
        }
    }
    
    
    class func colourforRowButton(_ index:Int)->UIColor{
        
        switch index {
        case 4 :
            return UIColor(hex: "#CCCCCC")!
        case 3:
            return UIColor(hex: "#999999")!
        case 2:
            return UIColor(hex: "#666666")!
        case 1:
            return UIColor(hex: "#333333")!
        case 0:
            return UIColor(hex: "#000000")!
            
        default :
            return UIColor(hex: "#CCCCCC")!
        }
    }
    
    class func getRandomString() -> String {
        let length = 36
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    class func DateFormatString(dateFormat:String,timeInterval:Double?)-> String {
        let DateFormat:String = dateFormat.replacingOccurrences(of: "D", with: "d")
        var dateString:String = ""
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat
        
        if timeInterval != nil {
            dateString = dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval!/1000))
        }
        
        return dateString
    }
    
    class func tableViewPdfCreator(view:UIView,tableView: UITableView,fileName:String,fileformat:String = ".pdf") -> URL {
        let priorBounds = tableView.bounds
        
        let fittedSize = tableView.sizeThatFits(CGSize(
            width: priorBounds.size.width,
            height: tableView.contentSize.height
        ))
        
        tableView.bounds = CGRect(
            x: 0, y: 0,
            width: fittedSize.width,
            height: fittedSize.height
        )
        
        let pdfPageBounds = CGRect(
            x :0, y: 0,
            width: tableView.frame.width,
            height: view.frame.height
        )
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)
        
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
            tableView.contentOffset = CGPoint(x: 0, y: pageOriginY) // move "renderer"
        }
        UIGraphicsEndPDFContext()
        
        tableView.bounds = priorBounds
        var docURL = (FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)).last! as URL
        docURL = docURL.appendingPathComponent("\(fileName)\(fileformat)")
        pdfData.write(to: docURL as URL, atomically: true)
        return docURL
    }
    
}

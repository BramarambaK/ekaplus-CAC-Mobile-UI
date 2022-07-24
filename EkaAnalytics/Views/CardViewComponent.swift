//
//  CardViewComponent.swift
//  EkaAnalytics
//
//  Created by Nithin on 20/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class CardViewComponent: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblSubTitle: UILabel!
    
    class func instanceFromNib() -> CardViewComponent {
        return UINib(nibName: "CardViewComponent", bundle: nil).instantiate(withOwner: CardViewComponent.self, options: nil)[0] as! CardViewComponent
    }
    
    class func getCardStackView(withOptions:ChartOptionsModel, clipped:Bool = true) -> UIStackView {
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fill
        
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .center
        horizontalStackView.distribution = .fill
        
        let chartTitle = UILabel()
        chartTitle.text = withOptions.name
        chartTitle.textAlignment = .center
        chartTitle.font = UIFont.systemFont(ofSize: 21)
        chartTitle.adjustsFontSizeToFitWidth = true
        chartTitle.sizeToFit()
        
        let parentStack = UIStackView()
        parentStack.axis = .vertical
      
        let cardData = withOptions.cardValues!
        let numberFormat = withOptions.numberFormatMap
        var i = 0
        
        for (key, value, columnId) in cardData {
            i += 1
            if i == 3 && clipped {
                let cardComponent = CardViewComponent.instanceFromNib()
                cardComponent.lblTitle.text = "..."
                cardComponent.lblSubTitle.text = "See more"
                verticalStackView.addArrangedSubview(cardComponent)
                break
            }
            
            let cardComponent = CardViewComponent.instanceFromNib()
            let numberFormatOptions = formattingOptions(for: value, numberFormat: numberFormat, columnId: columnId)
            if let numberFormatOptions = numberFormatOptions {
                cardComponent.lblTitle.text = numberFormatOptions.formattedString
                if let fontColor = numberFormatOptions.fontColor {
                   cardComponent.lblTitle.textColor = fontColor
                }
                cardComponent.lblSubTitle.text = key
            } else {
                cardComponent.lblTitle.text = value.description
                cardComponent.lblSubTitle.text = key
            }
            verticalStackView.addArrangedSubview(cardComponent)
        }
        
        horizontalStackView.addArrangedSubview(verticalStackView)
        horizontalStackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        parentStack.addArrangedSubview(chartTitle)
        parentStack.addArrangedSubview(horizontalStackView)
        parentStack.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        return parentStack
    }
    
   class func formattingOptions(for value: Double, numberFormat:JSON?, columnId:String)->(formattedString:String, fontColor:UIColor?)?{
        if let numberFormat = numberFormat, numberFormat[columnId].count > 0 {
            let numberFormatForColumn = numberFormat[columnId]
            let prefix = numberFormatForColumn["prefix"].stringValue
            let suffix = numberFormatForColumn["suffix"].stringValue
            let groupingSeparator = numberFormatForColumn["groupingSeparator"].stringValue
            let decimalSeparator = numberFormatForColumn["decimalSeparator"].stringValue
            let decimalPlaces = numberFormatForColumn["decimalPlaces"].stringValue
            let numberFormatType = numberFormatForColumn["numberFormatType"].stringValue
            let negativeNumberStyle = numberFormatForColumn["negativeNumbers"].stringValue
            
            var number:Double = value
            var numberFormatSuffix = ""
            
            if numberFormatType == "BillionMillionKilo" {
                if Int(abs(value)/1000000000) > 0 {
                    number = value/1000000000
                    numberFormatSuffix = "B"
                } else if Int(abs(value)/1000000) > 0 {
                    number = value/1000000
                    numberFormatSuffix = "M"
                } else if Int(abs(value)/1000) > 0 {
                    number = value/1000
                    numberFormatSuffix = "K"
                }
            } else if numberFormatType == "Percentage"{
                number *= 100
                numberFormatSuffix = "%"
            }
            
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.numberStyle = .decimal
            if groupingSeparator != ""{
                formatter.groupingSeparator = groupingSeparator
            }
            if decimalSeparator != ""{
                formatter.decimalSeparator = decimalSeparator
            }
            formatter.maximumFractionDigits = Int(decimalPlaces) ?? 0
            
            var formattedNumber = formatter.string(from: NSNumber(value: number))!
            formattedNumber = prefix + formattedNumber + numberFormatSuffix + suffix
            
            var formattedNumberAbsolute = formatter.string(from: NSNumber(value: abs(number)))!
            formattedNumberAbsolute = prefix + formattedNumberAbsolute + numberFormatSuffix + suffix
            
            var fontColor : UIColor?
            
            if value < 0 {
                
                switch negativeNumberStyle {
                    
                case "2":
                    formattedNumber = "(" + formattedNumberAbsolute + ")"
                    fontColor = UIColor.red
                case "3":
                    formattedNumber = "(" + formattedNumberAbsolute + ")"
                    fontColor = nil
                    
                default:
                    break
                }
            }
            
            return (formattedString : formattedNumber, fontColor : fontColor)
            
        }
        return nil
    }
    
}




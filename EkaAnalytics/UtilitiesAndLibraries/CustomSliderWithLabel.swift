//
//  CustomSliderWithLabel.swift
//  EkaAnalytics
//
//  Created by Nithin on 19/03/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

public class CustomSliderWithLabel: UISlider {
    
    var label: UILabel
    var labelXMin: CGFloat?
    var labelXMax: CGFloat?
    var labelText: ()->String = { "" }
    
    required public init?(coder aDecoder: NSCoder) {
        label = UILabel()
        label.layer.cornerRadius = 5
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(onValueChanged(sender:)), for: .valueChanged)
        
    }
    func setup(){
        labelXMin = frame.origin.x + 20
        labelXMax = frame.origin.x + self.frame.width - 18
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset: CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference: CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos, y: self.frame.origin.y - 30, width: 73, height: 25)
        label.text = Int(self.value).description + " MT"
        self.superview!.addSubview(label)
        
    }
    func updateLabel(){
        label.text = labelText()
        let labelXOffset: CGFloat = labelXMax! - labelXMin!
        let valueOffset : CGFloat = CGFloat(self.maximumValue - self.minimumValue)
        let valueDifference : CGFloat = CGFloat(self.value - self.minimumValue)
        let valueRatio: CGFloat = CGFloat(valueDifference/valueOffset)
        let labelXPos = CGFloat(labelXOffset*valueRatio + labelXMin!)
        label.frame = CGRect(x: labelXPos - label.frame.width/2, y: self.frame.origin.y - 30, width: 73, height: 25)
        label.textAlignment = NSTextAlignment.center
        self.superview!.addSubview(label)
    }
    public override func layoutSubviews() {
        labelText = { Int(self.value).description + " MT" }
        setup()
        updateLabel()
        super.layoutSubviews()
        super.layoutSubviews()
    }
    @objc func onValueChanged(sender: CustomSliderWithLabel){
        updateLabel()
    }
}

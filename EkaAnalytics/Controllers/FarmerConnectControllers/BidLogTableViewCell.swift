//
//  BidLogTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 10/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class BidLogTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblRemarks: UILabel!
    
    @IBOutlet weak var indicatorImageView: UIImageView!
    
    @IBOutlet weak var dashedLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
       
    }


    override func layoutSubviews() {
        super.layoutSubviews()
         drawDottedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: dashedLineView.frame.size.height), on: dashedLineView)
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, on view:UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [7, 3] // 7 is the length of dash, 3 is length of the gap.
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
    }
}

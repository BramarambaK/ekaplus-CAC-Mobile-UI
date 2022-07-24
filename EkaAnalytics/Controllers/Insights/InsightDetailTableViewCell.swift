//
//  InsightDetailTableViewCell.swift
//  EkaAnalytics
//
//  Created by Nithin on 06/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class InsightDetailTableViewCell: UITableViewCell {

    static let reuseIdentifier = "InsightDetailTableViewCell"
    
    
    @IBOutlet weak var chartContainerView: UIView!
    
    var chartView:HIChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = Utility.chartBGColor
        
        chartView = HIChartView(frame: chartContainerView.bounds)
        chartView.frame = chartContainerView.bounds
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chartView.backgroundColor = .lightGray

          self.chartContainerView.addSubview(chartView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        chartView.options = HIOptions()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

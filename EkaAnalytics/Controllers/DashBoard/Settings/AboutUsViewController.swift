//
//  AboutUsViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 20/02/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class AboutUsViewController: GAITrackedViewController {
    
    @IBOutlet weak var attributedTextView:AttributedTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.aboutUs

        let aboutUs =
            
        "Eka ".color(Utility.appThemeColor).font(UIFont.systemFont(ofSize: 25, weight: .medium))
        
        + "Version \(Bundle.main.releaseVersionNumber!)\n\n".black.size(17)
        
            
    +   """
        Eka is the global leader in providing Smart Commodity Management software solutions. Eka's analytics-driven, end-to-end Commodity Management platform enables companies to efficiently and profitably meet the challenges of complex and volatile markets.\n
        The company’s best-of-breed solutions manage commodity trading, enterprise risk, compliance, procurement, supply chain, operations, logistics, bulk handling, processing, and decision support. Eka partners with customers to accelerate growth, increase profitability, improve operational control, and manage risks and exposures.\n
        Eka is a team of 315 staff with offices in the Americas, Asia, Australia, and EMEA, serving a rapidly growing global client base across multiple commodity segments.
        """.black.size(17)
        
        attributedTextView.attributer = aboutUs
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }

}

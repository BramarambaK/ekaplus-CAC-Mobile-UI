//
//  IntroCollectionViewCell.swift
//  EkaAnalytics
//
//  Created by GoodWorkLabs Services Private Limited on 15/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class IntroCollectionViewCell: UICollectionViewCell {
	
	static let reuseIdentifier = "IntroCell"
	
	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var lblContent: UILabel!

    
	func setUp(image:UIImage, content:String){
		self.imageView?.image = image.withRenderingMode(.alwaysTemplate)
        self.imageView.tintColor = UIColor(hex: "002D49")
		self.lblContent?.text = content
	}
	
}

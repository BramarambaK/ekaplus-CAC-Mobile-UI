//
//  DiseaseIdentificationTVCell.swift
//  EkaAnalytics
//
//  Created by Shreeram on 09/10/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class DiseaseIdentificationTVCell: UITableViewCell {

    //MARK: - IBOutlet
    @IBOutlet weak var lbl_Result: UILabel!
    @IBOutlet weak var lbl_imgName: UILabel!
    @IBOutlet weak var lbl_CreatedDate: UILabel!
    @IBOutlet weak var lbl_DiseaseDescription: UILabel!
    @IBOutlet weak var lbtn_Delete: UIButton!
    @IBOutlet weak var img_Diseaseimage: UIImageView!
    @IBOutlet weak var lv_Sepeartor: UIView!
    @IBOutlet weak var img_Processimage: UIImageView!

    override func prepareForReuse() {
        img_Diseaseimage.image = UIImage(named: "Placeholder")
    }
}

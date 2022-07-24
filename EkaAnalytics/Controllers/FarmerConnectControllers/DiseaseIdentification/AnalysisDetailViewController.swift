//
//  AnalysisDetailViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 12/10/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol DiseaseIdentificationdelegate : AnyObject {
    func deleteRequestId(requestId:String)
}

class AnalysisDetailViewController: UIViewController,HUDRenderer {
    
    //MARK: - Variable
    //    var ls_appCategory:String?
    var ls_RequestId:String = "" // Sent from previous VC
    var ls_DiseaseDetails:DiseaseIdentification?
    weak var delegate:DiseaseIdentificationdelegate?
    
    lazy var apiController:DiseaseIdentificationAPIController = {
        return DiseaseIdentificationAPIController()
    }()
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy HH:MM:ss"
        return df
    }()
    
    var ls_Feedbackprovided:Bool = false
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 200
        setupData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Local Function
    
    func setupData(){
        self.showActivityIndicator()
        apiController.getAnalysisresult(requestId: ls_RequestId) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let result):
                self.ls_DiseaseDetails = result
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlert(message: "\(error)")
            case .failureJson(_):
                break
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func btnBackClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnShareClicked(_ sender: Any) {
        let screenShot:UIImage?
        screenShot = self.tableView.screenshotView()
        let shareScreen = self.storyboard?.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        shareScreen.screenShotImage = screenShot
        shareScreen.modalPresentationStyle = .fullScreen
        self.present(shareScreen, animated: true, completion: nil)
    }
    
    @IBAction func deletebtn_Pressed(_ sender: Any) {
        
        showAlert(title: NSLocalizedString("Confirmation", comment: "confirmation"), message: NSLocalizedString("Are you sure you want to delete?", comment: " "), okButtonText: NSLocalizedString("Ok", comment: " "), cancelButtonText: NSLocalizedString("Cancel", comment: "Cancel button title")) { (success) in
            if success {
                self.delegate?.deleteRequestId(requestId: (self.ls_DiseaseDetails?.requestId)!)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Cancel Clicked.")
            }
        }
        
        
    }
    
    @IBAction func right_predictionClicked(_ sender: Any) {
        
        if ls_Feedbackprovided == false {
            ls_Feedbackprovided = true
            let button:UIButton = sender as! UIButton
            button.borderWidth = 1.5
            button.borderColor = Utility.appThemeColor
            
            apiController.updateFeedBack(requestId: ls_DiseaseDetails?.requestId, feedback: "Right Prediction")
            showAlert(message: NSLocalizedString("Thanks for the Feedback.", comment: ""))
            tableView.reloadData()
        }
        
    }
    
    @IBAction func wrong_predictionClicked(_ sender: Any) {
        
        if ls_Feedbackprovided == false {
            ls_Feedbackprovided = true
            let button:UIButton = sender as! UIButton
            button.borderWidth = 1.5
            button.borderColor = Utility.appThemeColor
            
            apiController.updateFeedBack(requestId: ls_DiseaseDetails?.requestId, feedback: "Wrong Prediction")
            showAlert(message: NSLocalizedString("Thanks for the Feedback.", comment: ""))
            tableView.reloadData()
        }
        
    }
    
    @IBAction func notSure_Clikced(_ sender: Any) {
        
        if ls_Feedbackprovided == false {
            ls_Feedbackprovided = true
            let button:UIButton = sender as! UIButton
            button.borderWidth = 1.5
            button.borderColor = Utility.appThemeColor
            
            apiController.updateFeedBack(requestId: ls_DiseaseDetails?.requestId, feedback: "Not Sure")
            showAlert(message: NSLocalizedString("Thanks for the Feedback.", comment: ""))
            tableView.reloadData()
        }
        
    }
}

extension AnalysisDetailViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ls_DiseaseDetails != nil {
            if ls_DiseaseDetails?.status == "Completed" {
                return 3
            }else{
                return 2
            }}
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "imageCell", for:     indexPath) as! DiseaseImageTVCell
            if ls_DiseaseDetails != nil {
                cell.img_Diseaseimage.imageFromServerURL(urlString: (ls_DiseaseDetails?.imageURL)!)
            }
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 1 {
            let cell  = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! DiseaseDescriptionTVCell
            cell.lbtn_Delete.isHidden = true
            
            if ls_DiseaseDetails?.status == "Failed" {
                cell.lbl_Heading.text = NSLocalizedString("INVALID IMAGE", comment: "")
                cell.lbl_Heading.textColor =  UIColor(hex: "999999")
                cell.lbl_Description.text = NSLocalizedString("Something went wrong! Please try again.", comment: "")
                cell.lbtn_Delete.isHidden = false
            }else{
                let diseaseType = ls_DiseaseDetails?.InfectionStatus
                if diseaseType == "Infected"{
                    cell.lbl_Heading.text = NSLocalizedString("THREAT FOUND", comment: "")
                    cell.lbl_Heading.textColor = UIColor(hex: "#D0021B")
                    cell.lbl_Description.text =  NSLocalizedString("The plant is infected with", comment: "") + " " + "\(ls_DiseaseDetails?.DiseaseType ?? "")" + " " +  NSLocalizedString("disease", comment: "")
                }else{
                    cell.lbl_Heading.text = NSLocalizedString("NO THREAT FOUND", comment: "")
                    cell.lbl_Description.text = NSLocalizedString("The plant is healthy", comment: "")
//                    cell.lbl_Description.text = NSLocalizedString("The image shows very less probability of any infection, for confirmation, take multiple photos from different positions.", comment: "")
                    cell.lbl_Heading.textColor = UIColor(hex: "#009688")
                }
            }
            
            let date = Date(timeIntervalSince1970: ((ls_DiseaseDetails?.createdDate)!/1000))
            cell.lbl_CreatedDate.text = "\(dateFormatter.string(from: date))" + " IST"
            cell.selectionStyle = .none
            return cell
        }
        else{
            let cell  = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackTVCell
            
            switch ls_DiseaseDetails?.feedback{
//            case "Not Sure":
//                ls_Feedbackprovided = true
//                cell.lbtn_notSure.borderWidth = 1.5
//                cell.lbtn_notSure.borderColor = Utility.appThemeColor
//                break
            case "Wrong Prediction":
                ls_Feedbackprovided = true
                cell.lbtn_wrongPrediction.borderWidth = 1.5
                cell.lbtn_wrongPrediction.borderColor = Utility.appThemeColor
                cell.lbtn_rightPrediction.borderColor = UIColor.init(hex: "CCCCCC")
//                cell.lv_RightPrediction.backgroundColor = UIColor.init(hex: "CCCCCC")
                cell.lbl_RightPrediction.textColor = UIColor.lightGray
                cell.lmv_RightPrediction.image = cell.lmv_RightPrediction.image!.withRenderingMode(.alwaysTemplate)
                cell.lmv_RightPrediction.tintColor = UIColor.init(hex: "CCCCCC")
//                cell.lv_RightPrediction.cornerRadius = 5
                break
            case "Right Prediction":
                ls_Feedbackprovided = true
                cell.lbtn_rightPrediction.borderWidth = 1.5
                cell.lbtn_rightPrediction.borderColor = Utility.appThemeColor
                cell.lbtn_wrongPrediction.borderColor = UIColor.init(hex: "CCCCCC")
//                cell.lv_WrongPrediction.backgroundColor = UIColor.init(hex: "CCCCCC")
                cell.lbl_WrongPrediction.textColor = UIColor.lightGray
                cell.lmv_WrongPrediction.image = cell.lmv_WrongPrediction.image!.withRenderingMode(.alwaysTemplate)
                cell.lmv_WrongPrediction.tintColor = UIColor.init(hex: "CCCCCC")
//                cell.lv_WrongPrediction.cornerRadius = 5
                break
            default :
                ls_Feedbackprovided = false
                break
            }
            
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            let bounds = UIScreen.main.bounds
            return bounds.size.height/2
        }else if indexPath.row == 2 {
            return 135
        }
        else{
            return UITableView.automaticDimension
        }
        
    }
    
    
    
}

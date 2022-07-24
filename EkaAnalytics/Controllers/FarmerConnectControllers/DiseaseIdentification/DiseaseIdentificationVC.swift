//
//  DiseaseIdentificationVC.swift
//  EkaAnalytics
//
//  Created by Shreeram on 08/10/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

final class DiseaseIdentificationVC: UIViewController,HUDRenderer,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DiseaseIdentificationdelegate,imagePickerdelegate {
    
    //MARK: - Varibale
    var app:App!  //Passed from previous VC
    
    var totalCount:Int = 0
    
    var usedCount:Int = 0
    
    var refreshTimer: Timer!
    
    var refreshCount:Int = 0
    let imagePicker = UIImagePickerController()
    
    lazy var apiController:DiseaseIdentificationAPIController = {
        return DiseaseIdentificationAPIController()
    }()
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy HH:MM:ss"
        return df
    }()
    
    var IdentifictionList = [DiseaseIdentification]()
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var cameraFloatingButton: UIButton!
    
    @IBOutlet weak var lbl_BalanceCount: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnFavourite: UIBarButtonItem!
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        setTitle(app.name)
        
        btnFavourite.tintColor = .white
        
        if self.app.isFavourite{
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-enable").withRenderingMode(.alwaysTemplate)
        } else {
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-disable").withRenderingMode(.alwaysTemplate)
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPage), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        self.DataSetup()
        //        self.setRightBarButtons()
        
    }
    
    @objc func timerUpdateRecords(){
        if refreshCount == 0 {
            refreshTimer.invalidate()
        }else{
            refreshCount -= 1
            self.apiController.getIdentifiedList({ (response) in
                self.hideActivityIndicator()
                switch response {
                case .success(let diseaseList):
                    self.IdentifictionList = diseaseList
                    self.tableView.reloadData()
                    
                case .failure( _):
                    break
                case .failureJson(_):
                    break
                }
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(app.categoryName)
    }
    
    //    override func willMove(toParent parent: UIViewController?) {
    //        super.willMove(toParent: parent)
    //        self.navigationController?.navigationBar.barTintColor = Utility.appThemeColor
    //    }
    
    
    //MARK: - IBAction
    
    @IBAction func favouriteTapped(_ sender: UIBarButtonItem) {
        
        self.app.isFavourite = !self.app.isFavourite
        
        if self.app.isFavourite{
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-enable").withRenderingMode(.alwaysTemplate)
        } else {
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-disable").withRenderingMode(.alwaysTemplate)
        }
        
        AppFavouriteAPIController.shared.toggleAppFavourite(app.id, appType: app.appType, isFavourite: self.app.isFavourite) { (response) in
            //            print(response)
        }
    }
    
    @IBAction func cameraFloatingButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open Gallery", comment: ""), style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.view.tintColor = UIColor(hex: "002D49")
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Local Function
    
    private func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("You don't have camera.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: NSLocalizedString("Warning", comment: ""), message: NSLocalizedString("You don't have perission to access gallery.", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func deleteRequest(delRequestId:String){
        self.apiController.deleteInvalidImage(requestId: delRequestId) { (response) in
            self.DataSetup()
        }
    }
    
    func setRightBarButtons(){
        
        let refresh = UIBarButtonItem(image: #imageLiteral(resourceName: "Messenger"), style: .plain, target: self, action: #selector(refreshPage))
        refresh.tintColor = .white
        
        //Space has been added to provide space between the Bar Button
        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        space.width = 18
        
        self.navigationItem.rightBarButtonItems = [refresh,space]
    }
    
    
    //MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imgPickerVC = self.storyboard?.instantiateViewController(withIdentifier: "ImagePickerViewController") as! ImagePickerViewController
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imgPickerVC.selectedImage = image
        imgPickerVC.delegate = self
        imgPickerVC.modalPresentationStyle = .fullScreen
        switch picker.sourceType {
        case .camera:
            picker.present(imgPickerVC, animated: true, completion: nil)
        case .photoLibrary:
            self.imagePicker.dismiss(animated: false)
            self.present(imgPickerVC, animated: true, completion: nil)
        case .savedPhotosAlbum:
            break
        @unknown default:
            break
        }
        
    }
    
    //MARK: - imagePickerdelegate
    
    func refreshTableview(){
        self.refreshPage()
        refreshCount = 5
        refreshTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(timerUpdateRecords), userInfo: nil, repeats: true)
    }
    
    //MARK: - Local Function
    
    func DataSetup(){
        self.showActivityIndicator()
        
        //Get Disease Identification List
        
        self.apiController.getIdentifiedList({ (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let diseaseList):
                if diseaseList.count > 0 {
                    self.IdentifictionList = diseaseList
                }
                
                //Get Used and Unused count
                
                self.showActivityIndicator()
                self.apiController.getBalanceCount { (response) in
                    self.hideActivityIndicator()
                    switch response {
                    case .success(let count):
                        self.totalCount = count["total"].intValue
                        self.usedCount = count["used"].intValue
                        
                        DispatchQueue.main.async {
                            self.lbl_BalanceCount.text = NSLocalizedString("Balance", comment: "") + ": " + "\(self.totalCount-self.usedCount)"
                            
                            if self.usedCount == 0 {
                                let label = UILabel()
                                label.text  = NSLocalizedString("No Record Found.", comment: "")
                                label.numberOfLines = 0
                                label.textAlignment = .center
                                self.tableView?.backgroundView = label
                            } else {
                                self.tableView?.backgroundView = nil
                                self.tableView.reloadData()
                            }
                        }
                        
                    case .failure( _):
                        self.showAlert(message: NSLocalizedString("Something went wrong please try again after some time.", comment: ""))
                        DispatchQueue.main.async {
                            self.lbl_BalanceCount.text = NSLocalizedString("Balance", comment: "") + ": - "
                        }
                        
                    case .failureJson(_):
                        break
                    }
                }
                self.tableView.reloadData()
            case .failure( _):
                self.showAlert(message: NSLocalizedString("Something went wrong please try again after some time.", comment: ""))
                DispatchQueue.main.async {
                    self.lbl_BalanceCount.text = NSLocalizedString("Balance", comment: "") + ": - "
                }
                
            case .failureJson(_):
                break
            }
        })
    }
    
    @objc func refreshPage(){
        DataSetup()
        tableView.refreshControl?.endRefreshing()
    }
    
    //MARK: - DiseaseIdentificationdelegate
    
    func deleteRequestId(requestId: String) {
        self.deleteRequest(delRequestId: requestId)
    }
    
    //MARK: - IBAction
    
    @IBAction func deletebtn_Pressed(_ sender: Any) {
        
        showAlert(title: NSLocalizedString("Confirmation", comment: "confirmation"), message: NSLocalizedString("Are you sure you want to delete?", comment: " "), okButtonText: NSLocalizedString("Ok", comment: " "), cancelButtonText: NSLocalizedString("Cancel", comment: "Cancel button title")) { (success) in
            if success {
                let selectedButton = sender as! UIButton
                self.deleteRequest(delRequestId: self.IdentifictionList[selectedButton.tag].requestId)
            } else {
                print("Cancel Clicked.")
            }
        }
    }
    
    
}

extension DiseaseIdentificationVC:UITableViewDelegate,UITableViewDataSource{
    
    //MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usedCount > 20 && IdentifictionList.count > 0{
            return 20
        }else{
            return IdentifictionList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "DiseaseIdentificationTVCell", for: indexPath) as! DiseaseIdentificationTVCell
        
        if IdentifictionList.count > 0 {
            let result = IdentifictionList[indexPath.row].status
            cell.lbtn_Delete.isHidden = true
            cell.img_Processimage.loadGif(name: "Processgif")
            
            
            if result == "In Progress"{
                cell.lbl_Result.isHidden = true
                cell.lbl_DiseaseDescription.isHidden = true
                cell.lbl_imgName.isHidden = true
                cell.lbl_CreatedDate.isHidden = true
                cell.lv_Sepeartor.isHidden = true
                cell.img_Processimage.isHidden = false
                
                
            }else if result == "Failed"{
                cell.lbl_Result.isHidden = false
                cell.lbl_DiseaseDescription.isHidden = false
                cell.lbl_imgName.isHidden = false
                cell.lbl_CreatedDate.isHidden = false
                cell.lv_Sepeartor.isHidden = false
                cell.img_Processimage.isHidden = true
                cell.lbl_Result.text = NSLocalizedString("INVALID IMAGE", comment: "")
                cell.lbl_Result.textColor = UIColor(hex: "999999")
                cell.lbl_DiseaseDescription.text = NSLocalizedString("Invalid Image", comment: "")
                cell.lbtn_Delete.isHidden = false
                cell.lbtn_Delete.tag = indexPath.row
            }else{
                cell.lbl_Result.isHidden = false
                cell.lbl_DiseaseDescription.isHidden = false
                cell.lbl_imgName.isHidden = false
                cell.lbl_CreatedDate.isHidden = false
                cell.lv_Sepeartor.isHidden = false
                cell.img_Processimage.isHidden = true
                let diseaseType = IdentifictionList[indexPath.row].InfectionStatus
                if diseaseType == "Infected"{
                    cell.lbl_Result.text = NSLocalizedString("THREAT FOUND", comment: "")
                    cell.lbl_DiseaseDescription.text = NSLocalizedString("The plant is infected with", comment: "") + " " + "\(IdentifictionList[indexPath.row].DiseaseType)" + " " +  NSLocalizedString("disease", comment: "")
                    cell.lbl_Result.textColor = UIColor(hex: "#D0021B")
                }else{
                    cell.lbl_Result.text = NSLocalizedString("NO THREAT FOUND", comment: "")
                    cell.lbl_DiseaseDescription.text = NSLocalizedString("The plant is healthy", comment: "")
                    cell.lbl_Result.textColor = UIColor(hex: "#009688")
                }
            }
            
            cell.img_Diseaseimage.imageFromServerURL(urlString: IdentifictionList[indexPath.row].thumb_imageURL)
            cell.lbl_imgName.text = IdentifictionList[indexPath.row].imageName
            let date = Date(timeIntervalSince1970: (IdentifictionList[indexPath.row].createdDate/1000))
            cell.lbl_CreatedDate.text = "\(dateFormatter.string(from: date))" + " IST"
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if IdentifictionList[indexPath.row].status != "In Progress" {
            let  AnalysisDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "AnalysisDetailViewController") as! AnalysisDetailViewController
            AnalysisDetailVC.ls_RequestId = IdentifictionList[indexPath.row].requestId
            AnalysisDetailVC.delegate = self
            if refreshTimer != nil {
                refreshTimer.invalidate()
            }
            AnalysisDetailVC.modalPresentationStyle = .fullScreen
            self.present(AnalysisDetailVC, animated: true, completion: nil)
        }
        
    }
    
}

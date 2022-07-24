//
//  ImagePickerViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 05/10/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol imagePickerdelegate : AnyObject {
    func refreshTableview()
}

final class ImagePickerViewController: UIViewController,KeyboardObserver,UITextFieldDelegate,HUDRenderer {
    
    //MARK: - Variable
    var selectedImage:UIImage?
    var selectedImagename:String?
    var delegate:imagePickerdelegate?
    
    var container: UIView{
        return self.scrollView
    }
    
    lazy var apiController:DiseaseIdentificationAPIController = {
        return DiseaseIdentificationAPIController()
    }()
    
    
    //MARK: - IBOutlet
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var btn_SendAnalysis: UIButton!
    
    @IBOutlet weak var ltxf_imageName: UITextField!
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerForKeyboardNotifications(shouldRegister: true)
        
        self.selectedImageView.image = selectedImage
        //        self.ltxf_imageName.text = selectedImagename
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.ltxf_imageName.becomeFirstResponder()
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - IBAction
    
    @IBAction func CloseButtonClicked(_ sender: Any) {
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendAnalysisClicked(_ sender: Any) {
        
        if (ltxf_imageName.text?.count)! > 0 {
            self.showActivityIndicator()
            apiController.validateFileName(FileName: ltxf_imageName.text!) { (response) in
                switch response {
                case .success(let result):
                    if result == true {
                        self.hideActivityIndicator()
                        let alertMessage:String = "'" + self.ltxf_imageName.text! + "' " + NSLocalizedString("already exist.", comment: "")
                        self.showAlert(message: alertMessage)
                        self.ltxf_imageName.becomeFirstResponder()
                    }else{
                        self.apiController.uploadImage(uploadImage: self.selectedImage!, fileName: self.ltxf_imageName.text!) { (response) in
                            self.hideActivityIndicator()
                            switch response {
                            case .success( _):
                                self.delegate?.refreshTableview()
                                DispatchQueue.main.async {
                                    self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                                }
                                
                            case .failure(let error):
                                print(error)
                                
                            case .failureJson(_):
                                break
                            }
                        }
                    }
                    
                case .failure(let error):
                    print(error)
                    
                case .failureJson(_):
                    break
                }
            }
        }else{
            showAlert(message: NSLocalizedString("Enter Image Name.", comment: ""))
        }
        
    }
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        ltxf_imageName.text = textField.text?.removeHTMLTag()
        if (ltxf_imageName.text?.count)! > 0 {
            apiController.validateFileName(FileName: ltxf_imageName.text!) { (response) in
                switch response {
                case .success(let result):
                    if result == true {
                        let alertMessage:String = "'" + self.ltxf_imageName.text! + "' " + NSLocalizedString("already exist.", comment: "")
                        self.showAlert(message: alertMessage)
                        self.ltxf_imageName.becomeFirstResponder()
                    }
                    
                case .failure(let error):
                    print(error)
                    
                case .failureJson(_):
                    break
                }
            }
        }
    }
}

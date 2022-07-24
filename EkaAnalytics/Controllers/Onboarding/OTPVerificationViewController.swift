//
//  OTPVerificationViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 26/05/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

class OTPVerificationViewController: UIViewController,UITextFieldDelegate,HUDRenderer {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnDismiss:UIButton!
    @IBOutlet weak var btnResendOTP:UIButton!
    @IBOutlet weak var txf_OTP:UITextField!
    
    //MARK: - Variable
    
    var container: UIView{
        return self.scrollView
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
   
    var timer : Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = true
        
        btnResendOTP.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(UserDefaults.standard.integer(forKey: UserDefaultsKeys.disbaleResendOtp.rawValue)), repeats: false, block: { _ in
            self.btnResendOTP.isEnabled = true
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - IBAction
    
    @IBAction func dismiss(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func VerifyOTP_Tapped(_ sender: Any) {
        
        guard txf_OTP.text!.count == 6
            else {
                showAlert(title:NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Please enter six digit OTP.", comment: "error message"))
                return
        }
        
        let userName:String = UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!
        
        self.showActivityIndicator()
        
        LoginApiController.verifyOTP(userName: userName, OTP: txf_OTP.text!) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(_ ):
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) != nil {
                    let DashVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                    self.navigationController?.pushViewController(DashVC, animated: true)
                }else{
                    self.showAlert(message: NSLocalizedString("Something went wrong please try again after some time.", comment: ""))
                }
            case .failure(let error):
                self.showAlert(title:"Error", message:error.description)
            case .failureJson(_):
                break
            }
            
        }
    }
    
    @IBAction func ResendOTP_Tapped(_ sender: Any) {
        
        btnResendOTP.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(UserDefaults.standard.integer(forKey: UserDefaultsKeys.disbaleResendOtp.rawValue)), repeats: false, block: { _ in
            self.btnResendOTP.isEnabled = true
        })
        
        let userName:String = UserDefaults.standard.string(forKey: UserDefaultsKeys.userName.rawValue)!
        
        self.showActivityIndicator()
        LoginApiController.resendOTP(userName: userName) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(_ ):
                self.showAlert(message: "OTP has been sent sucessfully.")
            case .failure(let error):
                self.showAlert(title:"Error", message:error.description)
            case .failureJson(_):
                break
            }
            
        }
    }
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.count == 6 {
            return true
        }else{
            self.showAlert(message: "Please enter the six digit OTP.")
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text!.count < 6 || string == "" {
            return true
        }else{
            return false
        }
        
    }
    
}


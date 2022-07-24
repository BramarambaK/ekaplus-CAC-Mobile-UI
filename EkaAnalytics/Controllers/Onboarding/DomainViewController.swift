//
//  DomainViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 14/05/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

class DomainViewController: UIViewController,KeyboardObserver,UITextFieldDelegate,HUDRenderer {
    
    //MARK: - IBOutlet
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnNext:UIButton!
    @IBOutlet weak var txfDomain:UITextField!
    @IBOutlet weak var lbtn_Back: UIButton!
    
    
    //MARK: - Variable
    var container: UIView{
        return self.scrollView
    }
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SecurityUtilities().ExitOnJailbreak()
        
        self.txfDomain.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        //Retrive stored Domain Name
        if let lastSuccessfulBaseURL = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) {
            txfDomain.text = lastSuccessfulBaseURL
            lbtn_Back.isHidden = false
        }else{
            lbtn_Back.isHidden = true
        }
    }
    
    //MARK: - Keyboard Notification
    //Implemented to make the login button float on top of keyboard
    fileprivate func handler(notification:Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        let animationDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        let up = notification.name == UIResponder.keyboardWillShowNotification ? true : false
        
        let movementDuration:TimeInterval = animationDuration
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        
        if up{
            
            (container as! UIScrollView).contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height + 10, right: 0)
            
            var frame:CGRect
            
            if let  rect =   btnNext.superview?.convert(btnNext.frame, to: container){
                frame = rect
            } else{
                frame = btnNext.frame
            }
            
            (container as! UIScrollView).scrollRectToVisible(frame.offsetBy(dx: 0, dy: 10), animated: true)
            
            
        } else {
            (container as! UIScrollView).contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        UIView.commitAnimations()
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveDomainName()
        return true
    }
    
    //MARK: - IBAction
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveDomainName()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: Segues.domain.rawValue, sender: self)
    }
    
    
    //MARK: - Local Function
    func saveDomainName(){
        
        txfDomain.text = txfDomain.text?.removeHTMLTag()
        
        guard txfDomain.text != nil && txfDomain.text!.count > 0 , let url = URL(string: txfDomain.text!.last! == " " ? String(describing: txfDomain.text!.dropLast()) : txfDomain.text!) , url.query == nil, (txfDomain.text!.contains("ekaanalytics.com") || txfDomain.text!.contains("ekaplus.com"))  else {
            showAlert(title:NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Please enter a valid domain.", comment: "error message"))
            return
        }
        
        self.view.endEditing(true)
        
        UserDefaults.standard.setValue(txfDomain.text!.last! == "/" ? String(describing: txfDomain.text!.dropLast()) : txfDomain.text!.last! == " " ? String(describing: txfDomain.text!.dropLast()) : txfDomain.text!, forKey: UserDefaultsKeys.tenantDomain.rawValue)
        
        self.showActivityIndicator()
        
        LoginApiController.getTenantSettings { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let result):
                let is_mfa_enabled = result["is_mfa_enabled"].boolValue
                let show_eka_login = result["identityProviderSetting"]["show_eka_login"].boolValue
                let identity_provider_type = result["identityProviderSetting"]["identity_provider_type"].string ?? ""
                let enabled_sso_mobile = result["identityProviderSetting"]["enabled_sso_mobile"].boolValue
                let mobile_client_id = result["identityProviderSetting"]["mobile_client_id"].string ?? ""
                let disbale_resend_otp = result["disbale_resend_otp_link_in_seconds"].intValue
                
                //OKTA Login
                let issuer = result["identityProviderSetting"]["issuer"].string ?? ""
                let redirectUri = result["identityProviderSetting"]["mobile_redirect_uri"].string ?? ""
                let logoutRedirectUri = result["identityProviderSetting"]["mobile_logout_redirect_uri"].string ?? ""
                
                let defaults = UserDefaults.standard
                defaults.set(is_mfa_enabled, forKey: UserDefaultsKeys.isMFAEnabled.rawValue)
                defaults.set(show_eka_login, forKey: UserDefaultsKeys.showEkaLogin.rawValue)
                defaults.set(identity_provider_type,forKey: UserDefaultsKeys.identityProviderType.rawValue)
                defaults.set(enabled_sso_mobile,forKey: UserDefaultsKeys.enabledSSOMobile.rawValue)
                defaults.set(mobile_client_id,forKey: UserDefaultsKeys.ssoClientId.rawValue)
                defaults.set(disbale_resend_otp,forKey: UserDefaultsKeys.disbaleResendOtp.rawValue)
                defaults.set(issuer,forKey: UserDefaultsKeys.issuer.rawValue)
                defaults.set(redirectUri,forKey: UserDefaultsKeys.redirecturi.rawValue)
                defaults.set(logoutRedirectUri,forKey: UserDefaultsKeys.logoutRedirectUri.rawValue)
                self.performSegue(withIdentifier: Segues.domain.rawValue, sender: self)
                
            case .failure(let error):
                self.showAlert(message: "\(error)")
                
            case .failureJson(let errorJson):
                self.showAlert(message: errorJson["errorMessage"].stringValue)
            }
            
        }
    }
}

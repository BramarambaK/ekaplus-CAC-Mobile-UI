//
//  LoginMFAViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 25/05/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

class LoginMFAViewController: UIViewController,HUDRenderer,UITextFieldDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnDismiss:UIButton!
    @IBOutlet weak var txfUserName: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var btnLogin:UIButton!
    
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
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
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
            
            (container as! UIScrollView).contentInset = UIEdgeInsets(top: 0, left: 0,bottom: keyboardRect.height + 10, right: 0)
            
            var frame:CGRect
            
            if let  rect =   btnLogin.superview?.convert(btnLogin.frame, to: container){
                frame = rect
            } else{
                frame = btnLogin.frame
            }
            
            (container as! UIScrollView).scrollRectToVisible(frame.offsetBy(dx: 0, dy: 10), animated: true)
            
            
        } else {
            (container as! UIScrollView).contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        UIView.commitAnimations()
    }
    
    //MARK: - TextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfUserName {
            txfPassword.becomeFirstResponder()
        }else{
            self.view.endEditing(true)
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
    }
    
    //MARK: - Local Function
    
    func validate()->Bool{
        
        return txfUserName.text != "" && txfPassword.text != ""
    }
    
    //MARK: - IBAction
    
    @IBAction func dismiss(_ sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func LoginTapped(_ sender: Any) {
        
        guard validate() else {
            showAlert(title:NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Please enter the credentials", comment: "error message"))
            return
        }
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Login", action: "Login", label: "General", value: nil).build() as? [AnyHashable : Any])
        }
        
        self.view.endEditing(true)
        switch UserDefaults.standard.bool(forKey: UserDefaultsKeys.isMFAEnabled.rawValue){
        case true:
            
            showActivityIndicator()
            
            LoginApiController.getVerification(userName: txfUserName.text!, password: txfPassword.text!) { (response) in
                self.hideActivityIndicator()
                switch response {
                 case .success(let json):
                    if json["isMFAEnabled"].boolValue {
                        let uniqueToken = json["uniqueToken"].stringValue
                        UserDefaults.standard.set(uniqueToken, forKey: UserDefaultsKeys.uniqueToken.rawValue)
                        
                        let OTPVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationViewController") as! OTPVerificationViewController
                        self.navigationController?.pushViewController(OTPVC, animated: true)
                    }else{
                        let tokenDetails = json["auth2AccessToken"]
                        let accessToken = tokenDetails["access_token"].stringValue
                        let refreshToken = tokenDetails["refresh_token"].stringValue
                        let sessionTimeOutSeconds = json["sessionTimeoutInSeconds"].intValue
                        
                        let defaults = UserDefaults.standard
                        defaults.set(accessToken, forKey: UserDefaultsKeys.accessToken.rawValue)
                        defaults.set(refreshToken, forKey: UserDefaultsKeys.refreshToken.rawValue)
                        defaults.set(sessionTimeOutSeconds, forKey: UserDefaultsKeys.sessionTimeOutInSeconds.rawValue)
                        defaults.set(true, forKey: UserDefaultsKeys.refreshTokenValidation.rawValue)
                        
                        //Set the logged in flag
                        defaults.set(true, forKey: UserDefaultsKeys.isUserLoggedIn.rawValue)
                        
                        let DashVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                        self.navigationController?.pushViewController(DashVC, animated: true)
                    }
                   
                case .failure(let error):
                    self.showAlert(title:"Error", message:error.description)
                case .failureJson(_):
                    break
                }
                
            }
            
        case false:
            let domain = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)
            
            showActivityIndicator()
            LoginApiController.loginWithCredentials(userName: txfUserName.text!, password: txfPassword.text!, domain: domain!) { (response) in
                self.hideActivityIndicator()
                switch response {
                case .success(_ ):
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.txfUserName.text = ""
                    self.txfPassword.text = ""
                    
                    if let url = URL(string: "\(baseURL!)/apps/platform/classic/resources/images/clientLogo/\(UserDefaults.standard.value(forKey:UserDefaultsKeys.tenantShortName.rawValue)!).png") {
                        self.downloadImage(url: url)
                    }
                    let DashVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                    self.navigationController?.pushViewController(DashVC, animated: true)
                    
                case .failure(let error):
                    self.showAlert(title:"Error", message:error.description)
                case .failureJson(_):
                    break
                }
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
    //Download the image from the Server and Display client banner on login
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let filename = paths[0].appendingPathComponent("ClientLogo.png")
                print(filename)
                try? data.write(to: filename)
                guard UIImage(contentsOfFile: filename.path) != nil else { return }
                let clientBanner = Banner(title: nil, subtitle: nil, image: UIImage(contentsOfFile: filename.path), backgroundColor: UIColor.white.withAlphaComponent(0.5))
                clientBanner.show(duration: 3.0)
            }
        }
    }
}

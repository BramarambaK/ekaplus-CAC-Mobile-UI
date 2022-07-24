//
//  ViewController.swift
//  EkaAnalytics
//
//  Created by GoodWorkLabs Services Private Limited on 15/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, HUDRenderer,UITextFieldDelegate{
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txfUserName: UITextField!
    
    @IBOutlet weak var txfPassword: UITextField!
    
    @IBOutlet weak var btnLogin:UIButton!
    
    //MARK: - Variable
    
    //    var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    var container: UIView{
        return self.scrollView
    }
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SecurityUtilities().ExitOnJailbreak()
        
        //        registerForKeyboardNotifications(shouldRegister: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
        
       
        
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
            
            (container as! UIScrollView).contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardRect.height + 10, right: 0)
            
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
    
    @objc
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func validate()->Bool{
        
        return txfUserName.text != "" && txfPassword.text != ""
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        //        self.appDelegate?.ShowLocalNotification(title: "Local Notification.", body: "This is an sample Notification.")
        
        guard validate() else {
            showAlert(title:NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Please enter the credentials", comment: "error message"))
            return
        }
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Login", action: "Login", label: "General", value: nil).build() as? [AnyHashable : Any])
        }
        
        self.view.endEditing(true)
        
        let domain = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue)
        
        showActivityIndicator()
        LoginApiController.loginWithCredentials(userName: txfUserName.text!, password: txfPassword.text!, domain: domain!) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(_ ):
                
                self.txfUserName.text = ""
                self.txfPassword.text = ""
                
                if let url = URL(string: "\(baseURL!)/apps/platform/classic/resources/images/clientLogo/\(UserDefaults.standard.value(forKey:UserDefaultsKeys.tenantShortName.rawValue)!).png") {
                    self.downloadImage(url: url)
                }
                
                
                //Commented code can be used for testing to download the image from URL
//                if let url = URL(string: "https://cdn.pixabay.com/photo/2017/01/03/02/07/vine-1948358_1280.png") {
//                    self.downloadImage(url: url)
//                }
                
                self.view.endEditing(true)
                self.performSegue(withIdentifier: Segues.login.rawValue, sender: self)
                break
            case .failure(let error):
                self.showAlert(title:"Error", message:error.description)
            case .failureJson(_):
                break
            }
        }
    }
    
    @IBAction func chnageTenantButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segues.changedomain.rawValue, sender: self)
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
}


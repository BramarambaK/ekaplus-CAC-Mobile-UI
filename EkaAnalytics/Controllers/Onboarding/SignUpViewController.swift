//
//  SignUpViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 16/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit

class SignUpViewController: UIViewController, KeyboardObserver, HUDRenderer,WKNavigationDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txfFirstName: UITextField!
    
    @IBOutlet weak var txfLastName: UITextField!
    
    @IBOutlet weak var txfEmail: UITextField!
    
    @IBOutlet weak var txfJobTitle: UITextField!
    
    @IBOutlet weak var txfCompanyName: UITextField!
    
    @IBOutlet weak var txfPhoneNumber: UITextField!
    
    @IBOutlet weak var txfCountry: UITextField!
    
    @IBOutlet weak var btnDismiss:UIButton!
    
    @IBOutlet weak var lv_webView:UIView!
    
    //MARK: - Variable
    
    var webView : WKWebView!
    
    var container: UIView{
        return self.scrollView
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.registerForKeyboardNotifications(shouldRegister: true)
        
//        let _ = [txfFirstName,txfLastName,txfEmail,txfJobTitle,
//        txfCompanyName,txfPhoneNumber,txfCountry].map({$0?.addDoneToolBarButton()})
//
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        self.view.addGestureRecognizer(tap)
        
        
        let url = UserDefaults.standard.value(forKey: UserDefaultsKeys.registrationUrl.rawValue) as? String ?? "https://info.ekaplus.com/sign-up-free-software"
        let request = URLRequest(url: URL(string: url)!)
        
        // init and load request in webview.
        webView = WKWebView(frame: self.lv_webView.frame)
        webView.navigationDelegate = self
        webView.load(request as URLRequest)
        self.lv_webView.addSubview(webView)
        self.lv_webView.sendSubviewToBack(webView)
        
        
    }
    
    deinit {
        self.registerForKeyboardNotifications(shouldRegister: false)
    }

    @objc
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
   
    //MARK: - IBAction
    
    @IBAction func dismiss(_ sender:UIButton){
        if webView.canGoBack{
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func signUpTapped(_ sender: UIButton) {
    }
    
    
    @IBAction func checkBoxToggled(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    
    //MARK: - WKNavigationDelegate
       
       private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
           hideActivityIndicator()
       }
       func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
           showActivityIndicator()
       }
       func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
           hideActivityIndicator()
       }
       
       
       func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
           if (navigationAction.navigationType == .linkActivated){
              btnDismiss.setImage(#imageLiteral(resourceName: "Back").withRenderingMode(.alwaysTemplate), for: .normal)
               btnDismiss.tintColor = Utility.appThemeColor
               decisionHandler(.cancel)
           } else {
               btnDismiss.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
               decisionHandler(.allow)
           }
       }
    
}

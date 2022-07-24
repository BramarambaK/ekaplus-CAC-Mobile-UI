//
//  ProblemLoggingInViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit

class ProblemLoggingInViewController: UIViewController,HUDRenderer,WKNavigationDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var lv_webView: UIView!
    
    //MARK: - Variable
    
    var webView : WKWebView!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = UserDefaults.standard.value(forKey: UserDefaultsKeys.contactUsUrl.rawValue) as? String ?? "https://info.ekaplus.com/service-request"
        let request = URLRequest(url: URL(string: url)!)
        
        
        // init and load request in webview.
        webView = WKWebView(frame: self.lv_webView.frame)
        webView.navigationDelegate = self
        webView.load(request as URLRequest)
        self.lv_webView.addSubview(webView)
        self.lv_webView.sendSubviewToBack(webView)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
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
    
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //MARK: - IBAction
    
    @IBAction func dismiss(_ sender: UIButton){
        if webView.canGoBack{
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

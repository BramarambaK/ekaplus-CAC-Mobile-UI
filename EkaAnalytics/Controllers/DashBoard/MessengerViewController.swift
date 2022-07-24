//
//  MessengerViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 10/07/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit

class MessengerViewController: GAITrackedViewController,HUDRenderer,WKNavigationDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lv_webView: UIView!
    
    //MARK: - Variable
    
    var webView : WKWebView!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        self.screenName = ScreenNames.messenger
        
        self.navigationBarSetup()
        
        /*
         self.navigationItem.leftItemsSupplementBackButton = true
         self.navigationItem.hidesBackButton = false
         if #available(iOS 11, *){
         setTitle(NSLocalizedString("Messenger", comment: "Messenger"), color: .white, backbuttonTint: Utility.appThemeColor,bckbtnimage:"cancel")
         } else {
         setTitle(NSLocalizedString("Messenger", comment: "Messenger"))
         }
         */
//       self.webView.scrollView.bounces = false
        
        let urlString = "\(baseURL!)/apps/chatwebview?authToken=\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")&Device-Id=\(Utility.getVendorID())"
        
        #if QA
            print(urlString)
        #endif
        
        //Chat URL needs to be loaded by clearing WebView cache
        let request = URLRequest(url:  URL(string: urlString)!, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        
        // init and load request in webview.
        webView = WKWebView(frame: self.lv_webView.frame)
        webView.navigationDelegate = self
        webView.load(request as URLRequest)
        self.lv_webView.addSubview(webView)
        self.lv_webView.sendSubviewToBack(webView)
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
    
    //MARK: - Navigation Setup
    
    @objc func closeMessenger(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func goBack(){
        if webView.canGoBack{
            webView.goBack()
        }
    }
    
    func navigationBarSetup(){
        
        let backButton = UIButton(type: .custom)
        let backImage = UIImage(named: "Back")
        backButton.setImage(backImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        backButton.tintColor = UIColor.white
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: backButton)
        self.navigationItem.setLeftBarButtonItems([item1], animated: true)
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Messenger", comment: "Messenger")
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        titleLabel.textColor = UIColor.white
        titleLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 25)
        titleLabel.sizeToFit()
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 1
        let titleBarItem = UIBarButtonItem(customView: titleLabel)
        if self.navigationItem.leftBarButtonItems == nil {
            self.navigationItem.leftBarButtonItems = []
        }
        self.navigationItem.leftBarButtonItems?.append(titleBarItem)
        
        let closeButton = UIButton(type: .custom)
        let closeImage = UIImage(named: "cancel")
        closeButton.setImage(closeImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        closeButton.tintColor = UIColor.white
        closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        closeButton.addTarget(self, action: #selector(self.closeMessenger), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: closeButton)
        
        self.navigationItem.setRightBarButtonItems([item2], animated: true)
    }
    
}

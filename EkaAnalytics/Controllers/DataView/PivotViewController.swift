//
//  PivotViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 27/02/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit

final class PivotViewController: GAITrackedViewController,WKNavigationDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lv_webView: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lbtn_Share: UIButton!
    
    //MARK: - Variable
    
    var chartOptions:ChartOptionsModel!
    var webView : WKWebView!
    var slicerLookUp:[JSON]? = nil
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.dataView
        
        self.lbtn_Share.setImage(UIImage.init(named: NSLocalizedString("Share", comment: "")), for: .normal)
        lblTitle.text = chartOptions.name
        
        self.setupWebView()
        
    }
    
    //MARK: - Local Function
    
    private func setupWebView(){
        
        let webServerUrl = UserDefaults.standard.string(forKey: UserDefaultsKeys.webServerUrl.rawValue) ?? "http://demo.ios.ekaanalytics.com:8080/apps/WebviewApp"
        
        //Temporary fix
        //        webServerUrl = webServerUrl.replacingOccurrences(of: "ekaanalytics", with: "ekaplus")
        
        if let url = URL(string: webServerUrl){
            var request = URLRequest.init(url: url)
            request.cachePolicy = .returnCacheDataElseLoad
            
            let config = WKWebViewConfiguration()
            let contentController = WKUserContentController()
            
            var js =  "sessionStorage.clear();"
            js = js + "sessionStorage.setItem('accessToken', '\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")');sessionStorage.setItem('dId', '\(chartOptions.dataViewID!)');sessionStorage.setItem('chartType', '\(chartOptions.type.rawValue)');sessionStorage.setItem('deviceId', '\(Utility.getVendorID())');sessionStorage.setItem('showToolbar', 'true');"
            
            if chartOptions.type.rawValue == "DotMap" {
                js = js + "sessionStorage.setItem('mapNavigation', 'true');"
            }
            
            if slicerLookUp != nil {
                js = js + "sessionStorage.setItem('filters',JSON.stringify(\(self.slicerLookUp!)));"
            }
            
            let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
            contentController.addUserScript(userScript)
            
            config.userContentController = contentController
            self.webView = WKWebView(frame: self.lv_webView.frame, configuration: config)
            
            // init and load request in webview.
            //            webView = WKWebView(frame: self.lv_webView.frame)
            webView.navigationDelegate = self
            webView.load(request as URLRequest)
            self.lv_webView.addSubview(webView)
            self.lv_webView.backgroundColor = .yellow
            
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.leadingAnchor.constraint(equalTo: self.lv_webView.leadingAnchor, constant: 0).isActive = true
            webView.trailingAnchor.constraint(equalTo: self.lv_webView.trailingAnchor, constant: 0).isActive = true
            webView.topAnchor.constraint(equalTo: self.lv_webView.topAnchor, constant: 0).isActive = true
            webView.bottomAnchor.constraint(equalTo: self.lv_webView.bottomAnchor, constant: 0).isActive = true
            
            self.lv_webView.sendSubviewToBack(webView)
        }
        
    }
    
    //MARK: - IBAction
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let screenShot:UIImage?
        
        screenShot = webView?.screenshotView()
        
        let shareScreen = self.storyboard?.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        shareScreen.screenShotImage = screenShot
        shareScreen.modalPresentationStyle = .fullScreen
        self.present(shareScreen, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
}

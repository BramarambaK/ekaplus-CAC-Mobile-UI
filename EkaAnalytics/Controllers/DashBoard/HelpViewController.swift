//
//  HelpViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 01/02/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit

final class HelpViewController: GAITrackedViewController, KeyboardObserver, HUDRenderer,WKNavigationDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var txfFirstName: UITextField!
    
    @IBOutlet weak var txfLastName: UITextField!
    
    @IBOutlet weak var txfEmail: UITextField!
    
    @IBOutlet weak var lblSelectDropDown: EdgeInsetLabel!
    
    @IBOutlet weak var dropDownOptionsStackView: UIStackView!
    
    @IBOutlet weak var txfDescription: UITextView!
    
    @IBOutlet weak var btnSendMessage: UIButton!
    
    @IBOutlet weak var imgArrow:UIImageView!
    
    @IBOutlet weak var btnDismiss:UIButton!
    
    @IBOutlet weak var lv_webView: UIView!
    
    @IBOutlet weak var lbl_Title: UILabel!
    
    //MARK: - Variable
    
    var container: UIView{
        return self.scrollView
    }
    
    var webView : WKWebView!
    var url:String? = "https://eka1.com/service-request"
    var screenContent:String? = nil
    var screenTitle:String = "Need Help?"
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.needHelp
        
        //        dropDownOptionsStackView.isHidden = true
        //
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(selectDropdownTapped(_:)))
        //        lblSelectDropDown.addGestureRecognizer(tap)
        //        lblSelectDropDown.isUserInteractionEnabled = true
        //
        //        [txfEmail, txfLastName, txfFirstName].forEach {
        //            $0.addDoneToolBarButton()
        //        }
        //        txfDescription.addDoneToolBarButton()
        
        //        txfEmail.text = UserDefaults.standard.string(forKey: UserDefaultsKeys)
        
        //        let url = "http://reference.integ2.ekaanalytics.com:3019/apps/chatwebview?authToken=\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")&Device-Id=\(Utility.getVendorID())"
        
        //        let url = "https://eka1.com/service-request"
        
        self.lbl_Title.text = screenTitle
        
        // init and load request in webview.
        webView = WKWebView(frame: self.lv_webView.frame)
        webView.navigationDelegate = self
        if screenContent != nil {
            webView.loadHTMLString(screenContent!, baseURL: nil)
            webView.scrollView.setZoomScale(1.5, animated: true)
        }else{
            let request = URLRequest(url: URL(string: url!)!)
            webView.load(request as URLRequest)
        }
        self.lv_webView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: lv_webView.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: lv_webView.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: lv_webView.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: lv_webView.trailingAnchor).isActive = true
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
    
    
    //MARK: - IBAction
    
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if webView.canGoBack{
            webView.goBack()
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func selectedCategoryOption(_ sender: UIButton) {
    }
    
    
    @IBAction func sendMessageTapped(_ sender: UIButton) {
    }
    
    @objc
    func selectDropdownTapped(_ sender:UITapGestureRecognizer){
        
        UIView.animate(withDuration: 0.25) {
            self.dropDownOptionsStackView.isHidden = !self.dropDownOptionsStackView.isHidden
            
            self.dropDownOptionsStackView.layoutIfNeeded()
            
            if self.dropDownOptionsStackView.isHidden {
                self.imgArrow.transform = CGAffineTransform.identity
            } else {
                self.imgArrow.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            
        }
    }
    
}

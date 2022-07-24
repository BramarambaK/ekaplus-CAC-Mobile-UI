//
//  DownloadViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 04/08/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit
import PDFKit


class DownloadViewController: UIViewController,WKNavigationDelegate,HUDRenderer {
    
    //MARK: - IBOutlet
    @IBOutlet weak var lv_webView: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lbtn_Share: UIButton!
    
    //MARK: - Variable
    var app:App!
    var webServerUrl: String!
    var webView: WKWebView!
    var ls_title:String?
    var ls_Id:String?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lblTitle.text! = ls_title!
        self.lbtn_Share.setImage(UIImage(named: "share_icon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.lbtn_Share.tintColor = UIColor(hex: "#2D7EBC")!
        
        self.setupWebView()
       
        if #available(iOS 11.0, *) {
            //            self.view.addSubview(pdfView)
        }else{
            self.lv_webView.addSubview(self.webView)
        }
        
    }
    
    private func setupWebView() {
        
        let tempUrlString = webServerUrl!.replacingOccurrences(of: " ", with: "%20")
        
        if #available(iOS 11.0, *) {
            let pdfView = PDFView(frame: self.view.bounds)
            pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            let url = URL(string:tempUrlString)!
            pdfView.document = PDFDocument(url: url)
            pdfView.displayMode = .singlePageContinuous
            pdfView.pageBreakMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            pdfView.autoScales = true
            self.lv_webView.addSubview(pdfView)
        } else {
            self.webView = WKWebView(frame: self.lv_webView.bounds)
            webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            print(tempUrlString)
            let url = URL(string:tempUrlString)!
            let request = URLRequest(url: url)
            self.webView.load(request)
            
            self.webView.navigationDelegate = self
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func dismiss(_ sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sharebtn_Tapped(_ sender: Any) {
 
        let documentoPath = "\(self.getDocumentsDirectory())/\(self.ls_Id!)"
            
        let fileURL = NSURL(fileURLWithPath: documentoPath)
        
        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()
        
        // Add the path of the file to the Array
        filesToShare.append(fileURL)
        
        // Make the activityViewContoller which shows the share-view
        let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
        
        // Show the share-view
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    //MARK: - WebView Delegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideActivityIndicator()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showActivityIndicator()
    }
    
    //MARK: - Local Function
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0].appendingFormat("/" + "\(UserDefaults.standard.string(forKey:UserDefaultsKeys.TenantID.rawValue)!)_\(UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "")_\(self.app.id)") //documents directory
        
        return documentsDirectory
    }
    
}

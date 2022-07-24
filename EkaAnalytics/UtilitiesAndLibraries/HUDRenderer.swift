//
//  HUDRenderer.swift
//  EkaAnalytics
//
//  Created by Nithin on 28/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol HUDRenderer{}

var li_ActivityIndicator:Int = 0

extension HUDRenderer where Self : UIViewController{
    
    
    func showAlert(title:String = "",message:String, okButtonText:String = "OK",cancelButtonText:String? = nil, presentOnRootVC:Bool = false, handler: @escaping (_ succeeded:Bool)->() = {_ in  }){
     
        DispatchQueue.main.async {
            
        
             var alertController : UIAlertController
            alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            
             if let cancelText = cancelButtonText{
                 alertController.addAction(UIAlertAction(title: cancelText, style: UIAlertAction.Style.default, handler: { finished in
             
             handler(false)
             }))
             }
            
            alertController.addAction(UIAlertAction(title: okButtonText, style: UIAlertAction.Style.default, handler: { finished in
            
             handler(true)
             }))
            
            if presentOnRootVC { //If this is called from any place other than a view controller
            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
            } else {
            
            //Present alert on a conforming viewcontroller
                self.present(alertController, animated: true, completion: nil)
                
            }
                
        }
        
    }
    
    func showActivityIndicator(){
        
        if li_ActivityIndicator == 0 || li_ActivityIndicator == -1 {
            
            li_ActivityIndicator += 1
            
            let delegate = (UIApplication.shared.delegate as! AppDelegate)
            
            DispatchQueue.main.async {
                
                if delegate.activityIndicatorView == nil {
                    
                    if let window = UIApplication.shared.keyWindow{
                        
                        let bgView = UIView(frame: window.frame)
                        bgView.backgroundColor = .black
                        bgView.alpha = 0.5
                        
                        let activityIndicator = UIActivityIndicatorView(style: .white)
                        activityIndicator.center = window.center
                        bgView.addSubview(activityIndicator)
                        
                        delegate.activityIndicatorView = bgView
                        
                        activityIndicator.startAnimating()
                        
                        window.addSubview(delegate.activityIndicatorView!)
                        
                    }
                    
                }
            }
        }
        else{
            li_ActivityIndicator += 1
        }
    }
    
    func hideActivityIndicator(){
        li_ActivityIndicator -= 1
        if li_ActivityIndicator == 0 || li_ActivityIndicator == -1{
            li_ActivityIndicator = 0
            let delegate = (UIApplication.shared.delegate as! AppDelegate)
            DispatchQueue.main.async {
                
                if delegate.activityIndicatorView != nil {
                    delegate.activityIndicatorView?.removeFromSuperview()
                    delegate.activityIndicatorView = nil
                }
            }
        }
    }
}




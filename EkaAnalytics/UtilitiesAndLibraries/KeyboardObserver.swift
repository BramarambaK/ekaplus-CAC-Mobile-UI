//
//  KeyboardObserver.swift
//  EkaAnalytics
//
//  Created by Nithin on 21/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//
import Foundation
import UIKit


protocol KeyboardObserver {
    var container:UIView{get}
}

extension KeyboardObserver{
    
    func registerForKeyboardNotifications(shouldRegister:Bool) {
        
        var willShowObserver:NSObjectProtocol?
        var willHideObserver:NSObjectProtocol?
        
        if shouldRegister{
            willShowObserver =   NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
            
            willHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
        } else {
            
            if let observer1 = willShowObserver, let observer2 = willHideObserver{
                NotificationCenter.default.removeObserver(observer1)
                NotificationCenter.default.removeObserver(observer2)
            }
        }
        
    }
    
    //Utility function
    func findFirstResponder(inView view: UIView) -> UIView? {
        for subView in view.subviews  {
            if subView.isFirstResponder {
                return subView
            }
            
            if let recursiveSubView = self.findFirstResponder(inView: subView) {
                return recursiveSubView
            }
        }
        
        return nil
    }
    
    fileprivate func animateViewWith(sender:UIView, notification:Notification){
        
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        let animationDuration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        let firstResponder = findFirstResponder(inView: container)
        
        let up = notification.name == UIResponder.keyboardWillShowNotification ? true : false
        
        if let firstResponder = firstResponder{
            
            let movementDuration:TimeInterval = animationDuration
            UIView.beginAnimations( "animateView", context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(movementDuration )
            
            let frame = firstResponder.convert(firstResponder.frame, to: container)
            let visibleContainerHeight = container.frame.height - keyboardRect.height
//            print(keyboardRect.height)
            let firstResponderPosition = frame.origin.y + frame.height
            
            let offsetY = visibleContainerHeight - firstResponderPosition
            
            if up{
                
                if firstResponderPosition > visibleContainerHeight && !(sender is UIScrollView) {
                    container.transform = CGAffineTransform(translationX: 0, y: offsetY)
                }
                
                if sender is UIScrollView{
                    (sender as! UIScrollView).contentInset = UIEdgeInsets(top: 0, left: 0,
bottom: keyboardRect.height + 10, right: 0)
                    
                    var frame:CGRect
                    
                    if let  rect =   firstResponder.superview?.convert(firstResponder.frame, to: container){
                        frame = rect
                    } else{
                        frame = firstResponder.frame
                    }
                    
                    (sender as! UIScrollView).scrollRectToVisible(frame.offsetBy(dx: 0, dy: 10), animated: true)
                    (sender as! UIScrollView).bounces = false
                }
                
            } else {
                
                if sender is UIScrollView{
                    (sender as! UIScrollView).contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                } else /*if firstResponderPosition > visibleContainerHeight*/ {
                    container.transform = CGAffineTransform.identity
                }
            }
            UIView.commitAnimations()
        }
    }
    
    fileprivate func handler(notification:Notification){
        animateViewWith(sender: container, notification: notification)
    }
}


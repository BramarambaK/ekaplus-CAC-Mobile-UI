//
//  ShareViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 31/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit
import jot


enum AnnotationMode{
    case drawing
    case text
    case none
}

enum AnnotationColor:Int{
    case black
    case white
    case red
    case green
    case yellow
    case blue
}


class ShareViewController: GAITrackedViewController, JotViewControllerDelegate {
    
    
    @IBOutlet weak var btnClearAll: UIButton!
    
    @IBOutlet weak var drawingColorPallete: UIStackView!
    
    @IBOutlet weak var textColorPallete: UIStackView!
    
    @IBOutlet weak var btnDraw: UIButton!
    
    @IBOutlet weak var btnText: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var btnShare:UIButton!
    
    var jotViewController:JotViewController!
    
    var currentColor:AnnotationColor = .black
    var currentMode:AnnotationMode = .none
    
    var screenShotImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.shareScreenShot
        
        imageView.image = screenShotImage
        imageView.contentMode = .scaleAspectFit
        
        btnClearAll.isHidden = true
        drawingColorPallete.isHidden = true
        textColorPallete.isHidden = true
        btnText.tintColor = .black
        btnDraw.tintColor = .black
        
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: handler(notification:))
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
        NotificationCenter.default.removeObserver(self)
    }
    
    func handler(notification:Notification){
        let up = notification.name == UIResponder.keyboardWillShowNotification ? true : false
        
        if up {
            btnShare.isEnabled = false
        } else {
            btnShare.isEnabled = true
        }
    }
    
    func setUpJotVC(){
        if jotViewController == nil {
            jotViewController = JotViewController()
            addChild(jotViewController)
            containerView.addSubview(jotViewController.view)
            jotViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            jotViewController.didMove(toParent: self)
            jotViewController.view.frame = containerView.bounds
        }
    }
 
    @IBAction func shareTapped(_ sender: UIButton) {
        
//        jotViewController?.state = .default
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let image = self.containerView.screenshotView() {
                let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
                vc.popoverPresentationController?.sourceView = self.view
                vc.popoverPresentationController?.sourceRect = sender.frame
                self.present(vc, animated: true)
            }
        }
    }
    
    @IBAction func clearAllTapped(_ sender: UIButton) {
        sender.isHidden = true
        jotViewController.clearAll()
        currentColor = .black
        btnText.tintColor = .black
        btnDraw.tintColor = .black
        currentMode = .none
        jotViewController.state = .default
        
        UIView.animate(withDuration: 0.25, animations: {
            self.btnDraw.transform = CGAffineTransform.identity
            self.btnText.transform = CGAffineTransform.identity
        })
        
        for subView in drawingColorPallete.arrangedSubviews where subView is UIButton{
            (subView as! UIButton).isSelected = false
        }
        
        for subView in textColorPallete.arrangedSubviews where subView is UIButton{
            (subView as! UIButton).isSelected = false
        }
        
        if !self.textColorPallete.isHidden{
            UIView.animate(withDuration: 0.25, animations: {
                self.textColorPallete.isHidden = true
            })
        }
        
        if !self.drawingColorPallete.isHidden{
            UIView.animate(withDuration: 0.25, animations: {
                self.drawingColorPallete.isHidden = true
            })
        }
    }
    
    @IBAction func colorSelected(_ sender: UIButton) {
        currentColor = AnnotationColor(rawValue: sender.tag)!
        setUpJotVC()
        btnClearAll.isHidden = false
 
        if currentMode == .drawing{
            
            //Remove any previous color selection and select current color
            for subView in drawingColorPallete.arrangedSubviews where subView is UIButton{
                (subView as! UIButton).isSelected = false
            }
            sender.isSelected = true
            
            //remove text color selection
            for subView in textColorPallete.arrangedSubviews where subView is UIButton{
                (subView as! UIButton).isSelected = false
            }
            
            if !self.drawingColorPallete.isHidden{
                UIView.animate(withDuration: 0.25, animations: {
                    self.drawingColorPallete.isHidden = true
                })
            }
            
            jotViewController.state = .drawing
            jotViewController.drawingStrokeWidth = 5
            jotViewController.drawingColor = colorForTag(currentColor.rawValue)
            btnDraw.tintColor = colorForTag(currentColor.rawValue)
            btnText.tintColor = .black
            
        } else if currentMode == .text {
            for subView in textColorPallete.arrangedSubviews where subView is UIButton{
                (subView as! UIButton).isSelected = false
            }
            sender.isSelected = true
            
            //remove drawing color selection
            for subView in drawingColorPallete.arrangedSubviews where subView is UIButton{
                (subView as! UIButton).isSelected = false
            }
            
            if !self.textColorPallete.isHidden{
                UIView.animate(withDuration: 0.25, animations: {
                    self.textColorPallete.isHidden = true
                })
            }
            jotViewController.state = .editingText
            jotViewController.fontSize = 25
            jotViewController.textColor = colorForTag(currentColor.rawValue)
            btnText.tintColor = colorForTag(currentColor.rawValue)
            btnDraw.tintColor = .black
            
        }
        
    }
    
    @IBAction func drawingModeSelected(_ sender: UIButton) {
        
        if currentMode == .drawing && !self.drawingColorPallete.isHidden{
            return
        }
        
        currentMode = .drawing
        UIView.animate(withDuration: 0.25) {
            
            if !self.textColorPallete.isHidden{
                self.textColorPallete.isHidden = true
            }

            if self.drawingColorPallete.isHidden{
                self.drawingColorPallete.isHidden = false
            }
            
            sender.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            self.btnText.transform = CGAffineTransform.identity
        }
        
    }
    
    @IBAction func textModeSelected(_ sender: UIButton) {
        
        if currentMode == .text && !self.textColorPallete.isHidden {
            return
        }

        currentMode = .text
        
        UIView.animate(withDuration: 0.25) {
            if self.textColorPallete.isHidden{
                self.textColorPallete.isHidden = false
            }
            
            if !self.drawingColorPallete.isHidden{
                self.drawingColorPallete.isHidden = true
            }
            sender.transform = CGAffineTransform.init(scaleX: 1.6, y: 1.6)
            self.btnDraw.transform = CGAffineTransform.identity
        }
    }
    
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func colorForTag(_ tag:Int)->UIColor{
        switch tag {
        case 0 : return .black
        case 1 : return .white
        case 2 : return UIColor(hex: "#D0021B")! //red
        case 3 : return UIColor(hex: "#5DAD00")! //green
        case 4 : return UIColor(hex: "#F6B700")! //yellow
        case 5 : return UIColor(hex: "#0068E1")! //blue
        default: return .black
        }
    }
    
}

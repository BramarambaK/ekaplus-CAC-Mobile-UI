//
//  Extensions.swift
//  EkaAnalytics
//
//  Created by Nithin on 21/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import Foundation
import UIKit

/*-------------------------------------------------------*/

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
    }
    
}

/*-------------------------------------------------------*/

extension UIStackView {
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach {
            self.removeArrangedSubview($0)
            NSLayoutConstraint.deactivate($0.constraints)
            $0.removeFromSuperview()
        }
    }
}

/*-------------------------------------------------------*/

extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
}
/*-------------------------------------------------------*/
extension UITextField {
    
    func addDoneToolBarButton(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneSelector))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
        self.inputAccessoryView?.tintColor = Utility.appThemeColor
    }
    
    @objc func doneSelector(){
        self.resignFirstResponder()
    }
}

extension UITextView {
    @objc
    func addDoneToolBarButton(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneSelector))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
        self.inputAccessoryView?.tintColor = Utility.appThemeColor
    }
    
    @objc func doneSelector(){
        self.resignFirstResponder()
    }
}

/*-------------------------------------------------------*/

extension Dictionary {
    func jsonString(_ prettyPrinted: Bool = false) -> String {
        do {
            if prettyPrinted == true{
                if #available(iOS 11.0, *) {
                    let data = try JSONSerialization.data(withJSONObject: self, options: [.sortedKeys])
                    return String(data: data, encoding: String.Encoding.utf8) ?? ""
                } else {
                    let data = try JSONSerialization.data(withJSONObject: self, options: [])
                    return String(data: data, encoding: String.Encoding.utf8) ?? ""
                    // Fallback on earlier versions
                }
            }else{
                if #available(iOS 11.0, *) {
                    let data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted,.sortedKeys])
                    return String(data: data, encoding: String.Encoding.utf8) ?? ""
                } else {
                    let data = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
                    return String(data: data, encoding: String.Encoding.utf8) ?? ""
                }
            }
            
        } catch {
            return ""
        }
    }
}
/*-------------------------------------------------------*/

extension UIViewController {
    
    //Reload the TableView in the viewcontroller.
    func reloadTableview(tableView: UITableView) {
        DispatchQueue.main.async {
            let contentOffset = tableView.contentOffset
            tableView.reloadData()
            tableView.layoutIfNeeded()
            tableView.setContentOffset(contentOffset, animated: false)
        }
    }
    
    fileprivate func setBackButtonImage(_ tint:UIColor,bckbtnimage:String){
        
        if tint == .white {
            self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: bckbtnimage)?.withRenderingMode(.alwaysOriginal)
            
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: bckbtnimage)?.withRenderingMode(.alwaysOriginal)
        } else {
            self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: bckbtnimage)
            
            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: bckbtnimage)
        }
        
        
        let backBtn = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        backBtn.tintColor = tint
        self.navigationItem.backBarButtonItem = backBtn
        self.navigationItem.backBarButtonItem?.tintColor = tint
    }
    
    func setTitle(_ text:String, color:UIColor = .white, backbuttonTint:UIColor = .white,bckbtnimage:String = "Back"){
        
        let actualEndIndex = text.endIndex
        
        var text:String = text
        
        if  actualEndIndex.encodedOffset > 25 {
            let endIndex = text.index(text.startIndex, offsetBy:25)
            text = String(text[..<endIndex]) + "..."
        } else {
            text = String(text[..<actualEndIndex])
        }
        
        
        
        if let titleLabel = self.navigationItem.leftBarButtonItems?.last?.customView as? UILabel {
            titleLabel.text = text
            titleLabel.sizeToFit()
            titleLabel.lineBreakMode = .byTruncatingTail
        } else {
            let titleLabel = UILabel()
            titleLabel.text = text
            titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            titleLabel.textColor = color
            titleLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 25)
            titleLabel.sizeToFit()
            titleLabel.lineBreakMode = .byTruncatingTail
            titleLabel.numberOfLines = 1
            let titleBarItem = UIBarButtonItem(customView: titleLabel)
            if self.navigationItem.leftBarButtonItems == nil {
                self.navigationItem.leftBarButtonItems = []
            }
            self.navigationItem.leftBarButtonItems?.append(titleBarItem)
        }
        
        setBackButtonImage(backbuttonTint, bckbtnimage: bckbtnimage)
    }
}
/*-------------------------------------------------------*/

extension UIColor {
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt32 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

/*-------------------------------------------------------*/

extension String {
    func heightWithConstrainedWidth(width:CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func widthWithConstrainedHeight(height:CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height:height)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                if $0.count > 0 {
                    return ($0 + " " + String($1))
                }
            }
            return $0 + String($1)
        }
    }
    
    func getEmailandPhoneValidation() -> Bool {
        
        var is_emailPresent:Bool = false
        var is_phoneNumeberPresent:Bool = false
        
        //Email check
        if let regex = try? NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: .caseInsensitive)
        {
            let string = self as NSString
            
            let email = regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "", with: "").lowercased()}
            
            if email.count > 0{
                is_emailPresent = true
            }
            
        }
        
        
        //Phonenumber Check
        
        if let regex = try? NSRegularExpression(pattern: "[0-9]{10}", options: .caseInsensitive)
        {
            let string = self as NSString
            
            let phoneNumber = regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "", with: "").lowercased()}
            
            if phoneNumber.count > 0{
                is_phoneNumeberPresent = true
                
            }
        }
        
        if is_emailPresent || is_phoneNumeberPresent {
            return true
        }
        else{
            return false
        }
    }
    
    func removeHTMLTag() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
    }
}

/*-------------------------------------------------------*/

extension UIView {
    
    enum ViewSide {
        case Left, Right, Top, Bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .Left: border.frame = CGRect(x: frame.minX, y: frame.minY, width: thickness, height: frame.height); break
        case .Right: border.frame = CGRect(x: frame.maxX, y: frame.minY, width: thickness, height: frame.height); break
        case .Top: border.frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: thickness); break
        case .Bottom: border.frame = CGRect(x: frame.minX, y: frame.maxY, width: frame.width, height: thickness); break
        }
        
        layer.addSublayer(border)
    }
}

/*-------------------------------------------------------*/

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

/*-------------------------------------------------------*/

extension UITableView {
    var noDataMessage:String?{
        set{
            if let message = newValue {
                let label = UILabel()
                label.text = message
                label.numberOfLines = 0
                label.textAlignment = .center
                label.frame = self.bounds
                self.backgroundView = label
            } else {
                self.backgroundView = nil
            }
        }
        get {
            if let label = self.backgroundView as? UILabel{
                return label.text
            } else {
                return nil
            }
        }
    }
}

/*-------------------------------------------------------*/

extension UICollectionView {
    var noDataMessage:String?{
        set{
            if let message = newValue {
                let label = UILabel()
                label.text = message
                label.numberOfLines = 0
                label.textAlignment = .center
                label.frame = self.bounds
                self.backgroundView = label
            } else {
                self.backgroundView = nil
            }
        }
        get {
            if let label = self.backgroundView as? UILabel{
                return label.text
            } else {
                return nil
            }
        }
    }
}

/*-------------------------------------------------------*/

extension UIButton {
    //MARK: - Animate check mark
    func checkboxAnimation(closure: @escaping () -> Void){
        guard let image = self.imageView else {return}
        
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            image.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.isSelected = !self.isSelected
                //to-do
                closure()
                image.transform = .identity
            }, completion: nil)
        }
        
    }
}

/*-------------------------------------------------------*/

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        
        let tempUrlString = urlString.replacingOccurrences(of: " ", with: "%20")
        guard let url = URL(string: tempUrlString) else {
            print("Invalid URL.")
            return
        }
        
        image = UIImage(named: "Placeholder")
        
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = imageFromCache
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                
                if let imageToCache = UIImage(data: data!) {
                    imageCache.setObject(imageToCache, forKey: urlString as NSString)
                    self.image = imageToCache
                }
            })
            
        }).resume()
    }
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 17)]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12)]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        
        return self
    }
}

//
//  NewPwdViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 21/04/22.
//  Copyright © 2022 Eka Software Solutions. All rights reserved.
//

import UIKit

final class NewPwdViewController: UIViewController,KeyboardObserver,HUDRenderer {
    
    //MARK: - Variable
    var container: UIView{
        return self.contentView
    }
    
    lazy var changePasswordApiController:ChangePasswordAPIController = {
        return ChangePasswordAPIController()
    }()
    
    var currentPwd:String?
    var passwordPolicy:NSMutableAttributedString? = NSMutableAttributedString(string: "")
    var policy:[String]?
    
    //MARK: - @IBOutlet
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var txfNewPassword: UITextField!
    
    @IBOutlet weak var txfConfirmPassword: UITextField!
    
    @IBOutlet weak var lblPasswordPolicy: UILabel!
    
    @IBOutlet weak var changePwdStack: UIStackView!
    
    @IBOutlet weak var lv_PolicyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lv_PolicyView.isHidden = true
        
        changePasswordApiController.getPasswordPolicy { Policy,PolicyString  in
            self.policy = Policy
            self.passwordPolicy = PolicyString
            if self.passwordPolicy == nil{
                let view = self.changePwdStack.arrangedSubviews[2]
                self.changePwdStack.removeArrangedSubview(view)
                self.lblPasswordPolicy.removeFromSuperview()
            }else{
                self.lv_PolicyView.isHidden = false
                self.lblPasswordPolicy.attributedText = self.passwordPolicy
            }
        }
        
        [txfNewPassword, txfConfirmPassword].forEach{
            $0?.addDoneToolBarButton()
            $0?.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications(shouldRegister: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
    }
    
    //MARK: - @IBAction
    @IBAction func closebtnTapped(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savebtnTapped(_ sender: Any) {
        guard validate() else {
            self.showAlert(title:NSLocalizedString("Warning", comment: ""),message: NSLocalizedString("Please enter all the fields", comment: ""))
            return
        }
        
        if txfConfirmPassword.text != txfNewPassword.text  {
            self.showAlert(title:NSLocalizedString("Warning", comment: ""),message: NSLocalizedString("New and Confirm Password are not same.", comment: ""))
            return
        }
        
        changePasswordApiController.changePassword(oldPassword: currentPwd ?? "", newPassword: txfNewPassword.text!) { (success) in
            if success {
                
                self.showAlert(message: NSLocalizedString("Successfully changed the password. Please login again", comment: ""), okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: false, handler: { (success) in
                    if success {
                        
                        self.showActivityIndicator()
                        LoginApiController.logout({ (response) in
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.signOut.rawValue)
                            self.hideActivityIndicator()
                            switch response {
                            case .success(_):
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                    ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
                                })
                                
                            case .failure(let error):
                                print(error)
                                self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false, completion: {
                                    ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
                                })
                            case .failureJson(_):
                                break
                            }
                        })
                        
                        
                    }
                })
            }
        }
    }
    
    private func validate() -> Bool {
        return  txfNewPassword.text != nil && txfConfirmPassword.text != nil && txfNewPassword.text != "" && txfConfirmPassword.text != ""
    }
    
}

extension NewPwdViewController:UITextFieldDelegate {
    
    //Text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
        if textField == self.txfNewPassword, textField.text != nil, textField.text != "",passwordPolicy != nil {
            
            self.showActivityIndicator()
            changePasswordApiController.passwordValidator(textField.text!) { result in
                self.hideActivityIndicator()
                self.formatPolicy(rawString: result)
            }
            //            changePasswordApiController.validateNewPassword(textField.text!, { (success) in
            //                self.hideActivityIndicator()
            //                if !success {
            //                    self.showAlert(message: NSLocalizedString("The new password doesn't conform to our password policy. Please choose a different one.", comment: ""))
            //                    textField.text = nil
            //                }
            //            })
        } else if textField == self.txfConfirmPassword, textField.text != nil, textField.text != "" {
            if self.txfNewPassword.text != self.txfConfirmPassword.text {
                self.showAlert(message: NSLocalizedString("The new password and confirm password doesn't match.", comment: ""))
                textField.text = nil
            }
        }
        
    }
    
    func formatPolicy(rawString:JSON){
        let policyValidator = NSMutableAttributedString(string: "")
        
        let passstrength:String = "\(rawString["passwordValidatorResultList"][0]["message"])"
        
        if passstrength.contains("Very strong"){
            let range = (passstrength as NSString).range(of: "Very strong")
            let attributedString = NSMutableAttributedString(string:passstrength)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 71/255, green: 194/255, blue: 90/255, alpha: 1), range: range)
            policyValidator.append(attributedString)
        }else if passstrength.contains("Fair"){
            let range = (passstrength as NSString).range(of: "Fair")
            let attributedString = NSMutableAttributedString(string:passstrength)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 235/255, green: 174/255, blue: 70/255, alpha: 1), range: range)
            policyValidator.append(attributedString)
        }else if passstrength.contains("Good"){
            let range = (passstrength as NSString).range(of: "Good")
            let attributedString = NSMutableAttributedString(string:passstrength)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 232/255, green: 231/255, blue: 74/255, alpha: 1), range: range)
            policyValidator.append(attributedString)
        }else if passstrength.contains("Strong"){
            let range = (passstrength as NSString).range(of: "Strong")
            let attributedString = NSMutableAttributedString(string:passstrength)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 178/255, green: 224/255, blue: 76/255, alpha: 1), range: range)
            policyValidator.append(attributedString)
        }else if passstrength.contains("Weak"){
            let range = (passstrength as NSString).range(of: "Weak")
            let attributedString = NSMutableAttributedString(string:passstrength)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 220/255, green: 33/255, blue: 41/255, alpha: 1), range: range)
            policyValidator.append(attributedString)
        }
        
        policyValidator.append(NSMutableAttributedString(string: "\n\(policy![0])"))
        
        var value:[String:Bool] = [:]
        
        for i in 1..<rawString["passwordValidatorResultList"].count {
            value[rawString["passwordValidatorResultList"][i]["message"].stringValue] = rawString["passwordValidatorResultList"][i]["pass"].boolValue
        }
        
        for i in 1..<policy!.count {
            policyValidator.append(NSAttributedString(string: "\n"))
            
            let image1Attachment = NSTextAttachment()
            
            if value[policy![i]] == true {
                image1Attachment.image = UIImage(named: "Tick.png")
            }else{
                image1Attachment.image = UIImage(named: "Failed.png")
            }
            
            let image1String = NSAttributedString(attachment: image1Attachment)
            
            policyValidator.append(image1String)
            policyValidator.append(NSAttributedString(string: "\(policy![i])"))
        }
        self.lblPasswordPolicy.attributedText = policyValidator
    }
}

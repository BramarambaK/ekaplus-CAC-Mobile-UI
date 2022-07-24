//
//  ChangePasswordViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 09/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol LogOutAfterChangingPassword:AnyObject{
    func logTheUserOut()
}

class ChangePasswordViewController: UIViewController, HUDRenderer, KeyboardObserver, UITextFieldDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var txfCurrentPassword: UITextField!
    
    @IBOutlet weak var txfNewPassword: UITextField!
    
    @IBOutlet weak var txfConfirmPassword: UITextField!
    
    weak var logoutUserDelegate:LogOutAfterChangingPassword?
    
    var container: UIView{
        return self.view
    }
    
    lazy var changePasswordApiController:ChangePasswordAPIController = {
        return ChangePasswordAPIController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        setTitle(NSLocalizedString("Change Password", comment: ""), color: .black, backbuttonTint:Utility.appThemeColor)
        
        [txfCurrentPassword, txfNewPassword, txfConfirmPassword].forEach{
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
    
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard validate() else {
            self.showAlert(message: NSLocalizedString("Please enter all the fields", comment: ""))
            return
        }
        
        changePasswordApiController.changePassword(oldPassword: txfCurrentPassword.text!, newPassword: txfNewPassword.text!) { (success) in
            if success {
                
                self.showAlert(message: NSLocalizedString("Successfully changed the password. Please login again", comment: ""), okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: false, handler: { (success) in
                    if success {
                        self.navigationController?.popViewController(animated: true)
                        self.logoutUserDelegate?.logTheUserOut()
                    }
                })
            }
        }
    }
    
    func validate() -> Bool {
        return txfCurrentPassword.text != nil && txfNewPassword.text != nil && txfConfirmPassword.text != nil && txfNewPassword.text == txfConfirmPassword.text && txfCurrentPassword.text != "" && txfNewPassword.text != "" && txfConfirmPassword.text != ""
    }
    
    //Text field delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
        if textField == self.txfCurrentPassword, textField.text != nil, textField.text != "" {
            self.showActivityIndicator()
            changePasswordApiController.validateExistingPassword(textField.text!, { (success) in
                self.hideActivityIndicator()
                if !success {
                    self.showAlert(message: NSLocalizedString("The existing password doesn't match our records.", comment: ""))
                    textField.text = nil
                }
            })
        } else if textField == self.txfNewPassword, textField.text != nil, textField.text != "" {
            
            if self.txfCurrentPassword.text == nil || self.txfCurrentPassword.text == "" {
                self.showAlert(message: NSLocalizedString("Please enter the current password first", comment: ""))
                textField.text = nil
                return
            }
            
            if txfNewPassword.text == txfCurrentPassword.text {
                self.showAlert(message: NSLocalizedString("This is same as the existing password, Please choose a different one.", comment: ""))
                textField.text = nil
                return
            }
            
            
            self.showActivityIndicator()
            changePasswordApiController.validateNewPassword(textField.text!, { (success) in
                self.hideActivityIndicator()
                if !success {
                    self.showAlert(message: NSLocalizedString("The new password doesn't conform to our password policy. Please choose a different one.", comment: ""))
                    textField.text = nil
                }
            })
        } else if textField == self.txfConfirmPassword, textField.text != nil, textField.text != "" {
            if self.txfNewPassword.text != self.txfConfirmPassword.text {
                self.showAlert(message: NSLocalizedString("The new password and confirm password doesn't match.", comment: ""))
                textField.text = nil
            }
        }
    }
    
}

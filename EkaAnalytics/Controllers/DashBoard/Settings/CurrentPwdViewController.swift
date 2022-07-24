//
//  CurrentPwdViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 20/04/22.
//  Copyright © 2022 Eka Software Solutions. All rights reserved.
//

import UIKit

final class CurrentPwdViewController: UIViewController,KeyboardObserver,HUDRenderer {
    
    //MARK: - Variable
    var container: UIView{
        return self.contentView
    }
    
    lazy var changePasswordApiController:ChangePasswordAPIController = {
       return ChangePasswordAPIController()
    }()
    
    //MARK: - @IBOutlet
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var txfCurrentPassword: UITextField!
    
    //MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        [txfCurrentPassword].forEach{
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.registerForKeyboardNotifications(shouldRegister: false)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - @IBAction
    @IBAction func closebtnTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func NextbtnTapped(_ sender: Any) {
        
        guard validate() else{
            self.showAlert(title:NSLocalizedString("Information", comment: "Information"),message: NSLocalizedString("Please enter the Current Password.", comment: ""))
            return
        }
        
        self.showActivityIndicator()
        changePasswordApiController.validateExistingPassword(txfCurrentPassword.text!, { (success) in
            self.hideActivityIndicator()
            if !success {
                self.showAlert(title:NSLocalizedString("Information", comment: "Information"),message: NSLocalizedString("The existing password doesn't match our records.", comment: ""))
                self.txfCurrentPassword.text = nil
            }else{
                let NewPwdVc = self.storyboard?.instantiateViewController(withIdentifier: "NewPwdViewController") as! NewPwdViewController
                NewPwdVc.currentPwd = self.txfCurrentPassword.text!
                NewPwdVc.modalPresentationStyle = .overFullScreen
                self.present(NewPwdVc, animated: true)
            }
        })
       
    }
    
    
    //MARK: - Local Function
    
    private func validate() -> Bool {
        return txfCurrentPassword.text != nil && txfCurrentPassword.text != ""
    }
}


extension CurrentPwdViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.text = textField.text?.removeHTMLTag()
    }
}

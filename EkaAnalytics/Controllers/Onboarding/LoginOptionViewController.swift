//
//  LoginOptionViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 24/05/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit
import MSAL
import OktaOidc

final class LoginOptionViewController: UIViewController,HUDRenderer {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lv_EkaLogin: UIView!
    @IBOutlet weak var ekaLogin_Height: NSLayoutConstraint!
    @IBOutlet weak var msLogin_Height: NSLayoutConstraint!
    @IBOutlet weak var oktaLogin_Height: NSLayoutConstraint!
    @IBOutlet weak var lv_MsLogin: UIView!
    @IBOutlet weak var lbl_Version: UILabel!
    @IBOutlet weak var lbl_copyRights: UILabel!
    @IBOutlet weak var lv_OktaLogin: UIView!
    @IBOutlet weak var ltxv_privacyTextView: UITextView!
    
    //MARK: - Variable
    var container: UIView{
        return self.scrollView
    }
    
    lazy var ApiController:LoginApiController = {
        return LoginApiController()
    }()
    
    //Azure AD configuration
    
    let kClientID = "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.ssoClientId.rawValue) ?? "")"
    let kAuthority = "https://login.microsoftonline.com/organizations"
    
    let kScopes: [String] = ["user.read"]
    
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var currentAccount: MSALAccount?
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    private var oktaAppAuth: OktaOidc?
    private var authStateManager: OktaOidcStateManager? {
        didSet {
            oldValue?.clear()
            authStateManager?.writeToSecureStorage()
        }
    }
    
    private var oktaConfig: OktaOidcConfig? {
        return  try? OktaOidcConfig(with: [
            "issuer": "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.issuer.rawValue) ?? "")",
            "clientId": "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.ssoClientId.rawValue) ?? "")",
            "redirectUri": "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.redirecturi.rawValue) ?? "")",
            "logoutRedirectUri": "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.logoutRedirectUri.rawValue) ?? "")",
            "scopes": "openid profile offline_access email"
        ])
    }
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: Date())
        
        self.lbl_Version.text = "Version \(Bundle.main.releaseVersionNumber!)"
        self.lbl_copyRights.text = "© 2017-\(yearString) \(NSLocalizedString("Eka Software Solutions Pvt. Ltd. All rights reserved.", comment: ""))"
        
        SecurityUtilities().ExitOnJailbreak()
        
        //EKA Login
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSSOMobile.rawValue) && UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "azure"  {
            self.lv_MsLogin.isHidden = false
            self.msLogin_Height.constant = 45
            self.lv_OktaLogin.isHidden = true
            self.oktaLogin_Height.constant = 0
            do {
                try self.initMSAL()
            } catch let error {
                print("Unable to create Application Context \(error)")
            }
        }else if UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "okta"  {
            self.lv_OktaLogin.isHidden = false
            self.oktaLogin_Height.constant = 45
            self.lv_MsLogin.isHidden = true
            self.msLogin_Height.constant = 0
            
            oktaAppAuth = try? OktaOidc(configuration: oktaConfig)
            AppDelegate.shared.oktaOidc = oktaAppAuth
            
            if let config = oktaAppAuth?.configuration {
                authStateManager = OktaOidcStateManager.readFromSecureStorage(for: config)
            }
            
        }else{
            self.lv_MsLogin.isHidden = true
            self.msLogin_Height.constant = 0
            self.lv_OktaLogin.isHidden = true
            self.oktaLogin_Height.constant = 0
        }
        
        //Azure Login
        if (UserDefaults.standard.bool(forKey: UserDefaultsKeys.showEkaLogin.rawValue)){
            self.lv_EkaLogin.isHidden = false
            self.ekaLogin_Height.constant = 45
        }else{
            self.lv_EkaLogin.isHidden = true
            self.ekaLogin_Height.constant = 0
        }
        
        self.setupPrivacyView()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSSOMobile.rawValue) && UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "azure" && UserDefaults.standard.bool(forKey: UserDefaultsKeys.signOut.rawValue){
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.signOut.rawValue)
            self.signOut()
        }else if UserDefaults.standard.bool(forKey: UserDefaultsKeys.enabledSSOMobile.rawValue) && UserDefaults.standard.string(forKey: UserDefaultsKeys.identityProviderType.rawValue) == "okta" && UserDefaults.standard.bool(forKey: UserDefaultsKeys.signOut.rawValue){
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.signOut.rawValue)
            self.oktasignOut()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: - IBAction
    
    @IBAction func ChangeTenant(_ sender: Any) {
        self.performSegue(withIdentifier: Segues.changedomain.rawValue, sender: self)
    }
    
    @IBAction func ekaLogin_Tapped(_ sender: Any) {
        let LoginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginMFAViewController") as! LoginMFAViewController
        self.navigationController?.pushViewController(LoginVC, animated: true)
    }
    
    @IBAction func oktaLogin_Tapped(_ sender: Any) {
        
        oktaAppAuth?.signInWithBrowser(from: self) { authStateManager, error in
            if let error = error {
                self.authStateManager = nil
                print(error)
                return
            }
            
            self.authStateManager = authStateManager
            authStateManager?.writeToSecureStorage()
            
            self.showActivityIndicator()
            self.ApiController.AzureandoktaLogin(id_Token: "\(authStateManager?.idToken ?? "")", medium: "okta") { (result) in
                self.hideActivityIndicator()
                switch result{
                case .success( _):
                    if let url = URL(string: "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "")/apps/platform/classic/resources/images/clientLogo/\(UserDefaults.standard.value(forKey:UserDefaultsKeys.tenantShortName.rawValue)!).png") {
                        self.downloadImage(url: url)
                    }
                    
                    let DashVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                    self.navigationController?.pushViewController(DashVC, animated: true)
                case .failure(let error):
                    print(error)
                    break
                case .failureJson(_):
                    break
                }
            }
        }
        
    }
    
    @IBAction func msLogin_Tapped(_ sender: Any) {
        self.acquireTokenInteractively { (result) in
            switch result{
                
            case .success( _):
                
                if let url = URL(string: "\(UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantDomain.rawValue) ?? "")/apps/platform/classic/resources/images/clientLogo/\(UserDefaults.standard.value(forKey:UserDefaultsKeys.tenantShortName.rawValue)!).png") {
                    self.downloadImage(url: url)
                }
                
                let DashVC = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as! DashBoardViewController
                self.navigationController?.pushViewController(DashVC, animated: true)
                
            case .failure(let error):
                print(error)
                break
            case .failureJson(_):
                break
            }
        }
    }
}

extension LoginOptionViewController {
    
    func initMSAL() throws {
        
        guard let authorityURL = URL(string: kAuthority) else {
            print("Unable to create authority URL")
            //              self.updateLogging(text: "Unable to create authority URL")
            return
        }
        
        let authority = try MSALAADAuthority(url: authorityURL)
        
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: kClientID, redirectUri: nil, authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        self.initWebViewParams()
    }
    
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self)
    }
    
    
    
    func acquireTokenInteractively(completion:@escaping (ServiceResponse<Bool>)->()) {
        
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        
        let parameters = MSALInteractiveTokenParameters(scopes: kScopes, webviewParameters: webViewParameters)
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                print("Could not acquire token: \(error)")
                completion(.failure(.custom(message: "Could not acquire token: \(error)")))
                return
            }
            
            guard let result = result else {
                print("Could not acquire token: No result returned")
                completion(.failure(.custom(message: "Could not acquire token: No result returned")))
                return
            }
            
            self.showActivityIndicator()
            self.ApiController.AzureandoktaLogin(id_Token: "\(result.idToken ?? "")", medium: "azure") { (result) in
                self.hideActivityIndicator()
                switch result{
                case .success( _):
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                case .failureJson(_):
                    break
                }
            }
        }
    }
    
    //Download the image from the Server and Display client banner on login
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let filename = paths[0].appendingPathComponent("ClientLogo.png")
                print(filename)
                try? data.write(to: filename)
                guard UIImage(contentsOfFile: filename.path) != nil else { return }
                let clientBanner = Banner(title: nil, subtitle: nil, image: UIImage(contentsOfFile: filename.path), backgroundColor: UIColor.white.withAlphaComponent(0.5))
                clientBanner.show(duration: 3.0)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }.resume()
    }
    
    func signOut(completion: AccountCompletion? = nil) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            
            if let error = error {
                print(error)
                return
            }
            
            if let currentAccount = currentAccount {
                
                self.currentAccount = currentAccount
                
                if let completion = completion {
                    completion(self.currentAccount)
                }
                
                guard let applicationContext = self.applicationContext else { return }
                
                guard let account = self.currentAccount else { return }
                
                do {
                    /**
                     Removes all tokens from the cache for this application for the provided account
                     
                     - account:    The account to remove from the cache
                     */
                    
                    let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
                    signoutParameters.signoutFromBrowser = true
                    
                    applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                        
                        if let error = error {
                            print("Couldn't sign out account with error: \(error)")
                            return
                        }
                    })
                    
                }
                
                return
            }
            
            if let completion = completion {
                completion(nil)
            }
        })
    }
    
    func oktasignOut(){
        guard let authStateManager = authStateManager else { return }
        
        oktaAppAuth?.signOut(authStateManager: authStateManager, from: self, progressHandler: { currentOption in
            if currentOption.contains(.revokeAccessToken) {
                print("Revoking tokens...")
            } else if currentOption.contains(.revokeRefreshToken) {
                print("Revoking tokens...")
            } else if currentOption.contains(.signOutFromOkta) {
                print("Signing out from Okta...")
            }
        }, completionHandler: { success, failedOptions in
            if success {
                self.authStateManager = nil
            } else {
                print("Error: failed to logout")
            }
        })
    }
}

extension LoginOptionViewController:UITextViewDelegate {
    
    //MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        let selectedOption:String = URL.absoluteString
        let header = ["Content-Type":"application/json"]
        
        if URL.absoluteString != "CookiePolicy" {
            self.showActivityIndicator()
            RequestManager.shared.request(.get, connectApiPath:.policiesDetailApi, headers: header) { (response) in
                self.hideActivityIndicator(
                )
                switch response {
                case .success(let json):
                    if json != nil {
                        self.navigatetoScreen(screenType: selectedOption, ResponseJson: json)
                    }else{
                        self.navigatetoScreen(screenType: selectedOption, ResponseJson: nil)
                    }
                case .failure(let error):
                    print(error)
                case .failureJson(_):
                    break
                }
                
            }
        }else{
            self.navigatetoScreen(screenType: selectedOption, ResponseJson: nil)
        }
        
        return false
    }
    
    private func setupPrivacyView(){
        let TermsConditions = NSMutableAttributedString(string: "By using this application, you’re accepting all the Terms & Conditions, ")
        let Termsrange = NSRange(location: 52, length: 18)
        let Termsurl = URL(string: "Terms&Conditions")!
        TermsConditions.setAttributes([.link: Termsurl], range: Termsrange)
        
        let PrivacyPolicy = NSMutableAttributedString(string: "Privacy Policy and ")
        let Privacyrange = NSRange(location: 0, length: 15)
        let Privacyurl = URL(string: "PrivacyPolicy")!
        PrivacyPolicy.setAttributes([.link: Privacyurl], range: Privacyrange)
        
        let CookiePolicy = NSMutableAttributedString(string: "Cookie Policy")
        let Cookierange = NSRange(location: 0, length: 13)
        let Cookieurl = URL(string: "CookiePolicy")!
        CookiePolicy.setAttributes([.link: Cookieurl], range: Cookierange)
        
        ltxv_privacyTextView.textStorage.setAttributedString(TermsConditions)
        ltxv_privacyTextView.textStorage.append(PrivacyPolicy)
        ltxv_privacyTextView.textStorage.append(CookiePolicy)
        ltxv_privacyTextView.linkTextAttributes = [
            .foregroundColor: UIColor(red: 51/255, green: 126/255, blue: 185/255, alpha: 1)
        ]
        
        ltxv_privacyTextView.font = .systemFont(ofSize: 14)
        ltxv_privacyTextView.textAlignment = .center
    }
    
    private func navigatetoScreen(screenType:String,ResponseJson:JSON?){
        
        let ls_noDatacontent:String? = "<b style=\"\"><font size=\"14\">​Data not available</font></b>"
        
        let helpVC = self.storyboard?.instantiateViewController(withIdentifier:"HelpViewController") as! HelpViewController
        
        switch screenType{
        case "Terms&Conditions" :
            helpVC.screenTitle = "Terms & Conditions"
            if ResponseJson != nil {
                if ResponseJson!["termsCondition"]["type"] == "enterUrl" {
                    helpVC.url = ResponseJson!["termsCondition"]["content"].stringValue
                }else{
                    if ResponseJson!["termsCondition"]["content"].stringValue.count > 0 {
                        helpVC.screenContent = ResponseJson!["termsCondition"]["content"].stringValue
                    }else{
                        helpVC.screenContent = ls_noDatacontent
                    }
                    helpVC.url = nil
                }
            }else{
                helpVC.screenTitle = "Error"
                helpVC.screenContent = ls_noDatacontent
                helpVC.url = nil
            }
        case "PrivacyPolicy":
            helpVC.screenTitle = "Privacy Policy"
            if ResponseJson != nil {
                if ResponseJson!["termsCondition"]["type"] == "enterUrl" {
                    helpVC.url = ResponseJson!["privacyPolicy"]["content"].stringValue
                }else{
                    if ResponseJson!["privacyPolicy"]["content"].stringValue.count > 0 {
                        helpVC.screenContent = ResponseJson!["privacyPolicy"]["content"].stringValue
                    }else{
                        helpVC.screenContent = ls_noDatacontent
                    }
                    helpVC.url = nil
                }
            }else{
                helpVC.screenTitle = "Error"
                helpVC.screenContent = ls_noDatacontent
                helpVC.url = nil
            }
        case "CookiePolicy" :
            helpVC.url = "https://eka1.com/cookie-policy/"
            helpVC.screenTitle = "Cookie Policy"
        default:
            break
        }
        helpVC.modalPresentationStyle = .fullScreen
        self.present(helpVC, animated: true, completion: nil)
        
    }
    
    
    
}

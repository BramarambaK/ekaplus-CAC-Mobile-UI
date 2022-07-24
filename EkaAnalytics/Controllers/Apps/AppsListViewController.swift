//
//  AppsListViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

class AppsListViewController: GAITrackedViewController, HUDRenderer, UITableViewDataSource, UITableViewDelegate, FavouriteToggleDelegate {

    @IBOutlet weak var tableView:UITableView!
    
    var categoryID:Int! //supplied from previous screen
    
    var categoryName:String!
    
    var apps = [App](){
        didSet{
            tableView.reloadData()
        }
    }
    
     //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.appList

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        
        self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(categoryName)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        
        setTitle(categoryName + " Apps")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getAppsList), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(categoryName)
        getAppsList()
    }
    
//    override func willMove(toParent parent: UIViewController?) {
//        super.willMove(toParent: parent)
//        self.navigationController?.navigationBar.barTintColor = Utility.appThemeColor
//    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (_) in
             self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(self.categoryName)
        }
    }

    @objc
    func getAppsList(){
        
        showActivityIndicator()
        
        AppListAPIController.shared.getAppsForCategory(self.categoryID) {[weak self] (response) in
            
            self?.hideActivityIndicator()
            self?.tableView.refreshControl?.endRefreshing()
            
            switch response {
            case .success(let apps):
                self?.apps = apps
                
//                print(apps)
            case .failure(let error):
                switch error {
                case .tokenRefresh:
                    self?.getAppsList()
                case .tokenExpired:
                    let message = error.description
                    self?.showAlert(title: "Error", message: message, okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
                        self?.navigationController?.popToRootViewController(animated: true)
                    })
                default:
                    self?.showAlert(message: error.description)
                }
            case .failureJson(_):
                break
            }
        }
    }
    
    
    func toggleFavouriteAppAtIndex(_ index: Int, favourite: Bool) {
        var app = apps[index]
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "Favourites", label: "\(app.name)", value: nil).build() as? [AnyHashable : Any])
        }
        
        AppFavouriteAPIController.shared.toggleAppFavourite(app.id, appType: app.appType, isFavourite: favourite) { (response) in
                app.isFavourite = favourite
                self.apps[index] = app
        }
    }

    //MARK: - Tableview datasource and delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.apps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppsListTableViewCell.reuseIdentifier, for: indexPath) as! AppsListTableViewCell
        
        let app = self.apps[indexPath.row]
        cell.lblAppName.text = app.name
//        cell.appImageView.image = UIImage(named: categoryName)
        cell.btnFavourite.isSelected = app.isFavourite
        cell.delegate = self
        cell.rowIndex = indexPath.row
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedApp = self.apps[indexPath.row]
        
        if  selectedApp.name == "Disease Identification"{
            let DiseaseIdentificationVC = self.storyboard?.instantiateViewController(withIdentifier: "DiseaseIdentificationVC") as! DiseaseIdentificationVC
            DiseaseIdentificationVC.app = selectedApp
            self.navigationController?.pushViewController(DiseaseIdentificationVC, animated: true)
        }else{
            SettingsBundleHelper().configureSettingsBundle()
            let insightDetailContainerVC = self.storyboard?.instantiateViewController(withIdentifier: "InsightDetailContainerVC") as! InsightDetailContainerVC
            insightDetailContainerVC.app = selectedApp
            self.navigationController?.pushViewController(insightDetailContainerVC, animated: true)
        }
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "Open", label: "\(selectedApp.name)", value: nil).build() as? [AnyHashable : Any])
        }
        
    }
    
    //MARK: - Local Function
    func getDashDetails(name:String,TenantID:String,selectedApp:App){
        self.showActivityIndicator()
        
        ConnectManager.shared.getConnectDetails(app_Id: name) {
            (response) in
            self.hideActivityIndicator()
            
            switch response {
            case .success(let json):
                if json.count > 0 {
                    let WorkflowDashVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "WorkFlowDashVC") as! WorkFlowDashViewController
                    WorkflowDashVC.app = selectedApp
                    WorkflowDashVC.app_metadata = json
                    self.navigationController?.pushViewController(WorkflowDashVC, animated: true)
                }else{
                    self.showAlert(message: "No Data setup.")
                }
            case .failure(let error):
                self.showAlert(message:error.description)
            case .failureJson(_):
                break
            }
        }
    }
}

//
//  AppsCategoryViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 23/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol AppsCategoryDelegate{
    func selectedMenu(menu:String)
}

final class AppsCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HUDRenderer{
    
    var delegate:AppsCategoryDelegate?
    
//    @IBOutlet weak var filterTag: FilterTagView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isShowingFavourites = false { //toggled from dashboard vc
        didSet{
            //If there is no initial data because of some network issue, retry to hit the api everytime menu is selected
            if (isShowingFavourites) || (isShowingFavourites == false && appCategories.count == 0){
                getDataFromAPI()
            }
            collectionView.reloadData()
            
            if isShowingFavourites {
                registerScreenViewInGoogleAnalytics(ScreenNames.favourites)
                if favourites.count != 0 {
                    collectionView.noDataMessage = nil
                }
            } else {
                registerScreenViewInGoogleAnalytics(ScreenNames.appCategories)
                if appCategories.count != 0 {
                    collectionView.noDataMessage = nil
                }
            }
        }
    }
    
    var appCategories = [AppCategory](){
        didSet{
            cellWidth = collectionView.frame.size.width
            collectionView.reloadData()
        }
    }
    
    var cellWidth:CGFloat = CGFloat.greatestFiniteMagnitude
    
    var favourites = [App](){ //For now, only apps can be marked as Favourites
        didSet{
            cellWidth = collectionView.frame.size.width
            collectionView.reloadData()
        }
    }
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
//        print("View did load of \(String(describing:self))")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getDataFromAPI), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //When user is logging out, he'll land briefly on this page for a fraction of second. In that case, don't hit the api
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.isUserLoggedIn.rawValue){
           getDataFromAPI()
        }
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            
        self.cellWidth = (size.width - 20) - 5 //10 leading + 10 trailing and 5 padding
        self.collectionView.reloadData()

        }, completion: nil)
    }
    
    @objc func getDataFromAPI(){
        if isShowingFavourites {
            getFavourites()
        } else {
            getAppCategories()
        }
    }
    
    func registerScreenViewInGoogleAnalytics(_ name:String){
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: name)
            tracker.send(GAIDictionaryBuilder.createScreenView().build() as? [AnyHashable : Any])
        }
    }
    
    //MARK: - API Hit
    func getAppCategories(){
        
        if self.appCategories.count == 0{//show indicator only for the first time
            self.showActivityIndicator()
        }
        
        AppCategoryAPIController.shared.getAppCategories { [weak self] (response) in
            self?.hideActivityIndicator()
            self?.collectionView.refreshControl?.endRefreshing()
            switch response {
            case .success(let appCategories):
                //Show only those categories that have atleast 1 app accessible to the user.
//                print(appCategories)
                
                self?.appCategories = appCategories.filter{$0.appsCount != 0}
                
                if self?.appCategories.count == 0 && !(self?.isShowingFavourites)! {
                    self?.collectionView.noDataMessage = "There are no apps accessible to you."
                } else {
                    self?.collectionView.noDataMessage = nil
                }
                
            case .failure(let error):
                
                switch error {
                case .tokenRefresh:
                    self?.getAppCategories()
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
    
    func getFavourites(){
        
        if self.favourites.count == 0{
            self.showActivityIndicator()
        }
        
        AppListAPIController.shared.getFavouriteApps{ [weak self] (response) in
            self?.hideActivityIndicator()
            self?.collectionView.refreshControl?.endRefreshing()
            switch response {
            case .success(let apps):
                self?.favourites = apps
                self?.collectionView.reloadData()
                
                if self?.favourites.count == 0 && (self?.isShowingFavourites)!{
                    self?.collectionView.noDataMessage = NSLocalizedString("No Favourites yet.", comment: "No Favourites yet Description.") 
                } else {
                    self?.collectionView.noDataMessage = nil
                }
                
            case .failure(let error):
                switch error {
                case .tokenRefresh:
                    self?.getFavourites()
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
    
    //Collectionview datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isShowingFavourites ?   self.favourites.count : self.appCategories.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AppsCollectionViewCell.reuseIdentifier, for: indexPath) as! AppsCollectionViewCell
        
        if isShowingFavourites { //Favourites
            let favApp = self.favourites[indexPath.row]
            cell.lblAppName.text = favApp.name
            cell.lblAppName.textColor = UIColor.white
            cell.backgroundColor = UIColor.init(hex: "002D49")
            cell.lblFavouriteTypeTag.isHidden = true
            cell.lblAppCount.isHidden = true
            cell.lv_view.isHidden = true
        } else { //Apps categories
            let category = self.appCategories[indexPath.row] as AppCategory
            cell.lblAppName.text = category.name
            cell.lblAppName.textColor =  UIColor.init(hex: "002D49")
            cell.backgroundColor = UIColor.white
            cell.lblAppCount.text = category.appsCount.description
            cell.lblFavouriteTypeTag.isHidden = true
            cell.lblAppCount.isHidden = false
            cell.lv_view.isHidden = false
        }
        cell.imgAppIcon.contentMode = .center
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isShowingFavourites{
         
            let selectedApp = self.favourites[indexPath.row]
            if  selectedApp.name == "Disease Identification"{
                let DiseaseIdentificationVC = self.storyboard?.instantiateViewController(withIdentifier: "DiseaseIdentificationVC") as! DiseaseIdentificationVC
                DiseaseIdentificationVC.app = selectedApp
                self.navigationController?.pushViewController(DiseaseIdentificationVC, animated: true)
            }else{
                SettingsBundleHelper().configureSettingsBundle()
                let insightDetailContainerVC = self.storyboard?.instantiateViewController(withIdentifier: "InsightDetailContainerVC") as! InsightDetailContainerVC
                insightDetailContainerVC.app = selectedApp
                insightDetailContainerVC.delegate = self
                self.navigationController?.pushViewController(insightDetailContainerVC, animated: true)
                
            }
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "Favourites", label: "\(selectedApp.name)", value: nil).build() as? [AnyHashable : Any])
            }
            
            
        } else {
            
            let selectedCategory = self.appCategories[indexPath.item]
            let appListController = self.storyboard?.instantiateViewController(withIdentifier: "AppsListViewController") as! AppsListViewController
            appListController.categoryID = selectedCategory.id
            appListController.categoryName = selectedCategory.name
            self.navigationController?.pushViewController(appListController, animated: true)
            
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "App Category", label: "\(selectedCategory.name)", value: nil).build() as? [AnyHashable : Any])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - Local Function
    
    func getDashDetails(name:String,TenantID:String,selectedApp:App){
        
        self.showActivityIndicator()
        
        ConnectManager.shared.getConnectDetails(app_Id: name) {
            (appResponse) in
            self.hideActivityIndicator()
            switch appResponse {
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

extension AppsCategoryViewController:InsightDetailDelegate{
    
    func selectedMenu(menu: String) {
        delegate?.selectedMenu(menu: "Selected")
        switch menu {
        case "Favourites" :
            isShowingFavourites = true
        case "Apps" :
            delegate?.selectedMenu(menu: "Apps")
        case "Switch Corporate" :
            delegate?.selectedMenu(menu: "Switch Corporate")
        default:
            break
        }
        collectionView.reloadData()
        
    }
}

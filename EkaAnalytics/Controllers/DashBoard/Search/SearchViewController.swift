//
//  SearchViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 22/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

final class SearchViewController: GAITrackedViewController, UISearchBarDelegate, HUDRenderer {
    
    var searchBar:UISearchBar!
    
    @IBOutlet weak var tableView:UITableView!
    
    var searchResults = [SearchResult](){
        didSet{
            tableView.reloadData()
        }
    }
    
    var recentlySearched = [SearchResult]()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.search
        
        searchBar = UISearchBar()
        searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .white
        }
        //        tableView.tableFooterView = UIView()
        self.navigationItem.titleView = searchBar
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        setTitle("")
        
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        DispatchQueue.main.async {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //To fix an issue in ios11 where there is a blackbar under navigationbar on the next pushed screen, because, navigation bar increases size if there is search bar in it
        self.navigationController?.view.layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.recentlySearched = DataCacheManager.shared.getRecentSearchedItems()
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = Utility.appThemeColor
            appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
            self.navigationController!.navigationBar.standardAppearance = appearance;
            self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
        }
        if searchResults.count > 0 && recentlySearched.count > 0 && tableView.numberOfSections == 2{
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    //MARK: - @IBAction
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let searchText = searchBar.text
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "Search", label: "\(searchText ?? "")", value: nil).build() as? [AnyHashable : Any])
        }
        
        self.searchBar.resignFirstResponder()
        self.showActivityIndicator()
        
        let encodedSearchText = searchText!.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        SearchApiController.shared.searchWithText(encodedSearchText!) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let results):
                //                print(results)
                self.searchResults = results
                if self.searchResults.count == 0{
                    self.showAlert(message: NSLocalizedString("No results found", comment: ""))
                }
            case .failure(let error):
                self.showAlert(message:error.description)
                
            case .failureJson(_):
                break
            }
        }
        
    }
    
    
    //MARK: - Local Function
    func getDashDetails(name:String,TenantID:String,selectedApp:App){
        self.showActivityIndicator()
        
        ConnectManager.shared.getConnectDetails(app_Id: name) { (response) in
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

extension SearchViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchResults.count > 0 || recentlySearched.count > 0 {
            if searchResults.count > 0 && recentlySearched.count > 0 {
                return 2
            }else{
                return 1
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchResults.count > 0 || recentlySearched.count > 0 {
            if section == 1 {
                return NSLocalizedString("Recently visited", comment: "No Recently visited")
            }else if searchResults.count == 0 && recentlySearched.count > 0 {
                return NSLocalizedString("Recently visited", comment: "No Recently visited")
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchResults.count > 0 || recentlySearched.count > 0 {
            if section == 1 {
                return 40
            }else if searchResults.count == 0 && recentlySearched.count > 0 {
                return 40
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if searchResults.count == 0 && recentlySearched.count > 0 {
                return recentlySearched.count
            }else{
                return searchResults.count
            }
        } else {
            return recentlySearched.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier , for: indexPath) as! SearchResultTableViewCell
        
        
        var result:SearchResult
        
        if indexPath.section == 0 {
            if searchResults.count == 0 && recentlySearched.count > 0 {
                result = recentlySearched[indexPath.row]
            }else{
                result = searchResults[indexPath.row]
            }
        } else {
            result = recentlySearched[indexPath.row]
        }
        
        if result.entityType == "app" {
            cell.imgIcon.image = UIImage(named: (result as! App).categoryName)
            cell.lblTitle.text = (result as! App).name
            cell.lblEntityTypeFlag.text = "App"
        } else {
            cell.imgIcon.image = UIImage(named: (result as! Insight).chartType) ?? #imageLiteral(resourceName: "Default")
            cell.lblTitle.text = (result as! Insight).name
            cell.lblEntityTypeFlag.text = "Insight"
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchBar.resignFirstResponder()
        
        var result:SearchResult
        
        if indexPath.section == 0 {
            if searchResults.count == 0 && recentlySearched.count > 0 {
                result = recentlySearched[indexPath.row]
            }else{
                result = searchResults[indexPath.row]
                DataCacheManager.shared.saveRecentlySearched(results: result)
            }
        } else {
            result = recentlySearched[indexPath.row]
        }
        
        SettingsBundleHelper().configureSettingsBundle()
        
        if result.entityType == "app" {
            if  (result as! App).name == "Disease Identification"{
                let DiseaseIdentificationVC = self.storyboard?.instantiateViewController(withIdentifier: "DiseaseIdentificationVC") as! DiseaseIdentificationVC
                DiseaseIdentificationVC.app = (result as! App)
                self.navigationController?.pushViewController(DiseaseIdentificationVC, animated: true)
            }else{
                let insightDetailContainerVC = self.storyboard?.instantiateViewController(withIdentifier: "InsightDetailContainerVC") as! InsightDetailContainerVC
                insightDetailContainerVC.app = (result as! App)
                self.navigationController?.pushViewController(insightDetailContainerVC, animated: true)
            }
        } else {
            let insightVC = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "InsightDetailViewController") as! InsightDetailViewController
            insightVC.insight = (result as! Insight)
            insightVC.titleString = (result as! Insight).name
            self.navigationController?.pushViewController(insightVC, animated: true)
        }
    }
    
}

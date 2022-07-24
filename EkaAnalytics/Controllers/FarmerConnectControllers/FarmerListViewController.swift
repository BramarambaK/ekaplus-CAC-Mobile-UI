//
//  FarmerListViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 25/06/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol FarmerNameListDelegate : AnyObject {
    func didSelectFarmer(FarmerName:Farmer)
}

class FarmerListViewController: UIViewController,HUDRenderer {
    
    //MARK: - IBOutlet
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK: - Variable
    var searchMode = false
    var farmer = [Farmer](){
        didSet{
            if farmer.count == 0{
                let label = UILabel()
                label.text  = NSLocalizedString("No Farmer available.", comment: "")
                label.numberOfLines = 0
                label.textAlignment = .center
                tableView?.backgroundView = label
            } else {
                tableView?.backgroundView = nil
            }
        }
    }
    var filteredFarmer:[Farmer] = []
    var NameWithSections = [String]()
    weak var delegate:FarmerNameListDelegate?
    var groupedFarmers = [[Farmer]]()
    var selectedFarmer:Farmer?
    
    lazy var apiController:CustomerAPIController = {
        return CustomerAPIController()
    }()
    
    
    //MARK: - View
    
    override func viewDidLoad() {
        
        selectedFarmer = DataCacheManager.shared.getLastSelectedFarmer()
        
        self.groupedFarmers = [DataCacheManager.shared.getRecentSearchedFarmer()]
        
        getFarmerList()
        configureSearchBar()
        
        btnSearch.setImage(#imageLiteral(resourceName: "Search").withRenderingMode(.alwaysTemplate), for: .normal)
        btnSearch.tintColor = .black
        tableView?.tableFooterView = UIView()
        self.tableView?.contentInsetAdjustmentBehavior = .never
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView?.contentOffset = CGPoint(x: 0, y: 55)
    }
    
    
    //MARK: - IBAction
    
    @IBAction func dismiss(_ sender:UIButton?){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchIconTapped(_ sender: UIButton) {
        tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func configureSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search Bidder Name", comment: "")
        searchBar.returnKeyType = .done
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        //        searchBar.sizeToFit()
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self.view, action:#selector(UIView.endEditing(_:)) )
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        searchBar.inputAccessoryView = doneToolbar
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let border = UIView()
        border.frame = searchBar.frame
        border.frame.size.height = 1
        border.frame.origin.y = searchBar.frame.size.height - 1
        border.backgroundColor = .lightGray
        border.autoresizingMask = [.flexibleWidth]
        searchBar.addSubview(border)
    }
    
    //MARK: - Local Function
    
    private func getFarmerList(){
        self.showActivityIndicator()
        apiController.getListofFarmers { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let Farmerlist):
                self.farmer = Farmerlist
                //Grouping contacts based on the first letter of their firstName
                let groupedDict = Dictionary(grouping: self.farmer) { (individualFarmer) -> Character  in
                    return individualFarmer.name.first!
                }
                groupedDict.keys.sorted().forEach{ key in
                    self.groupedFarmers.append(groupedDict[key]!)
                }
                self.tableView?.reloadData()
                
            case .failure(let error):
                self.showAlert(message: error.description)
                
            case .failureJson(_):
                break
            }
        }
    }
    
}

extension FarmerListViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FarmerNameTableViewCell.reuseIdentifier, for: indexPath) as! FarmerNameTableViewCell
        
        var name:String
        
        if searchMode {
            if filteredFarmer[indexPath.row].externalUserId == "" {
                name = filteredFarmer[indexPath.row].name
            }else{
                name = filteredFarmer[indexPath.row].name + "(" + filteredFarmer[indexPath.row].externalUserId + ")"
            }
//            name = filteredFarmer[indexPath.row].name
            if selectedFarmer != nil {
                if filteredFarmer[indexPath.row].id == selectedFarmer?.id {
                    cell.limg_Selection.image = UIImage(named: "Selected filter")
                }else{
                    cell.limg_Selection.image = nil
                }
            }else{
                cell.limg_Selection.image = nil
                
            }
        } else {
            if groupedFarmers[indexPath.section][indexPath.row].externalUserId == "" {
               name = groupedFarmers[indexPath.section][indexPath.row].name
            }else{
                name = groupedFarmers[indexPath.section][indexPath.row].name + "(" + groupedFarmers[indexPath.section][indexPath.row].externalUserId + ")"
            }
            if selectedFarmer != nil {
                if groupedFarmers[indexPath.section][indexPath.row].id == selectedFarmer?.id {
                    cell.limg_Selection.image = UIImage(named: "Selected filter")
                }else{
                    cell.limg_Selection.image = nil
                }
            }else{
                cell.limg_Selection.image = nil
                
            }
        }
        
        cell.lblFarmerName.text = name
        
        //        //        print(insight.chartType)
        //        cell.insightImageView.image = UIImage(named: insight.chartType) ?? #imageLiteral(resourceName: "Default")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMode ? filteredFarmer.count : groupedFarmers[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchMode {
            DataCacheManager.shared.saveRecentlySearchedFarmer(results: filteredFarmer[indexPath.row])
            delegate?.didSelectFarmer(FarmerName:filteredFarmer[indexPath.row])
            
        } else {
            DataCacheManager.shared.saveRecentlySearchedFarmer(results: groupedFarmers[indexPath.section][indexPath.row])
            delegate?.didSelectFarmer(FarmerName:groupedFarmers[indexPath.section][indexPath.row])
        }
        self.dismiss(nil)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //        if searchMode {
        //            return nil
        //        } else {
        let label = UILabel()
        label.backgroundColor = UIColor.white
        if section == 0 {
            if searchMode {
                label.text = " " + NSLocalizedString("Search results", comment: "")
            }else{
                label.text = " " + NSLocalizedString("Recently searched", comment: "")
            }
            
        }else{
            
            if let firstNameChar = groupedFarmers[section].first?.name.first {
                label.text = "  " + "\(firstNameChar)".capitalized
            }
        }
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.lightGray.cgColor
        return label
        //        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchMode ? 1 : groupedFarmers.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    
}

extension FarmerListViewController : UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchMode = true
        
        if searchText == "" {
            searchMode = false
            self.tableView?.reloadData()
            return
        }
        
        self.filteredFarmer = self.farmer.filter({$0.name.lowercased().contains(searchText.lowercased())})
        
        self.tableView?.reloadData()
    }
    
}

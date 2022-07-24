//
//  MainFilterViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 16/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol MainFilterScreenDelegate:AnyObject{
    func selectedFilters(_ filter:[JSON])
}

class MainFilterViewController: GAITrackedViewController, HUDRenderer, UITableViewDataSource, UITableViewDelegate, SubFilterScreenDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var moreBarBtn: UIBarButtonItem!
    
    
    //MARK: - Variable
    
    weak var delegate:MainFilterScreenDelegate?
    
    var filterOptions = [JSON]() //Fed from previous VC
    
    var basicFilterValues = [String:[String]]() //Fed from previous VC
    
    var preDefinedFilters = [JSON]() //Fed from previous VC
    
    var sections = [NSLocalizedString("Action Filters", comment: ""), NSLocalizedString("Predefined Filters", comment: "")]
    
    
    
    var filtersSelected = [String:JSON?]() //[columnId:[filters]] - used as a temporary cache.
    
    
    var isFarmerConnectFilter = false //Flag to differentiate Farmer connect or normal filters. In farmer connect we have don't have Top and Bottom number operators in Advanced filters. We use this flag to decide.
    
    var isMyBidSelected = false //Flag to check MyBid has been selected or not.
    
    var cacheIndex:Int = 1 // this is used to store multiple caches. By default we store one cache at 0 index. If required we need to pass the cache Index at which we need to store cache. This is used in Farmer Connect Filter functionality where we need to cache two set of sort values.
    
    lazy var apiController:FilterAPIController = {
        return FilterAPIController()
    }()
    
    var dataViewID:String?
    
    var dataViewJson:JSON?
    
    var lv_enableDrillDown:UIView!
    
    var drillButton:Bool = false
    
    var DrillDownStatus: Bool = false
    
    var ls_FarmerConnectMode:String?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.listOfFilters
        
        tableView.tableFooterView = UIView()
        setTitle(NSLocalizedString("Filters", comment: ""), color: .black, backbuttonTint: Utility.appThemeColor)
        
        //Load if any filters are cached
        if cacheIndex < DataCacheManager.shared.filterOptions.count, let selectedFilters = DataCacheManager.shared.filterOptions[cacheIndex] {
            self.filtersSelected = selectedFilters
        }
        
        if dataViewID != nil {
            getDataViewJson()
            moreBarBtn.isEnabled = true
            moreBarBtn.image = UIImage(named: "meat_balls")
        }else{
            moreBarBtn.isEnabled = false
            moreBarBtn.image = nil
        }
        
        tableView.reloadData()
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func removeAllTapped(_ sender: UIButton?) {
        self.showAlert(title: NSLocalizedString("Confirmation", comment: "Confirmation"), message: NSLocalizedString("Do you want to Remove All filter?", comment: "Confirmation message"), okButtonText: NSLocalizedString("Ok", comment: "accept"), cancelButtonText: NSLocalizedString("Cancel", comment: "cancel")) { (accepted) in
            if accepted{
                self.filtersSelected.removeAll()
                let selectedFiltersArray = [JSON]()
                self.delegate?.selectedFilters(selectedFiltersArray)
                
                //Update Cache
                if self.cacheIndex < DataCacheManager.shared.filterOptions.count {
                    DataCacheManager.shared.filterOptions[self.cacheIndex] = self.filtersSelected
                }
                
                //Check if remove all is tapped, if yes, update cache
                if self.filtersSelected.count == 0 {
                    DataCacheManager.shared.clearFilterCache(at: self.cacheIndex)
                }
                
                if self.isFarmerConnectFilter == true {
                    if self.ls_FarmerConnectMode?.uppercased() == "BID" {
                        DataCacheManager.shared.saveFarmerConnectFilter(offerType: "BID")
                    }else{
                        DataCacheManager.shared.saveFarmerConnectFilter(offerType: "OFFER")
                    }
                }
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func applyTapped(_ sender: UIButton) {
        var selectedFiltersArray = [JSON]()
        for (_, filterValue) in self.filtersSelected {
            if let filterValue = filterValue {
                selectedFiltersArray.append(filterValue)
            }
        }
        delegate?.selectedFilters(selectedFiltersArray)
        
        //Update Cache
        if cacheIndex < DataCacheManager.shared.filterOptions.count {
            DataCacheManager.shared.filterOptions[cacheIndex] = filtersSelected
        }
        
        //Check if remove all is tapped, if yes, update cache
        if filtersSelected.count == 0 {
            DataCacheManager.shared.clearFilterCache(at: cacheIndex)
        }
        
        if isFarmerConnectFilter == true {
            if self.ls_FarmerConnectMode?.uppercased() == "BID" {
                DataCacheManager.shared.saveFarmerConnectFilter(offerType: "BID")
            }else{
                DataCacheManager.shared.saveFarmerConnectFilter(offerType: "OFFER")
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moreTapped(_ sender: UIBarButtonItem) {
        var ls_drillDownValue:String?
        
        if   DrillDownStatus  == true{
            ls_drillDownValue = NSLocalizedString("Disable Cascading Filter", comment: "")
        }else{
            ls_drillDownValue = NSLocalizedString("Enable Cascading Filter", comment: "")
        }
        
        if drillButton == false {
            drillButton = true
            let MorebuttonTap = UITapGestureRecognizer(target: self, action: #selector(self.buttonTapped(_:)))
            
            let tappedOutside = UITapGestureRecognizer(target: self, action: #selector(self.DismissViewTap(_:)))
            
            lv_enableDrillDown = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            lv_enableDrillDown.backgroundColor = UIColor.clear
            lv_enableDrillDown.addGestureRecognizer(tappedOutside)
            
            self.view.addSubview(lv_enableDrillDown)
            
            let enableDrillDown = UILabel(frame: CGRect(x: self.view.frame.width-210, y: 0, width: 210, height: 50))
            enableDrillDown.textAlignment = .center
            enableDrillDown.text = ls_drillDownValue
            enableDrillDown.backgroundColor = UIColor.white
            enableDrillDown.layer.borderColor = UIColor.darkGray.cgColor
            enableDrillDown.layer.borderWidth = 1.0
            enableDrillDown.addGestureRecognizer(MorebuttonTap)
            enableDrillDown.isUserInteractionEnabled = true
            lv_enableDrillDown.addSubview(enableDrillDown)
            
        }else{
            self.lv_enableDrillDown.removeFromSuperview()
            drillButton = false
        }
    }
    
    
    //SubFilter Delegate
    func selectedFiltersForColumn(columnId: String, filters: JSON?) {
        self.filtersSelected[columnId] = filters
        if filters == nil{
             self.filtersSelected.remove(at: (self.filtersSelected.index(forKey: columnId)!))
        }
        //Update temporary cache
        tableView.reloadData()
    }
    
    //MARK: - TableView datasource and delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return  preDefinedFilters.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return filterOptions.count
        } else {
            return preDefinedFilters.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MainFilterTableViewCell.identifier, for: indexPath) as! MainFilterTableViewCell
        cell.backgroundColor = Utility.chartListSeperatorColor
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        switch indexPath.section {
        case 0 :
            let filterOption = filterOptions[indexPath.row]["columnName"].stringValue
            cell.lblTitle.text = filterOption
            
            //If a column has some filters selected, we show a checkmark as an indicator
            let columnID = filterOptions[indexPath.row]["columnId"].stringValue
            
            if let columnFilter = filtersSelected[columnID], columnFilter != nil {
                cell.imgCheckMark.image = #imageLiteral(resourceName: "Selected filter")
            } else {
                cell.imgCheckMark.image = nil
            }
            
        case 1:
            let preDefinedFilter = preDefinedFilters[indexPath.row]["columnName"].stringValue
            cell.lblTitle.text = preDefinedFilter
            cell.imgCheckMark.image = nil
            
        default:
            assert(true, "Unexpected indexpath")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            let columnId = filterOptions[indexPath.row]["columnId"].stringValue
            let subFilterVC = self.storyboard?.instantiateViewController(withIdentifier: "SubFilterViewController") as! SubFilterViewController
            
            //Pass basic and advanced filter values
            subFilterVC.advancedFilter = filterOptions[indexPath.row]
            
            if !isBasicFilterAvaliable(columnDetails: filterOptions[indexPath.row].dictionaryValue as NSDictionary) {
                subFilterVC.basicFilters = []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
                    subFilterVC.toggleNoDataMessage()
                }
            }else if self.isFarmerConnectFilter == false {
                var tempfiltersSelected = [String:JSON?]()
                
                if DrillDownStatus == true{
                    tempfiltersSelected = filtersSelected
                }else{
                    tempfiltersSelected = [:]
                }
                
                subFilterVC.showActivityIndicator()
                
                apiController.getFilterColumnvalue(dataViewJson: dataViewJson!, columnId: columnId, Selectedfilter: tempfiltersSelected) { (response) in
                    
                    switch response {
                    case .success(let resultData):
                        subFilterVC.basicFilters = resultData["basicFilter"] as! [String]
                        subFilterVC.toggleNoDataMessage()
                        subFilterVC.hideActivityIndicator()
                        break
                        
                    case .failure(let error):
                        subFilterVC.basicFilters = []
                        subFilterVC.toggleNoDataMessage()
                        subFilterVC.hideActivityIndicator()
                        print(error.description)
                        
                    case .failureJson(_):
                        break
                    }
                    
                }
            }
            
            
            
            
            //Check if any basic filter cache exists for this column and pass it
            if let filterValue = filtersSelected[columnId], let unwrappedFilterValue = filterValue, unwrappedFilterValue["type"].stringValue == "basic"{
                subFilterVC.selectedBasicFilters = unwrappedFilterValue["value"].arrayValue.map{$0.stringValue}
            }
            
            //Check if any advanced filter cache exists for this column and pass it
            if let advancedFilter = filtersSelected[columnId], let unwrappedFilterValue = advancedFilter, unwrappedFilterValue["type"].stringValue == "advanced"{
                subFilterVC.selectedAdvancedFilters = unwrappedFilterValue
            }
            
            
            //Pass Farmer connect details
            subFilterVC.isFarmerConnectFilter = self.isFarmerConnectFilter
            subFilterVC.isMyBidSelected = self.isMyBidSelected
            subFilterVC.farmerConnectFilterColumnId = filterOptions[indexPath.row]["columnId"].stringValue
            let columnType = filterOptions[indexPath.row]["columnType"].intValue
            subFilterVC.farmerConnectColumnType = ColumnFormatType(rawValue: columnType)!
            
            subFilterVC.delegate = self
            
            self.navigationController?.pushViewController(subFilterVC, animated: true)
        } else {
            let subPredefinedFilterVC = self.storyboard?.instantiateViewController(withIdentifier: "SubPreDefinedFilterViewController") as! SubPreDefinedFilterViewController
            
            if let array = preDefinedFilters[indexPath.row]["value"].array{
                subPredefinedFilterVC.dataSource = array.map{$0.stringValue}
            } else if let stringValue = preDefinedFilters[indexPath.row]["value"].string{
                subPredefinedFilterVC.dataSource = [stringValue]
            }
            
            subPredefinedFilterVC.filterTitle = preDefinedFilters[indexPath.row]["columnName"].stringValue
            self.navigationController?.pushViewController(subPredefinedFilterVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = EdgeInsetLabel()
        header.leftTextInset = 20
        header.topTextInset = 15
        header.text = sections[section]
        header.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        header.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30)
        return  header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    //MARK: - Local Function
    
    private func getDataViewJson(){
        DataViewApiConroller.shared.getDataViewDetails(dataViewID!) { (response) in
            guard case let .success(responseJson) = response  else {
                print("Failed in dataview api")
                return
            }
            self.dataViewJson = responseJson
        }
    }
    
    private func isBasicFilterAvaliable(columnDetails:NSDictionary) -> Bool {
        let columnType:String = "\(columnDetails["columnType"] ?? "")"
        let configZone:String? = "\(columnDetails["configZone"] ?? "")"
        
        if columnType == "3" || configZone! == "values" || configZone! == "values-line" || configZone! == "values-line-right" || configZone! == "values-column" || configZone! == "values-area" || configZone! == "values-card" || (configZone == nil && columnType == "2" || columnType == "-1" ) || (columnType == "2" && configZone == "columns-table") || (configZone == "xaxis" || configZone == "yaxis" || configZone == "size") {
            return false
        }else{
            return true
        }
        
    }
    
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        
        if DrillDownStatus == false{
            DrillDownStatus = true
        }else{
            DrillDownStatus = false
        }
        
        self.lv_enableDrillDown.removeFromSuperview()
        drillButton = false
    }
    
    @objc func DismissViewTap(_ sender: UITapGestureRecognizer) {
        self.lv_enableDrillDown.removeFromSuperview()
        DrillDownStatus = false
    }
    
    
}

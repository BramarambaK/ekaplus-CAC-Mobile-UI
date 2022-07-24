//
//  SubFilterViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//



import UIKit

protocol SubFilterScreenDelegate:AnyObject {
    func selectedFiltersForColumn(columnId:String, filters:JSON?)
}

class SubFilterViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate,KeyboardObserver, HUDRenderer {
    
    //MARK: - IBOutlet

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var btnReset: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerViewForFilter: UIView!
    
    //MARK: - Variable
    
    lazy var advancedFilterViewController:AdvancedFilterViewController = {
        let vc = self.children.first as! AdvancedFilterViewController
        return vc
    }()
    
    var basicFilters = [String]() //Data source for table view. In case of normal charts, this is fed from previous VC, but for farmer connect, we hit an api in viewdidLoad and populate it
    
    var advancedFilter : JSON! //Data source for advanced filter
    
    
    var selectedAdvancedFilters:JSON! //Temporary cache for advanced filters-Fed from previous vc
    var selectedBasicFilters = [String]()//Temporary cache for basic filters - Fed from previous vc
    
    weak var delegate:SubFilterScreenDelegate?
    
    var container: UIView{
        return self.view
    }
    
    var isFarmerConnectFilter = false
    var farmerConnectFilterColumnId:String!
    var farmerConnectColumnType:ColumnFormatType!
    var selectedFarmer:Farmer?
    var farmerId:String?
    var isMyBidSelected = false
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.basicFilters
        
        self.registerForKeyboardNotifications(shouldRegister: true)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        //Check if any temporary cache exists for either basic or advanced filters and load if any
        if selectedBasicFilters.count > 0 {
            
            segmentControl.selectedSegmentIndex = 0
            segmentControlSelectionDidChange(segmentControl)
            tableView.reloadData() //reloading tableview takes the  selectedBasicFilters passed from previous vc if any.
            
        } else if selectedAdvancedFilters != nil {
            segmentControl.selectedSegmentIndex = 1
            segmentControlSelectionDidChange(segmentControl)//We just need to change the segment control to show advanced filters. The actual cache values is passed in prepare for segue.
        }
        

        self.navigationItem.leftItemsSupplementBackButton = true
        setTitle(advancedFilter["columnName"].stringValue, color: .black, backbuttonTint: Utility.appThemeColor)
            btnDone.layer.borderColor = Utility.appThemeColor.cgColor
            btnDone.layer.borderWidth = 1
            btnDone.layer.cornerRadius = 2
            btnDone.clipsToBounds = true
        
        if isFarmerConnectFilter && farmerConnectColumnType == .strings {
            //Hit the api to get basic filter values in case of farmer connect.
           self.showActivityIndicator()
            
            selectedFarmer = DataCacheManager.shared.getLastSelectedFarmer()
            
            
            if isMyBidSelected == true {
                if selectedFarmer != nil {
                    farmerId = selectedFarmer?.id
                }
                BidListApiController.shared.getMyBidFiltersForColumn(farmerId: farmerId, columnName: farmerConnectFilterColumnId,  { (response) in
                    
                    self.hideActivityIndicator()
                    
                    switch response {
                    case .success(let filters):
                        self.basicFilters = filters
                    case .failure(_):
                        break
                    case .failureJson(_):
                        break
                    }
                    
                    self.toggleNoDataMessage()
                })
            }
            else{
                BidListApiController.shared.getFiltersForColumn(columnName:farmerConnectFilterColumnId , { (response) in
                    
                    self.hideActivityIndicator()
                    
                    switch response {
                    case .success(let filters):
                        self.basicFilters = filters
                    case .failure(_):
                        break
                    case .failureJson(_):
                        break
                    }
                    
                    self.toggleNoDataMessage()
                })
            }
            
            
            
        } else if isFarmerConnectFilter && farmerConnectColumnType != .strings  {
            //Else, we get filter values from previous screen only
            toggleNoDataMessage()
        }
        
        
        
    }
    
    deinit {
        self.registerForKeyboardNotifications(shouldRegister: false)
        print("deinit of \(String(describing:self))")
    }
    
    func toggleNoDataMessage(){
        if basicFilters.count == 0{
            tableView.noDataMessage = NSLocalizedString("Basic Filters are not available for this measure", comment: "")
        } else {
            tableView.noDataMessage = nil
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AdvancedFilterSegue"{
            
            //pass advanced filter source data to child vc
            let destinationVC = segue.destination as! AdvancedFilterViewController
            destinationVC.isFarmerConnectFilter = self.isFarmerConnectFilter
            destinationVC.filterSourceData = advancedFilter
            destinationVC.selectedFilter = self.selectedAdvancedFilters
        }
    }
    

    @IBAction func segmentControlSelectionDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {//Basic
            containerViewForFilter.isHidden = true
            tableView.isHidden = false
        } else { //Advanced
            containerViewForFilter.isHidden = false
            tableView.isHidden = true
        }
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        
        let columnId = advancedFilter["columnId"].stringValue
        
        if segmentControl.selectedSegmentIndex == 0 { //Basic
            
            if selectedBasicFilters.count > 0 {
                //initial 3 fields in selected filter should contain the same fields as of filterSourceData
                var selectedFilter = advancedFilter!
                selectedFilter["type"].stringValue = "basic"
                selectedFilter["operator"].stringValue = StringOperators.isIn.rawValue
                selectedFilter["value"].arrayObject = selectedBasicFilters
                if advancedFilter["columnType"].stringValue == "3"{
                    selectedFilter["dateFormat"].stringValue = "E MMM dd HH:mm:ss Z yyyy"
                }
                delegate?.selectedFiltersForColumn(columnId: columnId, filters: selectedFilter)
            } else {
                delegate?.selectedFiltersForColumn(columnId: columnId, filters: nil)
            }
        } else { //Advanced
            
            //Get advanced filters from AdvancedFilterViewController
            if let selectedAdvancedFilters = advancedFilterViewController.getSelectedFilters(){
                
                delegate?.selectedFiltersForColumn(columnId: columnId, filters: selectedAdvancedFilters)
            } else {
                delegate?.selectedFiltersForColumn(columnId: columnId, filters: nil)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResetTapped(_ sender: UIButton) {
        if segmentControl.selectedSegmentIndex == 0 {//Basic
            selectedBasicFilters.removeAll()
            tableView.reloadData()
        } else {
            advancedFilterViewController.clearAllFilters()
        }
    }
    
    
    //MARK: - Tableview datasource and delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basicFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicFilterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "BasicFilterCell")
        let basicFilter = basicFilters[indexPath.row]
        
        if selectedBasicFilters.contains(basicFilter){
            cell.imageView?.image = #imageLiteral(resourceName: "checked")
        } else {
            cell.imageView?.image = #imageLiteral(resourceName: "unchecked")
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = basicFilter
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let basicFilter = basicFilters[indexPath.row]
        if selectedBasicFilters.contains(basicFilter), let index = selectedBasicFilters.firstIndex(of: basicFilter){
            selectedBasicFilters.remove(at: index)
        } else {
            selectedBasicFilters.append(basicFilter)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

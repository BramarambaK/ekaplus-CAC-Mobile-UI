 //
 //  BidsListViewController.swift
 //  EkaAnalytics
 //
 //  Created by Nithin on 19/03/18.
 //  Copyright © 2018 Eka Software Solutions. All rights reserved.
 //
 
 import UIKit
 
 enum SegmentControlOptions:Int{
    case publishedPrices
    case bid
 }
 
 enum BidScreenOptions:String{
    case InProgress = "In-Progress"
    case Accept = "Accepted"
    case Reject = "Rejected"
    
    
    
    func BidScreenMessage () -> String {
        switch self {
        case .InProgress:
            return NSLocalizedString("No In-Progress bids.", comment: "No MyBids message")
        case .Accept:
            return NSLocalizedString("No accepted/cancelled bids.", comment: "No MyBids message")
        case .Reject:
            return NSLocalizedString("No rejected bids.", comment: "No MyBids message")
        }
    }
 }
 
 class BidsListViewController: GAITrackedViewController, HUDRenderer, SortScreenDelegate, MainFilterScreenDelegate,FarmerNameListDelegate {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var btnSort: UIBarButtonItem!
    
    @IBOutlet weak var btnFilter: UIBarButtonItem!
    
    @IBOutlet weak var lvFarmerDetails: UIView!
    
    @IBOutlet weak var lblFarmerName: UILabel!
    
    @IBOutlet weak var lbtn_select: UIButton!
    
    @IBOutlet weak var lvFilterView: UIView!
    
    @IBOutlet weak var lbtn_inprogress: UIButton!
    
    @IBOutlet weak var lbtn_Accepted: UIButton!
    
    @IBOutlet weak var lbtn_Cancelled: UIButton!
    
    @IBOutlet weak var newOfferFAB: UIButton!
    
    //MARK: - Variable
    
    var currentSelection : SegmentControlOptions = .publishedPrices
    
    var selectedFarmer:Farmer?
    
    var selectedTabFilter:String = "In-Progress"
    
    var app:App!
    
    let defaultPageSize = 8
    
    var myBids = [MyBid](){
        didSet{
            if myBids.count == 0 && currentSelection == .bid && selectedFarmer != nil{
                tableView.noDataMessage = BidScreenOptions(rawValue: selectedTabFilter)?.BidScreenMessage()
            }else {
                tableView.noDataMessage = nil
            }
            tableView.refreshControl?.endRefreshing()
            
            //The following is to deal with an issue, where cell height is not calculated correctly for the first time.
            tableView.reloadData()
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            tableView.reloadData()
        }
    }
    
    var publishedBids = [PublishedBid](){
        didSet{
            if publishedBids.count == 0 && currentSelection == .publishedPrices{
                tableView.noDataMessage = NSLocalizedString("NoPrices", comment: "No published prices message")
            } else {
                tableView.noDataMessage = nil
            }
            tableView.refreshControl?.endRefreshing()
            
            //The following is to deal with an issue, where cell height is not calculated correctly for the first time.
            tableView.reloadData()
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
            tableView.reloadData()
        }
    }
    
    var myBidCurrentpage = 0
    var publishedPriceCurrentpage = 0
    
    var myBidsSort : [String:Any]? {
        set{ DataCacheManager.shared.myBidsSort = newValue }
        get{ return DataCacheManager.shared.myBidsSort }
    }
    var myBidsFilter : [JSON]? {
        set{ DataCacheManager.shared.myBidsFilter = newValue ?? []}
        get{
            return DataCacheManager.shared.myBidsFilter
            
        }
        
    }
    
    var publishedBidsSort : [String:Any]? {
        set { DataCacheManager.shared.publishedBidsSort = newValue }
        get { return DataCacheManager.shared.publishedBidsSort }
    }
    var publishedBidsFilter : [JSON]? {
        set { DataCacheManager.shared.publishedBidsFilter = newValue ?? []}
        get {
            return DataCacheManager.shared.publishedBidsFilter
        }
    }
    
    
    lazy var numberFormatter:NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMM-YYYY"
        return df
    }()
    
    var ls_FarmerConnectMode:String?
    
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.publishedPricesAndBids
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //Set images which supports localization
        
        btnFilter.image = UIImage.init(named: NSLocalizedString("Filter", comment: ""))
        
        btnSort.image = UIImage.init(named: NSLocalizedString("Sort", comment: ""))
        
        self.selectedFarmer = DataCacheManager.shared.getLastSelectedFarmer()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPage), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        //Hide Note message-Because initially we land on published bid tab by default.
        lvFilterView.isHidden = true
        lvFarmerDetails.isHidden = true
        
        ResetSelection()
        selectedTabFilter = "In-Progress"
        lbtn_inprogress.isSelected = true
        lbtn_inprogress.backgroundColor = UIColor.white
        lbtn_inprogress.borderColor = Utility.appThemeColor
        
        setFilterAndSortSelectionState(currentSelection)
        
        //Right Barbutton Item.
        if ls_FarmerConnectMode == "OFFER" {
            
            //Bid Floating Button
            self.newOfferFAB.layer.shadowColor = UIColor.black.cgColor
            self.newOfferFAB.layer.shadowRadius = 2
            self.newOfferFAB.layer.shadowOpacity = 0.7
            self.newOfferFAB.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
            newOfferFAB.isHidden = false
        }else{
            newOfferFAB.isHidden = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(app.categoryName)
        refreshPage()
        
        if #available(iOS 11, *){
            setTitle(NSLocalizedString(app.name, comment: "Farmer connect") + " (\(NSLocalizedString(ls_FarmerConnectMode!, comment: "Offer")))", color: .white, backbuttonTint: Utility.appThemeColor)
        } else {
            setTitle(NSLocalizedString(app.name, comment: "Farmer connect") + " (\(NSLocalizedString(ls_FarmerConnectMode!, comment: "Offer")))")
        }
        
        
        
    }
    
    
    
    @objc func refreshPage(){
        if currentSelection == .publishedPrices{
            getPublishedBids(publishedBidsSort, filter: publishedBidsFilter, pageNo: 0, pageSize: defaultPageSize)
        }else{
            self.hideActivityIndicator()
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.agentPermission.rawValue){
                if selectedFarmer != nil {
                    getMyBids(farmerId: selectedFarmer?.id, sort:myBidsSort, filter: myBidsFilter, pageNo: 0, pageSize: defaultPageSize)
                }else{
                    tableView.noDataMessage = BidScreenOptions(rawValue: selectedTabFilter)?.BidScreenMessage()
                }
            }else{
                getMyBids(farmerId: selectedFarmer?.id, sort:myBidsSort, filter: myBidsFilter, pageNo: 0, pageSize: defaultPageSize)
            }
        }
        
        //            currentSelection == .publishedPrices ? getPublishedBids(publishedBidsSort, filter: publishedBidsFilter, pageNo: 0, pageSize: defaultPageSize) : getMyBids(farmerId: UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedFarmer.rawValue) ?? "", sort:myBidsSort, filter: myBidsFilter, pageNo: 0, pageSize: defaultPageSize)
    }
    
    
    //MARK: - API Hit
    func getMyBids(farmerId:String?, sort:[String:Any]? = nil , filter:[JSON]? = nil, pageNo:Int = 0, pageSize:Int){
        
        var filterOptions:[JSON] = filter ?? []
        var ls_apiType:String = ""
        
        if ls_FarmerConnectMode == "OFFER" {
            filterOptions.append( JSON(["columnName": "User Name", "operator" : "in","columnType" : 1,"type" : "basic","columnId" : "username","value":["\(UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!)"]]))
            ls_apiType = "offeror"
        }else {
            filterOptions.append( JSON(["columnName": "User Name", "operator" : "nin","columnType" : 1,"type" : "basic","columnId" : "username","value":["\(UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!)"]]))
            ls_apiType = "farmer"
        }
        
        
        if myBids.count == 0{ //Show activity indicator only when the first page loads
            self.showActivityIndicator()
        }
        BidListApiController.shared.getMyBids(farmerId: farmerId, apiType: ls_apiType, sort: sort, filter: filterOptions, pageNo: pageNo, pageSize: pageSize,tapFilter:selectedTabFilter) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let myBids):
                if pageNo == 0 {
                    self.myBidCurrentpage = 0
                    self.myBids = myBids
                } else { //result for subsequent pages
                    self.myBids.append(contentsOf: myBids)
                    self.tableView.tableFooterView = nil
                }
                
            case .failure(let error):
                switch error {
                case .tokenRefresh:
                    self.refreshPage()
                case .tokenExpired:
                    let message = error.description
                    self.showAlert(title: "Error", message: message, okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                default:
                    self.showAlert(message: error.description)
                }
                
            case .failureJson(_):
                break
            }
        }
    }
    
    func getPublishedBids(_ sort:[String:Any]? = nil , filter:[JSON]? = nil, pageNo:Int = 0, pageSize:Int){
        if self.publishedBids.count == 0{
            self.showActivityIndicator()
        }
        
        var filterOptions:[JSON] = filter ?? []
        
        if ls_FarmerConnectMode == "OFFER" {
            filterOptions.append( JSON(["columnName": "User Name", "operator" : "in","columnType" : 1,"type" : "basic","columnId" : "username","value":["\(UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!)"]]))
        }else {
            filterOptions.append( JSON(["columnName": "User Name", "operator" : "nin","columnType" : 1,"type" : "basic","columnId" : "username","value":["\(UserDefaults.standard.string(forKey: UserDefaultsKeys.user.rawValue)!)"]]))
        }
        
        BidListApiController.shared.getPublishedBids(sort: sort, filter: filterOptions, pageNo: pageNo, pageSize: pageSize) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let publishedBids):
                if pageNo == 0{
                    self.publishedPriceCurrentpage = 0
                    self.publishedBids = publishedBids
                } else {//result for subsequent pages
                    self.publishedBids.append(contentsOf: publishedBids)
                    self.tableView.tableFooterView = nil
                }
                
            case .failure(let error):
                switch error {
                case .tokenRefresh:
                    self.refreshPage()
                case .tokenExpired:
                    let message = error.description
                    self.showAlert(title: "Error", message: message, okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                default:
                    self.showAlert(message: error.description)
                }
            case .failureJson(_):
                break
            }
        }
    }
    
    
    
    //MARK: - IBActions
    @IBAction func segmentControlDidChangeSelection(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        currentSelection = SegmentControlOptions(rawValue: selectedIndex)!
        tableView.reloadData()
        
        if currentSelection == .bid{
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "View Bids Status", label: "FarmerConnect", value: nil).build() as? [AnyHashable : Any])
            }
            
            self.lvFilterView.isHidden = false
            
            //Show Farmer selection option for the user has agent permission.
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.agentPermission.rawValue){
                self.lvFarmerDetails.isHidden = false
                
                //Get the selected farmer from Disk
                if selectedFarmer != nil {
                    didSelectFarmer(FarmerName:selectedFarmer!)
                }
                else{
                    lblFarmerName.text = NSLocalizedString("No Bidder Selected.", comment: "")
                    lbtn_select.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
                    tableView.noDataMessage = BidScreenOptions(rawValue: selectedTabFilter)?.BidScreenMessage()
                }
                
            }else{
                //If the user is a farmer then the API will be hit
//                if UserDefaults.standard.integer(forKey: UserDefaultsKeys.userType.rawValue) == 3 {
                    //Hit api
                    getMyBids(farmerId: selectedFarmer?.id, sort:myBidsSort, filter: myBidsFilter, pageNo: 0, pageSize: defaultPageSize)
//                }
            }
            
            
            
        } else {
            //Hide Note message
            self.lvFilterView.isHidden = true
            self.lvFarmerDetails.isHidden = true
            
            //Hit Api
            getPublishedBids(publishedBidsSort, filter: publishedBidsFilter, pageNo: 0, pageSize: defaultPageSize)
        }
        
        setFilterAndSortSelectionState(currentSelection)
        
    }
    
    func setFilterAndSortSelectionState(_ forMenu:SegmentControlOptions) {
        if forMenu == .bid {
            //Check any filters and highlight filter button accordingly
            if myBidsFilter!.count > 0 {
                btnFilter.tintColor = Utility.appThemeColor
            } else {
                btnFilter.tintColor = .black
            }
            
            //Check if any sorting applied
            if myBidsSort != nil {
                btnSort.tintColor = Utility.appThemeColor
            } else {
                btnSort.tintColor = .black
            }
        } else {
            //Check any filters and highlight filter button accordingly
            if publishedBidsFilter!.count > 0 {
                btnFilter.tintColor = Utility.appThemeColor
            } else {
                btnFilter.tintColor = .black
            }
            
            //Check if any sorting applied
            if publishedBidsSort != nil {
                btnSort.tintColor = Utility.appThemeColor
            } else {
                btnSort.tintColor = .black
            }
        }
    }
    
    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.agentPermission.rawValue){
            guard selectedFarmer != nil else {
                showAlert(message: NSLocalizedString("Please select a bidder.", comment: "No Farmer selected"))
                return
            }
        }
        
        //Sort page expects sort options in the below format
        var sortOptions = [
            JSON(["columnName":NSLocalizedString("Product", comment: "")]),
            JSON(["columnName":NSLocalizedString("Quality", comment: "")]),
            JSON(["columnName":NSLocalizedString("Incoterm", comment: "")]),
            JSON(["columnName":NSLocalizedString("Crop Year", comment: "")]),
            JSON(["columnName":NSLocalizedString("Location", comment: "")]),
            JSON(["columnName":NSLocalizedString("Published Price", comment: "")]),
            JSON(["columnName":NSLocalizedString("User Name", comment: "")])
        ]
        
        if currentSelection == .bid{
            sortOptions.append(JSON(["columnName":"Quantity"]))
        }
        
        
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) != "basic"{ sortOptions.append(JSON(["columnName":"Payment Terms"]))
            sortOptions.append(JSON(["columnName":"Packing Size"]))
            sortOptions.append(JSON(["columnName":"Packing Type"]))
        }
        
        
        let sortVC = self.parent?.storyboard?.instantiateViewController(withIdentifier: "SortViewController") as! SortViewController
        sortVC.sortOptions = sortOptions
        sortVC.delegate = self
        sortVC.cacheIndex = currentSelection == .bid ? 1 : 0
        sortVC.modalPresentationStyle = .overCurrentContext
        self.present(sortVC, animated: true, completion: nil)
    }
    
    
    @IBAction func filterTapped(_ sender: UIBarButtonItem) {
        
        if currentSelection == .bid {
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.agentPermission.rawValue){
                guard selectedFarmer != nil else {
                    showAlert(message: NSLocalizedString("Please select a bidder.", comment: "No Farmer selected"))
                    return
                }
            }
        }
        
        var filterOptions = [
            JSON(["columnId": "product", "columnName":NSLocalizedString("Product", comment: ""), "columnType":1]),
            JSON(["columnId": "quality", "columnName":NSLocalizedString("Quality", comment: ""), "columnType":1]),
            JSON(["columnId": "incoTerm", "columnName":NSLocalizedString("Incoterm", comment: ""), "columnType":1]),
            JSON(["columnId": "cropYear", "columnName":NSLocalizedString("Crop Year", comment: ""), "columnType":1]),
            
            JSON(["columnId": "location", "columnName":NSLocalizedString("Location", comment: ""), "columnType":1]),
            
            JSON(["columnId": "publishedPrice", "columnName":NSLocalizedString("Published Price", comment: ""), "columnType":2])
        ]
        
        if ls_FarmerConnectMode!.uppercased() == "BID" {
            filterOptions.append(JSON(["columnId": "username", "columnName":NSLocalizedString("User Name", comment: ""), "columnType":1]))
        }
        
        
        if currentSelection == .bid{
            filterOptions.append(JSON(["columnId": "quantity", "columnName":NSLocalizedString("Quantity", comment: ""), "columnType":2]))
        }
        
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) != "basic"{
            filterOptions.append(JSON(["columnId": "paymentTerms", "columnName":NSLocalizedString("Payment Terms", comment: ""), "columnType":1]))
            filterOptions.append(JSON(["columnId": "packingSize", "columnName":NSLocalizedString("Packing Size", comment: ""), "columnType":1]))
            filterOptions.append(JSON(["columnId": "packingType", "columnName":NSLocalizedString("Packing Type", comment: ""), "columnType":1]))
        }
        
       
        
        let filterNavVC = self.parent?.storyboard?.instantiateViewController(withIdentifier: "FilterNavVC") as!  UINavigationController
        
        
        let filterVC = filterNavVC.viewControllers.first as! MainFilterViewController
        filterVC.ls_FarmerConnectMode = self.ls_FarmerConnectMode
        filterVC.filterOptions = filterOptions
        filterVC.basicFilterValues =  [:]
        filterVC.delegate = self
        filterVC.cacheIndex = currentSelection == .bid ? 1 : 0
        filterVC.isMyBidSelected =  currentSelection == .bid ? true : false
        filterVC.isFarmerConnectFilter = true
        filterVC.modalPresentationStyle = .overFullScreen
        self.present(filterNavVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func btnChangeClicked(_ sender: Any) {
        
        let FarmerNameVC = UIStoryboard.init(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "FarmerListViewController") as! FarmerListViewController
        FarmerNameVC.delegate = self
        self.present(FarmerNameVC, animated: true, completion: nil)
    }
    
    @IBAction func Inprogress_Clicked(_ sender: Any) {
        ResetSelection()
        selectedTabFilter = "In-Progress"
        lbtn_inprogress.isSelected = true
        lbtn_inprogress.backgroundColor = UIColor.white
        lbtn_inprogress.borderColor = Utility.appThemeColor
        self.showActivityIndicator()
        self.refreshPage()
    }
    
    @IBAction func AcceptedClicked(_ sender: Any) {
        ResetSelection()
        selectedTabFilter = "Accepted\",\"Cancelled"
        lbtn_Accepted.isSelected = true
        lbtn_Accepted.backgroundColor = UIColor.white
        lbtn_Accepted.borderColor = Utility.appThemeColor
        self.showActivityIndicator()
        self.refreshPage()
    }
    
    @IBAction func CancelClicked(_ sender: Any) {
        ResetSelection()
        selectedTabFilter = "Rejected"
        lbtn_Cancelled.isSelected = true
        lbtn_Cancelled.backgroundColor = UIColor.white
        lbtn_Cancelled.borderColor = Utility.appThemeColor
        self.showActivityIndicator()
        self.refreshPage()
    }
    
    @IBAction func NewOfferbtn_Tapped(_ sender: Any) {
        let offerListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "NewOfferVC") as! NewOfferViewController
        self.navigationController?.pushViewController(offerListVC, animated: true)
    }
    
    //MARK: - Sort and Filter Delegate
    
    //SortDelegate
    func selectedSortOption(_ sortOptionValue: JSON?, sortOptionType: SortOptions) {
        
        if sortOptionType == .none {
            btnSort.tintColor = UIColor.black
        } else {
            btnSort.tintColor = Utility.appThemeColor
        }
        
        if let sortValue = sortOptionValue{
            let sort = sortValue.arrayValue[0]
            let orderBy = sort["orderBy"].stringValue
            
            let sortKeysMap = [
                NSLocalizedString("Product", comment: "")       :   "product",
                NSLocalizedString("Quality", comment: "")       :   "quality",
                NSLocalizedString("Incoterm", comment: "")     :   "incoTerm",
                NSLocalizedString("Crop Year", comment: "")     :   "cropYear",
                NSLocalizedString("Location", comment: "")      :   "location",
                NSLocalizedString("Published Price", comment: ""):   "publishedPrice",
                NSLocalizedString("User Name", comment: ""):   "username",
                NSLocalizedString("Quantity", comment: ""):   "quantity",
                NSLocalizedString("Payment Terms", comment: ""):   "paymentTerms",
                NSLocalizedString("Packing Size", comment: ""):   "packingSize",
                NSLocalizedString("Packing Type", comment: ""):   "packingType",
                
                //                "Quantity"          :   "quantity"
            ]
            
            let columnName = sort["columnName"].stringValue //This is display name
            // but keys should be passed to api
            
            let columnKey = sortKeysMap[columnName]!
            
            let sortParam = [columnKey:orderBy]
            
            currentSelection == .bid ? (myBidsSort = sortParam) : (publishedBidsSort = sortParam)
            
        } else {
            currentSelection == .bid ? (myBidsSort = nil) : (publishedBidsSort = nil)
        }
        self.showActivityIndicator()
        refreshPage()
    }
    
    //Filter delegate
    func selectedFilters(_ filter: [JSON]) {
        print(filter)
        
        if filter.count > 0 {
            currentSelection == .bid ? (myBidsFilter = filter) : (publishedBidsFilter = filter)
            btnFilter.tintColor = Utility.appThemeColor
        } else { //When user clears all filters, we pass default filter options
            currentSelection == .bid ? (myBidsFilter = nil) : (publishedBidsFilter = nil)
            btnFilter.tintColor = .black
        }
        
        self.showActivityIndicator()
        refreshPage()
    }
    
    //MARK: - Farmer Select delegate
    
    func didSelectFarmer(FarmerName: Farmer) {
        //Store selected Farmer to the disk
        DataCacheManager.shared.saveLastSelectedFarmer(farmer: FarmerName)
        selectedFarmer = FarmerName
        
        let attributedString = NSMutableAttributedString(string:NSLocalizedString("Showing bids of ", comment: ""))
        let attrs = (NSAttributedString(string: "\(FarmerName.name)", attributes:[.font:UIFont.boldSystemFont(ofSize: 17)]))
        attributedString.append(attrs)
        self.lblFarmerName.attributedText = attributedString
        self.lbtn_select.setTitle(NSLocalizedString("Change", comment: ""), for: .normal)
        //Hit API with Selected Farmer and reload the tableview
        getMyBids(farmerId: FarmerName.id, sort:myBidsSort, filter: myBidsFilter, pageNo: 0, pageSize: defaultPageSize)
        //        DataCacheManager.shared.clearFilterCache(at: 1)
        tableView.reloadData()
    }
    
    //MARK: - Local Function
    
    func ResetSelection() {
        lbtn_Accepted.isSelected = false
        lbtn_inprogress.isSelected = false
        lbtn_Cancelled.isSelected = false
        lbtn_Accepted.backgroundColor = UIColor.clear
        lbtn_inprogress.backgroundColor = UIColor.clear
        lbtn_Cancelled.backgroundColor = UIColor.clear
        lbtn_Accepted.borderColor = UIColor.init(hex: "CCCCCC")
        lbtn_inprogress.borderColor = UIColor.init(hex: "CCCCCC")
        lbtn_Cancelled.borderColor = UIColor.init(hex: "CCCCCC")
    }
    
 }
 
 
 //MARK: - Table view methods
 extension BidsListViewController:UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSelection {
        case .bid: return myBids.count
        case .publishedPrices: return publishedBids.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentSelection {
            
        case .bid:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BidCell", for: indexPath) as! BidTableViewCell
            let myBid = myBids[indexPath.row]
            cell.lblBidId.text = myBid.offerType + " | " + myBid.refId + " | " + myBid.incoTerm
            cell.lblSite.text = myBid.location
            cell.lblQuality.text = myBid.quality
            cell.lblCropYear.text = myBid.cropYear
            
            let status = myBid.status
            let pendingOn = myBid.pendingOn
            
            switch status {
            case .accepted:
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Bid_Accepted")
                cell.lblCancelledBid.isHidden = true
            case .rejected:
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Bid_Rejected")
                cell.lblCancelledBid.isHidden = true
            case .inProgress:
                cell.lblCancelledBid.isHidden = true
                if ls_FarmerConnectMode?.uppercased() == "BID"{
                    if pendingOn == .trader {
                        cell.indicatorImageView.image = #imageLiteral(resourceName: "Bid_Send")
                    } else if pendingOn == .farmer  {
                        cell.indicatorImageView.image = #imageLiteral(resourceName: "Bid_Received")
                    }
                }else{
                    if pendingOn == .farmer  {
                        cell.indicatorImageView.image = #imageLiteral(resourceName: "Bid_Send")
                    } else if pendingOn == .trader  {
                        cell.indicatorImageView.image = #imageLiteral(resourceName: "Bid_Received")
                    }
                }
            case .cancelled:
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Bid_Accepted")
                cell.lblCancelledBid.isHidden = false
                cell.lblCancelledBid.text = NSLocalizedString("Cancelled", comment: "Cancelled")
                
            }
            
            /*
             let attributedString = NSMutableAttributedString(string:NSLocalizedString("Incoterm: ", comment: ""))
             let attrs = NSAttributedString(string: myBid.incoTerm, attributes:[.foregroundColor:UIColor.black])
             attributedString.append(attrs)
             cell.lblTerm.attributedText = attributedString
             */
            //            cell.lblTerm.text = " " + myBid.incoTerm + "  "
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerorInfoRestricted.rawValue) == false{
                
                if myBid.offerorName.count > 0 {
                    cell.lblOffererName.text = myBid.offerorName
                }else{
                    cell.lblOffererName.text = NSLocalizedString("Not Available", comment: "")
                }
                
            }else{
                cell.lblOffererName.text = ""
            }

            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerRatingAllowed.rawValue) == true{
                
                if myBid.offerorRating.count > 0 && myBid.offerorRating != "Pending"  {
                    cell.lblOffererRating.text = NSLocalizedString("Rating", comment: "") + " : \(Double(myBid.offerorRating)!)"
                }else{
                    cell.lblOffererRating.text = NSLocalizedString("Not Available", comment: "")
                }
            }else{
                cell.lblOffererRating.text = ""
            }
            
            cell.lblPaymentTerm.text = myBid.paymentTerms
            
            
            cell.lblQuantity.text = numberFormatter.string(from: NSNumber(value: myBid.quantity))! + " " + myBid.quantityUnit
            let date = Date(timeIntervalSince1970: (myBid.deliveryFromDateInMillis/1000))
            cell.lblShipmentDate.text = dateFormatter.string(from: date)
            cell.selectionStyle = .none
            return cell
            
        case .publishedPrices:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PublishedPriceCell", for: indexPath) as! PublishedPriceTableViewCell
            let publishedBid = publishedBids[indexPath.row]
            
            cell.lblCropYear.text = publishedBid.cropYear
            cell.lblQuality.text = NSLocalizedString(publishedBid.quality, comment: "product quality")
            cell.lblBidId.text = publishedBid.offerType + " | " + publishedBid.id + " | " + publishedBid.incoTerm
            if publishedBid.expiry == "Today" || publishedBid.expiry == "Tomorrow" {
                cell.lblExpiry.text = "(" + NSLocalizedString("Expires", comment: "Expiry date prefix") + " " + publishedBid.expiry + ")"
            }else{
                cell.lblExpiry.text = "(" + NSLocalizedString("Expires in", comment: "Expiry date prefix") + " " + publishedBid.expiry + ")"
            }
            cell.lblPublishedPrice.text = numberFormatter.string(from: NSNumber(value: publishedBid.price))!  + " " + publishedBid.pricePerUnitQuantity
            cell.lblLocation.text = publishedBid.location
            /*
             let attributedString = NSMutableAttributedString(string:NSLocalizedString("Incoterm: ", comment: ""))
             let attrs = NSAttributedString(string: publishedBid.incoTerm, attributes:[.foregroundColor:UIColor.black])
             attributedString.append(attrs)
             cell.lblTerm.attributedText = attributedString
             */
            //            cell.lblTerm.text = " " + publishedBid.incoTerm + "  "
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerorInfoRestricted.rawValue) == false{
                if publishedBid.offerorName.count > 0 {
                    cell.lblOffererName.text = publishedBid.offerorName
                }else{
                    cell.lblOffererName.text = NSLocalizedString("Not Available", comment: "")
                }
            }else{
                cell.lblOffererName.text = ""
            }
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerRatingAllowed.rawValue) == true{
                if publishedBid.offerorRating.count > 0 && publishedBid.offerorRating != "Pending"  {
                    cell.lblOffererRating.text = NSLocalizedString("Rating", comment: "") + " : \(Double(publishedBid.offerorRating)!)"
                }else{
                    cell.lblOffererRating.text = NSLocalizedString("Not Available", comment: "")
                }
            }else{
                cell.lblOffererRating.text = ""
            }
            
            cell.lblQuantity.text =  numberFormatter.string(from: NSNumber(value: publishedBid.quantity))! + " " + publishedBid.quantityUnit
            let date = Date(timeIntervalSince1970: (publishedBid.deliveryFromDateInMillis/1000))
            cell.lblShipmentDate.text = dateFormatter.string(from: date)
            
            cell.lblPaymentTerm.text = publishedBid.paymentTerms
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch currentSelection {
        case .bid:
            
            
            if selectedFarmer != nil {
                
                //currentPage is the page which is already loaded. it starts from 1
                let currentPage = ceil(Double(myBids.count/defaultPageSize))
                
                if indexPath.row == myBids.count - 1 && Int(currentPage) > myBidCurrentpage {
                    myBidCurrentpage += 1
                    getMyBids(farmerId:selectedFarmer?.id,sort: myBidsSort, filter: myBidsFilter, pageNo: myBidCurrentpage,pageSize: defaultPageSize)
                    print("API Hit for page \(myBidCurrentpage)")
                    let activityIndicator = UIActivityIndicatorView(style: .gray)
                    activityIndicator.startAnimating()
                    tableView.beginUpdates()
                    tableView.tableFooterView = activityIndicator
                    tableView.endUpdates()
                }
            }
            
            
        case .publishedPrices:
            
            let currentPage = ceil(Double(publishedBids.count/defaultPageSize))
            
            if indexPath.row == publishedBids.count - 1 && Int(currentPage) > publishedPriceCurrentpage {
                publishedPriceCurrentpage += 1
                print("API Hit for page \( publishedPriceCurrentpage)")
                getPublishedBids(publishedBidsSort, filter: publishedBidsFilter, pageNo: publishedPriceCurrentpage, pageSize: defaultPageSize)
                
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.startAnimating()
                tableView.beginUpdates()
                tableView.tableFooterView = activityIndicator
                tableView.endUpdates()
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch currentSelection {
        case .bid:
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "Open Bid", label: "FarmerConnect", value: nil).build() as? [AnyHashable : Any])
            }
            
            let biddingVC = self.storyboard?.instantiateViewController(withIdentifier: "BiddingViewController") as! BiddingViewController
            biddingVC.bid =  myBids[indexPath.row]
            biddingVC.bidRefID = myBids[indexPath.row].refId
            biddingVC.ls_FarmerConnectMode = self.ls_FarmerConnectMode
            self.navigationController?.pushViewController(biddingVC, animated: true)
            
            
        case .publishedPrices:
            
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "View Published Price", label: "FarmerConnect", value: nil).build() as? [AnyHashable : Any])
            }
            
            if ls_FarmerConnectMode!.uppercased() == "BID" {
                let initiateBidVC = self.storyboard?.instantiateViewController(withIdentifier: "InitiateBidViewController") as! InitiateBidViewController
                initiateBidVC.publishedBid = publishedBids[indexPath.row]
                self.navigationController?.pushViewController(initiateBidVC, animated: true)
            }else{
                let offerDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "OfferDetailVC") as! OfferDetailViewController
                offerDetailVC.publishedBid = publishedBids[indexPath.row]
                self.navigationController?.pushViewController(offerDetailVC, animated: true)
            }
        }
    }
 }

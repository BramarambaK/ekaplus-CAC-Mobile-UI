//
//  InsightDetailContainerVC.swift
//  EkaAnalytics
//
//  Created by Nithin on 06/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import FlexiblePageControl
import Intercom

protocol InsightDetailDelegate{
    func selectedMenu(menu:String)
}

final class InsightDetailContainerVC: GAITrackedViewController, HUDRenderer, InsightListDelegate, SlicerDelegate,WFHamburgerMenuDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var lblInsightName: UILabel!
    @IBOutlet weak var pageIndicatorContainer: UIView!
    @IBOutlet weak var btnSlicer: UIButton!
    @IBOutlet weak var btnFavourite: UIBarButtonItem!
    @IBOutlet weak var bidFloatinButton: UIButton!
    @IBOutlet weak var workFlowFloatingButton: UIButton!
    
    //MARK: - Variable
    
    var menuVC:WF_MenuViewController!
    var larr_navbarDetails:JSON?
    var app_metadata:JSON?
    var delegate:InsightDetailDelegate?
    
    
    lazy var DynamicApiController:DynamicAppApiController = {
        return DynamicAppApiController()
    }()
    
    lazy var apiController:PermCodeAPIController = {
        return PermCodeAPIController()
    }()
    
    fileprivate(set) lazy var orderedViewControllers = [UIViewController]()
    
    let impactFeedback = UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light)
    
    var pageViewController : UIPageViewController? {
        return self.children.first as? UIPageViewController
    }
    
    var app:App!  //Passed from previous VC
    
    var linkedAppID:String!{ //In case of standard app it's linked app id
        if app.appType == .StandardApps{
            return app.id
        }
        return nil
    }
    
    var selectedInsightIDs:[String]!{ //In case of my app it's selected insight ids
        if app.appType == .MyApps{
            return app.selectedInsightIDs
        }
        return nil
    }
    
    var currentIndex = 0
    
    var insights = [Insight]() {
        didSet{
            pageControl.isHidden = false
            pageControl.numberOfPages = insights.count
            prepareInsightDetailVCsForPageController()
        }
    }
    
    var pageControl:FlexiblePageControl!
    
    var selectedInsightId:String?
    
    var larr_FloatButton:[String] = []
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Bid Floating Button
        self.bidFloatinButton.layer.shadowColor = UIColor.black.cgColor
        self.bidFloatinButton.layer.shadowRadius = 2
        self.bidFloatinButton.layer.shadowOpacity = 0.7
        self.bidFloatinButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        
        bidFloatinButton.isHidden = true
        
        //Workflow Floating Button
        self.workFlowFloatingButton.layer.shadowColor = UIColor.black.cgColor
        self.workFlowFloatingButton.layer.shadowRadius = 2
        self.workFlowFloatingButton.layer.shadowOpacity = 0.7
        self.workFlowFloatingButton.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        
        workFlowFloatingButton.isHidden = true
        
        
        switch Int(app.id){
        case 22:
            self.showActivityIndicator()
            apiController.getPermCode(appId: app.id) { (response) in
                self.hideActivityIndicator()
                switch response {
                case .success(let premCode):
                    
                    //Uncomment the below code to enable Agent flow
                    //                    if premCode.contains("FC_FARMER_BIDS_MGMT"){
                    //                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.agentPermission.rawValue)
                    //                        self.bidFloatinButton.isHidden = false
                    //                    }
                    
                    
                    if premCode.contains("STD_APP_BIDDER_BID"){
                        self.larr_FloatButton.append("BID")
                    }
                    
                    if premCode.contains("STD_APP_BIDS_OFFEROR"){
                        self.larr_FloatButton.append("OFFER")
                    }
                    
                    switch self.larr_FloatButton.count{
                    case 0:
                        self.bidFloatinButton.isHidden = true
                    case 1:
                        self.bidFloatinButton.isHidden = false
                        
                        self.bidFloatinButton.setTitle("\( NSLocalizedString(self.larr_FloatButton[0] as String, comment: ""))", for: .normal)
                    case 2:
                        self.bidFloatinButton.isHidden = false
                        self.bidFloatinButton.setImage(UIImage(named: "Menu"), for: .normal)
                    default:
                        self.bidFloatinButton.isHidden = true
                    }
                    
                case .failure(let error):
                    print(error.description)
                    
                case .failureJson(_):
                    break
                }
            }
            
        default:
            break
        }
        
        /*
         if app.id == "22"{
         self.showActivityIndicator()
         apiController.getPermCode(appId: app.id) { (response) in
         self.hideActivityIndicator()
         switch response {
         case .success(let premCode):
         if premCode.contains("FC_FARMER_BIDS_MGMT"){
         UserDefaults.standard.set(true, forKey: UserDefaultsKeys.agentPermission.rawValue)
         self.bidFloatinButton.isHidden = false
         }
         
         if premCode.contains("STD_APP_BIDDER_BID"){
         self.larr_FloatButton.append("BID")
         }
         
         if premCode.contains("STD_APP_BIDS_OFFEROR"){
         self.larr_FloatButton.append("OFFER")
         }
         
         switch self.larr_FloatButton.count{
         case 0:
         self.bidFloatinButton.isHidden = true
         case 1:
         self.bidFloatinButton.isHidden = false
         self.bidFloatinButton.setTitle("\(self.larr_FloatButton[0] as String)", for: .normal)
         case 2:
         self.bidFloatinButton.isHidden = false
         self.bidFloatinButton.setImage(UIImage(named: "Menu"), for: .normal)
         default:
         self.bidFloatinButton.isHidden = true
         }
         
         case .failure(let error):
         print(error.description)
         }
         }
         }
         
         */
        self.screenName = ScreenNames.insightDetails
        
        self.pageViewController?.delegate = self
        self.pageViewController?.dataSource = self
        
        self.navigationItem.hidesBackButton = false
        
        self.navigationItem.leftItemsSupplementBackButton = true
        setTitle(app.name)
        
        if app.isWorkFlowApp {
            self.getnavBarDetails(name: app.id, TenantID: BaseTenantID, selectedApp: app)
        }else if self.app.id == "39" {
            self.getnavBarDetails(name: app.id, TenantID: BaseTenantID, selectedApp: app)
        }
        
        pageControl = FlexiblePageControl(frame: pageIndicatorContainer.bounds)
        pageIndicatorContainer.addSubview(pageControl)
        pageControl.isHidden = true
        pageControl.updateViewSize()
        
        let config = FlexiblePageControl.Config(displayCount: 8, dotSize: 8, dotSpace: 5, smallDotSizeRatio: 0.5, mediumDotSizeRatio: 0.7)
        //            FlexiblePageControl.Config(displayCount: 8, dotSize: 8, dotSpace: 5)
        
        pageControl.setConfig(config)
        
        /*
         pageControl.dotSize = 8
         pageControl.dotSpace = 5
         pageControl.displayCount = 8
         */
        
        pageControl.pageIndicatorTintColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 66.0/255.0, alpha: 0.2)
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "FF0042")!
        //        pageControl.currentPage = 0
        
        self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(app.categoryName)
        
        getInsights()
        
        
        btnFavourite.tintColor = .white
        
        if self.app.isFavourite{
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-enable").withRenderingMode(.alwaysTemplate)
        } else {
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-disable").withRenderingMode(.alwaysTemplate)
        }
        
        switch self.app.name{
            
        case "Regulatory and Compliance",
            "Position and Mark to Market",
            "P&L Explained", "Trade Finance", "VaR",
            "Risk and Monitoring", "Purchase Analysis",
            "Procurement Analysis","Inventory Analytics",
            "Plan Performance","Pre-Trade Analysis",
            "Farmer Connect","Disease Prediction","Cash Flow",
            "Yield Forecast","Crop Intelligence",
            "Disease Risk Assessment","Basis Analysis",
            "Freight Exposure","Logistics Operations Analysis",
            "Reconciliation","Credit Risk","Thomson Reuters App",
            "Hyper Local Weather","Power Spread Analysis",
            "Quality Arbitrage Analysis","Vessel Management",
            "Invoice Aging","Plant Outage","Emissions Hedging",
            "Customer Connect","Supply Demand","Price Trend Analysis" :
            
            let btnOptions = UIBarButtonItem(image: #imageLiteral(resourceName: "meat_balls").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(optionsButtonTapped(_:event:)))
            btnOptions.tintColor = .white
            self.navigationItem.rightBarButtonItems?.insert(btnOptions, at: 0)
            
        case "Options Valuation","Disease Identification":
            
            let btnOptions = UIBarButtonItem(image: #imageLiteral(resourceName: "meat_balls").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(optionsBtnTapped(_:event:)))
            btnOptions.tintColor = .white
            self.navigationItem.rightBarButtonItems?.insert(btnOptions, at: 0)
            
        default:
            let btnShare = UIBarButtonItem(image: #imageLiteral(resourceName: "Share_Blank").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(shareBtnTapped(_:event:)))
            btnShare.tintColor = .white
            self.navigationItem.rightBarButtonItems?.insert(btnShare, at: 0)
        }
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Show the selected insight if any
        guard let insightID = self.selectedInsightId else {return}
        
        let selectedInsightVC = orderedViewControllers.filter({($0 as! InsightDetailViewController).insight.id == insightID}).first!
        
        if let index = orderedViewControllers.firstIndex(of: selectedInsightVC) {
            
            
            let direction:UIPageViewController.NavigationDirection = currentIndex<index ? .forward : .reverse
            
            self.pageViewController?.setViewControllers([selectedInsightVC],
                                                        direction: direction,
                                                        animated: true,
                                                        completion: nil)
            
            currentIndex = index
            pageControl.setCurrentPage(at: index)
            //            pageControl.currentPage = index
            lblInsightName.text = insights[currentIndex].name
            btnSlicer.isHidden = !insights[currentIndex].slicerPresent
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(app.categoryName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.selectedInsightId = nil //clear previously selected insightid every time view disappears.
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {//Screen is getting popped
            DataCacheManager.shared.clearSlicerCache()
        }
        
        //We are not chnging the navigation bar color after rebranding.
        //Commented by shreeram on 08-Apr-2021
        /*
         //Change Navigation bar tint only if this screen is pushed from Dashboard Favourites or search view controller
         //Changes when going to previous screen
         let count = self.navigationController?.viewControllers.count
         if let count = count, let previousVC = self.navigationController?.viewControllers[count - 2], (previousVC.isKind(of: DashBoardViewController.self)||previousVC.isKind(of: SearchViewController.self)) {
         self.navigationController?.navigationBar.barTintColor = Utility.appThemeColor
         }
         */
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.navigationController?.navigationBar.barTintColor = Utility.colorForCategory(self.app.categoryName)
        }
    }
    
    
    func preparePreSelectedSlicerValuesIfAny(_ insight:Insight) -> [String:[JSON]]? {
        var defaultActionFiltersMap = JSON()
        let dataViews = insight.contents["dataviews"].arrayValue
        
        
        for dataView in dataViews {
            if let defaultValue = dataView.dictionary?["default"], defaultValue.count > 0 {
                
                let dataViewId = dataView["dataViewId"].stringValue //Slicer Dataview id
                
                defaultActionFiltersMap[dataViewId] = JSON(["value": defaultValue["value"].arrayValue])
                
                if let dateFormat = defaultValue["dateFormat"].string{
                    defaultActionFiltersMap[dataViewId]["dateFormat"].stringValue = dateFormat
                }
                
                if let customDateFormat = defaultValue["customDateFormat"].string{
                    defaultActionFiltersMap[dataViewId]["customDateFormat"].stringValue = customDateFormat
                }
            }
        }
        
        let actions = insight.actions!
        
        //Check the slicer actions associated with the slicer having default values. Get the target dataviews affected by default value slicer and pass it when hitting dataview api for that particular target dataview.
        
        
        var actionFiltersMap = [String:[JSON]]()
        //construct the actionFiltersMap to be passed to dataview api in the below format
        
        //Source dataview is an array because, multiple sources(slicers) can affect same dataview
        /*
         { targetDataViewId:  [
         {
         columnType:
         columnId:
         source:"actions"
         value:["values"]
         dateFormat:
         customDateFormat:
         operator: "in"
         
         }
         ]
         }
         */
        
        
        for action in actions{
            
            let sourceDvId = action["sourceDataViewId"].stringValue
            let targetDvId = action["targetDataViewId"].stringValue
            let columnType = action["columnMapping"].arrayValue[0]["targetColumnType"].intValue
            let columnId = action["columnMapping"].arrayValue[0]["targetColumn"].stringValue
            
            
            if defaultActionFiltersMap[sourceDvId].dictionary != nil {
                
                let value = defaultActionFiltersMap[sourceDvId]["value"]
                let dateFormat = defaultActionFiltersMap[sourceDvId]["dateFormat"].string
                let customDateFormat = defaultActionFiltersMap[sourceDvId]["customDateFormat"].string
                
                var filterJson = JSON()
                
                filterJson["columnType"].intValue = columnType
                filterJson["columnId"].stringValue = columnId
                filterJson["source"].stringValue = "actions"
                
                if let userSelectedFilter = dataViews.filter({$0["dataViewId"].stringValue == sourceDvId}).first {
                    switch userSelectedFilter["chartType"] {
                    case "DateRangeSlicer":
                        switch value.count {
                        case 2:
                            filterJson["operator"].stringValue = "range"
                            filterJson["value"] = value
                        case 1:
                            filterJson["operator"].stringValue = "advanced"
                            filterJson["value"].stringValue = value[0].stringValue
                        default:
                            break
                        }
                    default:
                        filterJson["operator"].stringValue = "in"
                        filterJson["value"] = value
                    }
                }
                
                if let dateformatString =  dateFormat{
                    filterJson["dateFormat"].stringValue = dateformatString
                }
                
                if let customDateString = customDateFormat{
                    filterJson["customDateFormat"].stringValue = customDateString
                }
                
                
                
                //                let json = JSON([
                //                    "columnType":columnType,
                //                    "columnId":columnId,
                //                    "source" : "actions",
                //                    "value":value,
                //                    "dateFormat":dateFormat,
                //                    "customDateFormat":customDateFormat,
                //                    "operator":"in"
                //                    ])
                
                
                if var filters = actionFiltersMap[targetDvId] {
                    filters.append(filterJson)
                    actionFiltersMap[targetDvId] = filters
                } else {
                    actionFiltersMap[targetDvId] = [filterJson]
                }
            }
        }
        
        return actionFiltersMap
        
    }
    
    
    func prepareInsightDetailVCsForPageController(){
        
        var insightVCs = [InsightDetailViewController]()
        for insight in insights {
            let vc = newVCWithInsight(insight)
            insightVCs.append(vc)
        }
        orderedViewControllers = insightVCs
        
        if let firstViewController = orderedViewControllers.first {
            self.pageViewController?.setViewControllers([firstViewController],
                                                        direction: .forward,
                                                        animated: true,
                                                        completion: nil)
            lblInsightName.text = insights.first?.name ?? "Insight"
            btnSlicer.isHidden = !(insights.first?.slicerPresent ?? false)
        } else if orderedViewControllers.count == 0 {
            
            let label = UILabel()
            label.text  = NSLocalizedString("No Insights available.", comment: "")
            self.view.addSubview(label)
            
            label.numberOfLines = 0
            label.frame = view.bounds
            label.textAlignment = .center
            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    
    private func newVCWithInsight(_ insight: Insight) -> InsightDetailViewController {
        let insightVC = UIStoryboard(name: "Main", bundle: nil) .
        instantiateViewController(withIdentifier: "InsightDetailViewController") as! InsightDetailViewController
        insightVC.insight = insight
        if insight.contents != nil {
            let preSelectedFilters = preparePreSelectedSlicerValuesIfAny(insight)
            insightVC.preSelectedSlicerFilters = preSelectedFilters
        }
        
        return insightVC
    }
    
    @objc
    func optionsButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        let config = FTPopOverMenuConfiguration.default()
        config?.tintColor = .white
        config?.textColor = .black
        config?.menuWidth = 150
        config?.menuTextMargin = 15
        
        FTPopOverMenu.show(from: event, withMenuArray: [NSLocalizedString("Share", comment: ""),NSLocalizedString("What am I seeing?", comment: ""), NSLocalizedString("Learn more", comment: "")], doneBlock: { (selectedIndex) in
            
            switch selectedIndex {
            case 0:
                let insightDetailVC = self.orderedViewControllers[self.pageControl.currentPage] as! InsightDetailViewController
                insightDetailVC.exportInsight()
            case 1:
                //Google Analytics event tracking
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "What Am I Seeing", label: "\(self.app.name)", value: nil).build() as? [AnyHashable : Any])
                }
                
                let whatAIS = self.storyboard?.instantiateViewController(withIdentifier: "WhatAmISeeingViewController") as! WhatAmISeeingViewController
                whatAIS.app = self.app
                whatAIS.modalPresentationStyle = .fullScreen
                self.present(whatAIS, animated: true, completion: nil)
            case 2:
                //Google Analytics event tracking
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "Learn More", label: "\(self.app.name)", value: nil).build() as? [AnyHashable : Any])
                }
                
                let learnMoreVC = self.storyboard?.instantiateViewController(withIdentifier: "LearnMoreViewController") as! LearnMoreViewController
                learnMoreVC.app = self.app
                learnMoreVC.modalPresentationStyle = .fullScreen
                self.present(learnMoreVC, animated: true, completion: nil)
            default:
                break
            }
        }) {
            //            print("Dismiss")
        }
    }
    
    @objc
    func optionsBtnTapped(_ sender:UIBarButtonItem, event:UIEvent){
        let config = FTPopOverMenuConfiguration.default()
        config?.tintColor = .white
        config?.textColor = .black
        config?.menuWidth = 150
        config?.menuTextMargin = 15
        
        FTPopOverMenu.show(from: event, withMenuArray: [NSLocalizedString("Share", comment: ""),NSLocalizedString("Learn more", comment: "")], doneBlock: { (selectedIndex) in
            
            switch selectedIndex {
            case 0:
                let insightDetailVC = self.orderedViewControllers[self.pageControl.currentPage] as! InsightDetailViewController
                insightDetailVC.exportInsight()
            case 1:
                //Google Analytics event tracking
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "Learn More", label: "\(self.app.name)", value: nil).build() as? [AnyHashable : Any])
                }
                
                let learnMoreVC = self.storyboard?.instantiateViewController(withIdentifier: "LearnMoreViewController") as! LearnMoreViewController
                learnMoreVC.app = self.app
                learnMoreVC.modalPresentationStyle = .fullScreen
                self.present(learnMoreVC, animated: true, completion: nil)
            default:
                break
            }
        }) {
            //            print("Dismiss")
        }
    }
    
    func getInsights(){
        showActivityIndicator()
        InsightListAPIController.shared.getListOfInsights(forAppID: linkedAppID, insightIDs: selectedInsightIDs) { [weak self] (response) in
            self?.hideActivityIndicator()
            switch response {
            case .success(let insightsArray):
                //                    print(insightsArray)
                self?.insights = insightsArray
                
            case .failure(let error):
                self?.hideActivityIndicator()
                switch error {
                case .tokenRefresh:
                    self?.getInsights()
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
    
    
    @objc
    func shareBtnTapped(_ sender:UIBarButtonItem, event:UIEvent){
        if orderedViewControllers.count > 0 {
            let insightDetailVC = self.orderedViewControllers[self.pageControl.currentPage] as! InsightDetailViewController
            insightDetailVC.exportInsight()
        }else{
            self.showAlert( message: NSLocalizedString("No Insights to share.", comment: ""))
        }
    }
    
    //MARK: - IBAction
    @IBAction func favouriteTapped(_ sender: UIBarButtonItem) {
        
        self.app.isFavourite = !self.app.isFavourite
        
        if self.app.isFavourite{
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-enable").withRenderingMode(.alwaysTemplate)
        } else {
            btnFavourite.image = #imageLiteral(resourceName: "Favourite-disable").withRenderingMode(.alwaysTemplate)
        }
        
        AppFavouriteAPIController.shared.toggleAppFavourite(app.id, appType: app.appType, isFavourite: self.app.isFavourite) { (response) in
            //            print(response)
        }
    }
    
    
    @IBAction func moreMenuTapped(_ sender: UIButton) {
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "List Of Insights", label: "\(app.name)", value: nil).build() as? [AnyHashable : Any])
        }
        
        
        let insightListVC = self.storyboard?.instantiateViewController(withIdentifier: "InsightsListViewController") as! InsightsListViewController
        insightListVC.insights = self.insights
        insightListVC.app = app
        insightListVC.delegate = self
        insightListVC.modalPresentationStyle = .fullScreen
        self.present(insightListVC, animated: true, completion: nil)
    }
    
    
    @IBAction func slicerTapped(_ sender: UIButton) {
        
        //Get the currently displayed vc in pageviewcontroller
        let slicerVC = self.storyboard?.instantiateViewController(withIdentifier: "SlicerViewController") as! SlicerViewController
        let insight = insights[currentIndex]
        slicerVC.insight = insight
        slicerVC.delegate = self
        
        var slicerIds = [String]()
        
        let dataViews = insight.contents["dataviews"].arrayValue
        
        dataViews.forEach { (dv) in
            if dv["chartType"].stringValue == "CheckSlicer" || dv["chartType"].stringValue == "RadioSlicer" || dv["chartType"].stringValue == "ComboSlicer" || dv["chartType"].stringValue == "TagSlicer" || dv["chartType"].stringValue == "DateRangeSlicer" {
                slicerIds.append(dv["dataViewId"].stringValue)
            }
        }
        
        slicerVC.slicerIds = slicerIds
        slicerVC.modalPresentationStyle = .fullScreen
        self.present(slicerVC, animated: true, completion: nil)
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Insight", action: "Slicer", label: "\(insight.name)", value: nil).build() as? [AnyHashable : Any])
        }
        
    }
    
    
    @IBAction func bidFloatinButtonTapped(_ sender: UIButton) {
        
        self.getGeneralSetting()
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "View Bids List", label: "FarmerConnect", value: nil).build() as? [AnyHashable : Any])
        }
        
        switch larr_FloatButton.count {
        case 1:
            if larr_FloatButton[0] == "BID"{
                //Get data for FarmerConnectFilter
                DataCacheManager.shared.getFarmerConnectFilter(offerType: "BID")
                
                let bidListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "BidsListViewController") as! BidsListViewController
                bidListVC.app = self.app
                bidListVC.ls_FarmerConnectMode = "Bid"
                self.navigationController?.pushViewController(bidListVC, animated: true)
            }else{
                //Get data for FarmerConnectFilter
                DataCacheManager.shared.getFarmerConnectFilter(offerType: "OFFER")
                
                let bidListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "BidsListViewController") as! BidsListViewController
                bidListVC.app = self.app
                bidListVC.ls_FarmerConnectMode = "OFFER"
                self.navigationController?.pushViewController(bidListVC, animated: true)
            }
        case 2:
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            //Add offer button in the list
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Offer", comment: ""), style: .default, handler: { _ in
                
                //Get data for FarmerConnectFilter
                DataCacheManager.shared.getFarmerConnectFilter(offerType: "OFFER")
                
                let bidListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "BidsListViewController") as! BidsListViewController
                bidListVC.app = self.app
                bidListVC.ls_FarmerConnectMode = "OFFER"
                self.navigationController?.pushViewController(bidListVC, animated: true)
                
            }))
            
            
            //Add Bid button in the list
            alert.addAction(UIAlertAction(title: NSLocalizedString("Bid", comment: ""), style: .default, handler: { _ in
                
                //Get data for FarmerConnectFilter
                DataCacheManager.shared.getFarmerConnectFilter(offerType: "BID")
                
                let bidListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "BidsListViewController") as! BidsListViewController
                bidListVC.app = self.app
                bidListVC.ls_FarmerConnectMode = "BID"
                self.navigationController?.pushViewController(bidListVC, animated: true)
            }))
            
            alert.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
        
    }
    
    //    @IBAction func workFlowFloatingButtonTapped(_ sender: UIButton) {
    //        self.getDashDetails(name: app.id, TenantID: BaseTenantID, selectedApp: app)
    //    }
    
    //Slicer Delegate Method
    func selectedSlicerFilters(_ filters:[String:[String:Any]],_ dateFilters:[String:[String:Any]]){
        //Filters is in the format [SourceDataViewID: [array of selected filter values]]
        
        //call refresh method on current insightDetailVC
        let currentPageVC = orderedViewControllers[currentIndex] as! InsightDetailViewController
        
        guard let insightSlicerActions = insights[currentIndex].actions else {
            return
        }
        
        //Final format should be like, for each targetDataViewID, we need an array of filters
        var targetDataViewFilters = [String:[JSON]]()
        
        
        //Each source dataViewID (slicer is a source) can affect multiple dataviews
        for (sourceDataViewId, slicerOptions) in filters {
            
            //Get all actions whose source dataview id is same and target different dataviews
            let actions = insightSlicerActions.filter{$0["sourceDataViewId"].stringValue == sourceDataViewId}
            
            //For each action on a targetDataView, build filter array
            actions.forEach{ (action) in
                
                let targetDataViewID = action["targetDataViewId"].stringValue
                let columnMappings = action["columnMapping"].arrayValue
                
                //On a particular target dataview, source dataview can target multiple columns in the target. so we sholud pass an array of filters each corresponding to each column
                
                var jsonFilters = [JSON]()
                
                let filterValues = slicerOptions["selectedValues"] as? [String] ?? []
                
                
                for columnMapping in columnMappings {
                    let targetColumnType = columnMapping["targetColumnType"].intValue
                    let targetColumnId = columnMapping["targetColumn"].stringValue
                    
                    var filter:[String : Any] = [
                        "columnId":targetColumnId,
                        "operator":"in",
                        "columnType":targetColumnType,
                        "value":filterValues,
                        "source":"actions"
                    ]
                    
                    if let dateFormat = slicerOptions["dateFormat"] as? String {
                        filter.updateValue(dateFormat, forKey: "dateFormat")
                    }
                    
                    if let customDateFormat = slicerOptions["customDateFormat"] as? String{
                        filter.updateValue(customDateFormat, forKey: "customDateFormat")
                    }
                    
                    
                    if filterValues.count > 0 { //If filter values is 0, dataview needs to be reset by passing empty filters array
                        let filterJson = JSON(filter)
                        jsonFilters.append(filterJson)
                    }
                }
                
                //More than one slicer can target same dataView, in that case, we might have filters already corresponding to previous slicer. we should not override it. instead, append to it
                if var existingFilters = targetDataViewFilters[targetDataViewID] {
                    existingFilters.append(contentsOf: jsonFilters)
                    targetDataViewFilters[targetDataViewID] = existingFilters
                } else {
                    targetDataViewFilters[targetDataViewID] = jsonFilters
                }
            }
            
        }
        
        for (sourceDataViewId, slicerOptions) in dateFilters {
            
            //Get all actions whose source dataview id is same and target different dataviews
            let actions = insightSlicerActions.filter{$0["sourceDataViewId"].stringValue == sourceDataViewId}
            
            //For each action on a targetDataView, build filter array
            actions.forEach{ (action) in
                
                let targetDataViewID = action["targetDataViewId"].stringValue
                let columnMappings = action["columnMapping"].arrayValue
                
                //On a particular target dataview, source dataview can target multiple columns in the target. so we sholud pass an array of filters each corresponding to each column
                
                var jsonFilters = [JSON]()
                let filterValues = slicerOptions["selectedValues"] as? [String] ?? []
                
                for columnMapping in columnMappings {
                    let targetColumnType = columnMapping["targetColumnType"].intValue
                    let targetColumnId = columnMapping["targetColumn"].stringValue
                    
                    
                    var filter:[String : Any] = [
                        "columnId":targetColumnId,
                        "columnType":targetColumnType,
                        "source":"actions"
                    ]
                    
                    switch filterValues.count {
                    case 2:
                        filter["value"] = filterValues
                        filter["operator"] = "range"
                    case 1:
                        filter["value"] = filterValues[0]
                        filter["operator"] = "advanced"
                    default:
                        break
                    }
                    
                    if let dateFormat = slicerOptions["dateFormat"] as? String {
                        filter.updateValue(dateFormat, forKey: "dateFormat")
                    }
                    
                    if let customDateFormat = slicerOptions["customDateFormat"] as? String{
                        filter.updateValue(customDateFormat, forKey: "customDateFormat")
                    }
                    
                    
                    if filterValues.count > 0 { //If filter values is 0, dataview needs to be reset by passing empty filters array
                        let filterJson = JSON(filter)
                        jsonFilters.append(filterJson)
                    }
                }
                
                //More than one slicer can target same dataView, in that case, we might have filters already corresponding to previous slicer. we should not override it. instead, append to it
                if var existingFilters = targetDataViewFilters[targetDataViewID] {
                    existingFilters.append(contentsOf: jsonFilters)
                    targetDataViewFilters[targetDataViewID] = existingFilters
                } else {
                    targetDataViewFilters[targetDataViewID] = jsonFilters
                }
            }
            
        }
        
        currentPageVC.refreshDataViews(filters: targetDataViewFilters)
    }
    
    //InsightList Delegate method
    func didSelectInsight(insightID: String) {
        //To get a proper selection, set the selected insightid and in viewdidappear, move to the selected vc of pagecontroller
        self.selectedInsightId = insightID
        
    }
    
    //MARK: - Local Function
    /*
     func getDashDetails(name:String,TenantID:String,selectedApp:App){
     self.showActivityIndicator()
     
     ConnectManager.shared.getConnectDetails(app_Id: name) {
     (appResponse) in
     self.hideActivityIndicator()
     switch appResponse {
     case .success(let json):
     self.app_metadata = json
     
     self.showActivityIndicator()
     
     let bodydictionary = ["appId":"\(json["sys__UUID"].stringValue)",
     "workFlowTask":"home","deviceType" : "mobile"] as [String : Any]
     
     ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (homeResponse) in
     self.hideActivityIndicator()
     switch homeResponse {
     case .success(let json):
     DispatchQueue.main.async {
     self.gettaskDetails(taskName: (json["flow"]["home"]["workflow"].stringValue))
     }
     case .failure(let error):
     self.showAlert(message: error.localizedDescription)
     
     case .failureJson(let errorJson):
     print(errorJson)
     }
     }
     case .failure(let error):
     self.showAlert(message:error.description)
     case .failureJson(_):
     break
     }
     }
     }
     */
}


extension InsightDetailContainerVC:UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            
            if let viewControllers = pageViewController.viewControllers {
                if let viewControllerIndex = self.orderedViewControllers.firstIndex(of: viewControllers[0]) {
                    impactFeedback.impactOccurred()
                    self.currentIndex = viewControllerIndex
                    self.pageControl.setCurrentPage(at: currentIndex)
                    //                    self.pageControl.currentPage = currentIndex
                    lblInsightName.text = insights[currentIndex].name
                    btnSlicer.isHidden = !insights[currentIndex].slicerPresent
                }
            }
            
        }
    }
    
    func getGeneralSetting(){
        apiController.getGeneralSetting { (response) in
            switch response {
            case .success(let json):
                
                //Quantity Lock
                UserDefaults.standard.set(json["bidQuantityLocked"].boolValue, forKey: UserDefaultsKeys.isQualityLock.rawValue)
                
                //Cancel Permission
                UserDefaults.standard.set(json["bidCancellationAllowed"].boolValue, forKey: UserDefaultsKeys.cancelPermission.rawValue)
                
                //Personal InfoSharingRestricted Permission
                UserDefaults.standard.set(json["personalInfoSharingRestricted"].boolValue, forKey: UserDefaultsKeys.personalInfoSharingRestricted.rawValue)
                
                //Offer Type Permission
                UserDefaults.standard.set(json["offerType"].stringValue, forKey: UserDefaultsKeys.offerType.rawValue)
                
                //offerorInfoRestricted Permission
                UserDefaults.standard.set(json["offerorInfoRestricted"].stringValue, forKey: UserDefaultsKeys.offerorInfoRestricted.rawValue)
                
                //offerorInfoRestricted Permission
                UserDefaults.standard.set(json["offerRatingAllowed"].stringValue, forKey: UserDefaultsKeys.offerRatingAllowed.rawValue)
                
                
            case .failure( _):
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isQualityLock.rawValue)
                
            case .failureJson(_):
                break
            }
        }
    }
    
    
    func setNavigationBarWithSideMenu()
    {
        
        self.navigationItem.leftItemsSupplementBackButton = false
        
        menuVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "WF_MenuViewController") as? WF_MenuViewController
        menuVC.larr_ConnectedMenu = larr_navbarDetails
        menuVC.ls_appName = app.name
        menuVC.delegate = self
        
        //Add Hamburger Button
        let sideMenuBtn = UIButton(type: UIButton.ButtonType.system)
        sideMenuBtn.tintColor = .white
        sideMenuBtn.setImage(UIImage.init(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        sideMenuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        sideMenuBtn.addTarget(menuVC, action: #selector(menuVC.hamburgerClicked(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: sideMenuBtn)
        
        let titleLabel = UILabel()
        titleLabel.text = app.name
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        titleLabel.textColor = UIColor.white
        titleLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 25)
        titleLabel.sizeToFit()
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.numberOfLines = 1
        let titleBarItem = UIBarButtonItem(customView: titleLabel)
        
        self.navigationItem.leftBarButtonItems = [customBarItem,titleBarItem]
    }
    
    
    private func getnavBarDetails(name:String,TenantID:String,selectedApp:App){
        self.showActivityIndicator()
        
        ConnectManager.shared.getConnectDetails(app_Id: name) {
            (appResponse) in
            self.hideActivityIndicator()
            switch appResponse {
            case .success(let json):
                self.showActivityIndicator()
                self.app_metadata = json
                
                ConnectManager.shared.getNavBarDetails(app_Id: json["sys__UUID"].stringValue) {  (navBarResponse) in
                    self.hideActivityIndicator()
                    
                    switch navBarResponse {
                    case .success(let json):
                        if json.array == nil {
                            self.larr_navbarDetails = json
                        }else{
                            for i in 0..<2{
                                if json[i]["deviceType"].stringValue == "mobile"{
                                    self.larr_navbarDetails = json[i]
                                    break
                                }
                            }
                        }
                        
                        //Uncomment below line to enable Offline Support
                        //ConnectManager.shared.getAndSavelistoflayout(appId: json["refTypeId"].stringValue)
                        
                        guard self.larr_navbarDetails != nil  else {
                            return
                        }
                        
                        if json["navbar"][0]["apiMenuData"][0]["menuItems"][0]["items"].count > 0 || json["navbar"][0]["apiMenuData"][0]["menu"].count > 0{
                            self.setNavigationBarWithSideMenu()
                        }
                        
                    case .failure(let error):
                        self.showAlert(message: error.localizedDescription)
                    case .failureJson(let errorJson):
                        self.showAlert(message: errorJson["errorMessage"].stringValue)
                    }
                }
            case .failure(let error):
                if error.description.uppercased() == "Token validity expired.".uppercased() || error.description.uppercased() == "The token has been refreshed".uppercased() {
                    self.getnavBarDetails(name: self.app.id, TenantID: BaseTenantID, selectedApp: self.app)
                }else{
                    self.showAlert(message:error.description)
                }
                
            case .failureJson(let errorJson):
                self.showAlert(message: errorJson["errorMessage"].stringValue)
            }
        }
    }
    
    func selectedMenu(handler: String, queryparameter: String?) {
        menuVC.dismissHamburgerMenu()
        gettaskDetails(taskName: handler,queryparameter:queryparameter)
    }
    
    
    private func gettaskDetails(taskName:String,queryparameter: String? = nil){
        
        self.showActivityIndicator()
        let bodydictionary = ["appId":"\(app_metadata!["sys__UUID"].stringValue)",
                              "workFlowTask":"\(taskName)",
                              "deviceType":"mobile"] as [String : Any]
        
        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
            self.hideActivityIndicator()
            switch taskResponse {
            case .success(let json):
                let larr_fields = json["flow"][taskName]["fields"].arrayValue
                let larr_Decision = json["flow"][taskName]["decisions"].arrayValue
                let ls_Title = json["flow"][taskName]["label"].stringValue
                
                switch json["flow"][taskName]["layout"]["name"].stringValue {
                case "list":
                    
                    if json["flow"][taskName]["layout"]["getInitialData"].bool == true {
                        self.showActivityIndicator()
                        
                        var dataBodyDictionary:[String : Any] = [:]
                        
                        dataBodyDictionary = ["appId":"\(self.app_metadata!["sys__UUID"].stringValue)",
                                              "workFlowTask":"\(taskName)","deviceType": "mobile"] as [String : Any]
                        dataBodyDictionary["operation"] = []
                        
                        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { (dataResponse) in
                            self.hideActivityIndicator()
                        }
                    }
                    
                    var larr_SortList:[String] = []
                    var larr_FilterList:[JSON] = []
                    
                    for each in larr_fields{
                        
                        if each["filter"] != nil && each["filter"] == true {
                            larr_FilterList.append(each)
                        }
                        
                        if each["sort"] != nil && each["sort"] == true {
                            larr_SortList.append(each["key"].stringValue)
                        }
                    }
                    
                    let ListVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "ListVC") as! ListViewController
                    ListVC.lb_Search = json["flow"][taskName]["layout"]["options"]["serverSearch"].bool ?? false
                    ListVC.larr_Decision = larr_Decision
                    ListVC.ls_ScreenTitle = ls_Title
                    ListVC.ls_appName = self.app_metadata!.dictionaryValue["sys__UUID"]!.stringValue
                    ListVC.ls_taskName = taskName
                    //                    ListVC.ls_Selectedappname = self.app.name
                    ListVC.larr_FilterList = larr_FilterList
                    ListVC.larr_SortList = larr_SortList
                    ListVC.layoutJson = json
                    ListVC.app = self.app
                    ListVC.ls_selectedQueryParameter = queryparameter
                    ListVC.ls_previousWorkflow = taskName
                    ListVC.ls_HomeWorkFlow  = taskName
                    self.navigationController?.pushViewController(ListVC, animated: true)
                    
                case "create":
                    let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                    CreateVC.app_metaData =  json
                    CreateVC.ls_taskName = taskName
                    CreateVC.ls_ScreenTitle = ls_Title
                    CreateVC.app = self.app
                    self.navigationController?.pushViewController(CreateVC, animated: true)
                    
                case "customv2":
                    if self.app.id == "39" {
                        let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "CombinedVC") as! CombinedViewController
                        customVC.ls_ScreenTitle = ls_Title
                        customVC.ls_appName = self.app_metadata!["sys__UUID"].stringValue
                        customVC.ls_taskName = taskName
                        customVC.app_metaData = json
                        customVC.ls_Selectedappname = self.app.name
                        
                        self.navigationController?.pushViewController(customVC, animated: true)
                    }else{
                        let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "AdvCompositeVC") as! AdvancedCompositeViewController
                        customVC.app_metaData = json
                        customVC.ls_taskName = taskName
                        //                    customVC.ls_ScreenTitle = ls_Title
                        //                    customVC.ls_appName = self.app_metadata!["sys__UUID"].stringValue
                        //                    customVC.ls_taskName = taskName
                        
                        //                    customVC.ls_Selectedappname = self.app.name
                        //                    customVC.ls_tentantId = BaseTenantID
                        
                        self.navigationController?.pushViewController(customVC, animated: true)
                    }
                    
                    
                    
                    /*
                     let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "CompositeVC") as! CompositeViewController
                     
                     customVC.ls_ScreenTitle = ls_Title
                     customVC.ls_appName = self.app_metadata!["sys__UUID"].stringValue
                     customVC.ls_taskName = taskName
                     customVC.app_metaData = json
                     customVC.ls_Selectedappname = self.app.name
                     customVC.ls_tentantId = BaseTenantID
                     
                     self.navigationController?.pushViewController(customVC, animated: true)
                     */
                    
                case "chart":
                    let ChartVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "ChartViewController") as! ChartViewController
                    ChartVC.layoutJson = json
                    ChartVC.ls_taskName = taskName
                    ChartVC.ls_ScreenTitle = ls_Title
                    self.navigationController?.pushViewController(ChartVC, animated: true)
                    
                default:
                    break
                }
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(let errorJson):
                print(errorJson)
            }
        }
    }
}


extension InsightDetailContainerVC:WF_HamburgerMenuDelegate{
    func WF_ConnectselectedMenu(handler: String, queryparameter: String?) {
        menuVC.dismissHamburgerMenu()
        gettaskDetails(taskName: handler,queryparameter:queryparameter)
    }
    
    
    func WF_SelectedMenu(_ menu: String) {
        menuVC.dismissHamburgerMenu()
        
        switch menu {
            
        case "Favourites":
            delegate?.selectedMenu(menu: "Favourites")
            self.navigationController?.popViewController(animated: true)
        case "Apps":
            delegate?.selectedMenu(menu: "Apps")
            self.navigationController?.popViewController(animated: true)
        case "Switch Corporate":
            delegate?.selectedMenu(menu: "Switch Corporate")
            self.navigationController?.popViewController(animated: true)
        case "Settings":
            let settingsNavVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsNavigationVC") as! UINavigationController
            let settingsVC = settingsNavVC.viewControllers[0] as! SettingsViewController
            settingsVC.mode = .Settings
            settingsNavVC.modalPresentationStyle = .fullScreen
            self.present(settingsNavVC, animated: true, completion: nil)
            
        case "UserProfile":
            let farmerProfile = UIStoryboard.init(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "FarmeUserProfileViewController") as! FarmeUserProfileViewController
            farmerProfile.modalPresentationStyle = .fullScreen
            self.present(farmerProfile, animated: true, completion: nil)
            
            
        case "About us":
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "About us", label: "General", value: nil).build() as? [AnyHashable : Any])
            }
            
            let aboutUsVc = self.storyboard?.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
            aboutUsVc.modalPresentationStyle = .fullScreen
            self.present(aboutUsVc, animated: true, completion: nil)
            
        case "Need Help?":
            
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Home", action: "Need help?", label: "General", value: nil).build() as? [AnyHashable : Any])
            }
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.supportChatView.rawValue){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    Intercom.presentMessenger()
                }
            }
            else{
                let helpVC = self.storyboard?.instantiateViewController(withIdentifier:"HelpViewController") as! HelpViewController
                helpVC.modalPresentationStyle = .fullScreen
                self.present(helpVC, animated: true, completion: nil)
            }
            
        default:
            break
            
        }
    }
}

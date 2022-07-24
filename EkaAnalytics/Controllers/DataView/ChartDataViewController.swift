//
//  ChartDataViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 23/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit

class ChartDataViewController: GAITrackedViewController, SortScreenDelegate, HUDRenderer , MainFilterScreenDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CustomLayoutDelegateForTable,ChartPointSelectDelegate{
    
    //MARK: - IBOutlet
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet weak var btnLegend: UIBarButtonItem!
    
    @IBOutlet weak var btnSort: UIBarButtonItem!
    
    @IBOutlet weak var btnFilter: UIBarButtonItem!
    
    @IBOutlet weak var btnShare: UIBarButtonItem!
    
    @IBOutlet weak var drillViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var drillUp: UIButton!
    
    @IBOutlet weak var drillLabel: UILabel!
    
    @IBOutlet weak var drillDown: UIButton!
    
    //MARK: - Variable
    
    var chartOptions:ChartOptionsModel!{//Fed from previous VC
        didSet{
            if chartOptions.type != .Card && chartOptions.type != .Table {
                self.options = chartOptionProvider.hiOptions(for: chartOptions)
            }
        }
    }
    
    var slicerFilters:[JSON]?
    
    private var chartView:HIChartView!
    private var options:HIOptions!
    
    var collectionView:UICollectionView?
    
    var noDataLabel:UILabel?
    
    var legendEnabled:NSNumber = true {
        didSet{
            btnLegend.tintColor = legendEnabled == true ?  Utility.appThemeColor : UIColor.black
            options.legend.enabled = legendEnabled
        }
    }
    
    var selectedFilters:[JSON]?
    var selectedSortOptions:JSON?
    
    var cardValues = [(key:String, value:Double,columnId:String)]()
    var tableColumnWidths = [CGFloat]()
    
    let swiftHandler: @convention(block) (Int) -> Void = { dataPoint in
        print(dataPoint)
    }
    
    var webView:WKWebView?
    
    var drillDownOption:[NSDictionary] = []
    
    var drillDownInfo:NSDictionary? = [:]
    
    var chartLevel:Int = 0
    
    var drillFilter:[NSDictionary] = []
    
    var chartOptionProvider = OptionProvider()
    
    var chartLevelFilterValue:NSMutableDictionary = [:]
    
    var lv_enableDrillDown:UIView!
    
    var DrillDownStatus: Bool = false
    
    var drillButton:Bool = false
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.dataView
        
         chartOptionProvider.delegate = self
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        setTitle(chartOptions.name ?? "Pivot")
        
        
        //Set Images which support localization
        btnLegend.image = UIImage.init(named: NSLocalizedString("Legend", comment: ""))
        btnSort.image = UIImage.init(named: NSLocalizedString("Sort", comment: ""))
        
        btnFilter.image = UIImage.init(named: NSLocalizedString("Filter", comment: ""))
        
        btnShare.image = UIImage.init(named: NSLocalizedString("Share", comment: ""))
        
        drillDown.setImage(UIImage.init(named: NSLocalizedString("Drilldownall", comment: "")), for: .normal)
        drillDown.tintColor = UIColor.darkGray
        
        drillUp.setImage(UIImage.init(named: NSLocalizedString("Drillup", comment: "")), for: .normal)
        drillUp.tintColor = UIColor.darkGray
        
       
        
        if chartOptions.type == .Card{
            
            //Disable sort and legend buttons
            btnSort.isEnabled = false
            btnLegend.isEnabled = false
            
            let customLayout = CustomLayoutForCard()
            customLayout.cellHeight = 70
            collectionView = UICollectionView(frame: containerView.bounds, collectionViewLayout: 
                customLayout)
            guard let collectionView = self.collectionView else {return}
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = Utility.cardBGColor
            containerView.addSubview(collectionView)
            
            self.cardValues = chartOptions.cardValues
            
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CardCell")
            
            collectionView.reloadData()
            return
        } else if chartOptions.type == .Table {
            //Disable sort and legend buttons
            btnSort.isEnabled = false
            btnLegend.isEnabled = false
            btnFilter.isEnabled = false
            
            let tableHeaders = chartOptions.tableHeaders
            let tableValues = chartOptions.tableValues
            
            for  (columnIndex, header) in tableHeaders!.enumerated(){
                var columnValues = [String]()
                columnValues.append(header)
                columnValues.append(contentsOf: tableValues![columnIndex])
                
                var maxWidth:CGFloat = 0
                for colValue in columnValues{
                    let width = colValue.widthWithConstrainedHeight(height: 50, font: UIFont.systemFont(ofSize: 17))
                    if width>maxWidth{
                        maxWidth = width
                    }
                }
                self.tableColumnWidths.insert(maxWidth, at: columnIndex)
            }
            
            
            let customLayout = CustomLayoutForTable()
            customLayout.numberOfColumns = tableHeaders!.count
            customLayout.cellHeight = 50
            customLayout.delegate = self
            collectionView = UICollectionView(frame: containerView.bounds, collectionViewLayout:
                customLayout)
            guard let collectionView = self.collectionView else {return}
            collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            collectionView.dataSource = self
            collectionView.delegate = self
            
            collectionView.register(SlicerTitleHeader.self, forCellWithReuseIdentifier: "TitleHeader")
            collectionView.register(UINib.init(nibName: "SlicerTitleHeader", bundle: nil), forCellWithReuseIdentifier: "TitleHeader")
            
            collectionView.backgroundColor = .white
            containerView.addSubview(collectionView)
            collectionView.reloadData()
            return
        }
        
        if chartOptions.type == .Line || chartOptions.type == .Spline || chartOptions.type == .Scatter || chartOptions.type == .Bar || chartOptions.type == .Bar3D || chartOptions.type == .StackedBar || chartOptions.type == .StackedPercentageBar || chartOptions.type == .Column || chartOptions.type == .Column3D || chartOptions.type == .StackedColumn || chartOptions.type == .StackedPercentageColumn || chartOptions.type == .Area || chartOptions.type == .AreaSpline || chartOptions.type == .StackedArea || chartOptions.type == .StackedPercentageArea {
            DrillDownSetup()
        }
        
        if drillDownOption.count > 1 {
            let btnOptions = UIBarButtonItem(image: #imageLiteral(resourceName: "meat_balls").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(optionsButtonTapped(_:event:)))
            btnOptions.tintColor = .white
            
            self.navigationItem.rightBarButtonItems = [btnOptions]
        }
        
        chartView = HIChartView(frame: self.containerView.bounds)
        chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(chartView)
        
        options.legend.enabled = legendEnabled
        btnLegend.tintColor = Utility.appThemeColor
        options.chart.backgroundColor = HIColor(uiColor: .white)
        options.title.text = ""
        chartView.options = self.options
        
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {_ in
            if let layout = self.collectionView?.collectionViewLayout as? CustomLayoutForCard {
                layout.invalidateLayout()
            }
        }) { (_) in
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent{
        //Clear cache values if back button is tapped
        DataCacheManager.shared.clearEntireCache()
        }
    }
    
    //Custom layout delegate for table
    
    func widthForColumn(_ column: Int) -> CGFloat {
        return tableColumnWidths[column] + 32
        //32 is the sum of leading and trailing constraints of label(including some offset) in collectionview cell
    }

    //MARK: - Collectionview datasource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       //Card and Table charts are implemented using collectionview where as the remaining are from HighCharts library(Except pivot and timeline)
        if chartOptions.type == .Card{
        
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath)
            
            let card = cardValues[indexPath.item]
            
            if cell.contentView.viewWithTag(5) == nil {
                let cardComponent = CardViewComponent.instanceFromNib()
                cardComponent.tag = 5
                cardComponent.frame = cell.bounds
                cardComponent.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                cell.contentView.addSubview(cardComponent)
                
                let numberFormatOptions = CardViewComponent.formattingOptions(for: card.value, numberFormat: chartOptions.numberFormatMap , columnId: card.columnId)
                if let numberFormatOptions = numberFormatOptions {
                    cardComponent.lblTitle.text = numberFormatOptions.formattedString
                    if let fontColor = numberFormatOptions.fontColor {
                        cardComponent.lblTitle.textColor = fontColor
                    }
                    cardComponent.lblSubTitle.text = card.key
                } else {
                    cardComponent.lblTitle.text = card.value.description
                    cardComponent.lblSubTitle.text = card.key
                }
            }
            
            cell.backgroundColor = Utility.cardBGColor
            return cell
            
        } else if chartOptions.type == .Table {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleHeader", for: indexPath) as! SlicerTitleHeader
            
                let numberOfColumns = chartOptions.tableHeaders!.count
                let currentRow = indexPath.item/Int(numberOfColumns)
                let currentColumn = (indexPath.item - numberOfColumns*currentRow)
                
                var tableValue = ""
                
            if chartOptions.transposed == true {
                if indexPath.item < numberOfColumns {
                    tableValue = chartOptions.tableHeaders![indexPath.item]
                    if currentColumn == 0 {
                        cell.backgroundColor = .black
                        cell.lblTitle.textColor = .white
                    }
                    else{
                        cell.backgroundColor = .white
                        cell.lblTitle.textColor = .black
                    }
                    
                }else{
                    tableValue = chartOptions.tableValues[currentColumn][currentRow-1]
                    if currentColumn == 0 {
                        cell.backgroundColor = .black
                        cell.lblTitle.textColor = .white
                    }
                    else{
                        cell.lblTitle.textColor = .black
                        
                        if currentRow > 1 && currentRow % 2 == 0 {
                            cell.backgroundColor = .white
                        } else {
                            
                            cell.backgroundColor = UIColor(hex: "#FAFAFA")
                        }
                    }
                }
            }else{
                if indexPath.item < numberOfColumns {
                    tableValue = chartOptions.tableHeaders![indexPath.item]
                    cell.backgroundColor = .black
                    cell.lblTitle.textColor = .white
                } else {
                    tableValue = chartOptions.tableValues[currentColumn][currentRow-1]
                    cell.lblTitle.textColor = .black
                    
                    if currentRow > 1 && currentRow % 2 == 0 {
                        cell.backgroundColor = .white
                    } else {
                        
                        cell.backgroundColor = UIColor(hex: "#FAFAFA")
                    }
                }
            }
            
           
            cell.lblTitle.text = tableValue
            cell.lblTitle.font = UIFont.systemFont(ofSize: 17)
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if chartOptions.type == .Card {
            return self.cardValues.count
        } else if chartOptions.type == .Table{
            return chartOptions.tableHeaders.count + (chartOptions.tableValues[0].count * chartOptions.tableHeaders.count)
        }
        
        return 0
    }
    
    
    //Sort Delegate
    func selectedSortOption(_ sortOptionValue: JSON?, sortOptionType:SortOptions) {
        
        if sortOptionType == .none {
            btnSort.tintColor = UIColor.black
        } else {
            btnSort.tintColor = Utility.appThemeColor
        }
        
        guard chartOptions.type != .Card else {return}
        
        self.selectedSortOptions = sortOptionValue
        
        reloadDataView()
    }
    
    //Filter Delegate
    func selectedFilters(_ filter:[JSON]) {
//        guard chartOptions.type != .Card else {return}
        if filter.count > 0 {
            self.selectedFilters = filter
            btnFilter.tintColor = Utility.appThemeColor
        } else { //When user clears all filters, we pass default filter options
            self.selectedFilters = chartOptions.sortOptions//default sort options and filter options are same
            btnFilter.tintColor = .black
        }
        reloadDataView()
    }
    
    
    func reloadDataView(){
        self.showActivityIndicator()
        DataViewApiConroller.shared.chainedApiRequestForDataView(chartOptions.dataViewID, slicerFilters:slicerFilters, sortOptions:selectedSortOptions, filterOptions:selectedFilters,drillDownOptions: drillDownInfo!) { (response) in
            
            self.hideActivityIndicator()
            
            switch response {
            case .success(let chartOptions):
                
                if chartOptions.type == .Card{
                    self.noDataLabel?.removeFromSuperview()
                    self.cardValues = chartOptions.cardValues
                    self.collectionView?.reloadData()
                } else {
                    
                    self.noDataLabel?.removeFromSuperview()
                    self.noDataLabel = nil
                    self.options = self.chartOptionProvider.hiOptions(for: chartOptions)
                    self.options.legend.enabled = self.legendEnabled
                    self.options.chart.backgroundColor = HIColor(uiColor: .white)
                    self.options.title.text = ""
                    self.chartView.options = self.options
                    
                }
                
            case .failure(let error):
                self.hideActivityIndicator()
                
                if case let .failedWithStatusCode(code) = error, code == 204{
                    
                    if self.chartOptions.type == .Card{
                        self.cardValues.removeAll()
                        self.collectionView?.reloadData()
                    } else {
                        self.options.series = nil
                        self.chartView.options = self.options
                    }
                    
                    if self.noDataLabel == nil {
                        
                        self.noDataLabel = UILabel()
                        self.noDataLabel?.text  = NSLocalizedString("No data to display. Please check the underlying collection(s) connection details or filter criteria", comment: "") + "  "
                        
                        self.view.addSubview(self.noDataLabel!)
                        
                        self.noDataLabel?.numberOfLines = 0
                        self.noDataLabel?.frame = self.view.bounds
                        self.noDataLabel?.textAlignment = .center
                        self.noDataLabel?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    }
                    
                }
                //                print(error)
            
            case .failureJson(_):
                break
            }
        }
    }
    
    
    @IBAction func sortButtonTapped(_ sender: UIBarButtonItem) {
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "DataView", action: "Sort", label: "\(chartOptions.name ?? "")", value: nil).build() as? [AnyHashable : Any])
        }
        
        let sortVC = self.storyboard?.instantiateViewController(withIdentifier: "SortViewController") as! SortViewController
        sortVC.sortOptions = chartOptions.sortOptions
        sortVC.delegate = self
        sortVC.modalPresentationStyle = .overCurrentContext
        self.present(sortVC, animated: true, completion: nil)
    }
    
    @IBAction func filterButtonTaped(_ sender: UIBarButtonItem) {
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "DataView", action: "Filter", label: "\(chartOptions.name ?? "")", value: nil).build() as? [AnyHashable : Any])
        }
        
        let filterNavVC = self.storyboard?.instantiateViewController(withIdentifier: "FilterNavVC") as!  UINavigationController
        
        
        let filterVC = filterNavVC.viewControllers.first as! MainFilterViewController
        filterVC.filterOptions = chartOptions.sortOptions //Filter and sort options are same
        filterVC.basicFilterValues = chartOptions.filterValuesForColumn ?? [:]
        filterVC.preDefinedFilters = chartOptions.preDefinedFilters
        filterVC.delegate = self
        filterVC.dataViewID = chartOptions.dataViewID
        filterVC.modalPresentationStyle = .overFullScreen
        self.present(filterNavVC, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "DataView", action: "Share", label: "\(chartOptions.name ?? "")", value: nil).build() as? [AnyHashable : Any])
        }
        
        let screenShot:UIImage?
        
        //Card and table uses collection view, pivot uses webview and other charts uses chartView (Highcharts)
        if chartOptions.type == .Card || chartOptions.type == .Table{
            screenShot = containerView?.screenshotView()
        } else if chartOptions.type == .Pivot {
            screenShot = webView?.screenshotView()
        } else {
            screenShot = self.chartView.screenshotView()
        }
        
        let shareScreen = self.storyboard?.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        shareScreen.screenShotImage = screenShot
        shareScreen.modalPresentationStyle = .fullScreen
        self.present(shareScreen, animated: true, completion: nil)
    }
    
    @IBAction func toggleLegend(_ sender: UIBarButtonItem) {
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "DataView", action: "Legend", label: "\(chartOptions.name ?? "")", value: nil).build() as? [AnyHashable : Any])
        }

        guard chartOptions.type != .Card else {return}

        if legendEnabled == true {
            legendEnabled = false
        } else {
            legendEnabled = true
        }
        
        chartView.options = self.options
    }
    
    //MARK: - DrillDown Function
    
    func DrillDownSetup(){
        if chartOptions.type != .Table || chartOptions.type != .Card  {
            for eachitem in chartOptions.sortOptions{
                if eachitem["configZone"] == "axis"{
                    drillDownOption.append(eachitem.dictionary! as NSDictionary)
                }
            }
        }
        if chartOptions.drilldown == true {
            self.drillViewHeight.constant = 40
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
                self.drillUp.isHidden = false
                self.drillDown.isHidden = false
                self.drillLabel.isHidden = false
            }
            DrillDownStatus = true
            self.drillLabel.text = "\(drillDownOption[chartLevel]["columnName"]!)"
        }else{
            self.drillViewHeight.constant = 0
            UIView.animate(withDuration: 0) {
                self.view.layoutIfNeeded()
                self.drillUp.isHidden = true
                self.drillDown.isHidden = true
                self.drillLabel.isHidden = true
            }
            DrillDownStatus = false
        }
        
        if chartLevel != drillDownOption.count-1 {
            self.drillDown.isEnabled = true
            self.drillUp.isEnabled = false
        }
    }
    
    
    @objc func optionsButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        var ls_drillDownValue:String?
        
        if chartOptions.drilldown == true{
            ls_drillDownValue = NSLocalizedString("Disable Drilldown", comment: "")
        }else{
            ls_drillDownValue = NSLocalizedString("Enable Drilldown", comment: "")
        }
        
        if drillButton == false {
            drillButton = true
            let MorebuttonTap = UITapGestureRecognizer(target: self, action: #selector(self.buttonTapped(_:)))
            
            let tappedOutside = UITapGestureRecognizer(target: self, action: #selector(self.DismissViewTap(_:)))
            
            lv_enableDrillDown = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            lv_enableDrillDown.backgroundColor = UIColor.clear
            lv_enableDrillDown.addGestureRecognizer(tappedOutside)
            
            self.view.addSubview(lv_enableDrillDown)
            
            let enableDrillDown = UILabel(frame: CGRect(x: self.view.frame.width-175, y: 0, width: 175, height: 50))
            enableDrillDown.textAlignment = .center
            enableDrillDown.text = ls_drillDownValue
            enableDrillDown.backgroundColor = UIColor.white
            enableDrillDown.layer.borderColor = UIColor.darkGray.cgColor
            enableDrillDown.layer.borderWidth = 1.0
            enableDrillDown.addGestureRecognizer(MorebuttonTap)
            enableDrillDown.isUserInteractionEnabled = true
            lv_enableDrillDown.addSubview(enableDrillDown)
            DrillDownStatus = true
            
        }else{
            self.lv_enableDrillDown.removeFromSuperview()
             drillButton = false
            DrillDownStatus = false
        }
    }
    
    // function which is triggered when handleTap is called
    @objc func buttonTapped(_ sender: UITapGestureRecognizer) {
        if self.chartOptions.drilldown == true{
            self.chartOptions.drilldown = false
            self.drillViewHeight.constant = 0
            DrillDownStatus = false
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.drillUp.isHidden = true
                self.drillDown.isHidden = true
                self.drillLabel.isHidden = true
            }
            self.drillLabel.text = ""
        }else{
            self.chartOptions.drilldown = true
            self.drillViewHeight.constant = 40
            DrillDownStatus = true
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
                self.drillUp.isHidden = false
                self.drillDown.isHidden = false
                self.drillLabel.isHidden = false
            }
            self.drillLabel.text = "\(drillDownOption[chartLevel]["columnName"]!)"
        }
        self.lv_enableDrillDown.removeFromSuperview()
        drillButton = false
    }
    
    @objc func DismissViewTap(_ sender: UITapGestureRecognizer) {
        self.lv_enableDrillDown.removeFromSuperview()
         DrillDownStatus = false
    }
    
    
    
    //MARK: - ChartPointSelect Delegate
    
    func didPointSelected(context:HIChartContext){
        
        if drillButton == false {
            if DrillDownStatus ==  true {
                if chartLevel < drillDownOption.count-1 {
                    var FilterValue:NSDictionary = [:]
                    FilterValue = ["columnType": drillDownOption[chartLevel]["columnType"]!, "operator": "equal", "columnId": drillDownOption[chartLevel]["columnId"]!, "value": ["\(context.getProperty("this.category")!)"]]
                    
                    chartLevelFilterValue.setValue(FilterValue, forKey: "\(chartLevel)")
                    
                    drillFilter = chartLevelFilterValue.allValues as! [NSDictionary]
                    
                    drillDownInfo = ["drillDownAll":"false","level":drillDownOption[chartLevel+1]["columnId"]!,"configZone":"axis","filters":drillFilter,"drillDown":"true"]
                    chartLevel += 1
                    reloadDataView()
                }
                
                self.drillLabel.text = "\(drillDownOption[chartLevel]["columnName"]!)"
            }
        }else{
            self.lv_enableDrillDown.removeFromSuperview()
            drillButton = false
             DrillDownStatus = false
        }
        
        if chartLevel == 0{
            self.drillDown.isEnabled = true
            self.drillUp.isEnabled = false
        }else if chartLevel == drillDownOption.count-1 {
            self.drillDown.isEnabled = false
            self.drillUp.isEnabled = true
        }else{
            self.drillDown.isEnabled = true
            self.drillUp.isEnabled = true
        }
        
    }
    
    
    //MARK: - IBAction
    @IBAction func drillDownClicked(_ sender: Any) {
        if chartLevel < drillDownOption.count-1 {
            chartLevel += 1
            drillDownInfo = ["drillDownAll":"true","level":drillDownOption[chartLevel]["columnId"]!,"configZone":"axis","filters":[],"drillDown":"true"]
            self.drillLabel.text = "\(drillDownOption[chartLevel]["columnName"]!)"
            reloadDataView()
        }
        
        
        if chartLevel == drillDownOption.count-1 {
            self.drillDown.isEnabled = false
            self.drillUp.isEnabled = true
        }else{
            self.drillDown.isEnabled = true
            self.drillUp.isEnabled = true
        }
        
    }
    
    @IBAction func drillUpClicked(_ sender: Any) {
        if drillFilter.count == 0 {
            if chartLevel > 0 {
                chartLevel -= 1
                drillDownInfo = ["drillDownAll":"true","level":drillDownOption[chartLevel]["columnId"]!,"configZone":"axis","filters":[],"drillDown":"true"]
                self.drillLabel.text = "\(drillDownOption[chartLevel]["columnName"]!)"
                reloadDataView()
            }
        }
        else{
            chartLevel -= 1
            chartLevelFilterValue.removeObject(forKey: "\(chartLevel)")
            drillFilter = chartLevelFilterValue.allValues as! [NSDictionary]
           
            drillDownInfo = ["drillDownAll":"false","level":drillDownOption[chartLevel]["columnId"]!,"configZone":"axis","filters":drillFilter,"drillDown":"true"]
            self.drillLabel.text = "\(drillDownOption[chartLevel]["columnName"]!)"
            reloadDataView()
        }
        
        
        if chartLevel == 0 {
            self.drillDown.isEnabled = true
            self.drillUp.isEnabled = false
        }else{
            self.drillDown.isEnabled = true
            self.drillUp.isEnabled = true
        }
 
    }
    
}

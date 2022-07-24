//
//  InsightDetailViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 06/12/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit
import WebKit


enum Tags:Int{
    case chartView = 500
    case noDataLabel = 600
    case unSupportedLabel = 700
    case webView = 800
    case card = 900
    case unableToRender = 1000
}


final class InsightDetailViewController: UIViewController, HUDRenderer, UICollectionViewDataSource, UICollectionViewDelegate, CustomLayoutDelegateForTable {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView:UITableView?
    
    //MARK: - Variable
    
    private var dataViews = [String](){
        didSet{
            tableView?.reloadData()
        }
    }
    
    public var insight:Insight!{
        didSet{
            dataViews = insight.selectedDataviewIds
            // print(dataViews)
        }
    }
    
    
    
    var cachedResponse = [Int:ChartOptionsModel]()
    
    var apiFiredLookUp = [Int:Bool]()
    
    let optionsProvider = OptionProvider()
    
    var preSelectedSlicerFilters : [String:[JSON]]? = nil //Fed from previous vc
    
    private var slicerFilters : [String : [JSON]]? = nil //Raw slicer populated by slicer screen selection
    
    private var slicerLookUp = [String:[JSON]]()  // [DataviewId:SlicerFilters]   Final slicers that can be passed to api. Populated in cell for row and passed to next screen on did select
    
    var titleString = ""
    
    var tableColumnWidths = [CGFloat]()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.separatorStyle = .none
        self.tableView?.contentInsetAdjustmentBehavior = .never
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.hidesBackButton = false
        setTitle(titleString)
        
        if dataViews.count == 0 {
            let label = UILabel()
            label.text  = NSLocalizedString("No data to display.", comment: "")
            label.numberOfLines = 0
            label.sizeToFit()
            label.textAlignment = .center
            tableView?.backgroundView = label
        } else {
            tableView?.backgroundView = nil
        }
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadAllDataViews), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if dataViews.count != 0 {
            tableView?.reloadData()
        }
    }
    
    func refreshDataViews(filters:[String : [JSON]]){
        //Filters is in the format [dataViewID: [array of selected filter values]]
        self.slicerFilters = filters
        
        //Change the apiFired flag to false for those dataviews to be refreshed
        var indexPaths = [IndexPath]()
        for (dataViewId, _) in filters {
            
            if let index = self.dataViews.firstIndex(of: dataViewId) {
                //                print(dataViewId)
                apiFiredLookUp[index] = false
                let indexPath = IndexPath(row: index, section: 0)
                indexPaths.append(indexPath)
            }
        }
        tableView?.reloadRows(at: indexPaths, with: .automatic)
    }
    
    @objc
    func reloadAllDataViews(){
        apiFiredLookUp.removeAll()
        tableView?.refreshControl?.endRefreshing()
        tableView?.reloadData()
    }
    
}

extension InsightDetailViewController : UITableViewDataSource, UITableViewDelegate, HIChartViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        print(dataViews.count)
        return dataViews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = "ChartCell\(indexPath.row)"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        
        let dataViewID = dataViews[indexPath.row]
        
        if  apiFiredLookUp[indexPath.row] == nil || !apiFiredLookUp[indexPath.row]! {
            //First time api hit
            
            //            print("API hit for cell\(indexPath.row)")
            
            let loadingIndicator = UIActivityIndicatorView(style: .gray)
            loadingIndicator.center = CGPoint(x: self.view.frame.width/2, y: (tableView.frame.size.height * 0.75)/2)
            loadingIndicator.startAnimating()
            cell.contentView.addSubview(loadingIndicator)
            
            var slicers:[JSON]? = nil
            
            if let slicer = self.slicerFilters {
                var filterArray = [JSON]()
                for (targetDataViewId, slicerFilterArray) in slicer where targetDataViewId == dataViewID {
                    filterArray.append(contentsOf: slicerFilterArray)
                }
                slicers = filterArray
                slicerLookUp[dataViewID] = slicers
            } else if let preSelectedSlicer = self.preSelectedSlicerFilters{
                
                var filterArray = [JSON]()
                for (targetDataViewId, slicerFilterArray) in preSelectedSlicer where targetDataViewId == dataViewID {
                    filterArray.append(contentsOf: slicerFilterArray)
                }
                slicers = filterArray
                slicerLookUp[dataViewID] = slicers
            }
            
            
            
            DataViewApiConroller.shared.chainedApiRequestForDataView(dataViewID, slicerFilters : slicers) { (response) in
                
                switch response {
                case .success(let chartOptions):
                    
                    self.cachedResponse[indexPath.row] = chartOptions
                    
                    if chartOptions.type == .Card {
                        
                        if let existingCard = cell.viewWithTag(Tags.card.rawValue){
                            existingCard.removeFromSuperview()
                        }
                        
                        //Remove no data label
                        if let label = cell.viewWithTag(Tags.noDataLabel.rawValue) as? UILabel {
                            label.removeFromSuperview()
                        }
                        
                        //Remove Unsupported Label
                        if let label = cell.viewWithTag(Tags.unSupportedLabel.rawValue) as? UILabel {
                            label.removeFromSuperview()
                        }
                        
                        //Remove unableToRender label
                        if let label = cell.viewWithTag(Tags.unableToRender.rawValue) as? UILabel {
                            label.removeFromSuperview()
                        }
                        
                        let card = CardViewComponent.getCardStackView(withOptions: chartOptions)
                        
                        cell.backgroundColor = Utility.chartListSeperatorColor
                        
                        card.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        
                        let containerView = UIView(frame: cell.bounds.insetBy(dx: 0, dy: 5))
                        containerView.backgroundColor = Utility.cardBGColor
                        
                        card.frame = containerView.bounds.insetBy(dx: 0, dy: 5)
                        containerView.addSubview(card)
                        
                        loadingIndicator.stopAnimating()
                        loadingIndicator.removeFromSuperview()
                        
                        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        
                        containerView.tag = Tags.card.rawValue
                        
                        cell.addSubview(containerView)
                        
                        UIView.setAnimationsEnabled(false)
                        tableView.beginUpdates()
                        tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                        return
                    } else if chartOptions.type == .ComboSlicer || chartOptions.type == .CheckSlicer || chartOptions.type == .RadioSlicer || chartOptions.type == .TagSlicer || chartOptions.type == .DateRangeSlicer {
                        self.hideActivityIndicator()
                        loadingIndicator.stopAnimating()
                        loadingIndicator.removeFromSuperview()
                        //                        self.slicerOptions.append(chartOptions)
                        UIView.setAnimationsEnabled(false)
                        tableView.beginUpdates()
                        tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                        return
                    } else if chartOptions.type == .Pivot || chartOptions.type == .PointTime || chartOptions.type == .SplineTime || chartOptions.type == .AreaTime || chartOptions.type == .AreaSplineTime || chartOptions.type == .LineTime || chartOptions.type == .ColumnTime || chartOptions.type == .DotMap {
                        
                        loadingIndicator.stopAnimating()
                        loadingIndicator.removeFromSuperview()
                        
                        let webServerUrl = UserDefaults.standard.string(forKey: UserDefaultsKeys.webServerUrl.rawValue) ?? "http://demo.ios.ekaanalytics.com:8080/apps/WebviewApp"
                        
                        //                        //Temporary fix
                        //                        webServerUrl = webServerUrl.replacingOccurrences(of: "ekaanalytics", with: "ekaplus")
                        
                        if let url = URL(string: webServerUrl){
                            var request = URLRequest.init(url: url)
                            request.cachePolicy = .returnCacheDataElseLoad
                            
                            if self.slicerLookUp[chartOptions.dataViewID!] == nil {
                                if let webview = cell.viewWithTag(Tags.webView.rawValue) as? WKWebView {
                                    webview.load(request)
                                    return
                                }
                            }
                            
                            let config = WKWebViewConfiguration()
                            let contentController = WKUserContentController()
                            
                            var js =  "sessionStorage.clear();"
                            js = js + "sessionStorage.setItem('accessToken', '\(UserDefaults.standard.string(forKey: UserDefaultsKeys.accessToken.rawValue) ?? "")');sessionStorage.setItem('dId', '\(chartOptions.dataViewID!)');sessionStorage.setItem('chartType', '\(chartOptions.type.rawValue)');sessionStorage.setItem('deviceId', '\(Utility.getVendorID())');sessionStorage.setItem('showToolbar', 'false');"
                            
                            if chartOptions.type.rawValue == "DotMap" {
                                js = js + "sessionStorage.setItem('mapNavigation', 'false');"
                            }
                            
                            if self.slicerLookUp[chartOptions.dataViewID!] != nil {
                                js = js + "sessionStorage.setItem('filters',JSON.stringify( \(self.slicerLookUp[chartOptions.dataViewID!]!)));"
                            }
                            
                            let userScript = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
                            contentController.addUserScript(userScript)
                            
                            config.userContentController = contentController
                            
                            let webView = WKWebView(frame: self.view.bounds, configuration: config)
                            webView.isUserInteractionEnabled =  false
                            webView.frame = cell.bounds.insetBy(dx: 0, dy: 5)
                            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            webView.tag = Tags.webView.rawValue
                            cell.addSubview(webView)
                            
                            webView.translatesAutoresizingMaskIntoConstraints = false
                            webView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0).isActive = true
                            webView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0).isActive = true
                            webView.topAnchor.constraint(equalTo: cell.topAnchor, constant: -20).isActive = true
                            webView.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0).isActive = true
                            webView.load(request)
                        }
                        return
                    } else if chartOptions.type == .Table{
                        
                        //Dispatch the processing on to a background thread and return.
                        DispatchQueue.global(qos: .userInteractive).async {
                            
                            let tableHeaders = chartOptions.tableHeaders
                            let tableValues = chartOptions.tableValues
                            
                            //Calculate max width of each table column by iterating through all the data.
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
                            
                            //Configure UI on main thread
                            DispatchQueue.main.async {
                                
                                let collectionView = UICollectionView(frame: cell.bounds, collectionViewLayout:
                                                                        customLayout)
                                collectionView.dataSource = self
                                collectionView.delegate = self
                                
                                collectionView.register(SlicerTitleHeader.self, forCellWithReuseIdentifier: "TitleHeader")
                                collectionView.register(UINib.init(nibName: "SlicerTitleHeader", bundle: nil), forCellWithReuseIdentifier: "TitleHeader")
                                
                                collectionView.tag = indexPath.row//Used in collectionview datasource to get chartOptions
                                collectionView.backgroundColor = .white
                                collectionView.isUserInteractionEnabled = false
                                
                                let titleLabel = UILabel()
                                titleLabel.text = chartOptions.name
                                titleLabel.textAlignment = .center
                                titleLabel.font = UIFont.systemFont(ofSize: 19)
                                
                                
                                titleLabel.backgroundColor = .black
                                titleLabel.textColor = .white
                                
                                titleLabel.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 80)
                                
                                let stackView = UIStackView()
                                stackView.axis = .vertical
                                stackView.addArrangedSubview(titleLabel)
                                stackView.addArrangedSubview(collectionView)
                                stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                stackView.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.size.width, height: cell.bounds.size.height - 15)
                                stackView.spacing = 1
                                
                                
                                cell.contentView.addSubview(stackView)
                                cell.contentView.clipsToBounds = true
                                collectionView.reloadData()
                            }
                            
                        }
                        return
                    }
                    
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                    
                    //Remove no data label
                    if let label = cell.viewWithTag(Tags.noDataLabel.rawValue) as? UILabel {
                        label.removeFromSuperview()
                    }
                    
                    //Remove Unsupported Label
                    if let label = cell.viewWithTag(Tags.unSupportedLabel.rawValue) as? UILabel {
                        label.removeFromSuperview()
                    }
                    
                    //Remove unableToRender label
                    if let label = cell.viewWithTag(Tags.unableToRender.rawValue) as? UILabel {
                        label.removeFromSuperview()
                    }
                    
                    let options = self.optionsProvider.hiOptions(for: chartOptions)
                    //If chartView is already there, just update options
                    if let chartView = cell.viewWithTag(Tags.chartView.rawValue) as? HIChartView {
                        chartView.options = options
                        return
                    }
                    
                    //Else add the chart view to cell
                    let  chartView = HIChartView()
                    chartView.isUserInteractionEnabled = false
                    chartView.frame = cell.bounds.insetBy(dx: 0, dy: 5)
                    chartView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    chartView.options = options
                    chartView.tag = Tags.chartView.rawValue
                    cell.addSubview(chartView)
                    chartView.delegate = self
                    
                case .failure(let error):
                    self.hideActivityIndicator()
                    loadingIndicator.stopAnimating()
                    loadingIndicator.removeFromSuperview()
                    
                    switch error {
                    case .unsupportedChart(_):
                        
                        if let chartView = cell.viewWithTag(Tags.chartView.rawValue) as? HIChartView{
                            chartView.removeFromSuperview()
                        }
                        
                        guard cell.viewWithTag(Tags.unSupportedLabel.rawValue) == nil else {return}
                        
                        let label = UILabel()
                        label.text  = error.description
                        label.tag = Tags.unSupportedLabel.rawValue
                        cell.addSubview(label)
                        
                        label.numberOfLines = 0
                        label.frame = cell.bounds
                        label.textAlignment = .center
                        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        
                    case .failedWithStatusCode(let code):
                        
                        switch code{
                        case 204:
                            //Remove the cached response.
                            self.cachedResponse.removeValue(forKey: indexPath.row)
                            
                            //Remove any existing chart view
                            if let chartView = cell.viewWithTag(Tags.chartView.rawValue) as? HIChartView{
                                chartView.removeFromSuperview()
                            }
                            
                            //Remove any existing card view
                            if let cardView = cell.viewWithTag(Tags.card.rawValue){
                                cardView.removeFromSuperview()
                            }
                            
                            //Remove unableToRender label
                            if let label = cell.viewWithTag(Tags.unableToRender.rawValue) as? UILabel {
                                label.removeFromSuperview()
                            }
                            
                            //Remove Unsupported Label
                            if let label = cell.viewWithTag(Tags.unSupportedLabel.rawValue) as? UILabel {
                                label.removeFromSuperview()
                            }
                            
                            guard cell.viewWithTag(Tags.noDataLabel.rawValue) == nil else {return}
                            
                            let label = UILabel()
                            label.text  = NSLocalizedString("No data to display. Please check the underlying collection(s) connection details or filter criteria", comment: "")
                            
                            label.tag = Tags.noDataLabel.rawValue
                            cell.addSubview(label)
                            
                            label.numberOfLines = 0
                            label.frame = cell.bounds
                            label.textAlignment = .center
                            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        case 403:
                            if let chartView = cell.viewWithTag(Tags.chartView.rawValue) as? HIChartView{
                                chartView.removeFromSuperview()
                            }
                            
                            //Remove no data label
                            if let label = cell.viewWithTag(Tags.noDataLabel.rawValue) as? UILabel {
                                label.removeFromSuperview()
                            }
                            
                            //Remove Unsupported Label
                            if let label = cell.viewWithTag(Tags.unSupportedLabel.rawValue) as? UILabel {
                                label.removeFromSuperview()
                            }
                            
                            guard cell.viewWithTag(Tags.unableToRender.rawValue) == nil else {return}
                            
                            let label = UILabel()
                            label.text  = NSLocalizedString("User Unauthorized.", comment: " ")
                            
                            label.tag = Tags.unableToRender.rawValue
                            cell.addSubview(label)
                            
                            label.numberOfLines = 0
                            label.frame = cell.bounds
                            label.textAlignment = .center
                            label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            
                            print(error.description)
                        default:
                            break
                        }
                        
                    default:
                        
                        if let chartView = cell.viewWithTag(Tags.chartView.rawValue) as? HIChartView{
                            chartView.removeFromSuperview()
                        }
                        
                        //Remove no data label
                        if let label = cell.viewWithTag(Tags.noDataLabel.rawValue) as? UILabel {
                            label.removeFromSuperview()
                        }
                        
                        //Remove Unsupported Label
                        if let label = cell.viewWithTag(Tags.unSupportedLabel.rawValue) as? UILabel {
                            label.removeFromSuperview()
                        }
                        
                        guard cell.viewWithTag(Tags.unableToRender.rawValue) == nil else {return}
                        
                        let label = UILabel()
                        label.text  = NSLocalizedString("Unable to render chart.", comment: " ")
                        
                        label.tag = Tags.unableToRender.rawValue
                        cell.addSubview(label)
                        
                        label.numberOfLines = 0
                        label.frame = cell.bounds
                        label.textAlignment = .center
                        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                        
                        print(error.description)
                    }
                    
                    
                case .failureJson(_):
                    break
                }
            }
            apiFiredLookUp[indexPath.row] = true
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = Utility.chartListSeperatorColor
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let type = cachedResponse[indexPath.row]?.type
        
        if type == .Card {
            return tableView.frame.size.height * 0.5
        } else if type == .ComboSlicer || type == .CheckSlicer || type == .RadioSlicer || type == .TagSlicer || type == .DateRangeSlicer{
            return 0
        }
        
        return  tableView.frame.size.height * 0.75
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  tableView.frame.size.height * 0.75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let chartOptions = cachedResponse[indexPath.row] {
            
            //Google Analytics event tracking
            if let tracker = GAI.sharedInstance().defaultTracker {
                tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "DataView", action: "View", label: "\(chartOptions.name ?? "")", value: nil).build() as? [AnyHashable : Any])
            }
            
            if chartOptions.type == .Pivot || chartOptions.type == .PointTime || chartOptions.type == .SplineTime || chartOptions.type == .AreaTime || chartOptions.type == .AreaSplineTime || chartOptions.type == .LineTime || chartOptions.type == .ColumnTime || chartOptions.type == .DotMap {
                let pivotController = self.storyboard?.instantiateViewController(withIdentifier: "PivotViewContoller") as! PivotViewController
                pivotController.chartOptions = chartOptions
                pivotController.slicerLookUp = self.slicerLookUp[chartOptions.dataViewID!]
                pivotController.modalPresentationStyle = .overCurrentContext
                self.present(pivotController, animated: true, completion: nil)
                
            } else {
                
                let chartDataViewVC = self.storyboard?.instantiateViewController(withIdentifier: "ChartDataViewController") as! ChartDataViewController
                chartDataViewVC.chartOptions = chartOptions
                
                let dataViewID = dataViews[indexPath.row]
                chartDataViewVC.slicerFilters = slicerLookUp[dataViewID]
                
                self.navigationController?.pushViewController(chartDataViewVC, animated: true)
            }
        }
    }
    
    
    //ChartView delegate
    
    func chartViewDidLoad(_ chart: HIChartView!) {
        self.hideActivityIndicator()
    }
    
    //Collectionview delegate for Table chart
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleHeader", for: indexPath) as! SlicerTitleHeader
        
        let chartOptions = self.cachedResponse[collectionView.tag]!
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
                    cell.backgroundColor = UIColor(hex: "#FAFAFA")
                } else {
                    cell.backgroundColor = .white
                }
            }
        }
        
        cell.lblTitle.text = tableValue
        cell.lblTitle.font = UIFont.systemFont(ofSize: 17)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let chartOptions = self.cachedResponse[collectionView.tag]!
        return chartOptions.tableHeaders.count + (chartOptions.tableValues[0].count * chartOptions.tableHeaders.count)
    }
    
    //Custom layout delegate for table
    
    func widthForColumn(_ column: Int) -> CGFloat {
        return tableColumnWidths[column] + 32
        //32 is the sum of leading and trailing constraints of label(including some offset) in collectionview cell
    }
    
    func exportInsight(){
        let pdfPath = Utility.tableViewPdfCreator(view: self.view, tableView: tableView!, fileName: "Insight_\(Int(Date().timeIntervalSince1970 * 1000))")
        
        if FileManager.default.fileExists(atPath: pdfPath.path) {
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [pdfPath], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        } else {
            print("document was not found")
        }
    }
    
}

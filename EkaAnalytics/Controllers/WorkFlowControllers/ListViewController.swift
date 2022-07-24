//
//  ListViewController.swift
//  Dynamic App
//
//  Created by Shreeram on 17/04/19.
//  Copyright © 2019 GWL. All rights reserved.
//

import UIKit
import QuickLook

protocol ListViewDelegate {
    func SegmentedTitle(workFlowName:String,listCount:String)
}

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,HUDRenderer,SortScreenDelegate,WF_MainFilterScreenDelegate,QLPreviewControllerDataSource,WFHamburgerMenuDelegate {
    
    //MARK: - Variable
    var app:App!
    //    var ls_Selectedappname:String?
    var larr_Datasource:[[[NSMutableAttributedString]]] = []
    var larr_Decision:[JSON]?
    var ls_ScreenTitle:String?
    var ls_appName:String = ""
    var ls_objectName:String?
    var ls_taskName:String?
    var larr_rawData:[JSON]?
    var ldict_Decision:JSON?
    var ldict_rowDecision:JSON?
    var larr_dropDownServiceKey:[[String:Any]]=[]
    var ldict_dropdownData:JSON = [:]
    var larr_SortList:[String] = []
    var larr_FilterList:[JSON] = []
    var ldict_object:[String:JSON] = [:]
    var FilterValue:Bool = true
    var lb_ScreenHeight:Bool = true
    var ldict_ScreenData:JSON?
    var larr_operation:[String] = []
    var sortOption:[[String:Any]] = []
    var filterOption:[String:Any] = [:]
    var searchOption:[String:Any] = [:]
    var lb_Search:Bool = false
    var previousScreenResponse:JSON?
    var layoutJson:JSON?
    var ls_selectedQueryParameter:String? = nil
    lazy var webServerUrl = NSURL()
    var larr_navbarDetails:JSON?
    var menuVC:WorkFlowMenuViewController!
    var isHome:Bool = false
    var ls_HomeWorkFlow:String?
    var ls_previousWorkflow:String?
    var filtersSelected:[String:[String]]? = nil
    var searchController: UISearchController!
    var ls_searchString:String = ""
    
    var delegate:ListViewDelegate?
    
    var li_refreshFlag:Bool = false
    
    let defaultPageSize = 10
    var DataCurrentpage = 0
    
    lazy var DynamicApiController:DynamicAppApiController = {
        return DynamicAppApiController()
    }()
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if app != nil && isHome == true {
            self.getnavBarDetails()
        }
        
        self.setupdata()
        
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        if ls_ScreenTitle != nil {
            DispatchQueue.main.async {
                self.setTitle("\(self.ls_ScreenTitle!)")
            }
        }
        
        let BackButton = UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action:  #selector(goBack))
        
        self.navigationItem.setLeftBarButtonItems([BackButton], animated: true)
        
        var rightBarbutton:[UIBarButtonItem] = []
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPage), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        //Set screen size
        if lb_ScreenHeight == true{
            if larr_FilterList.count > 0 || larr_SortList.count > 0 || lb_Search == true {
                if larr_FilterList.count > 0 || larr_SortList.count > 0 || lb_Search == true{
                    if self.ls_ScreenTitle == nil {
                        self.tableViewHeight.constant = self.view.frame.height-109
                    }else{
                        self.tableViewHeight.constant = self.view.frame.height-44
                    }
                }
                else{
                    self.tableViewHeight.constant = self.view.frame.height-110
                }
            }else{
                self.tableViewHeight.constant = self.view.frame.height
            }
        }else{
            if lb_Search == true{
                self.tableViewHeight.constant = self.view.frame.height-150
            }else{
                self.tableViewHeight.constant = self.view.frame.height
            }
        }
        
        if larr_rawData?.count == 0 || larr_rawData == nil {
            tableView.noDataMessage = "No Data"
        }else{
            tableView.noDataMessage = nil
        }
        
        if larr_Decision != nil && larr_Decision!.count > 0{
            for n in 0...larr_Decision!.count-1 {
                
                switch self.larr_Decision![n]["position"].stringValue {
                case "default":
                    let rightBtn1 = UIButton(type: .custom)
                    
                    if self.larr_Decision![n]["label"].string != nil {
                        rightBtn1.setTitle(larr_Decision![n]["label"].stringValue, for: .normal)
                    }else if self.larr_Decision![n]["iconClass"] != nil {
                        rightBtn1.setImage(UIImage(named: larr_Decision![n]["iconClass"].stringValue), for: .normal)
                    }
                case "row-selection":
                    self.ldict_rowDecision = larr_Decision![n]
                default:
                    if self.larr_Decision![n]["selection"].stringValue == "default" {
                        let rightBtn1 = UIButton(type: .custom)
                        
                        if self.larr_Decision![n]["label"].string != nil {
                            rightBtn1.setTitle(larr_Decision![n]["label"].stringValue, for: .normal)
                        }else if self.larr_Decision![n]["iconClass"] != nil {
                            rightBtn1.setImage(UIImage(named: larr_Decision![n]["iconClass"].stringValue), for: .normal)
                        }
                        
                        rightBtn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                        rightBtn1.tag = n
                        rightBtn1.addTarget(self, action: #selector(rightBtn1Tapped(_:)), for: .touchUpInside)
                        
                        let rightBtn1item = UIBarButtonItem(customView: rightBtn1)
                        
                        rightBarbutton.append(rightBtn1item)
                    }
                }
                
            }
        }
        
        if self.DataCurrentpage == 0 {
            self.larr_rawData = []
        }
        self.navigationItem.setRightBarButtonItems(rightBarbutton, animated: true)
        
        tableView.estimatedRowHeight = 150
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //        AppUtility.lockOrientation(.all , andRotateTo: .portraitUpsideDown)
        li_refreshFlag = true
        refreshPage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if larr_FilterList.count > 0 || larr_SortList.count > 0 || lb_Search == true {
            switch UIDevice.current.name {
            case "iPhone 6","iPhone 6 Plus","iPhone 6S","iPhone 6S Plus","iPhone 7","iPhone 7 Plus","iPhone 8","iPhone 8 Plus":
                preferredContentSize = CGSize(width: self.view.bounds.width, height:  UIScreen.main.bounds.height - (navigationController?.toolbar.frame.size.height)! - (navigationController?.navigationBar.frame.size.height)! - 35)
            default:
                preferredContentSize = CGSize(width: self.view.bounds.width, height:  UIScreen.main.bounds.height - (navigationController?.toolbar.frame.size.height)! - (navigationController?.navigationBar.frame.size.height)! - 65)
            }
        }else{
            preferredContentSize = self.tableView.contentSize
        }
    }
    
    //MARK: - Tableview Delegate and Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if layoutJson != nil{
            if larr_Datasource.count > 0 {
                tableView.noDataMessage = nil
            }
            return larr_Datasource.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if ls_taskName! == "documentlisting"{
        //            let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath) as! DocumentTableViewCell
        //            let rowData = larr_Datasource[indexPath.row]
        //
        //            cell.lbtn_btn1.tag = indexPath.row
        //            cell.lbtn_btn1.isHidden = true
        //
        //            if layoutJson != nil {
        //                for each in layoutJson!["flow"][ls_taskName!]["fields"].arrayValue {
        //                    if each["placement"] == "Row1" {
        //                        cell.lbl_row0.text! = larr_rawData![indexPath.row]["\(each["key"])"].stringValue
        //
        //                    }else if each["placement"] == "Row2" {
        //                         cell.lbl_row1.text! = larr_rawData![indexPath.row]["\(each["key"])"].stringValue
        //                        if each["style"] != nil {
        //                            if let colour = each["style"]["fontcolour"].string {
        //                                cell.lbl_row1.textColor = UIColor(hex: colour)
        //                            }
        //                        }
        //                    }
        //                    else if each["placement"] == "Row3" {
        //
        //                        if each["style"] != nil {
        //                            if let colour = each["style"]["fontcolour"].string {
        //                                cell.lbl_row2.textColor = UIColor(hex: colour)
        //                            }
        //                        }
        //
        //                        if let timeResult = larr_rawData![indexPath.row]["\(each["key"])"].double {
        //                            let date = Date(timeIntervalSince1970: timeResult)
        //                            let dateFormatter = DateFormatter()
        //                            dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        //                            dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        //                            dateFormatter.timeZone = .current
        //                            let localDate = dateFormatter.string(from: date)
        //                            cell.lbl_row2.text! = localDate
        //                        }
        //                    }
        //                }
        //            }
        //            let subString = larr_rawData![indexPath.row]["fileName"].stringValue.split(separator: ".")
        //            if "\(subString[subString.count-1])" == "pdf"{
        //                 cell.img_thumbnail.image = UIImage(named: "\(subString[subString.count-1])")
        //            }else{
        //                cell.img_thumbnail.image = UIImage(named: "Default")
        //            }
        //
        //
        //            cell.selectionStyle = .none
        //            return cell
        //        }else{
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListDataCell", for: indexPath) as! ListDataViewCell
        
        let rowData = larr_Datasource[indexPath.row]
        
        if rowData.count > 0 {
            
            //Row 0
            if rowData[0].count == 3 {
                if rowData[0][0].string  != "" {
                    cell.imageView?.image = UIImage(named: rowData[0][0].string)
                    cell.rowWidth00.constant = 20
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-65)/2
                    cell.rowWidth02.constant = (cell.contentView.bounds.width-65)/2
                }else{
                    cell.rowWidth00.constant = 0
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-45)/2
                    cell.rowWidth02.constant = (cell.contentView.bounds.width-45)/2
                }
                
                //Set Value for Label
                cell.lbl_row01.attributedText = rowData[0][1]
                cell.lbl_row02.attributedText = rowData[0][2]
                
            }
            else if rowData[0].count == 2{
                if rowData[0][0].string  != "" {
                    cell.imageView?.image = UIImage(named: rowData[0][0].string)
                    cell.rowWidth00.constant = 20
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-65)
                }else{
                    cell.rowWidth00.constant = 0
                    cell.rowWidth01.constant = (cell.contentView.bounds.width-45)
                }
                
                cell.lbl_row01.attributedText = rowData[0][1]
            }
            else{
                cell.rowSep00.constant = 0
            }
            
            //Row 1
            if rowData[1].count == 3 {
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth11.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth12.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowSep10.constant = 1
                cell.rowSep11.constant = 1
                
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
                cell.lbl_row11.attributedText = rowData[1][1]
                cell.lbl_row12.attributedText = rowData[1][2]
            }
            else if rowData[1].count == 2{
                //Set Row width
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowWidth12.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowSep10.constant = 1
                cell.rowSep11.constant = 0
                
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
                cell.lbl_row12.attributedText = rowData[1][1]
            }
            else if rowData[1].count == 1{
                //Set Row width
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)
                cell.rowSep10.constant = 0
                cell.rowSep11.constant = 0
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
            }
            else{
                cell.rowSep01.constant = 0
            }
            
            //Row 2
            if rowData[2].count == 3 {
                //Set Row width
                cell.rowWidth20.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth21.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowWidth22.constant =  (cell.contentView.bounds.width-45)/3
                cell.rowSep20.constant = 1
                cell.rowSep21.constant = 1
                
                //Set Value for Label
                cell.lbl_row20.attributedText = rowData[2][0]
                cell.lbl_row21.attributedText = rowData[2][1]
                cell.lbl_row22.attributedText = rowData[2][2]
            }
            else if rowData[2].count == 2{
                //Set Row width
                cell.rowWidth20.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowWidth22.constant =  (cell.contentView.bounds.width-45)/2
                cell.rowSep20.constant = 0
                cell.rowSep21.constant = 1
                
                //Set Value for Label
                cell.lbl_row20.attributedText = rowData[2][0]
                cell.lbl_row22.attributedText = rowData[2][1]
            }
            else if rowData[2].count == 1{
                //Set Row width
                cell.rowWidth10.constant =  (cell.contentView.bounds.width-45)
                cell.rowSep10.constant = 0
                cell.rowSep11.constant = 0
                //Set Value for Label
                cell.lbl_row10.attributedText = rowData[1][0]
            }else{
                cell.rowSep01.constant = 0
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        
        var larr_Button:[UIContextualAction] = []
        var RightmenuArray:[JSON] = []
        
        if self.larr_Decision!.count > 0{
            for n in 0...self.larr_Decision!.count-1 {
                if larr_Decision![n]["selection"] == "row" || larr_Decision![n]["selection"] == "global" {
                    
                    
                    if larr_Decision![n]["displayed"].string != nil{
                        
                        if let displayed =  larr_Decision![n]["displayed"].string{
                            var displayedSplit:[String] = displayed.components(separatedBy: "==")
                            if displayedSplit.count > 1 {
                                
                                if displayed.contains("||"){
                                    let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                                    var licheck = 0
                                    for j in 0..<valueSplit.count {
                                        if "'\(self.larr_rawData![indexPath.row][displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                            licheck = 1
                                        }
                                    }
                                    
                                    if licheck == 1 {
                                        RightmenuArray.append(larr_Decision![n])
                                    }
                                }else if displayed.contains("&&"){
                                    let valueSplit:[String] = displayedSplit[1].components(separatedBy: "&&")
                                    var licheck = 0
                                    for j in 0..<valueSplit.count {
                                        if "'\(self.larr_rawData![indexPath.row][displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                            if j == 0 && licheck == 0 {
                                                licheck = 1
                                            }else if licheck != 1 {
                                                licheck = 0
                                            }
                                        }
                                    }
                                    if licheck == 1 {
                                        RightmenuArray.append(larr_Decision![n])
                                    }
                                }else{
                                    if "'\(self.larr_rawData![indexPath.row][displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                        RightmenuArray.append(larr_Decision![n])
                                    }
                                }
                                
                            }else{
                                displayedSplit = displayed.components(separatedBy: "!=")
                                if displayed.contains("||"){
                                    let valueSplit:[String] = displayedSplit[1].components(separatedBy: "||")
                                    var licheck = 0
                                    for j in 0..<valueSplit.count {
                                        if "'\(self.larr_rawData![indexPath.row][displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                            licheck = 1
                                        }
                                    }
                                    if licheck == 1 {
                                        RightmenuArray.append(larr_Decision![n])
                                    }
                                }else if displayed.contains("&&"){
                                    let valueSplit:[String] = displayedSplit[1].components(separatedBy: "&&")
                                    var licheck = 0
                                    for j in 0..<valueSplit.count {
                                        if "'\(self.larr_rawData![indexPath.row][displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(valueSplit[j])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                                            if j == 0 && licheck == 0 {
                                                licheck = 1
                                            }else if licheck != 1 {
                                                licheck = 0
                                            }
                                        }
                                    }
                                    if licheck == 1 {
                                        RightmenuArray.append(larr_Decision![n])
                                    }
                                }else{
                                    if "'\(self.larr_rawData![indexPath.row][displayedSplit[0].components(separatedBy: ".")[1].trimmingCharacters(in: .whitespacesAndNewlines)].stringValue.uppercased())'"  == "\(displayedSplit[1])".uppercased().trimmingCharacters(in: .whitespacesAndNewlines){
                                        RightmenuArray.append(larr_Decision![n])
                                    }
                                }
                            }
                            
                            
                        }else{
                            RightmenuArray.append(larr_Decision![n])
                        }
                        
                        
                        for i in 0..<RightmenuArray.count{
                            
                            let ButtonAction = UIContextualAction(style: .normal, title:  RightmenuArray[i]["label"].stringValue, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                                
                                self.ActionbtnTapped(decision: RightmenuArray[i],selectedRow:indexPath.row)
                                
                                success(true)
                            })
                            ButtonAction.backgroundColor = Utility.colourforRowButton(RightmenuArray[i].count-i)
                            
                            larr_Button.append(ButtonAction)
                        }
                        
                        
                    }else{
                        let ButtonAction = UIContextualAction(style: .normal, title:  larr_Decision![n]["label"].stringValue, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                            
                            self.ActionbtnTapped(decision: self.larr_Decision![n],selectedRow:indexPath.row)
                            
                            success(true)
                        })
                        ButtonAction.backgroundColor = Utility.colourforRowButton(self.larr_Decision!.count-n)
                        
                        larr_Button.append(ButtonAction)
                    }
                }
                
            }
            
        }
        return UISwipeActionsConfiguration(actions: larr_Button)
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //currentPage is the page which is already loaded. it starts from 1
        //        let currentPage = ceil(Double(larr_Datasource.count/defaultPageSize))
        
        
        if indexPath.row == larr_Datasource.count - 1 && larr_Datasource.count >= defaultPageSize && layoutJson!["flow"][self.ls_taskName!]["layout"]["lazyLoading"] == true  {
            DataCurrentpage = larr_Datasource.count
            DataReload()
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.startAnimating()
            tableView.beginUpdates()
            tableView.tableFooterView = activityIndicator
            tableView.endUpdates()
        }
        tableView.refreshControl?.endRefreshing()
        
        if lb_ScreenHeight == true{
            if larr_FilterList.count > 0 || larr_SortList.count > 0 || lb_Search == true {
                if larr_FilterList.count > 0 || larr_SortList.count > 0 || lb_Search == true {
                    if self.ls_ScreenTitle == nil {
                        self.tableViewHeight.constant = self.view.frame.height-109
                    }else{
                        self.tableViewHeight.constant = self.view.frame.height-44
                    }
                }else{
                    self.tableViewHeight.constant = self.view.frame.height-44
                }
            }else{
                self.tableViewHeight.constant = self.view.frame.height
            }
        } else{
            if larr_FilterList.count > 0 || larr_SortList.count > 0 || lb_Search == true {
                switch UIDevice.current.name {
                case "iPhone 6","iPhone 6 Plus","iPhone 6S","iPhone 6S Plus","iPhone 7","iPhone 7 Plus","iPhone 8","iPhone 8 Plus":
                    self.tableViewHeight.constant = UIScreen.main.bounds.height - (navigationController?.toolbar.frame.size.height)! - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.size.height - 36
                default:
                    self.tableViewHeight.constant = UIScreen.main.bounds.height - (navigationController?.toolbar.frame.size.height)! - (navigationController?.navigationBar.frame.size.height)! - UIApplication.shared.statusBarFrame.size.height - 36 - 29
                }
            }else{
                self.tableViewHeight.constant = self.tableView.contentSize.height
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ldict_rowDecision != nil {
            switch ldict_rowDecision!["outcomes"][0]["type"] {
            case "downloadLink":
                var filePath = ""
                
                // Fine documents directory on device
                let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
                
                if dirs.count > 0 {
                    let dir = dirs[0].appendingFormat("/" + "\(BaseTenantID)_\(UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "")_\(self.app.id)") //documents directory
                    
                    filePath = dir.appendingFormat("/" + "\(self.larr_rawData?[indexPath.row]["fileName"] ?? "")")
                    print("Local path = \(filePath)")
                    
                } else {
                    print("Could not find local directory to store file")
                    return
                }
                
                
                
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: filePath) {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let dataPath = documentsDirectory.appendingPathComponent("\(BaseTenantID)_\(UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "")_\(app.id)")
                    
                    let filename = dataPath.appendingPathComponent("\(self.larr_rawData?[indexPath.row]["fileName"] ?? "")")
                    
                    self.webServerUrl = filename as NSURL
                    let quickLookController = QLPreviewController()
                    quickLookController.dataSource = self
                    UINavigationBar.appearance().tintColor = Utility.appThemeColor
                    UINavigationBar.appearance().isTranslucent = false
                    self.present(quickLookController, animated: true, completion: nil)
                    
                    
                    //                     let DownloadVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as! DownloadViewController
                    //                     DownloadVC.webServerUrl = "\(filename)"
                    //                     DownloadVC.ls_Id = "\(self.larr_rawData?[indexPath.row]["id"] ?? "")"
                    //                     DownloadVC.ls_title = "\(self.larr_rawData?[indexPath.row]["fileName"] ?? "")"
                    //                     DownloadVC.modalPresentationStyle = .overCurrentContext
                    //                     DownloadVC.app = self.app
                    //                     self.present(DownloadVC, animated: true, completion: nil)
                    
                    print("File exist")
                } else {
                    if ldict_rowDecision!["outcomes"][0]["forceDownload"].boolValue {
                        self.showActivityIndicator()
                        DynamicApiController.downloadDocumentBLOB(decision: ldict_rowDecision!, selectedRow: larr_rawData![indexPath.row], tenantId: BaseTenantID, platformId: app.id) { (URLResponse) in
                            self.hideActivityIndicator()
                            switch URLResponse {
                            case .success(let BLOBURL):
                                
                                self.webServerUrl = BLOBURL as NSURL
                                let quickLookController = QLPreviewController()
                                quickLookController.dataSource = self
                                UINavigationBar.appearance().tintColor = Utility.appThemeColor
                                UINavigationBar.appearance().isTranslucent = false
                                self.present(quickLookController, animated: true, completion: nil)
                                
                                
                            //                                 let DownloadVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as! DownloadViewController
                            //                                 DownloadVC.webServerUrl = "\(BLOBURL)"
                            //                                 DownloadVC.ls_Id = "\(self.larr_rawData?[indexPath.row]["id"] ?? "")"
                            //                                 DownloadVC.ls_title = "\(self.larr_rawData?[indexPath.row]["fileName"] ?? "")"
                            //                                 DownloadVC.modalPresentationStyle = .overCurrentContext
                            //                                 DownloadVC.app = self.app
                            //                                 self.present(DownloadVC, animated: true, completion: nil)
                            //                                 break
                            
                            case .failure(let error):
                                self.showAlert(message: error.description)
                            case .failureJson(_):
                                break
                                
                            }
                        }
                    }else{
                        self.showActivityIndicator()
                        DynamicApiController.downloadDocumentUrl(decision: ldict_rowDecision!, selectedRow: larr_rawData![indexPath.row], tenantId: BaseTenantID) { (URLResponse) in
                            self.hideActivityIndicator()
                            switch URLResponse {
                            case .success(let json):
                                let DocumentURL = json["url"].stringValue
                                
                                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let dataPath = documentsDirectory.appendingPathComponent("\(BaseTenantID)_\(UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "")_\(self.app.id)")
                                
                                
                                do {
                                    try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                                } catch let error as NSError {
                                    print("Error creating directory: \(error.localizedDescription)")
                                }
                                
                                let paths = dataPath.appendingPathComponent("\(self.larr_rawData?[indexPath.row]["fileName"] ?? "")")
                                
                                print(paths)
                                let tempUrlString = "\(UIbaseURL)/connect/\(DocumentURL)".replacingOccurrences(of: " ", with: "%20")
                                
                                if URL(string: tempUrlString) != nil{
                                    let pdfDoc = NSData(contentsOf:URL(string: tempUrlString)!)
                                    fileManager.createFile(atPath: paths.path, contents: pdfDoc as Data?, attributes: nil)
                                    
                                    self.webServerUrl = paths as NSURL
                                    let quickLookController = QLPreviewController()
                                    quickLookController.dataSource = self
                                    UINavigationBar.appearance().tintColor = Utility.appThemeColor
                                    UINavigationBar.appearance().isTranslucent = false
                                    self.present(quickLookController, animated: true, completion: nil)
                                }else{
                                    self.showAlert(message: "Unsupported format")
                                }
                                
                                //                                 let DownloadVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as! DownloadViewController
                                //                                 DownloadVC.webServerUrl = "\(UIbaseURL)/connect/\(DocumentURL)"
                                //                                 DownloadVC.ls_Id = "\(self.larr_rawData?[indexPath.row]["id"] ?? "")"
                                //                                 DownloadVC.ls_title = "\(self.larr_rawData?[indexPath.row]["fileName"] ?? "")"
                                //                                 DownloadVC.modalPresentationStyle = .overCurrentContext
                                //                                 DownloadVC.app = self.app
                                //                                 self.present(DownloadVC, animated: true, completion: nil)
                                break
                                
                            case .failure(let error):
                                self.showAlert(message: error.description)
                            case .failureJson(_):
                                break
                            }
                        }
                    }
                }
                
            default:
                let bodydictionary = ["appId":"\(ls_appName)","workFlowTask":"\(ldict_rowDecision!["outcomes"][0]["name"])", "deviceType":"mobile"] as [String : Any]
                
                self.showActivityIndicator()
                
                ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                    self.hideActivityIndicator()
                    switch taskResponse {
                    case .success(let json):
                        if self.ldict_rowDecision!["outcomes"][0]["targetPath"] != nil {
                            let WebVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "WebViewVC") as! WebViewController
                            WebVC.ls_taskName = self.ldict_rowDecision!.dictionaryValue["outcomes"]![0]["name"].stringValue
                            WebVC.layoutJson = json
                            WebVC.ls_previousWorkflow = self.ls_taskName
                            WebVC.ls_targetPath = self.ldict_rowDecision!["outcomes"][0]["targetPath"].stringValue
                            WebVC.ls_orientation = self.ldict_rowDecision!["outcomes"][0]["orientation"].stringValue
                            WebVC.ldict_ScreenData = self.larr_rawData![indexPath.row]
                            WebVC.ls_appName = self.ls_appName
                            self.navigationController?.pushViewController(WebVC, animated: true)
                        }else{
                            
                            switch json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["layout"]["name"].stringValue {
                            case "customv2":
                                
                                let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "AdvCompositeVC") as! AdvancedCompositeViewController
                                customVC.app_metaData = json
                                customVC.ls_taskName = self.ldict_rowDecision!["outcomes"][0]["name"].stringValue
                                if self.larr_rawData!.count > 0 {
                                    var selectedData:[JSON] = []
                                    selectedData.append(JSON.init(self.larr_rawData![indexPath.row]))
                                    customVC.SelectedData = selectedData
                                }
                                self.navigationController?.pushViewController(customVC, animated: true)
                                
                            case "create":
                                let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                                CreateVC.app = self.app
                                CreateVC.app_metaData =  json
                                CreateVC.ls_ScreenTitle = json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                                CreateVC.ls_taskName = self.ldict_rowDecision!["outcomes"][0]["name"].stringValue
                                if self.ldict_rowDecision!["outcomes"][0]["data"].string != nil {
                                    var bodyJson:[String:String] = [:]
                                    for each in self.larr_rawData![indexPath.row].dictionaryValue {
                                        if bodyJson[each.key] == nil {
                                            bodyJson[each.key] = "\(each.value)"
                                        }
                                    }
//                                    CreateVC.larr_bodyJson = bodyJson
                                    CreateVC.ldict_ScreenData = self.larr_rawData![indexPath.row].dictionaryValue
                                }
                                
                                if self.layoutJson!["flow"][self.ls_taskName!]["layout"]["offlineSupport"] == true {
                                    CreateVC.ls_ScreenMode = "Offline"
                                }
                                
                                self.navigationController?.pushViewController(CreateVC, animated: true)
                            default:
                                let DetailVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
                                DetailVC.app_metaData =  json
                                DetailVC.ls_appName = self.ls_appName
                                DetailVC.ls_taskName = self.ldict_rowDecision!["outcomes"][0]["name"].stringValue
                                DetailVC.larr_ScreenData = self.larr_rawData?[indexPath.row]
                                
                                if json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue.contains("${"){
                                    
                                    let title = json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                                    
                                    var titleString:String? = ""
                                    
                                    if title != "null"{
                                        let titleStartIndex =  title.range(of: "${")?.upperBound
                                        let titleEndIndex =  title.range(of: "}")?.lowerBound
                                        
                                        
                                        if titleStartIndex != nil && titleEndIndex != nil {
                                            var titleSubstring = title[(title.range(of: "${"))!.upperBound..<(title.range(of: "}"))!.lowerBound]
                                            if titleSubstring.contains("."){
                                                let titleSubstringsplit = titleSubstring.components(separatedBy: ".")
                                                titleSubstring = "\(titleSubstringsplit[titleSubstringsplit.count-1])"
                                            }
                                            
                                            let titleReplaceSubstring = title[(title.range(of: "${"))!.lowerBound ..< (title.range(of: "}"))!.upperBound]
                                            if self.larr_rawData!.count > 0 {
                                                titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_rawData![indexPath.row]["\(titleSubstring)"].stringValue)
                                            }
                                        }else{
                                            titleString = title
                                        }
                                    }else{
                                        titleString = nil
                                    }
                                    DetailVC.ls_ScreenTitle = titleString
                                    
                                }else{
                                    DetailVC.ls_ScreenTitle = json["flow"][self.ldict_rowDecision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                                }
                                
                                
                                self.navigationController?.pushViewController(DetailVC, animated: true)
                            }
                        }
                        
                    case .failure(let error):
                        self.showAlert(message: error.localizedDescription)
                    case .failureJson(_):
                        break
                    }
                }
            }
        }
    }
    
    //MARK: - SortScreenDelegate
    
    func selectedSortOption(_ sortOptionValue: JSON?, sortOptionType: SortOptions) {
        
        if sortOptionType == .none {
            if self.larr_operation.contains("sort") {
                self.larr_operation.remove(at: self.larr_operation.firstIndex(of: "sort")!)
            }
            sortOption = []
            self.larr_rawData = []
            
        }else{
            if !self.larr_operation.contains("sort") {
                self.larr_operation.append("sort")
            }
            sortOption = [["\(sortOptionValue![0]["key"].stringValue).raw":["order": "\(sortOptionValue![0]["orderBy"].stringValue)"]]]
            self.larr_rawData = []
        }
        
        DataReload()
    }
    
    
    func selectedFilters(_ filter: [Any]) {
        
        if filter.count > 0 {
            self.filtersSelected = filter[0] as? [String : [String]]
        }else{
            self.filtersSelected = nil
        }
        
        if filter.count > 0 {
            if !self.larr_operation.contains("filter") {
                self.larr_operation.append("filter")
            }
            
            var mustJson:[Any] = []
            
            let SelectedFilter:[String:[String]] = filter[0] as! [String : [String]]
            
            for each in SelectedFilter{
                var termsDictionary : [String:Any] = [:]
                termsDictionary["terms"] = ["\(each.key).raw":each.value]
                mustJson.append(termsDictionary)
            }
            
            filterOption = ["bool":["must":mustJson]]
            
            self.larr_rawData = []
        } else { //When user clears all filters, we pass default filter options
            if self.larr_operation.contains("filter") {
                self.larr_operation.remove(at: self.larr_operation.firstIndex(of: "filter")!)
            }
            filterOption = [:]
            self.larr_rawData = []
        }
        
        DataReload()
    }
    
    //MARK: - QLPreviewControllerDataSource
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.webServerUrl as QLPreviewItem
    }
    
    //MARK: - IBAction
    
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        // Create the search controller and specify that it should present its results in this same view
        searchController = UISearchController(searchResultsController: nil)
        
        // Set any properties (in this case, don't hide the nav bar and don't show the emoji keyboard option)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.text = ls_searchString
        searchController.searchBar.keyboardType = UIKeyboardType.asciiCapable
        
        // Make this class the delegate and present the search
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
        //        print("search Tapped.")
    }
    
    @IBAction func sortTapped(_ sender: UIBarButtonItem) {
        
        DataCurrentpage = 0
        
        //Sort page expects sort options in the below format
        
        var sortOptions:[JSON] = []
        
        for each in larr_SortList { sortOptions.append(JSON(["columnName":ldict_object[each]!["\(ldict_object[each]!["labelKey"])"],"key":ldict_object[each]!["labelKey"]]))
        }
        
        
        let sortVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SortViewController") as! SortViewController
        
        sortVC.sortOptions = sortOptions
        sortVC.delegate = self
        sortVC.modalPresentationStyle = .overCurrentContext
        self.present(sortVC, animated: true, completion: nil)
        
    }
    
    
    @IBAction func filterTapped(_ sender: UIBarButtonItem) {
        let filterVC = UIStoryboard(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "WF_MainFilterViewController") as! WF_MainFilterViewController
        filterVC.delegate = self
        filterVC.larr_FilterList = self.larr_FilterList
        filterVC.ls_taskName = self.ls_taskName
        filterVC.layoutJson = self.layoutJson
        filterVC.filtersSelected = filtersSelected ?? [:]
        filterVC.ls_appName = self.ls_appName
        filterVC.modalPresentationStyle = .overFullScreen
        self.present(filterVC, animated: true, completion: nil)
    }
    
    @IBAction func actionbtn_Pressed(_ sender: Any) {
        
        print((sender as! UIButton).tag)
        let decision = self.larr_Decision![0]
        
        switch decision["outcomes"][0]["type"] {
        case "downloadLink":
            if decision["outcomes"][0]["forceDownload"].boolValue {
                self.showActivityIndicator()
                DynamicApiController.downloadDocumentBLOB(decision: decision, selectedRow: larr_rawData![(sender as! UIButton).tag], tenantId: BaseTenantID, platformId: app.id) { (URLResponse) in
                    self.hideActivityIndicator()
                    switch URLResponse {
                    case .success(let BLOBURL):
                        let DownloadVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as! DownloadViewController
                        DownloadVC.webServerUrl = "\(BLOBURL)"
                        DownloadVC.ls_Id = "\(self.larr_rawData?[(sender as! UIButton).tag]["id"] ?? "")"
                        DownloadVC.ls_title = "\(self.larr_rawData?[(sender as! UIButton).tag]["fileName"] ?? "")"
                        DownloadVC.modalPresentationStyle = .overCurrentContext
                        DownloadVC.app = self.app
                        self.present(DownloadVC, animated: true, completion: nil)
                        break
                    case .failure(let error):
                        self.showAlert(message: error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }else{
                self.showActivityIndicator()
                DynamicApiController.downloadDocumentUrl(decision: decision, selectedRow: larr_rawData![(sender as! UIButton).tag], tenantId: BaseTenantID) { (URLResponse) in
                    self.hideActivityIndicator()
                    switch URLResponse {
                    case .success(let json):
                        let DocumentURL = json["url"].stringValue
                        
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let dataPath = documentsDirectory.appendingPathComponent("\(BaseTenantID)_\(UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "")_\(self.app.id)")
                        
                        
                        do {
                            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                        } catch let error as NSError {
                            print("Error creating directory: \(error.localizedDescription)")
                        }
                        
                        let paths = dataPath.appendingPathComponent(
                            "\(self.larr_rawData?[(sender as! UIButton).tag]["fileName"] ?? "")")
                        
                        print(paths)
                        let tempUrlString = "\(UIbaseURL)/connect/\(DocumentURL)".replacingOccurrences(of: " ", with: "%20")
                        let pdfDoc = NSData(contentsOf:URL(string: tempUrlString)!)
                        FileManager.default.createFile(atPath: paths.path, contents: pdfDoc as Data?, attributes: nil)
                        
                        
                        
                        let DownloadVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as! DownloadViewController
                        DownloadVC.webServerUrl = "\(UIbaseURL)/connect/\(DocumentURL)"
                        DownloadVC.ls_Id = "\(self.larr_rawData?[(sender as! UIButton).tag]["id"] ?? "")"
                        DownloadVC.ls_title = "\(self.larr_rawData?[(sender as! UIButton).tag]["fileName"] ?? "")"
                        DownloadVC.modalPresentationStyle = .overCurrentContext
                        DownloadVC.app = self.app
                        self.present(DownloadVC, animated: true, completion: nil)
                        break
                    case .failure(let error):
                        self.showAlert(message: error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }
            
        default:
            break
        }
    }
    
    
    //MARK: - Local Function
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshPage(){
        self.larr_rawData = []
        DataReload()
        tableView.refreshControl?.endRefreshing()
    }
    
    
    func ActionbtnTapped(decision:JSON,selectedRow:Int){
        
        switch decision["outcomes"][0]["type"] {
        case "downloadLink":
            if decision["outcomes"][0]["forceDownload"].boolValue {
                self.showActivityIndicator()
                DynamicApiController.downloadDocumentBLOB(decision: decision, selectedRow: larr_rawData![selectedRow], tenantId: BaseTenantID, platformId: app.id) { (URLResponse) in
                    self.hideActivityIndicator()
                    switch URLResponse {
                    case .success(let BLOBURL):
                        let DownloadVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as! DownloadViewController
                        DownloadVC.webServerUrl = "\(BLOBURL)"
                        DownloadVC.ls_Id = "\(self.larr_rawData?[selectedRow]["id"] ?? "")"
                        DownloadVC.ls_title = "\(self.larr_rawData?[selectedRow]["fileName"] ?? "")"
                        DownloadVC.modalPresentationStyle = .overCurrentContext
                        DownloadVC.app = self.app
                        self.present(DownloadVC, animated: true, completion: nil)
                        break
                    case .failure(let error):
                        self.showAlert(message: error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }else{
                self.showActivityIndicator()
                DynamicApiController.downloadDocumentUrl(decision: decision, selectedRow: larr_rawData![selectedRow], tenantId: BaseTenantID) { (URLResponse) in
                    self.hideActivityIndicator()
                    switch URLResponse {
                    case .success(let json):
                        let DocumentURL = json["url"].stringValue
                        
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let dataPath = documentsDirectory.appendingPathComponent("\(BaseTenantID)_\(UserDefaults.standard.string(forKey: UserDefaultsKeys.userID.rawValue) ?? "")_\(self.app.id)")
                        
                        
                        do {
                            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
                        } catch let error as NSError {
                            print("Error creating directory: \(error.localizedDescription)")
                        }
                        
                        let paths = dataPath.appendingPathComponent( "\(self.larr_rawData?[selectedRow]["fileName"] ?? "")")
                        
                        print(paths)
                        let tempUrlString = "\(UIbaseURL)/connect/\(DocumentURL)".replacingOccurrences(of: " ", with: "%20")
                        let pdfDoc = NSData(contentsOf:URL(string: tempUrlString)!)
                        FileManager.default.createFile(atPath: paths.path, contents: pdfDoc as Data?, attributes: nil)
                        
                        let DownloadVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "DownloadVC") as! DownloadViewController
                        DownloadVC.webServerUrl = "\(UIbaseURL)/connect/\(DocumentURL)"
                        DownloadVC.ls_Id =  "\(self.larr_rawData?[selectedRow]["id"] ?? "")"
                        DownloadVC.ls_title =  "\(self.larr_rawData?[selectedRow]["fileName"] ?? "")"
                        DownloadVC.modalPresentationStyle = .overCurrentContext
                        DownloadVC.app = self.app
                        self.present(DownloadVC, animated: true, completion: nil)
                        break
                        
                    case .failure(let error):
                        self.showAlert(message: error.description)
                    case .failureJson(_):
                        break
                        
                    }
                }
            }
            
        default:
            self.showActivityIndicator()
            
            ldict_Decision = decision
            
            let bodydictionary = ["appId":"\(ls_appName)",
                                  "workFlowTask":"\(decision.dictionaryValue["outcomes"]![0]["name"])",
                                  "deviceType":"mobile"] as [String : Any]
            
            ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                self.hideActivityIndicator()
                switch taskResponse {
                case .success(let json):
                    
                    if self.ldict_Decision!["outcomes"][0]["targetPath"] != nil {
                        let WebVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "WebViewVC") as! WebViewController
                        WebVC.ls_taskName = self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"].stringValue
                        WebVC.layoutJson = json
                        WebVC.ls_previousWorkflow = self.ls_taskName
                        WebVC.ls_targetPath = self.ldict_Decision!["outcomes"][0]["targetPath"].stringValue
                        WebVC.ls_orientation = self.ldict_Decision!["outcomes"][0]["orientation"].stringValue
                        WebVC.ldict_ScreenData = self.larr_rawData![selectedRow]
                        WebVC.ls_appName = self.ls_appName
                        self.navigationController?.pushViewController(WebVC, animated: true)
                    }else{
                        switch json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["name"].stringValue {
                        case "cancelpopup":
                            var alertController : UIAlertController
                            
                            let title = "\(json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["option"]["headerMessage"])"
                            
                            var titleString:String? = ""
                            
                            if title != "null"{
                                let titleStartIndex =  title.range(of: "${")?.upperBound
                                let titleEndIndex =  title.range(of: "}")?.lowerBound
                                
                                
                                if titleStartIndex != nil && titleEndIndex != nil {
                                    let titleSubstring = title[(title.range(of: "${"))!.upperBound..<(title.range(of: "}"))!.lowerBound]
                                    let titleReplaceSubstring = title[(title.range(of: "${"))!.lowerBound ..< (title.range(of: "}"))!.upperBound]
                                    titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_rawData![selectedRow]["\(titleSubstring)"].stringValue)
                                }else{
                                    titleString = title
                                }
                            }else{
                                titleString = nil
                            }
                            
                            let message = "\(json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["layout"]["option"]["bodyMessage"])"
                            
                            let msgStartIndex =  message.range(of: "${")?.upperBound
                            let msgEndIndex =  message.range(of: "}")?.lowerBound
                            var msgString = ""
                            
                            if msgStartIndex != nil && msgEndIndex != nil {
                                let messageSubstring =  message[(message.range(of: "${"))!.upperBound..<(message.range(of: "}"))!.lowerBound]
                                let messageReplaceSubstring = message[(message.range(of: "${"))!.lowerBound ..< (message.range(of: "}"))!.upperBound]
                                msgString = message.replacingOccurrences(of: messageReplaceSubstring, with: self.larr_rawData![selectedRow]["\(messageSubstring)"].stringValue)
                            }else{
                                msgString = message
                            }
                            
                            alertController = UIAlertController(title: titleString , message: msgString, preferredStyle:UIAlertController.Style.actionSheet)
                            
                            
                            let decision = json["flow"]["\(self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"])"]["decisions"]
                            
                            for i in 0..<decision.count {
                                if decision[i]["label"].stringValue.uppercased() != "CANCEL" {
                                    let Action = UIAlertAction(title: decision[i]["label"].stringValue, style: UIAlertAction.Style.default) { (finish) in
                                        if decision[i]["type"] != JSON.null && decision[i]["type"] == "submit" {
                                            self.submitData(decision: decision[i].dictionaryValue, selectedRow: selectedRow)
                                        }
                                    }
                                    alertController.addAction(Action)
                                }
                            }
                            
                            alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        case "lifecycle":
                            let LifeCycleVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "LifeCycleVC") as! LifeCycleViewController
                            LifeCycleVC.app_metadata = json
                            LifeCycleVC.ls_taskName = self.ldict_Decision!.dictionaryValue["outcomes"]![0]["name"].stringValue
                            LifeCycleVC.ls_appName = self.ls_appName
                            LifeCycleVC.ldict_ScreenData = self.larr_rawData![selectedRow]
                            self.navigationController?.pushViewController(LifeCycleVC, animated: true)
                            
                        case "customv2":
                            let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "CompositeVC") as! CompositeViewController
                            
                            let title = json["flow"][self.ldict_Decision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                            
                            var titleString:String? = ""
                            
                            if title != "null"{
                                let titleStartIndex =  title.range(of: "${")?.upperBound
                                let titleEndIndex =  title.range(of: "}")?.lowerBound
                                
                                
                                if titleStartIndex != nil && titleEndIndex != nil {
                                    var titleSubstring = title[(title.range(of: "${"))!.upperBound..<(title.range(of: "}"))!.lowerBound]
                                    if titleSubstring.contains("."){
                                        let titleSubstringsplit = titleSubstring.components(separatedBy: ".")
                                        titleSubstring = "\(titleSubstringsplit[titleSubstringsplit.count-1])"
                                    }
                                    
                                    let titleReplaceSubstring = title[(title.range(of: "${"))!.lowerBound ..< (title.range(of: "}"))!.upperBound]
                                    if self.larr_rawData!.count > 0 {
                                        titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_rawData![selectedRow]["\(titleSubstring)"].stringValue)
                                    }
                                }else{
                                    titleString = title
                                }
                            }else{
                                titleString = nil
                            }
                            
                            
                            customVC.ls_ScreenTitle = titleString
                            customVC.ls_appName = self.ls_appName
                            customVC.ls_taskName = self.ldict_Decision!["outcomes"][0]["name"].stringValue
                            customVC.app_metaData = json
                            customVC.ls_Selectedappname = self.app.name
                            if self.larr_rawData!.count > 0 {
                                customVC.larr_ScreenData = self.larr_rawData![selectedRow]
                            }
                            customVC.ldict_dropdownData = self.ldict_dropdownData
                            
                            self.navigationController?.pushViewController(customVC, animated: true)
                            
                            
                        default:
                            let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                            CreateVC.app_metaData =  json
                            //                            CreateVC.ls_appName = self.ls_appName
                            CreateVC.ls_taskName = self.ldict_Decision!["outcomes"][0]["name"].stringValue
                            CreateVC.ldict_ScreenData = self.larr_rawData![selectedRow].dictionaryValue
                            if json["flow"][self.ldict_Decision!["outcomes"][0]["name"].stringValue]["label"].stringValue.contains("${"){
                                
                                let title = json["flow"][self.ldict_Decision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                                
                                var titleString:String? = ""
                                
                                if title != "null"{
                                    let titleStartIndex =  title.range(of: "${")?.upperBound
                                    let titleEndIndex =  title.range(of: "}")?.lowerBound
                                    
                                    
                                    if titleStartIndex != nil && titleEndIndex != nil {
                                        var titleSubstring = title[(title.range(of: "${"))!.upperBound..<(title.range(of: "}"))!.lowerBound]
                                        if titleSubstring.contains("."){
                                            let titleSubstringsplit = titleSubstring.components(separatedBy: ".")
                                            titleSubstring = "\(titleSubstringsplit[titleSubstringsplit.count-1])"
                                        }
                                        
                                        let titleReplaceSubstring = title[(title.range(of: "${"))!.lowerBound ..< (title.range(of: "}"))!.upperBound]
                                        if self.larr_rawData!.count > 0 {
                                            titleString = title.replacingOccurrences(of: titleReplaceSubstring, with: self.larr_rawData![selectedRow]["\(titleSubstring)"].stringValue)
                                        }
                                    }else{
                                        titleString = title
                                    }
                                }else{
                                    titleString = nil
                                }
                                CreateVC.ls_ScreenTitle = titleString
                                
                            }else{
                                CreateVC.ls_ScreenTitle = json["flow"][self.ldict_Decision!["outcomes"][0]["name"].stringValue]["label"].stringValue
                            }
                            
                            //                            CreateVC.ls_Selectedappname = self.ls_Selectedappname
                            CreateVC.ls_ScreenMode = json["flow"][self.ldict_Decision!["outcomes"][0]["name"].stringValue]["layout"]["name"].stringValue
                            CreateVC.ls_previousWorkflow = self.ls_taskName
                            self.navigationController?.pushViewController(CreateVC, animated: true)
                            
                        }
                    }
                    
                case .failure(let error):
                    self.showAlert(message: error.description)
                case .failureJson(_):
                    break
                }
            }
        }
    }
    
    @objc func rightBtn1Tapped(_ sender: Any?) {
        
        let selectedButton = sender as! UIButton
        let selectedDecision = larr_Decision![selectedButton.tag]
        
        self.showActivityIndicator()
        
        let bodydictionary = ["appId":"\(ls_appName)","workFlowTask":"\(selectedDecision["outcomes"][0]["name"])", "deviceType":"mobile"] as [String : Any]
        
        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
            self.hideActivityIndicator()
            switch taskResponse {
            case .success(let json):
                if selectedDecision["outcomes"][0]["targetPath"] != nil {
                    let WebVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "WebViewVC") as! WebViewController
                    WebVC.ls_taskName = selectedDecision.dictionaryValue["outcomes"]![0]["name"].stringValue
                    WebVC.layoutJson = json
                    WebVC.ls_previousWorkflow = self.ls_taskName
                    WebVC.ls_targetPath = selectedDecision["outcomes"][0]["targetPath"].stringValue
                    WebVC.ls_orientation = selectedDecision["outcomes"][0]["orientation"].stringValue
                    WebVC.ls_appName = self.ls_appName
                    self.navigationController?.pushViewController(WebVC, animated: true)
                }
                else{
                    let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                    CreateVC.app_metaData =  json
                    //                    CreateVC.ls_appName = self.ls_appName
                    CreateVC.ls_taskName = selectedDecision["outcomes"][0]["name"].stringValue
                    CreateVC.ls_ScreenTitle = json["flow"][selectedDecision["outcomes"][0]["name"].stringValue]["label"].stringValue
                    //                    CreateVC.ls_Selectedappname = self.ls_Selectedappname
                    CreateVC.ls_previousWorkflow = self.ls_taskName
                    self.navigationController?.pushViewController(CreateVC, animated: true)
                }
                
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            case .failureJson(_):
                break
            }
        }
    }
    
    func DataReload(){
        if layoutJson == nil{
            self.showActivityIndicator()
            
            let bodydictionary = ["appId":"\(ls_appName)",
                                  "workFlowTask":"\(ls_taskName!)",
                                  "deviceType":"mobile"] as [String : Any]
            
            ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) {  (taskResponse) in
                self.hideActivityIndicator()
                switch taskResponse {
                case .success(let json):
                    self.layoutJson = json
                    
                    if self.larr_FilterList.count > 0 || self.larr_SortList.count > 0 {
                        self.toolBar.isHidden = false
                        var items = [UIBarButtonItem]()
                        
                        items.append(
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                        )
                        
                        
                        if let optionsOrder = json["flow"][self.ls_taskName!]["layout"]["optionsOrder"].arrayObject{
                            for i in 0 ..< optionsOrder.count{
                                if optionsOrder[i] as! String == "filter" {
                                    if self.larr_FilterList.count > 0 {
                                        let filterBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Filter"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.filterTapped(_:)))
                                        
                                        filterBarButton.tintColor = .black
                                        
                                        items.append(filterBarButton)
                                        
                                        items.append(
                                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                                        )
                                    }
                                }else if optionsOrder[i] as! String == "sort"{
                                    if self.larr_SortList.count > 0 {
                                        
                                        let sortBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Sort"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.sortTapped(_:)))
                                        
                                        if self.previousScreenResponse != nil && self.previousScreenResponse!["data"][self.ls_taskName!]["query"] == nil{
                                            sortBarButton.isEnabled = false
                                            sortBarButton.tintColor = .darkGray
                                        }else{
                                            sortBarButton.isEnabled = true
                                            sortBarButton.tintColor = .black
                                        }
                                        
                                        items.append(sortBarButton)
                                        
                                        items.append(
                                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                                        )
                                    }
                                }
                            }
                            
                        }else{
                            if self.larr_SortList.count > 0 {
                                
                                let sortBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Sort"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.sortTapped(_:)))
                                
                                if self.previousScreenResponse != nil && self.previousScreenResponse!["data"][self.ls_taskName!]["query"] == nil{
                                    sortBarButton.isEnabled = false
                                    sortBarButton.tintColor = .darkGray
                                }else{
                                    sortBarButton.isEnabled = true
                                    sortBarButton.tintColor = .black
                                }
                                
                                items.append(sortBarButton)
                                
                                items.append(
                                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                                )
                            }
                            
                            
                            if self.larr_FilterList.count > 0 {
                                let filterBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Filter"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.filterTapped(_:)))
                                
                                filterBarButton.tintColor = .black
                                
                                items.append(filterBarButton)
                                
                                items.append(
                                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                                )
                            }
                        }
                        
                        self.toolBar.setItems(items, animated: true)
                        
                    }else{
                        self.toolBar.isHidden = true
                    }
                    
                    self.getData()
                    
                case .failure(let error):
                    print(error)
                case .failureJson(_):
                    break
                }
            }
        }else{
            
            if self.larr_FilterList.count > 0 || self.larr_SortList.count > 0 || self.lb_Search == true{
                self.toolBar.isHidden = false
                var items = [UIBarButtonItem]()
                
                items.append(
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                )
                
                
                if let optionsOrder = layoutJson!["flow"][self.ls_taskName!]["layout"]["optionsOrder"].arrayObject{
                    for i in 0 ..< optionsOrder.count{
                        if optionsOrder[i] as! String == "filter" {
                            if self.larr_FilterList.count > 0 {
                                let filterBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Filter"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.filterTapped(_:)))
                                
                                filterBarButton.tintColor = .black
                                
                                items.append(filterBarButton)
                                
                                items.append(
                                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                                )
                            }
                        }else if optionsOrder[i] as! String == "sort"{
                            if self.larr_SortList.count > 0 {
                                
                                let sortBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Sort"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.sortTapped(_:)))
                                
                                if self.previousScreenResponse != nil && self.previousScreenResponse!["data"][self.ls_taskName!]["query"] == nil{
                                    sortBarButton.isEnabled = false
                                    sortBarButton.tintColor = .darkGray
                                }else{
                                    sortBarButton.isEnabled = true
                                    sortBarButton.tintColor = .black
                                }
                                
                                items.append(sortBarButton)
                                
                                items.append(
                                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                                )
                            }
                        }
                    }
                    
                }else{
                    if self.lb_Search == true {
                        let searchBarButton:UIBarButtonItem =  UIBarButtonItem(image: #imageLiteral(resourceName: "Search_txt"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.searchTapped(_:)))
                        
                        searchBarButton.tintColor = .black
                        
                        items.append(searchBarButton)
                        
                        items.append(
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                        )
                    }
                    
                    if self.larr_SortList.count > 0 {
                        
                        let sortBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Sort"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.sortTapped(_:)))
                        
                        if self.previousScreenResponse != nil && self.previousScreenResponse!["data"][self.ls_taskName!]["query"] == nil{
                            sortBarButton.isEnabled = false
                            sortBarButton.tintColor = .darkGray
                        }else{
                            sortBarButton.isEnabled = true
                            sortBarButton.tintColor = .black
                        }
                        
                        items.append(sortBarButton)
                        
                        items.append(
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                        )
                    }
                    
                    if self.larr_FilterList.count > 0 {
                        let filterBarButton:UIBarButtonItem =  UIBarButtonItem(image: UIImage(named: "Filter"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(self.filterTapped(_:)))
                        
                        filterBarButton.tintColor = .black
                        
                        items.append(filterBarButton)
                        
                        items.append(
                            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                        )
                    }
                    
                }
                
                self.toolBar.setItems(items, animated: true)
                
            }else{
                self.toolBar.isHidden = true
            }
            
            getData()
        }
    }
    
    func getData(){
        self.larr_Decision = layoutJson!["flow"][self.ls_taskName!]["decisions"].arrayValue
        let larr_fields = layoutJson!["flow"][self.ls_taskName!]["fields"].arrayValue
        self.ldict_object = layoutJson!["objectMeta"]["fields"].dictionaryValue
        
        if layoutJson!["flow"][self.ls_taskName!]["layout"]["offlineSupport"] == true {
            self.larr_rawData = RequestManager.shared.fetchDraftData(taskId: layoutJson!["flow"][self.ls_taskName!]["layout"]["offlinetask"].stringValue)
            
            if self.ls_ScreenTitle != nil && (self.layoutJson!["flow"][self.ls_taskName!]["layout"]["footer"].bool == nil || self.layoutJson!["flow"][self.ls_taskName!]["layout"]["footer"].boolValue == true) {
                DispatchQueue.main.async {
                    self.setTitle("\(self.ls_ScreenTitle!) (\(self.larr_rawData?.count ?? 0))")
                }
            }
            
            self.showActivityIndicator()
            
            if self.larr_rawData != nil {
                self.DynamicApiController.DataObjectMapping(DataJson: self.larr_rawData!, FieldsJson: larr_fields, ObjectJson: self.ldict_object, DropDownData: nil) { (DataMappingresponse) in
                    self.hideActivityIndicator()
                    
                    switch DataMappingresponse{
                    case .success(let listData):
                        self.larr_Datasource = listData as [[[NSMutableAttributedString]]]
                        self.larr_Decision = self.larr_Decision!
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView.setNeedsLayout()
                            self.tableView.layoutIfNeeded()
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        self.showAlert(message:error.description)
                    case .failureJson(_):
                        break
                    }
                }
            }
            else{
                self.hideActivityIndicator()
                self.larr_Datasource = []
                self.larr_Decision = self.larr_Decision!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.setNeedsLayout()
                    self.tableView.layoutIfNeeded()
                    self.tableView.reloadData()
                }
            }
            
        }else{
            self.showActivityIndicator()
            
            var dataBodyDictionary:[String : Any] = [:]
            
            if layoutJson!["flow"][self.ls_taskName!]["layout"]["lazyLoading"] == true{
                dataBodyDictionary = ["appId":"\(self.ls_appName)",
                                      "workFlowTask":"\(self.ls_taskName!)","deviceType" : "mobile"] as [String : Any]
                dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize]
                if !self.larr_operation.contains("pagination")  {
                    self.larr_operation.append("pagination")
                }
                dataBodyDictionary["operation"] = self.larr_operation
            }else{
                dataBodyDictionary = ["appId":"\(self.ls_appName)",
                                      "workFlowTask":"\(self.ls_taskName!)","deviceType" : "mobile"] as [String : Any]
                self.larr_rawData = []
            }
            if li_refreshFlag == true{
                dataBodyDictionary["refresh"] = true
                dataBodyDictionary["operation"] = []
                li_refreshFlag = false
            }
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.tableFooterView = nil
            }
            
            
            if previousScreenResponse != nil{
                if previousScreenResponse!["data"][ls_taskName!]["query"] != nil {
                    if self.larr_operation.contains("sort"){
                        dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":previousScreenResponse!["data"][ls_taskName!]["query"].dictionaryObject ?? [],"sort":self.sortOption]
                    }else{
                        dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":previousScreenResponse!["data"][ls_taskName!]["query"].dictionaryObject ?? [:]]
                        if !self.larr_operation.contains("filter") {
                            self.larr_operation.append("filter")
                        }
                    }
                    dataBodyDictionary["operation"] = self.larr_operation
                }else {
                    
                    let listData = previousScreenResponse!["data"][ls_taskName!].arrayValue
                    for each in listData{
                        self.larr_rawData?.append(each)
                    }
                    
                    if self.DataCurrentpage == 0 && (previousScreenResponse!["data"][ls_taskName!]).arrayValue.count == 0 {
                        self.larr_rawData = []
                        self.larr_Datasource = []
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView.setNeedsLayout()
                            self.tableView.layoutIfNeeded()
                            self.tableView.reloadData()
                        }
                    }
                    
                    if listData.count > 0 {
                        
                        for each in larr_fields {
                            if self.ldict_object["\(each["key"])"] != nil && self.ldict_object["\(each["key"])"]!["type"].stringValue == "dropdown" {
                                if self.ldict_object["\(each["key"])"]!["propertyKey"] != nil{
                                    self.ldict_dropdownData[each["key"].stringValue] = self.ldict_object["\(each["key"])"]!["propertyKey"]["\(each["key"])"]
                                }else{
                                    var DropdownServiceKey:[String:Any] = [:]
                                    
                                    DropdownServiceKey["serviceKey"] = self.ldict_object["\(each["key"])"]!["serviceKey"].stringValue
                                    
                                    if self.ldict_object["\(each["key"])"]!["dependsOn"] != JSON.null {
                                        DropdownServiceKey["dependsOn"] = self.ldict_object["\(each["key"])"]!["dependsOn"].arrayObject
                                    }else{
                                        
                                        if self.ldict_object["\(each["key"])"]!["parent"] != nil {
                                            var larr_parentString:[String] = []
                                            
                                            for i in 0..<self.ldict_object["\(each["key"])"]!["parent"].count {
                                                
                                                if listData.count == 1{ larr_parentString.append(listData[0][self.ldict_object["\(each["key"])"]!["parent"][i].stringValue].stringValue)
                                                }
                                            }
                                            
                                            DropdownServiceKey["dependsOn"] = larr_parentString
                                        }
                                    }
                                    self.larr_dropDownServiceKey.append(DropdownServiceKey)
                                }
                            }
                        }
                        
                        
                        self.DynamicApiController.DataObjectMapping(DataJson: self.larr_rawData!, FieldsJson: larr_fields, ObjectJson: self.ldict_object, DropDownData: self.ldict_dropdownData) { (DataMappingresponse) in
                            self.hideActivityIndicator()
                            
                            switch DataMappingresponse{
                            case .success(let listData):
                                self.larr_Datasource = listData as [[[NSMutableAttributedString]]]
                                self.larr_Decision = self.larr_Decision!
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    self.tableView.setNeedsLayout()
                                    self.tableView.layoutIfNeeded()
                                    self.tableView.reloadData()
                                }
                            case .failure(let error):
                                self.showAlert(message:error.description)
                            case .failureJson(_):
                                break
                            }
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    self.hideActivityIndicator()
                    return
                }
                
            }
            else if ls_selectedQueryParameter != nil {
                if self.larr_operation.contains("search") && self.larr_operation.contains("sort"){
                    var query = JSON.init(parseJSON: ls_selectedQueryParameter!)["query"]["bool"]["must"].arrayObject!
                    query.append(self.searchOption)
                    
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"sort":self.sortOption,"query":["bool":["must":query]]]
                    if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                        self.larr_operation.append("pagination")
                    }
                    dataBodyDictionary["operation"] = self.larr_operation
                }else if self.larr_operation.contains("search") {
                    var query = JSON.init(parseJSON: ls_selectedQueryParameter!)["query"]["bool"]["must"].arrayObject!
                    query.append(self.searchOption)
                    
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":["bool":["must":query]]]
                    if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                        self.larr_operation.append("pagination")
                    }
                    dataBodyDictionary["operation"] = self.larr_operation
                }
                else if self.larr_operation.contains("sort"){
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":JSON.init(parseJSON: ls_selectedQueryParameter!)["query"].dictionaryObject ?? [],"sort":self.sortOption]
                }else{
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":JSON.init(parseJSON: ls_selectedQueryParameter!)["query"].dictionaryObject ?? [:]]
                    if !self.larr_operation.contains("filter") {
                        self.larr_operation.append("filter")
                    }
                }
                dataBodyDictionary["operation"] = self.larr_operation
            }
            else if self.larr_operation.count > 0 {
                
                if self.larr_operation.contains("search") && self.larr_operation.contains("sort") && self.larr_operation.contains("filter"){
                    var queryOption:[String:Any] = [:]
                    queryOption["multi_match"] = self.searchOption["multi_match"]!
                    if self.filterOption["bool"] != nil {
                        queryOption["bool"] = self.filterOption["bool"]!
                    }
                    
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"sort":self.sortOption,"query":queryOption]
                    if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                        self.larr_operation.append("pagination")
                    }
                    dataBodyDictionary["operation"] = self.larr_operation
                }
                else if self.larr_operation.contains("search") && self.larr_operation.contains("sort"){
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"sort":self.sortOption,"query":self.searchOption]
                    if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                        self.larr_operation.append("pagination")
                    }
                    dataBodyDictionary["operation"] = self.larr_operation
                }
                else if self.larr_operation.contains("search") && self.larr_operation.contains("filter"){
                    var queryOption:[String:Any] = [:]
                    queryOption["multi_match"] = self.searchOption["multi_match"]!
                    if self.filterOption["bool"] != nil {
                        queryOption["bool"] = self.filterOption["bool"]!
                    }
                    
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":queryOption]
                    if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                        self.larr_operation.append("pagination")
                    }
                    dataBodyDictionary["operation"] = self.larr_operation
                }else if self.larr_operation.contains("search") {
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":self.searchOption]
                    if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                        self.larr_operation.append("pagination")
                    }
                    dataBodyDictionary["operation"] = self.larr_operation
                }else{
                    
                    if self.larr_operation.contains("filter") && self.larr_operation.contains("sort") {
                        dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":self.filterOption,"sort":self.sortOption]
                        if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                            self.larr_operation.append("pagination")
                        }
                        dataBodyDictionary["operation"] = self.larr_operation
                    }else{
                        if self.larr_operation.contains("filter"){
                            dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"query":self.filterOption]
                            if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                                self.larr_operation.append("pagination")
                            }
                            dataBodyDictionary["operation"] = self.larr_operation
                        }
                        
                        if self.larr_operation.contains("sort"){
                            dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize,"sort":self.sortOption]
                            if self.DataCurrentpage > 0 && !self.larr_operation.contains("pagination"){
                                self.larr_operation.append("pagination")
                            }
                            dataBodyDictionary["operation"] = self.larr_operation
                        }
                        
                        /*
                         if layoutJson!["flow"][self.ls_taskName!]["layout"]["lazyLoading"] == true{
                         dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize]
                         if !self.larr_operation.contains("pagination")  {
                         self.larr_operation.append("pagination")
                         }
                         dataBodyDictionary["operation"] = self.larr_operation
                         }
                         */
                    }
                }
                
            }else{
                if layoutJson!["flow"][self.ls_taskName!]["layout"]["lazyLoading"] == true{
                    dataBodyDictionary["qP"] = ["from": self.DataCurrentpage,"size":self.defaultPageSize]
                    //                if self.DataCurrentpage > 0{
                    if !self.larr_operation.contains("pagination")  {
                        self.larr_operation.append("pagination")
                    }
                    //                }
                    dataBodyDictionary["operation"] = self.larr_operation
                }
            }
            
            if self.ldict_ScreenData != nil {
                dataBodyDictionary["payLoadData"] = self.ldict_ScreenData!.dictionaryObject!
            }
            
            ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) {  (dataResponse) in
                self.hideActivityIndicator()
                switch dataResponse {
                case .success(let dataJson):
                    if  dataJson["totalCount"] == -1{
                        self.getData()
                        return
                    }
                    
                    if self.ls_ScreenTitle != nil && (self.layoutJson!["flow"][self.ls_taskName!]["layout"]["footer"].bool == nil || self.layoutJson!["flow"][self.ls_taskName!]["layout"]["footer"].boolValue == true) {
                        DispatchQueue.main.async {
                            self.setTitle("\(self.ls_ScreenTitle!) (\(dataJson["totalCount"].stringValue))")
                        }
                    }else if (self.layoutJson!["flow"][self.ls_taskName!]["layout"]["footer"].bool == nil || self.layoutJson!["flow"][self.ls_taskName!]["layout"]["footer"].boolValue == true) {
                        self.delegate?.SegmentedTitle(workFlowName: self.ls_taskName!, listCount: dataJson["totalCount"].stringValue)
                    }
                    
                    let listData = (dataJson.dictionary!["data"]!).arrayValue
                    for each in listData{
                        self.larr_rawData?.append(each)
                    }
                    
                    if self.DataCurrentpage == 0 && (dataJson.dictionary!["data"]!).arrayValue.count == 0 {
                        self.larr_rawData = []
                        self.larr_Datasource = []
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView.setNeedsLayout()
                            self.tableView.layoutIfNeeded()
                            self.tableView.reloadData()
                        }
                    }
                    
                    if listData.count > 0 {
                        
                        for each in larr_fields {
                            if self.ldict_object["\(each["key"])"] != nil && self.ldict_object["\(each["key"])"]!["type"].stringValue == "dropdown" {
                                if self.ldict_object["\(each["key"])"]!["propertyKey"] != nil{
                                    self.ldict_dropdownData[each["key"].stringValue] = self.ldict_object["\(each["key"])"]!["propertyKey"]["\(each["key"])"]
                                }else{
                                    var DropdownServiceKey:[String:Any] = [:]
                                    
                                    DropdownServiceKey["serviceKey"] = self.ldict_object["\(each["key"])"]!["serviceKey"].stringValue
                                    
                                    if self.ldict_object["\(each["key"])"]!["dependsOn"] != JSON.null {
                                        DropdownServiceKey["dependsOn"] = self.ldict_object["\(each["key"])"]!["dependsOn"].arrayObject
                                    }else{
                                        
                                        if self.ldict_object["\(each["key"])"]!["parent"] != nil {
                                            var larr_parentString:[String] = []
                                            
                                            for i in 0..<self.ldict_object["\(each["key"])"]!["parent"].count {
                                                
                                                if listData.count == 1{ larr_parentString.append(listData[0][self.ldict_object["\(each["key"])"]!["parent"][i].stringValue].stringValue)
                                                }
                                            }
                                            
                                            DropdownServiceKey["dependsOn"] = larr_parentString
                                        }
                                    }
                                    self.larr_dropDownServiceKey.append(DropdownServiceKey)
                                }
                            }
                        }
                        
                        
                        self.DynamicApiController.DataObjectMapping(DataJson: self.larr_rawData!, FieldsJson: larr_fields, ObjectJson: self.ldict_object, DropDownData: self.ldict_dropdownData) { (DataMappingresponse) in
                            self.hideActivityIndicator()
                            
                            switch DataMappingresponse{
                            case .success(let listData):
                                self.larr_Datasource = listData as [[[NSMutableAttributedString]]]
                                self.larr_Decision = self.larr_Decision!
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    self.tableView.setNeedsLayout()
                                    self.tableView.layoutIfNeeded()
                                    self.tableView.reloadData()
                                }
                            case .failure(let error):
                                self.showAlert(message:error.description)
                            case .failureJson(_):
                                break
                            }
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    
                case .failure(let error):
                    //                        self.showAlert(message: error.description)
                    print(error)
                case .failureJson(let errorJson):
                    print(errorJson)
                }
            }
        }
    }
    
    func submitData(decision:[String:JSON],selectedRow:Int){
        
        let bodydictionary:[String : Any] = ["workflowTaskName":decision["task"]!.stringValue,"task": decision["task"]!.stringValue,"appId":ls_appName,"id":larr_rawData![selectedRow]["_id"].stringValue,"output":[decision["task"]!.stringValue:larr_rawData![selectedRow].dictionaryObject!]] as [String : Any]
        
        self.showActivityIndicator()
        
        ConnectManager.shared.submitRecord(type: .post, dataBodyDictionary: bodydictionary) {  (resultResponse) in
            self.hideActivityIndicator()
            switch resultResponse {
            case .success(let result):
                if result["showPopUp"].boolValue == true{
                    self.showAlert(title: "", message: result["message"].stringValue, okButtonText: "Ok", cancelButtonText: nil, presentOnRootVC: true, handler: { (success) in
                        if success{
                            self.refreshPage()
                        }
                    })
                }else{
                    self.DataReload()
                }
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(_):
                break
            }
        }
        
    }
}


extension ListViewController : UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        ls_searchString = ""
        searchRecord()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
        ls_searchString = searchBar.text!
        searchRecord()
    }
    
    func searchRecord(){
        if ls_searchString != "" {
            if !self.larr_operation.contains("search") {
                self.larr_operation.append("search")
            }
            
            if !self.larr_operation.contains("filter") {
                self.larr_operation.append("filter")
            }
            searchOption = ["multi_match":["query": "\(ls_searchString)","type": "phrase_prefix","fields":["*"]]]
            
            
        }else{
            if self.larr_operation.contains("search") {
                self.larr_operation.remove(at: self.larr_operation.firstIndex(of: "search")!)
            }
            
            if filterOption.count == 0 {
                if self.larr_operation.contains("filter") {
                    self.larr_operation.remove(at: self.larr_operation.firstIndex(of: "filter")!)
                }
            }
            
            self.searchOption = [:]
        }
        
        self.larr_rawData = []
        self.larr_Datasource = []
        self.DataCurrentpage = 0
        DataReload()
        self.view.endEditing(true)
    }
    
    
    func getnavBarDetails(){
        self.showActivityIndicator()
        
        ConnectManager.shared.getNavBarDetails(app_Id: ls_appName) {  (navBarResponse) in
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
                self.setNavigationBarWithSideMenu()
            case .failure(let error):
                self.showAlert(message: error.localizedDescription)
            case .failureJson(_):
                break
            }
        }
    }
    
    func setNavigationBarWithSideMenu()
    {
        menuVC = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? WorkFlowMenuViewController
        menuVC.backgroundcolor = Utility.colorForCategory(app.categoryName)
        menuVC.delegate = self
        
        //Add Back Button
        let backBtn = UIButton(type: UIButton.ButtonType.system)
        backBtn.tintColor = .white
        backBtn.setImage(UIImage.init(named: "Back")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        backBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        backBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let backBarItem = UIBarButtonItem(customView: backBtn)
        
        //Add Hamburger Button
        let sideMenuBtn = UIButton(type: UIButton.ButtonType.system)
        sideMenuBtn.tintColor = .white
        sideMenuBtn.setImage(UIImage.init(named: "Menu")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
        sideMenuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        sideMenuBtn.addTarget(menuVC, action: #selector(menuVC.hamburgerClicked(_:)), for: UIControl.Event.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: sideMenuBtn)
        
        //Based on the config add the buttons
        if larr_navbarDetails?["navbar"].count ?? 0 > 0 && larr_navbarDetails != nil  {
            self.navigationItem.leftBarButtonItems = [backBarItem,customBarItem]
            menuVC.TableViewDatasource = larr_navbarDetails!["navbar"].arrayValue
        }else{
            self.navigationItem.leftBarButtonItems = [backBarItem]
        }
    }
    
    func selectedMenu(handler: String, queryparameter: String?) {
        menuVC.dismissHamburgerMenu()
        if ls_HomeWorkFlow != handler {
            ls_previousWorkflow = handler
            gettaskDetails(taskName: handler,queryparameter:queryparameter)
        }
    }
    
    func gettaskDetails(taskName:String,queryparameter: String? = nil){
        self.showActivityIndicator()
        
        let bodydictionary = ["appId":"\(self.ls_appName)",
                              "workFlowTask":"\(taskName)",
                              "deviceType":"mobile"] as [String : Any]
        
        ConnectManager.shared.getWorkFlowDetails(dataBodyDictionary: bodydictionary) { (taskResponse) in
            self.hideActivityIndicator()
            switch taskResponse {
            case .success(let json):
                let larr_fields = json["flow"][taskName]["fields"].arrayValue
                let larr_Decision = json["flow"][taskName]["decisions"].arrayValue
                
                switch json["flow"][taskName]["layout"]["name"].stringValue {
                case "list":
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
                    ListVC.ls_ScreenTitle = json["flow"][taskName]["label"].stringValue
                    ListVC.ls_appName = self.ls_appName
                    ListVC.ls_taskName = taskName
                    //                    ListVC.ls_tentantId = BaseTenantID
                    //                    ListVC.ls_Selectedappname = self.app.name
                    ListVC.larr_FilterList = larr_FilterList
                    ListVC.larr_SortList = larr_SortList
                    ListVC.layoutJson = json
                    ListVC.app = self.app
                    ListVC.ls_selectedQueryParameter = queryparameter
                    self.navigationController?.pushViewController(ListVC, animated: true)
                    
                case "create":
                    let CreateVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "NewVC") as! CreateViewController
                    CreateVC.app_metaData =  json
                    //                    CreateVC.ls_appName = self.ls_appName
                    CreateVC.ls_taskName = taskName
                    //                    CreateVC.ls_Selectedappname = self.app.name
                    CreateVC.ls_ScreenTitle = json["flow"][taskName]["label"].stringValue
                    CreateVC.app = self.app
                    self.navigationController?.pushViewController(CreateVC, animated: true)
                    
                case "customv2":
                    let customVC = UIStoryboard.init(name: "WorkFlow", bundle: nil).instantiateViewController(withIdentifier: "CompositeVC") as! CompositeViewController
                    
                    customVC.ls_ScreenTitle = json["flow"][taskName]["label"].stringValue
                    customVC.ls_appName = self.ls_appName
                    customVC.ls_taskName = taskName
                    customVC.app_metaData = json
                    customVC.ls_Selectedappname = self.app.name
                    
                    self.navigationController?.pushViewController(customVC, animated: true)
                default:
                    break
                }
            case .failure(let error):
                self.showAlert(message: error.description)
            case .failureJson(_):
                break
            }
        }
    }
}

extension ListViewController {
    func setupdata(){
        if layoutJson != nil {
            self.lb_Search = layoutJson!["flow"][ls_taskName!]["layout"]["options"]["serverSearch"].bool ?? false
        }
    }
}

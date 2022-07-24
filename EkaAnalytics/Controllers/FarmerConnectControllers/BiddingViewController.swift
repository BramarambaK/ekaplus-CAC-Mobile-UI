 //
 //  BiddingViewController.swift
 //  EkaAnalytics
 //
 //  Created by Nithin on 28/03/18.
 //  Copyright © 2018 Eka Software Solutions. All rights reserved.
 //
 
 import UIKit
 
 final class BiddingViewController: GAITrackedViewController, HUDRenderer, BidCounterCellDelegate, KeyboardObserver, BidRejectionDelegate,sellerRatingdelegate,CancelDealDelegate {
    
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var btnAcceptOrSend: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var toolBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var toolBarView: UIView!
    
    @IBOutlet var footerLabel: UILabel!
    
    @IBOutlet var footerView: UIView!
    
    //MARK: - Variable
    
    var selectedFarmer:Farmer?
    
    var container: UIView{
        return self.tableView
    }
    
    public var bidRefID:String! //passed from previous vc
    
    public var bid:MyBid? //passed from previous vc
    
    public var ls_colour:UIColor?
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat =  "yyyy-MM-dd"
        return df
    }()
    
    lazy var numberFormatter:NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    var defaultBiddingStatus : BidStatus = .accepted
    
    var ls_FarmerConnectMode:String?
    
    lazy var apiController:PermCodeAPIController = {
        return PermCodeAPIController()
    }()
    
    var larr_permissionCode:[String] = []
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.bids
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        self.registerForKeyboardNotifications(shouldRegister: true)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
            self.navigationController!.navigationBar.standardAppearance = appearance;
            self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
        }
        
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.leftItemsSupplementBackButton = false
        self.navigationItem.hidesBackButton = false
        //        setTitle("\(bidRefID!)", color: .black, backbuttonTint: Utility.appThemeColor)
        //        setTitle("\(bidRefID!)", color: .black, backbuttonTint: Utility.appThemeColor)
        
        let backbtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Back_blue").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(backButtonTapped(_:event:)))
        backbtn.tintColor = Utility.appThemeColor
        self.navigationItem.leftBarButtonItem = backbtn
        
        setTitle("\(bidRefID!)", color: .black, backbuttonTint: Utility.appThemeColor)
        
        let btnOptions = UIBarButtonItem(image: #imageLiteral(resourceName: "meat_balls").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(optionsButtonTapped(_:event:)))
        btnOptions.tintColor = Utility.appThemeColor
        self.navigationItem.rightBarButtonItem = btnOptions
        
        //Initially hide tool bar view. Depending on the api response, if its farmer's turn, show the toolbar view
        toolBarHeightConstraint.constant = 0
        toolBarView.isHidden = true
        
        self.selectedFarmer = DataCacheManager.shared.getLastSelectedFarmer()
        
        if bid != nil {
            setFooter()
            toggleToolBarView()
        }else{
            getMyBidDetails()
        }
        
        if ls_FarmerConnectMode?.uppercased() == "OFFER" {
            self.showActivityIndicator()
            apiController.getPermCode(appId: "22") { (response) in
                self.hideActivityIndicator()
                switch response {
                case .success(let premCode):
                    self.larr_permissionCode = premCode
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.larr_permissionCode = []
                    print(error.description)
                    
                case .failureJson(_):
                    break
                }
            }
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { (_) in
            self.navigationController?.navigationBar.barTintColor = .white
        }
    }
    
     override func willMove(toParent parent: UIViewController?) {
         super.willMove(toParent: parent)
         if #available(iOS 13.0, *) {
             let appearance = UINavigationBarAppearance()
             appearance.backgroundColor = Utility.appThemeColor
             appearance.titleTextAttributes = [.foregroundColor:Utility.appThemeColor]
             self.navigationController!.navigationBar.standardAppearance = appearance;
             self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
         }
     }
     
    
    func getMyBidDetails(){
        
        showActivityIndicator()
        BidListApiController.shared.getDetailsForMyBid(farmerId: selectedFarmer?.id, refId: self.bidRefID) { (response) in
            self.hideActivityIndicator()
            
            switch response {
            case .success(let mybid):
                self.bid = mybid
                
                DispatchQueue.main.async {
                    self.setFooter()
                    self.tableView.reloadData()
                }
                
                if self.ls_FarmerConnectMode?.uppercased() == "BID" {
                    //If its farmer turn, show the accept button
                    if mybid.pendingOn == .farmer {
                        self.toolBarHeightConstraint.constant = 60
                        UIView.animate(withDuration: 0.25, animations: {
                            self.toolBarView.isHidden = false
                            self.view.layoutIfNeeded()
                        })
                    } else {
                        self.toolBarHeightConstraint.constant = 0
                        UIView.animate(withDuration: 0.25, animations: {
                            self.toolBarView.isHidden = false
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                else{
                    //If its farmer turn, show the accept button
                    if mybid.pendingOn == .trader {
                        if self.larr_permissionCode.contains("STD_APP_BIDS_ACCEPT") || self.larr_permissionCode.contains("STD_APP_BIDS_COUNTER") {
                            self.toolBarHeightConstraint.constant = 60
                            UIView.animate(withDuration: 0.25, animations: {
                                self.toolBarView.isHidden = false
                                self.view.layoutIfNeeded()
                            })
                        }else{
                            self.toolBarHeightConstraint.constant = 0
                            UIView.animate(withDuration: 0.25, animations: {
                                self.toolBarView.isHidden = false
                                self.view.layoutIfNeeded()
                            })
                        }
                        
                    } else {
                        self.toolBarHeightConstraint.constant = 0
                        UIView.animate(withDuration: 0.25, animations: {
                            self.toolBarView.isHidden = false
                            self.view.layoutIfNeeded()
                        })
                    }
                }
                
                
            case .failure(let error):
                self.showAlert(message:error.description)
                
            case .failureJson(_):
                break
            }
        }
    }
    
    func setFooter(){
        let date = Date(timeIntervalSince1970: (bid!.updatedDate/1000))
        let dateString = dateFormatter.string(from: date)
        
        var acceptedBy = ""
        var agreedPrice = ""
        
        if ls_FarmerConnectMode?.uppercased() == "OFFER" {
            if bid!.lastBidActivityBy == "Bidder"{
                acceptedBy = NSLocalizedString("Bidder", comment: "Bidder")
                //If accepted by farmer, take Trader's price
                agreedPrice = (numberFormatter.string(from: NSNumber(value: bid!.latestOfferorPrice))!  + " " + bid!.pricePerUnitQuantity)
                
            } else if bid!.lastBidActivityBy == "Offeror"{
                acceptedBy = NSLocalizedString("you", comment: "you")
                //If accepted by trader, take farmer's price
                agreedPrice = (numberFormatter.string(from: NSNumber(value: bid!.latestBidderPrice))!  + " " + bid!.pricePerUnitQuantity)
            }
        }else{
            if bid!.lastBidActivityBy == "Bidder"{
                acceptedBy = NSLocalizedString("you", comment: "you")
                //If accepted by farmer, take Trader's price
                agreedPrice = (numberFormatter.string(from: NSNumber(value: bid!.latestOfferorPrice))!  + " " + bid!.pricePerUnitQuantity)
                
            } else if bid!.lastBidActivityBy == "Offeror"{
                acceptedBy = NSLocalizedString("Offeror", comment: "Offeror")
                //If accepted by trader, take farmer's price
                agreedPrice = (numberFormatter.string(from: NSNumber(value: bid!.latestBidderPrice))!  + " " + bid!.pricePerUnitQuantity)
            }else if bid!.lastBidActivityBy == "Agent"{
                acceptedBy = NSLocalizedString("Agent", comment: "Agent")
                //If accepted by trader, take farmer's price
                agreedPrice = (numberFormatter.string(from: NSNumber(value: bid!.latestOfferorPrice))!  + " " + bid!.pricePerUnitQuantity)
            }
        }
        
        //No Negotiation happened and farmer accepted at published price directly.
        if bid!.latestOfferorPrice == 0 && bid!.latestBidderPrice == 0 {
            agreedPrice = (numberFormatter.string(from: NSNumber(value: bid!.publishedPrice))!  + " " + bid!.pricePerUnitQuantity)
        }
        
        
        if bid!.status == .accepted{
            footerLabel.text = NSLocalizedString("The Deal was accepted by", comment: "") + " " + acceptedBy + " " + NSLocalizedString("on", comment: "") + " " + dateString + " " + NSLocalizedString("at", comment: "") + " " +  agreedPrice
            
            
            
            //                NSLocalizedString("The Deal was accepted by \(acceptedBy) on \(dateString) at \(agreedPrice)", comment: "Accepted message")
            
            footerLabel.sizeToFit()
            tableView.tableFooterView = footerView
        } else if bid!.status == .rejected {
            footerLabel.text = NSLocalizedString("The Deal was rejected by", comment: "") + " " +  acceptedBy + " " +  NSLocalizedString("on", comment: "") + " " +  dateString
            
            
            //                NSLocalizedString("The Deal was rejected by \(acceptedBy) on \(dateString)", comment: "Rejected message")
            
            footerLabel.sizeToFit()
            tableView.tableFooterView = footerView
        }else if bid!.status == .cancelled {
            footerLabel.text =  NSLocalizedString("The Deal was cancelled by", comment: "") + " " +  acceptedBy + " " +  NSLocalizedString("on", comment: "") + " " +  dateString
            footerLabel.sizeToFit()
            tableView.tableFooterView = footerView
        }
    }
    
    @objc
    func backButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func optionsButtonTapped(_ sender:UIBarButtonItem, event:UIEvent){
        let config = FTPopOverMenuConfiguration.default()
        config?.tintColor = .white
        config?.textColor = .black
        config?.menuWidth = 150
        config?.menuTextMargin = 15
        
        guard self.bid != nil else {
            return
        }
        
        var menuArray = [NSLocalizedString("Bid log", comment: "Bid log button")]
        
        if bid!.status == BidStatus.inProgress && bid!.pendingOn == .farmer && ls_FarmerConnectMode?.uppercased() != "OFFER" {
            menuArray.append(NSLocalizedString("Reject this deal", comment: "Reject deal button"))
        }
        
        if bid!.status == BidStatus.accepted && ls_FarmerConnectMode?.uppercased() == "OFFER" && UserDefaults.standard.bool(forKey: UserDefaultsKeys.cancelPermission.rawValue) && self.larr_permissionCode.contains("STD_APP_BIDS_CANCEL") {
            menuArray.append(NSLocalizedString("Cancel this deal", comment: ""))
        }
        
        if bid!.status == BidStatus.inProgress && bid!.pendingOn == .trader && ls_FarmerConnectMode?.uppercased() == "OFFER" && self.larr_permissionCode.contains("STD_APP_BIDS_REJECT")  {
            menuArray.append(NSLocalizedString("Reject this deal", comment: "Reject deal button"))
        }
        
        
        FTPopOverMenu.show(from: event, withMenuArray: menuArray, doneBlock: { (selectedIndex) in
            
            if selectedIndex == 0 {
                
                //Google Analytics event tracking
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "View Bid Log", label: "FarmerConnect", value: nil).build() as? [AnyHashable : Any])
                }
                
                let bidLogVC = self.storyboard?.instantiateViewController(withIdentifier: "BidLogViewController") as! BidLogViewController
                bidLogVC.refId = self.bid!.refId
                bidLogVC.id = self.bid!.id
                bidLogVC.ls_FarmerConnectMode = self.ls_FarmerConnectMode
                bidLogVC.modalPresentationStyle = .overCurrentContext
                self.present(bidLogVC, animated: true, completion: nil)
                
                
            } else if selectedIndex == 1 {
                
                //Google Analytics event tracking
                if let tracker = GAI.sharedInstance().defaultTracker {
                    tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Apps", action: "Reject Deal", label: "FarmerConnect", value: nil).build() as? [AnyHashable : Any])
                }
                
                if self.ls_FarmerConnectMode?.uppercased() == "BID"{
                    let bidRejectVC = self.storyboard?.instantiateViewController(withIdentifier: "BidRejectionViewController") as! BidRejectionViewController
                    bidRejectVC.modalPresentationStyle = .overCurrentContext
                    bidRejectVC.refId = self.bidRefID
                    bidRejectVC.delegate = self
                    bidRejectVC.latestTraderPrice = self.bid!.latestOfferorPrice
                    bidRejectVC.priceUnit = self.bid!.pricePerUnitQuantity
                    bidRejectVC.ls_FarmerConnectMode = self.ls_FarmerConnectMode
                    self.present(bidRejectVC, animated: true, completion: nil)
                }else{
                    if self.bid!.status == BidStatus.inProgress {
                        let bidRejectVC = self.storyboard?.instantiateViewController(withIdentifier: "BidRejectionViewController") as! BidRejectionViewController
                        bidRejectVC.modalPresentationStyle = .overCurrentContext
                        bidRejectVC.refId = self.bidRefID
                        bidRejectVC.delegate = self
                        bidRejectVC.latestTraderPrice = self.bid!.latestBidderPrice
                        bidRejectVC.priceUnit = self.bid!.pricePerUnitQuantity
                        bidRejectVC.ls_FarmerConnectMode = self.ls_FarmerConnectMode
                        self.present(bidRejectVC, animated: true, completion: nil)
                    }else{
                        let cancelVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "CancelDealVC") as! CancelDealViewController
                        cancelVC.ls_bidId = self.bid!.refId
                        cancelVC.delegate = self
                        cancelVC.modalPresentationStyle = .overCurrentContext
                        self.present(cancelVC, animated: true, completion: nil)
                    }
                }
            }
        }) {
            //print("Dismiss")
        }
    }
    
    //Bid Rejection delegate
    func refreshPage() {
        //        getMyBidDetails()
        toggleToolBarView()
        //After rejection, take the user back to bid listing screen
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelRefreshPage() {
        toggleToolBarView()
        self.navigationController?.popViewController(animated: true)
    }
    
    //Counter Cell delegate
    func counterToggled(_ selected: Bool) {
        if selected {
            btnAcceptOrSend.setTitle(NSLocalizedString("Send", comment: "Button title for send"), for: .normal)
            defaultBiddingStatus = .inProgress
        } else {
            btnAcceptOrSend.setTitle(NSLocalizedString("Accept", comment: "Button title for accept"), for: .normal)
            defaultBiddingStatus = .accepted
            
            //Clear price field if user has entered any.
            if let counterCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? BidCounterTableViewCell{
                counterCell.txfCounterPrice.text = nil
            }
        }
    }
    
    func updateBid(_ bidDetails:String){
        
        var queryParam:Bool = true
        
        if ls_FarmerConnectMode?.uppercased() == "BID"{
            queryParam = false
        }
        
        BidListApiController.shared.updateBid(farmerId:selectedFarmer?.id , refId: bidRefID, bidDetails,queryParam) { (response) in
            switch response {
            case .success(_):
                
                self.showAlert(title: NSLocalizedString("Success", comment: "alert title for success") , message: NSLocalizedString("Your message has been sent.", comment: "Message sent alert text") , okButtonText: NSLocalizedString("Ok", comment: "Alert ok button"), cancelButtonText: nil, handler: { (success) in
                    if success {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                
            case .failure(let error):
                self.showAlert(message: error.description)
                
            case .failureJson(_):
                break
            }
        }
    }
    
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        
        var bidUpdate:[String:Any]!
        
        bidUpdate = ["status":defaultBiddingStatus.rawValue]
        
        if let counterCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? BidCounterTableViewCell{
            
            
            if counterCell.btnCounterCheck.isSelected {
                guard let counterPrice = counterCell.txfCounterPrice.text, counterPrice != "", Utility.validNumber(num: counterPrice) != nil  else {
                    self.showAlert(message:NSLocalizedString("Please enter a valid non-zero counter price.", comment: "Validation message") )
                    return
                }
                bidUpdate.updateValue(counterPrice, forKey: "price")
            }
            
            
            if let remarks = counterCell.txvRemarks.text {
                if UserDefaults.standard.bool(forKey: UserDefaultsKeys.personalInfoSharingRestricted.rawValue){
                    if remarks.getEmailandPhoneValidation() == true {
                        self.showAlert(title: "Warning", message: NSLocalizedString("Kindly do not enter any email ids or phone numbers.", comment: ""), okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
                        })
                        return
                    }else{
                        bidUpdate.updateValue(remarks, forKey: "remarks")
                    }
                }else{
                      bidUpdate.updateValue(remarks, forKey: "remarks")
                }
            }
        }
        
        
        if defaultBiddingStatus == .accepted {
            
            if ls_FarmerConnectMode?.uppercased() == "BID"{
                //Ask for confirmation before accepting
                self.showAlert(title: NSLocalizedString("Confirmation", comment: "Confirmation"), message: NSLocalizedString("You're accepting the bid at the price \(bid!.latestOfferorPrice) \(bid!.pricePerUnitQuantity)", comment: "Confirmation message"), okButtonText: NSLocalizedString("Accept", comment: "accept"), cancelButtonText: NSLocalizedString("Cancel", comment: "cancel"), presentOnRootVC: true) { (accepted) in
                    if accepted{
                        self.updateBid(bidUpdate.jsonString())
                    }
                }
            }
            else{
                //Ask for confirmation before accepting
                self.showAlert(title: NSLocalizedString("Confirmation", comment: "Confirmation"), message: NSLocalizedString("You're accepting the bid at the price \(bid!.latestBidderPrice) \(bid!.pricePerUnitQuantity)", comment: "Confirmation message"), okButtonText: NSLocalizedString("Accept", comment: "accept"), cancelButtonText: NSLocalizedString("Cancel", comment: "cancel"), presentOnRootVC: true) { (accepted) in
                    if accepted{
                        self.updateBid(bidUpdate.jsonString())
                    }
                }
                
            }
        }
        else { //Sending a counter price
            self.updateBid(bidUpdate.jsonString())
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
 }
 
 extension BiddingViewController : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if bid == nil {
            return 0
        }
        //First cell has the basic details
        //Then comes the list of bid transactions(negotiations's  or bidlogs)
        //If it's farmer's turn, then show the cell to enter counter price
        if self.ls_FarmerConnectMode?.uppercased() ==  "BID" {
            return 1 + 1 + (bid?.pendingOn == .farmer ? 1 : 0)
        }else{
            if self.larr_permissionCode.contains("STD_APP_BIDS_COUNTER") {
                return 1 + 1 + (bid?.pendingOn == .trader ? 1 : 0)
            }else{
                return 1 + 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard bid != nil else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            //cell will be selected based on the User Type
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callTapFunction))
            let ratingTapGesture = UITapGestureRecognizer(target: self, action: #selector(ratingTapFunction))
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.agentPermission.rawValue){
                let Agentcell = tableView.dequeueReusableCell(withIdentifier: "AgentBidDetailsCell" , for: indexPath) as! AgentBidDetailsTableViewCell
                Agentcell.lblFarmerName.text = selectedFarmer?.name
                Agentcell.lblFarmerID.text = selectedFarmer?.externalUserId
                Agentcell.lblBidId.text = bid!.id
                Agentcell.lblRefId.text = bid!.refId
                Agentcell.lblProduct.text = bid!.product
                Agentcell.lblQuality.text = bid!.quality
                Agentcell.lblCropYear.text = bid!.cropYear
                Agentcell.lblLocation.text = bid!.location
                Agentcell.lblQuantity.text = numberFormatter.string(from: NSNumber(value: bid!.quantity))! + " " + bid!.quantityUnit
                Agentcell.lblTerm.text = bid!.incoTerm
                Agentcell.lblOfferType.text = bid!.offerType
                
                if bid!.offerorMobileNo.count > 0 {
                    Agentcell.lblOfferMobileNo.attributedText = NSAttributedString(string: bid!.offerorMobileNo, attributes:[.underlineStyle: NSUnderlineStyle.single.rawValue])
                    Agentcell.lblOfferMobileNo.textColor = UIColor.blue
                    Agentcell.lblOfferMobileNo.isUserInteractionEnabled = true
                    Agentcell.lblOfferMobileNo.addGestureRecognizer(tapGesture)
                }else{
                    Agentcell.lblOfferMobileNo.text = NSLocalizedString("Not Available", comment: "")
                }
                
                if bid!.offerorName.count > 0 {
                    Agentcell.lblOfferName.text = bid!.offerorName
                }else{
                    Agentcell.lblOfferName.text = NSLocalizedString("Not Available", comment: "")
                }
                
                if bid!.offerorRating.count > 0 {
                    Agentcell.lblOfferRating.text = "\(String(describing: Double(bid!.offerorRating)!))"
                }else{
                    Agentcell.lblOfferRating.text = NSLocalizedString("Not Available", comment: "")
                }
                
                if bid!.status == .accepted{
                    Agentcell.yourRatingHeight.constant = 20.5
                    Agentcell.yourRatingHeight1.constant = 20.5
                    print(bid!.currentBidRating)
                    if bid!.currentBidRating.count > 0 {
                        Agentcell.lblYourSellerRating1.text = "\(Double(bid!.currentBidRating)!)"
                    }else{
                        if bid!.offerorName.count > 0 {
                            Agentcell.lblYourSellerRating1.text = NSLocalizedString("Rate Now", comment: "")
                        }else{
                            Agentcell.lblYourSellerRating1.text = NSLocalizedString("Not Available", comment: "")
                        }
                        Agentcell.lblYourSellerRating1.textColor = UIColor.blue
                        Agentcell.lblYourSellerRating1.isUserInteractionEnabled = true
                        Agentcell.lblYourSellerRating1.addGestureRecognizer(ratingTapGesture)
                    }
                }else{
                    Agentcell.yourRatingHeight.constant = 0
                    Agentcell.yourRatingHeight1.constant = 0
                }
                
                //TimeInterval returned from API is in milli-seconds(java uses milliseconds). But Date api in swift expects timeinterval in seconds.
                let deliveryFromDate = Date(timeIntervalSince1970: (bid!.deliveryFromDateInMillis/1000))
                let deliveryToDate = Date(timeIntervalSince1970: (bid!.deliveryToDateInMillis/1000))
                
                Agentcell.lblShipmentDate.text = "\(dateFormatter.string(from: deliveryFromDate)) to \( dateFormatter.string(from: deliveryToDate))"
                
                Agentcell.selectionStyle = .none
                return Agentcell
            }
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "BidDetailsCell" , for: indexPath) as! BidDetailsTableViewCell
                cell.lblBidId.text = bid!.id
                cell.lblProduct.text = bid!.product
                cell.lblQuality.text = bid!.quality
                cell.lblCropYear.text = bid!.cropYear
                cell.lblLocation.text = bid!.location
                cell.lblQuantity.text = numberFormatter.string(from: NSNumber(value: bid!.quantity))! + " " + bid!.quantityUnit
                cell.lblTerm.text = bid!.incoTerm
                cell.lblOfferType.text = bid!.offerType
                
                if bid!.offerorMobileNo.count > 0 {
                    cell.lblOfferMobileNo.attributedText = NSAttributedString(string: bid!.offerorMobileNo, attributes:[.underlineStyle: NSUnderlineStyle.single.rawValue])
                    cell.lblOfferMobileNo.textColor = UIColor.blue
                    cell.lblOfferMobileNo.isUserInteractionEnabled = true
                    cell.lblOfferMobileNo.addGestureRecognizer(tapGesture)
                }else{
                    cell.lblOfferMobileNo.text = NSLocalizedString("Not Available", comment: "")
                }
                
                if bid!.offerorName.count > 0 {
                    cell.lblOfferName.text = bid!.offerorName
                }else{
                    cell.lblOfferName.text = NSLocalizedString("Not Available", comment: "")
                }
                
                if bid!.offerorRating.count > 0 && bid!.offerorRating != "Pending" {
                    cell.lblOfferRating.text = "\(String(describing: Double(bid!.offerorRating)!))"
                }else{
                    cell.lblOfferRating.text = NSLocalizedString("Not Available", comment: "")
                }
                
                
                if bid!.status == .accepted && UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerRatingAllowed.rawValue){
                    cell.yourRatingHeight.constant = 20.5
                    cell.yourRatingHeight1.constant = 20.5
                    print(bid!.currentBidRating)
                    if bid!.currentBidRating.count > 0 {
                        cell.lblYourSellerRating1.text = "\(Double(bid!.currentBidRating)!)"
                        cell.lblYourSellerRating1.textColor = UIColor.darkGray
                    }else{
                        if bid!.offerorName.count > 0 {
                            cell.lblYourSellerRating1.text = NSLocalizedString("Rate Now", comment: "")
                            
                        }
                        else{
                            cell.lblYourSellerRating1.text = NSLocalizedString("Not Available", comment: "")
                        }
                        cell.lblYourSellerRating1.textColor = UIColor.blue
                        cell.lblYourSellerRating1.isUserInteractionEnabled = true
                        cell.lblYourSellerRating1.addGestureRecognizer(ratingTapGesture)
                    }
                }else{
                    cell.yourRatingHeight.constant = 0
                    cell.yourRatingHeight1.constant = 0
                }
                
                //TimeInterval returned from API is in milli-seconds(java uses milliseconds). But Date api in swift expects timeinterval in seconds.
                
                let deliveryFromDate = Date(timeIntervalSince1970: (bid!.deliveryFromDateInMillis/1000))
                let deliveryToDate = Date(timeIntervalSince1970: (bid!.deliveryToDateInMillis/1000))
                
                cell.lblShipmentDate.text = "\(dateFormatter.string(from: deliveryFromDate)) to \( dateFormatter.string(from: deliveryToDate))"
                
                if UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerorInfoRestricted.rawValue){
                    cell.offerNameHeight.constant = 0
                    cell.offerMobileNoHeight.constant = 0
                    
                    
                    
//                    if bid!.status == .accepted && UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerRatingAllowed.rawValue){
//                        cell.yourRatingViewHeight.constant = 32.5
//                    }else{
//                        cell.yourRatingViewHeight.constant = 0
//                    }
                }else{
                    cell.offerNameHeight.constant = 32.5
                    cell.offerMobileNoHeight.constant = 53
//                    if bid!.status == .accepted && UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerRatingAllowed.rawValue){
////                        cell.offerDetailHeight.constant = 97.5
//                    }else{
////                         cell.offerDetailHeight.constant = 118
//                    }
                }
                
                
                
                if  UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerRatingAllowed.rawValue){
                    if bid!.status == .accepted && ls_FarmerConnectMode?.uppercased() == "BID"{
                        cell.offerRatingHeight.constant = 53
                        cell.yourRatingViewHeight.constant = 53
                    }else{
                        cell.offerRatingHeight.constant = 53
                        cell.yourRatingViewHeight.constant = 0
                    }
                }else{
                    cell.offerRatingHeight.constant = 0
                    cell.yourRatingViewHeight.constant = 0
                }
                
                
                
                if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) == "basic"{
                    cell.offerTypeHeight.constant = 0
                }else{
                    cell.offerTypeHeight.constant = 109.5
                    cell.lblPaymentTerm.text = bid!.paymentTerms
                    cell.lblPackingSize.text = bid!.packingSize
                    cell.lblPackingType.text = bid!.packingType
                }
                
                
                cell.selectionStyle = .none
                return cell
            }
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BidTransactionCell" , for: indexPath) as! BidTransactionTableViewCell
            
            cell.lblLatestFarmerPrice.text =  bid!.latestBidderPrice != 0 ?  (numberFormatter.string(from: NSNumber(value: bid!.latestBidderPrice))!  + " " + bid!.pricePerUnitQuantity) : ""
            
            cell.lblLatestTraderPrice.text =   bid!.latestOfferorPrice != 0 ? (numberFormatter.string(from: NSNumber(value: bid!.latestOfferorPrice))! + " " + bid!.pricePerUnitQuantity) : ""
            
            cell.lblPublishedBidPrice.text = bid!.publishedPrice != 0 ? (numberFormatter.string(from: NSNumber(value:bid!.publishedPrice))! + " " + bid!.pricePerUnitQuantity) : ""
            
            //If both are 0, No bids happened, and farmer accepted directly.
            if bid!.latestOfferorPrice == 0 && bid?.latestBidderPrice == 0 {
                cell.lblLatestFarmerPrice.text =  NSLocalizedString("No Bid Initiated", comment: "No bid initiated")
                cell.lblLatestTraderPrice.text = NSLocalizedString("No Bid Initiated", comment: "No bid initiated")
            }
            
            //If farmer accepts trader
            if bid!.status == .accepted || bid!.status == .rejected || bid!.status == .cancelled{
                if bid!.latestOfferorPrice == 0 {
                    cell.lblLatestTraderPrice.text = NSLocalizedString("No Bid Initiated", comment: "No bid initiated")
                }
            }
            
            if bid!.status == .inProgress {
                if bid!.latestBidderPrice == 0 {
                    cell.lblLatestFarmerPrice.text = NSLocalizedString("Pending", comment: "pending bid status")
                }
                if bid!.latestOfferorPrice == 0 {
                    cell.lblLatestTraderPrice.text = NSLocalizedString("Pending", comment: "pending bid status")
                }
            }
            
            cell.selectionStyle = .none
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BidCounterCell" , for: indexPath) as! BidCounterTableViewCell
            
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func toggleToolBarView(){
        
        if self.ls_FarmerConnectMode?.uppercased() == "BID" {
            //If its farmer turn, show the accept button
            if bid?.pendingOn == .farmer {
                self.toolBarHeightConstraint.constant = 60
                UIView.animate(withDuration: 0.25, animations: {
                    self.toolBarView.isHidden = false
                    self.view.layoutIfNeeded()
                })
            } else {
                self.toolBarHeightConstraint.constant = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.toolBarView.isHidden = false
                    self.view.layoutIfNeeded()
                })
            }
        }
        else{
            //If its farmer turn, show the accept button
            if bid?.pendingOn == .trader {
                self.toolBarHeightConstraint.constant = 60
                UIView.animate(withDuration: 0.25, animations: {
                    self.toolBarView.isHidden = false
                    self.view.layoutIfNeeded()
                })
            } else {
                self.toolBarHeightConstraint.constant = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.toolBarView.isHidden = false
                    self.view.layoutIfNeeded()
                })
            }
        }
        
        
    }
    
    @objc func callTapFunction(sender:UITapGestureRecognizer) {
        
        if let url = URL(string: "tel://\(bid!.offerorMobileNo)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func ratingTapFunction(sender:UITapGestureRecognizer) {
        if (bid?.userName.count)! > 0 {
            let sellerRatingVC = self.storyboard?.instantiateViewController(withIdentifier: "SellerRatingVC") as! SellerRatingViewController
            sellerRatingVC.ls_Headerlabel = NSLocalizedString("Rating", comment: "") + " (\(bid!.id) - \(bid!.refId))"
            sellerRatingVC.ls_SellerName = bid!.offerorName
            sellerRatingVC.ls_RefId = bid!.refId
            sellerRatingVC.delegate = self
            sellerRatingVC.modalPresentationStyle = .fullScreen
            self.present(sellerRatingVC, animated: true, completion: nil)
        }
    }
    
    
    func UpdateRating(rating:Double) {
        bid?.currentBidRating = "\(rating)"
        tableView.reloadData()
    }
    
 }

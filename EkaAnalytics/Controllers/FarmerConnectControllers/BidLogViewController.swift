//
//  BidLogViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 02/04/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class BidLogViewController: GAITrackedViewController, HUDRenderer {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var lbl_ScreenHeader: UILabel!
    
    //MARK: - Variable
    
    var refId:String!
    var id:String!
    
    
    private var logs = [JSON]() {
        didSet{
            tableView.reloadData()
        }
    }
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
//        df.dateFormat = "dd-MMM-yyyy"
        df.dateFormat = "dd-MMM-yyyy HH:MM:ss"
        return df
    }()
    
    lazy var numberFormatter:NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    var priceUnit:String = ""
    
    var ls_FarmerConnectMode:String?
    
    //MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.bidLogs
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        self.lbl_ScreenHeader.text = NSLocalizedString("Bid Log", comment: "") + " (\(id!) - \(refId!))"
        
        loadBidLogs()
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func loadBidLogs(){
        showActivityIndicator()
        BidListApiController.shared.getBidLogs(refId) { (response) in
            self.hideActivityIndicator()
            switch response {
            case .success(let json):
                self.priceUnit = json["priceUnit"].stringValue
                let logs = json["negotiationLogs"].arrayValue
                self.logs = logs.reversed()
            case .failure(let error):
                
                switch error {
                case .tokenRefresh:
                    self.loadBidLogs()
                case .tokenExpired:
                    let message = error.description
                    self.showAlert(title: "Error", message: message, okButtonText: "OK", cancelButtonText: nil, handler: { (success) in
                        
                        self.dismiss(animated: true, completion: {
                            self.parent?.navigationController?.popToRootViewController(animated: true)
                        })
                        
                    })
                default:
                    self.showAlert(message: error.description)
                }
                
                self.showAlert(message: error.description)
                
            case .failureJson(_):
                break
            }
        }
    }

}

extension BidLogViewController:UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidLogCell" , for: indexPath) as! BidLogTableViewCell
        
        let log = self.logs[indexPath.row]
        
        if indexPath.row == logs.count - 1{
            cell.lblDate.text = NSLocalizedString("Published Price", comment: "")
            cell.lblPrice.text = log["price"].doubleValue != 0 ? (numberFormatter.string(from: NSNumber(value:log["price"].doubleValue))! + " " + self.priceUnit) : ""
            cell.dashedLineView.isHidden = true
            cell.indicatorImageView.image = #imageLiteral(resourceName: "Published_with _bg")

            cell.selectionStyle = .none
            return cell
        }
        
        //TimeInterval returned from API is in milli-seconds(java uses milliseconds). But Date api in swift expects timeinterval in seconds.
        let date = Date(timeIntervalSince1970: (log["date"].doubleValue/1000))
    
        cell.lblDate.text = dateFormatter.string(from: date) + " IST"
        cell.lblPrice.text = log["price"].doubleValue != 0 ? (numberFormatter.string(from: NSNumber(value:log["price"].doubleValue))! + " " + self.priceUnit) : ""
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.offerorInfoRestricted.rawValue) == false {
             cell.lblRemarks.text = (log["remarks"].stringValue == "" ? NSLocalizedString("No Remarks", comment: "") : log["remarks"].stringValue)
        }else{
             cell.lblRemarks.text = log["name"].stringValue + ", " + log["by"].stringValue + ": " + (log["remarks"].stringValue == "" ? NSLocalizedString("No Remarks", comment: "") : log["remarks"].stringValue)
        }
        
        cell.dashedLineView.isHidden = false
        
        let by = BidPendingOn(rawValue: log["by"].stringValue)! //this represents that this price is proposed by farmer or trader
        
        if by == .farmer || by == .agent  {
            if ls_FarmerConnectMode?.uppercased() == "BID"{
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Sent_with_bg")
            }else{
                 cell.indicatorImageView.image = #imageLiteral(resourceName: "Received_with_bg")
            }
        } else if by == .trader {
            if ls_FarmerConnectMode?.uppercased() == "BID"{
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Received_with_bg")
            }else{
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Sent_with_bg")
            }
        }
        
        //Handle special case for the following
        //logType - 0 for published price(starting), 1- accepted , -1 for rejected
        
        if let logType = log["logType"].int {
            
            switch logType {
            case 0:
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Published_with _bg")
            case 1:
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Accepted_with bg")
                cell.lblPrice.text = NSLocalizedString("Accepted", comment: "accepted")
            case -1:
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Cancel bid_with bg")
                cell.lblPrice.text = NSLocalizedString("Rejected", comment: "rejected")
            case -2:
                cell.indicatorImageView.image = #imageLiteral(resourceName: "Cancelled_with bg")
                cell.lblPrice.text = NSLocalizedString("Cancelled", comment: "Cancelled")
            default: break
            }
        
        }
        
        cell.selectionStyle = .none
        return cell
    }
}

//
//  NotificationListViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 22/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class NotificationListViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate, PeekPopPreviewingDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    var dataSource = [BusinessAlert](){
        didSet{
            tableView.reloadData()
        }
    }
    
    var peekPop: PeekPop?
    
    var detailVC : NotificationDetailViewController?
    
    var dateFormatter:DateFormatter = {
        let dF = DateFormatter()
        dF.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        return dF
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.notificationList
        
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        if self.traitCollection.forceTouchCapability == .available{
            self.registerForPreviewing(with: self, sourceView: tableView)
        } else {
            peekPop = PeekPop(viewController: self)
            peekPop?.registerForPreviewingWithDelegate(self, sourceView: tableView)
        }
    
        setTitle(NSLocalizedString("Notifications", comment: ""))
        tableView.tableFooterView = UIView()
        
        self.dataSource = DataCacheManager.shared.notifications
        UserDefaults.standard.set(dataSource.count, forKey: UserDefaultsKeys.notificationCount.rawValue)
        
        if dataSource.count == 0 {
            tableView.noDataMessage = NSLocalizedString("No Notifications.", comment: "No Notifications description.")
        } else {
            tableView.noDataMessage = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = Utility.appThemeColor
            appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
            self.navigationController!.navigationBar.standardAppearance = appearance;
            self.navigationController!.navigationBar.scrollEdgeAppearance = self.navigationController!.navigationBar.standardAppearance
        }
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - preview delegates to support older devices
    func previewingContext(_ previewingContext: PreviewingContext, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath), let notificationDetailPopUp = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailPopUp") as? NotificationDetailPopUp else {return nil}

        notificationDetailPopUp.preferredContentSize = CGSize(width: 0.0, height: 150)
        notificationDetailPopUp.notifictionDetail = dataSource[indexPath.row]
        previewingContext.sourceRect = cell.frame

        //Assign detailVC to return it in commit/Pop phase
        let notificationDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailViewController") as!
            NotificationDetailViewController
        notificationDetailVC.notifictionDetail = dataSource[indexPath.row]
        detailVC = notificationDetailVC

        return notificationDetailPopUp
        
    }
    
    func previewingContext(_ previewingContext: PreviewingContext, commitViewController viewControllerToCommit: UIViewController) {
        if let vc = detailVC{
              self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    
    //3D touch preview delegates - iPhone6s or higher
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        if let vc = detailVC{
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }

    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath), let notificationDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailViewController") as? NotificationDetailViewController else {return nil}
        
        notificationDetailVC.preferredContentSize = CGSize(width: 0.0, height: 325)
        notificationDetailVC.notifictionDetail = dataSource[indexPath.row]
        previewingContext.sourceRect = cell.frame
        //pass data here to detail screen
        detailVC = notificationDetailVC
        return notificationDetailVC
    }
 
    
    //MARK: - Table view datasource and delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableViewCell.identifier , for: indexPath) as! NotificationTableViewCell
        
        let notification = dataSource[indexPath.row]
        cell.lblTitle.text = notification.name
        cell.lblLimitType.text = notification.limitType
        cell.lblMeasureName.text = notification.measureName
        
        
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm:ss"
        if let runDate = dateFormatter.date(from: notification.runDate){
            if Calendar.current.component(.day, from: runDate) == Calendar.current.component(.day, from: Date()) {
                cell.lblDateTime.text = "Today"
            } else if Calendar.current.component(.day, from: Date()) - Calendar.current.component(.day, from: runDate) == 1{
                cell.lblDateTime.text = "Yesterday"
            } else {
                dateFormatter.dateFormat = "E MMM dd HH:mm:ss yyyy"
                cell.lblDateTime.text = dateFormatter.string(from: runDate)
            }
        }else {
            cell.lblDateTime.text = notification.runDate
        }
        
        if notification.status == "Limit Breached" {
            cell.priorityIndicator.image = #imageLiteral(resourceName: "Limit breached")
        } else {
            cell.priorityIndicator.image = #imageLiteral(resourceName: "Threshold breached")
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notificationDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationDetailViewController") as! NotificationDetailViewController
       
        notificationDetailVC.notifictionDetail = dataSource[indexPath.row]
        self.navigationController?.pushViewController(notificationDetailVC, animated: true)
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
}

//
//  NotificationPreferencesViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 02/02/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class NotificationPreferencesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CollapsibleTableHeaderDelegate {
   
    @IBOutlet weak var tableView:UITableView!
    
    var sectionCollapsedLookUp = [Int:Bool]()
    
    let sectionTitles = ["Channel","Frequency", "Priority"]

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.reloadData()
        
        self.navigationItem.leftItemsSupplementBackButton = true
        setTitle("Notification preferences", color: .black, backbuttonTint: Utility.appThemeColor)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleSection(_ section: Int) {
        if let collapsed = sectionCollapsedLookUp[section] {
            sectionCollapsedLookUp[section] = !collapsed
        } else { //First time tap. so expand it
            sectionCollapsedLookUp[section] = false
        }
        tableView.reloadSections(IndexSet.init(integer: section), with: .automatic)
    }
    
    

    //MARK: - Tableview datasource and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let collapsed = sectionCollapsedLookUp[section] {
            return collapsed ? 0 : 3
        } else {
            return 0 //For the first time, make the section collapsed by default
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationPreferenceTableViewCell.identifier , for: indexPath) as! NotificationPreferenceTableViewCell
        
        cell.selectionStyle = .none
        cell.lblPreferenceName.text = "Preference"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UINib(nibName: "TableDropdownHeaderView", bundle: nil).instantiate(withOwner: TableDropdownHeaderView.self, options: nil).first as! TableDropdownHeaderView
        
        if let collapsed = sectionCollapsedLookUp[section] {
            header.setCollapsed(collapsed)
        }
        
        header.lblTitle.text = sectionTitles[section]
        header.delegate = self
        header.section = section
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 91
    }

}

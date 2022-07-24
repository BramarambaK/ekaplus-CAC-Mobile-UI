//
//  SubPreDefinedFilterViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class SubPreDefinedFilterViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    var filterTitle:String? //Fed from previous vc
    var dataSource = [String]() //Fed from previous vc

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.preDefinedFilters
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        
        self.navigationItem.leftItemsSupplementBackButton = true
        setTitle(filterTitle ?? "", color: .black, backbuttonTint: Utility.appThemeColor)
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    //MARK: - Table view datasource and delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreDefinedFilterCell") ?? UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "PreDefinedFilterCell")
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

//
//  WF_SubFilterViewController.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 19/03/20.
//  Copyright © 2020 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol WF_SubFilterScreenDelegate:AnyObject{
    func selectedFiltersForColumn(columnId:String, filters:[String]?)
}

class WF_SubFilterViewController: GAITrackedViewController, UITableViewDataSource, UITableViewDelegate,KeyboardObserver, HUDRenderer {
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var lbl_ScreenHeader: UILabel!
    
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var btnReset: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var containerViewForFilter: UIView!
    
    //MARK: - Variable
    
    var filterOptions:JSON = []
    
    var FiltersData = [String]()
    
    var selectedBasicFilters = [String]()//Temporary cache for basic filters - Fed from previous vc
    
    weak var delegate:WF_SubFilterScreenDelegate?
    
    var container: UIView{
        return self.view
    }
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lbl_ScreenHeader.text = filterOptions["columnName"].stringValue
    }
    
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        
        let columnId = filterOptions["columnId"].stringValue
        
        if selectedBasicFilters.count > 0 {
            delegate?.selectedFiltersForColumn(columnId: columnId, filters: selectedBasicFilters)
        }else{
            delegate?.selectedFiltersForColumn(columnId: columnId, filters: nil)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnResetTapped(_ sender: UIButton) {
        selectedBasicFilters.removeAll()
        tableView.reloadData()
    }
    
    
    //MARK: - Tableview datasource and delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FiltersData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicFilterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "BasicFilterCell")
        let basicFilter = FiltersData[indexPath.row]
        
        if selectedBasicFilters.contains(basicFilter){
            cell.imageView?.image = #imageLiteral(resourceName: "checked")
        } else {
            cell.imageView?.image = #imageLiteral(resourceName: "unchecked")
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = basicFilter
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let basicFilter = FiltersData[indexPath.row]
        if selectedBasicFilters.contains(basicFilter), let index = selectedBasicFilters.firstIndex(of: basicFilter){
            selectedBasicFilters.remove(at: index)
        } else {
            selectedBasicFilters.append(basicFilter)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//
//  SortViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 11/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

enum SortOptions:String{
    case ascending = "asc"
    case descending = "desc"
    case none = "none"
}

protocol SortCellDelegate:AnyObject{
    func didTapSortOption(_ sortOption:SortOptions, row:Int)
}

protocol SortScreenDelegate:AnyObject{
    func selectedSortOption(_ sortOptionValue: JSON?, sortOptionType:SortOptions)
}

class SortViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SortCellDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    
    weak var delegate:SortScreenDelegate?
    
    var sortOptions = [JSON]()
    
    var selectedSortOption : (row:Int, option:SortOptions) = (0, .none)
    
    var cacheIndex:Int = 0 // this is used to store multiple caches. By default we store one cache at 0 index. If required we need to pass the cache Index at which we need to store cache. This is used in Farmer Connect sort functionality where we need to cache two set of sort values.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Check if some cache exists because of previous selection
        if cacheIndex < DataCacheManager.shared.sortOptions.count, let selectedSort = DataCacheManager.shared.sortOptions[cacheIndex] {
            selectedSortOption = selectedSort
        }
        
        tableView.tableFooterView = UIView()
//        tableView.isScrollEnabled = false
        tableView.reloadData()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        self.view.addGestureRecognizer(tap)
        tap.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let requiredSize = tableView.contentSize.height + 50
        tableViewHeightConstraint.constant = min(view.frame.size.height/2, requiredSize)
        UIView.animate(withDuration: 0.5) {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }
        
        UIView.setAnimationCurve(.easeIn)
    }
    
    @objc
    func tapHandler(_ sender:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view! == self.view
    }
    
    //SortCellDelegate method
    func didTapSortOption(_ sortOption: SortOptions, row: Int) {
        
        if sortOption != .none{
            var selectedSortOptionFromCell = sortOptions[row - 1]
            selectedSortOptionFromCell["orderBy"].stringValue = sortOption.rawValue
            
            delegate?.selectedSortOption([selectedSortOptionFromCell], sortOptionType: sortOption)
            
        } else { //None option selected
            delegate?.selectedSortOption(nil, sortOptionType: sortOption)
        }
        
        //Update cached value
        if cacheIndex <= DataCacheManager.shared.sortOptions.count - 1 {
            DataCacheManager.shared.sortOptions[cacheIndex] = (row, sortOption)
        } else {
            DataCacheManager.shared.sortOptions.insert((row, sortOption), at: cacheIndex)
        }
        
        UIView.animate(withDuration: 0.1, animations: {
          self.view.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Table view datasource and delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortOptions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: SortNoneTableViewCell.identifier, for: indexPath) as! SortNoneTableViewCell
            cell.row = indexPath.row
            cell.delegate = self
            cell.lblTitle.text = NSLocalizedString("None", comment: "")
            if selectedSortOption.option == .none {
                cell.btnSortNone.isSelected = true
            } else {
                cell.btnSortNone.isSelected = false
            }
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SortTableViewCell.identifier , for: indexPath) as! SortTableViewCell
        cell.row = indexPath.row
        cell.lblTitle.text = sortOptions[indexPath.row - 1 < 0 ? 0 : indexPath.row - 1 ]["columnName"].stringValue
        if indexPath.row == selectedSortOption.row {
            if selectedSortOption.option == .ascending {
                cell.btnSortAscending.isSelected = true
                cell.btnSortDescending.isSelected = false
            } else if selectedSortOption.option == .descending {
                cell.btnSortAscending.isSelected = false
                cell.btnSortDescending.isSelected = true
            }
            
        } else {
            cell.btnSortAscending.isSelected = false
            cell.btnSortDescending.isSelected = false
        }
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
}

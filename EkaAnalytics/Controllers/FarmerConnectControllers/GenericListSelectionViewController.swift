//
//  GenericListSelectionViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 20/03/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

class GenericListSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    @IBOutlet weak var tableView:UITableView!
    
    var dataSource = [String]()
    
    var selectedItems = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - Tableview datasource and delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicFilterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "BasicFilterCell")
        let text = dataSource[indexPath.row]
        
        if selectedItems.contains(text){
            cell.imageView?.image = #imageLiteral(resourceName: "checked")
        } else {
            cell.imageView?.image = #imageLiteral(resourceName: "unchecked")
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = dataSource[indexPath.row]
        if selectedItems.contains(text), let index = selectedItems.firstIndex(of: text){
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(text)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

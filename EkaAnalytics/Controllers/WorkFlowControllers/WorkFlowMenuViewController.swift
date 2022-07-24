//
//  WorkFlowMenuViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 23/04/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol WFHamburgerMenuDelegate : AnyObject {
    func selectedMenu(handler:String,queryparameter:String?)
}

class WorkFlowMenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - IBOutlet
    @IBOutlet weak var Tableview: UITableView!
    @IBOutlet weak var lv_menuHeaderView: UIView!
    
    
    //MARK: - Varibale
    
    var bgView:UIView?
    var menuState:MenuState = .close
    var TableViewDatasource:[JSON] = []
    weak var delegate:WFHamburgerMenuDelegate?
    var backgroundcolor:UIColor?
    var menuDataSource:[JSON]?
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Background colour for the Menu screen
        self.view.backgroundColor = backgroundcolor!
        self.Tableview.backgroundColor = backgroundcolor!
        if TableViewDatasource.count > 0 {
            //Add Title for the menu
            if TableViewDatasource[0]["apiMenuData"][0]["label"] != nil {
                let HeaderLabel = UILabel(frame: CGRect(x: 15, y: 10, width: 200, height: 40))
                HeaderLabel.textColor = .white
                HeaderLabel.attributedText =  NSMutableAttributedString().bold("\(TableViewDatasource[0]["apiMenuData"][0]["label"])")
                lv_menuHeaderView.addSubview(HeaderLabel)
            }
            
            if TableViewDatasource[0]["apiMenuData"][0]["menu"] != nil {
                menuDataSource = TableViewDatasource[0]["apiMenuData"][0]["menu"].arrayValue
            }
        }else{
            menuDataSource = []
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if TableViewDatasource.count > 0 {
            //Add Title for the menu
            if TableViewDatasource[0]["apiMenuData"][0]["label"] != nil {
                let HeaderLabel = UILabel(frame: CGRect(x: 15, y: 10, width: 200, height: 40))
                HeaderLabel.textColor = .white
                HeaderLabel.attributedText =  NSMutableAttributedString().bold("\(TableViewDatasource[0]["apiMenuData"][0]["label"])")
                lv_menuHeaderView.addSubview(HeaderLabel)
            }
            
            if TableViewDatasource[0]["apiMenuData"][0]["menu"] != nil {
                menuDataSource = TableViewDatasource[0]["apiMenuData"][0]["menu"].arrayValue
            }else{
                menuDataSource = nil
            }
        }else{
            menuDataSource = []
        }
        
        self.Tableview.reloadData()
    }
    
    
    @objc func dismissHamburgerMenu(){
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window!
        let moveLeft = CGAffineTransform(translationX: -window.frame.width*1.35, y: 0)
        UIView.animate(withDuration: 0.35, animations: {
            self.view.transform = moveLeft
            self.bgView!.backgroundColor = UIColor.black.withAlphaComponent(0)
        }) { (completed) in
            self.view.removeFromSuperview()
            self.bgView?.removeFromSuperview()
            self.menuState = .close
        }
    }
    
    
    //Animation functions
    @objc func hamburgerClicked(_ sender: UIButton){
        
        guard let menuView = self.view else {return}
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window!
        
        let moveRight = CGAffineTransform(translationX: -window.frame.width*0.20, y: 0)
        let moveLeft = CGAffineTransform(translationX: -window.frame.width*1.35, y: 0)
        
        menuView.frame.size = UIScreen.main.bounds.size
        menuView.transform = moveLeft
        
        bgView = UIView()
        bgView!.backgroundColor = UIColor.black.withAlphaComponent(0)
        bgView!.frame.size = UIScreen.main.bounds.size
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissHamburgerMenu))
        bgView!.addGestureRecognizer(tap)
        
        window.addSubview(bgView!)
        window.addSubview(menuView)
        
        UIView.animate(withDuration: 0.35, animations: {
            menuView.transform = moveRight
            self.bgView!.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }, completion : { _ in
            self.menuState = .open
        })
    }
    
    
    //MARK: - Tableview Delegate and Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if menuDataSource != nil {
            return 1
        }else{
             return TableViewDatasource[0]["apiMenuData"][0]["menuItems"].count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let HeaderLabel = UILabel(frame: CGRect(x: 15, y: 10, width: 200, height: 40))
        HeaderLabel.textColor = .white
        HeaderLabel.attributedText =  NSMutableAttributedString().bold(TableViewDatasource[0]["apiMenuData"][0]["menuItems"][section]["text"].string ?? "")
        headerView.addSubview(HeaderLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if menuDataSource != nil {
            return 0
        }else{
            if TableViewDatasource[0]["apiMenuData"][0]["menuItems"][section]["text"].string ?? "" == "" {
                return 0
            }else{
                return 40
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if menuDataSource != nil {
            return menuDataSource!.count
        }else{
           return TableViewDatasource[0]["apiMenuData"][0]["menuItems"][section]["items"].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        
        if menuDataSource != nil {
            cell.textLabel?.text = "\(menuDataSource![indexPath.row]["text"])"
        }else{
            cell.textLabel?.text = "\(TableViewDatasource[0]["apiMenuData"][0]["menuItems"][indexPath.section]["items"][indexPath.row]["text"])"
        }
        
        cell.textLabel?.textColor = UIColor.white
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if menuDataSource != nil {
            delegate?.selectedMenu(handler: "\(menuDataSource![indexPath.row]["handler"])", queryparameter: nil)
        }else{
             let selectedMenuURL = "\(TableViewDatasource[0]["apiMenuData"][0]["menuItems"][indexPath.section]["items"][indexPath.row]["handler"])".components(separatedBy: "/")
            let selectedQueryParameter = TableViewDatasource[0]["apiMenuData"][0]["menuItems"][indexPath.section]["items"][indexPath.row]["queryParams"].string
            delegate?.selectedMenu(handler: "\(selectedMenuURL[selectedMenuURL.count-1])", queryparameter: selectedQueryParameter)
        }
    }
    
}

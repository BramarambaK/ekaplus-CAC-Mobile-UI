//
//  InsightsListViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 30/11/17.
//  Copyright © 2017 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol InsightListDelegate : AnyObject {
    func didSelectInsight(insightID:String)
}

class InsightsListViewController: GAITrackedViewController, HUDRenderer {
    
    @IBOutlet weak var tableView:UITableView?

//    @IBOutlet weak var appDetailHeader: UIView!
    
//    @IBOutlet weak var lblAppName: UILabel!
    
//    @IBOutlet weak var btnAppFavourite: UIButton!
    
    @IBOutlet weak var btnDone: UIButton!
    
//    @IBOutlet weak var btnLearnMore: UIButton!
    
    @IBOutlet weak var btnSearch: UIButton!
    
    var insights = [Insight](){
        didSet{
            tableView?.reloadData()
        }
    }
    
    weak var delegate:InsightListDelegate?
    
    var app:App!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var searchMode = false
    var filteredInsights = [Insight]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.insightList
        
        configureSearchBar()

        btnSearch.setImage(#imageLiteral(resourceName: "Search").withRenderingMode(.alwaysTemplate), for: .normal)
        btnSearch.tintColor = .black
        tableView?.tableFooterView = UIView()
        self.tableView?.contentInsetAdjustmentBehavior = .never
        
        if insights.count == 0{
            let label = UILabel()
            label.text  = NSLocalizedString("No Insights available.", comment: "")
            label.numberOfLines = 0
            label.textAlignment = .center
            tableView?.backgroundView = label
        } else {
            tableView?.backgroundView = nil
        }
        
        
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView?.contentOffset = CGPoint(x: 0, y: 55)
    }
    
    @IBAction func searchIconTapped(_ sender: UIButton) {
        tableView?.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func configureSearchBar(){
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("Search Insights", comment: "")
        searchBar.returnKeyType = .done
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
//        searchBar.sizeToFit()
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self.view, action:#selector(UIView.endEditing(_:)) )
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        searchBar.inputAccessoryView = doneToolbar
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        let border = UIView()
        border.frame = searchBar.frame
        border.frame.size.height = 1
        border.frame.origin.y = searchBar.frame.size.height - 1
        border.backgroundColor = .lightGray
        border.autoresizingMask = [.flexibleWidth]
        searchBar.addSubview(border)
    }
    
    @IBAction func dismiss(_ sender:UIButton?){
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension InsightsListViewController:UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchMode ? filteredInsights.count : insights.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: InsightTableViewCell.reuseIdentifier, for: indexPath) as! InsightTableViewCell
        
        var insight:Insight
        
        if searchMode {
            insight = filteredInsights[indexPath.row]
        } else {
            insight = insights[indexPath.row]
        }
        
        cell.btnFavourite.isHidden = true //Not in scope currently
        cell.lblInsightName.text = insight.name
//        print(insight.chartType)
        cell.insightImageView.image = UIImage(named: insight.chartType) ?? #imageLiteral(resourceName: "Default")
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Google Analytics event tracking
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "Insight", action: "View", label: "\(insights[indexPath.row].name)", value: nil).build() as? [AnyHashable : Any])
        }
        
        if searchMode {
            delegate?.didSelectInsight(insightID: filteredInsights[indexPath.row].id)
        } else {
            delegate?.didSelectInsight(insightID: insights[indexPath.row].id)
        }
        
        self.dismiss(nil)
    }
    
}

extension InsightsListViewController : UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchMode = true
        
        if searchText == "" {
            self.filteredInsights = self.insights
            self.tableView?.reloadData()
            return
        }
        

        self.filteredInsights = self.insights.filter({$0.name.lowercased().contains(searchText.lowercased())})
        
        self.tableView?.reloadData()
    }
    
}

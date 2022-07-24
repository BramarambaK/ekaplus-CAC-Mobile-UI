//
//  OfferDetailViewController.swift
//  EkaAnalytics
//
//  Created by Shreeram on 25/08/19.
//  Copyright © 2019 Eka Software Solutions. All rights reserved.
//

import UIKit

final class OfferDetailViewController: UIViewController,HUDRenderer {
    
    //MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:// Variable
    
    var publishedBid:PublishedBid! //Passed from previous vc
    
    lazy var dateFormatter:DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    lazy var apiController:OfferApiController = {
        return OfferApiController()
    }()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        let backbtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Back_blue").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(backButtonTapped(_:event:)))
        backbtn.tintColor = Utility.appThemeColor
        self.navigationItem.leftBarButtonItem = backbtn
        
        setTitle("\(publishedBid.id)", color: .black, backbuttonTint: Utility.appThemeColor)
        
        let btnOptions = UIBarButtonItem(image: #imageLiteral(resourceName: "meat_balls").withRenderingMode(.alwaysTemplate), style: UIBarButtonItem.Style.plain , target: self, action: #selector(optionsButtonTapped(_:event:)))
        btnOptions.tintColor = Utility.appThemeColor
        self.navigationItem.rightBarButtonItem = btnOptions
        
//        tableView.estimatedRowHeight  = 470
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.reloadData()
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
        
        let menuArray = [NSLocalizedString("Modify", comment: "Modify button"),NSLocalizedString("Delete", comment: "Delete button")]
        
        FTPopOverMenu.show(from: event, withMenuArray: menuArray, doneBlock: { (selectedIndex) in
            
            if selectedIndex == 0 {
                let offerListVC = UIStoryboard(name: "FarmerConnect", bundle: nil).instantiateViewController(withIdentifier: "NewOfferVC") as! NewOfferViewController
                offerListVC.publishedPrice = self.publishedBid
                self.navigationController?.pushViewController(offerListVC, animated: true)
            }else{
                self.showAlert(title: NSLocalizedString("Confirmation", comment: ""), message: NSLocalizedString("Do you want to delete the offer?", comment: ""), okButtonText: NSLocalizedString("Ok", comment: ""), cancelButtonText: NSLocalizedString("Cancel", comment: ""), presentOnRootVC: true, handler: { (accepted) in
                    if accepted{
                        self.showActivityIndicator()
                        self.apiController.deletePublishBids(BidId: self.publishedBid.id, { (response) in
                            self.hideActivityIndicator()
                            switch response{
                            case .success(_):
                                self.navigationController?.popViewController(animated: true)
                            case .failure(let error):
                                print(error)
                                self.showAlert(message: "Unable to delete the published price.")
                            case .failureJson(_):
                                break
                            }
                        })
                    }
                })
            }
        }) {
            
        }
        
    }
}

extension OfferDetailViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let OfferDetailcell = tableView.dequeueReusableCell(withIdentifier: "OfferDetailsCell" , for: indexPath) as! OfferDetailsTableViewCell
        OfferDetailcell.lblOfferType.text = publishedBid.offerType
        OfferDetailcell.lblOfferRefNumber.text = publishedBid.id
        OfferDetailcell.lblProduct.text = publishedBid.product
        OfferDetailcell.lblQuality.text = publishedBid.quality
        OfferDetailcell.lblCropYear.text = publishedBid.cropYear
        OfferDetailcell.lblLocation.text = publishedBid.location
        OfferDetailcell.lblPublishedPrice.text = "\(publishedBid.price) \(publishedBid.pricePerUnitQuantity)"
        OfferDetailcell.lblExpiryDate.text = ((publishedBid.expiryDate).components(separatedBy: "T"))[0]
        OfferDetailcell.lblIncoTerm.text = publishedBid.incoTerm
        OfferDetailcell.lblQuantity.text = "\(publishedBid.quantity) \(publishedBid.quantityUnit)"
        OfferDetailcell.lblDeliveryPeriod.text = "\(((publishedBid.deliveryFromDate).components(separatedBy: "T"))[0]) to \(((publishedBid.deliveryToDate).components(separatedBy: "T"))[0])"
        
        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) == "basic" {
            OfferDetailcell.lv_AdvanceHeight.constant = 0
        }else{
            OfferDetailcell.lv_AdvanceHeight.constant = 113
            OfferDetailcell.lblPaymentTerm.text = publishedBid.paymentTerms
            OfferDetailcell.lblPackingType.text = publishedBid.packingType
            OfferDetailcell.lblPackingSize.text = publishedBid.packingSize
        }
        
        OfferDetailcell.selectionStyle = .none
        return OfferDetailcell
        
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if UserDefaults.standard.string(forKey: UserDefaultsKeys.offerType.rawValue) != "basic"{
//            return 350
//        }else{
//            return 500
//        }
//    }
    
    
}


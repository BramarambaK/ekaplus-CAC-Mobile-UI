//
//  cardsViewComponentView.swift
//  EkaAnalytics
//
//  Created by Sreeram R on 15/03/21.
//  Copyright © 2021 Eka Software Solutions. All rights reserved.
//

import UIKit

final class cardsViewComponentView: UIView {
    
    //MARK: - Variable
    var ls_taskName:String?
    var app_metaData:JSON?
    var SelectedData:[JSON] = []
    var filterArray:[String] = []
    var larr_ScreenData:[String:[JSON]] = [:]
    var ls_SelectedCardTab:Int?
    var delegate:AdvancedCompositeDelegate?
    
    //MARK: - IBOutlet
    @IBOutlet weak var cardViewStack: UIStackView!
    @IBOutlet weak var tabCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    func loadNib() -> Self {
        let view = Bundle.main.loadNibNamed(String(describing: cardsViewComponentView.self), owner: self, options: nil)?.first as! cardsViewComponentView
        return view as! Self
    }
    
    func config() {
        
        if app_metaData!["flow"][ls_taskName!]["layout"]["getInitialData"] == true && larr_ScreenData.count == 0 {
            self.getScreenData()
        }else{
            if app_metaData!["flow"][ls_taskName!]["fields"].count > 0 {
                ConnectManager.shared.appendDynamicData(Meta: app_metaData!["flow"][ls_taskName!]["fields"][0].arrayValue, Data: SelectedData) { (ResultData) in
                    self.SelectedData = ResultData
                    self.renderCardUI()
                }
            }
        }
        
    }
    
    private func renderCardUI(){
        var ls_TabField:String = ""
        
        for i in 0..<app_metaData!["flow"][ls_taskName!]["fields"].count {
            for j in 0..<app_metaData!["flow"][ls_taskName!]["fields"][i].count{
                if app_metaData!["flow"][ls_taskName!]["fields"][i][j]["filterType"].string != nil && app_metaData!["flow"][ls_taskName!]["fields"][i][j]["filterType"].string == "tabs" {
                    ls_TabField = app_metaData!["flow"][ls_taskName!]["fields"][i][j]["filterBy"].string ?? ""
                    break
                }
            }
            
        }
        
        self.larr_ScreenData.removeAll()
        
        for each in SelectedData {
            if filterArray.contains(each[ls_TabField].stringValue) == false{
                filterArray.append(each[ls_TabField].stringValue)
            }
            var larrData:[JSON] = self.larr_ScreenData["\(each[ls_TabField].stringValue)"] ?? []
            larrData.append(each)
            self.larr_ScreenData[each[ls_TabField].stringValue] = larrData
        }
        
        if filterArray.count > 0 {
            self.filterArray = filterArray.sorted()
            self.updateComponent(data: larr_ScreenData[filterArray[ls_SelectedCardTab ?? 0]])
        }
    }
    
    private func updateComponent(data:[JSON]?){
        
        cardViewStack.removeAllArrangedSubviews()
        if data != nil {
            switch app_metaData!["flow"][ls_taskName!]["layout"]["theme"].stringValue {
                
            case "cargil-request-contract":
                
                for i in 0..<data!.count{
                    let CardView = cardTheme1View().loadNib()
                    CardView.config(data: data![i], fields: app_metaData!["flow"][ls_taskName!]["fields"].arrayValue)
                    cardViewStack.addArrangedSubview(CardView)
                    CardView.translatesAutoresizingMaskIntoConstraints = false
                }
                
            case "cargill-contract-request-spread cargill-contract-details-card multi-grade mobile":
                let CardView = cardTheme2View().loadNib()
                CardView.config(data: data!, fields: app_metaData!["flow"][ls_taskName!]["fields"].arrayValue)
                cardViewStack.addArrangedSubview(CardView)
                CardView.translatesAutoresizingMaskIntoConstraints = false
                
            default:
                for i in 0..<data!.count{
                    
                    let test = ConnectManager.shared.evaluateJavaExpression(expression: app_metaData!["flow"][ls_taskName!]["fields"][1][0]["valueExpression"].stringValue, data: data![0],"detailsArray")
                    
                    print(test)
                    
                    //Add the View to the Stack View
                    let CardView = cardComponentView().loadNib()
                    
                    
                    for j in 0..<app_metaData!["flow"][ls_taskName!]["fields"].count {
                        var cardHeaderValue:[String] = []
                        var cardHeaderLabel:[String] = []
                        for k in 0..<app_metaData!["flow"][ls_taskName!]["fields"][j].count {
                            cardHeaderLabel.append(app_metaData!["flow"][ls_taskName!]["fields"][j][k]["label"].string ?? "")
                            if let valueExpression = app_metaData!["flow"][ls_taskName!]["fields"][j][k]["valueExpression"].string {
                                switch app_metaData!["flow"][ls_taskName!]["fields"][j][k]["aggregateFunction"].stringValue {
                                    
                                case "sum":
                                    var li_sum:Double = 0
                                    for h in 0..<data!.count{
                                        li_sum += Double("\(ConnectManager.shared.evaluateJavaExpression(expression: valueExpression, data: data![h]))")!
                                    }
                                    
                                    var UnitExpression:String = ""
                                    
                                    if app_metaData!["flow"][ls_taskName!]["fields"][j][k]["suffix"] != nil {
                                        
                                        let suffixString:String = ConnectManager.shared.evaluateJavaExpression(expression:  app_metaData!["flow"][ls_taskName!]["fields"][j][k]["suffix"].stringValue, data: data![0]) as? String ?? ""
                                        
                                        UnitExpression = suffixString
                                    }
                                    
                                    if app_metaData!["flow"][ls_taskName!]["fields"][j][k]["roundOff"] != nil {
                                        li_sum = li_sum.rounded()
                                    }
                                    
                                    cardHeaderValue.append("\(String(format: "%.0f", li_sum)) \(UnitExpression)")
                                default:
                                    let result:String = ConnectManager.shared.evaluateJavaExpression(expression: valueExpression, data: data![i]) as? String ?? ""
                                    if result != "" {
                                        cardHeaderValue.append(result)
                                    }
                                }
                                
                                
                            }else{
                                if app_metaData!["flow"][ls_taskName!]["fields"][j][k]["type"] == "details" {
                                    switch app_metaData!["flow"][ls_taskName!]["fields"][j][k]["aggregateFunction"].stringValue {
                                    case "count":
                                        cardHeaderValue.append("\(data!.count)")
                                    case "sum":
                                        var li_sum:Double = 0
                                        for h in 0..<data!.count{
                                            if Double("\(data![h]["\(app_metaData!["flow"][ls_taskName!]["fields"][j][k]["key"])"])") != nil {
                                                li_sum += Double("\(data![h]["\(app_metaData!["flow"][ls_taskName!]["fields"][j][k]["key"])"])")!
                                            }
                                        }
                                        
                                        var UnitExpression:String = ""
                                        
                                        if app_metaData!["flow"][ls_taskName!]["fields"][j][k]["suffix"] != nil {
                                            
                                            let suffixString:String = ConnectManager.shared.evaluateJavaExpression(expression:  app_metaData!["flow"][ls_taskName!]["fields"][j][k]["suffix"].stringValue, data: data![0]) as? String ?? ""
                                            
                                            UnitExpression = suffixString
                                        }
                                        
                                        if app_metaData!["flow"][ls_taskName!]["fields"][j][k]["roundOff"] != nil {
                                            li_sum = li_sum.rounded()
                                        }
                                        
                                        cardHeaderValue.append("\(String(format: "%.0f", li_sum)) \(UnitExpression)")
                                    case "display":
                                        cardHeaderValue.append("\(data![0]["\(app_metaData!["flow"][ls_taskName!]["fields"][j][k]["key"].stringValue)"].stringValue)")
                                    default:
                                        break
                                    }
                                    
                                }
                                else if app_metaData!["flow"][ls_taskName!]["fields"][j][k]["type"] == "footer" {
                                    cardHeaderLabel.append(app_metaData!["flow"][ls_taskName!]["fields"][j][k]["label"].stringValue)
                                }
                                else{
                                    if app_metaData!["flow"][ls_taskName!]["fields"][j][k].count != 0 {
                                        if app_metaData!["flow"][ls_taskName!]["fields"][j][k]["style"]["display"].string == nil {
                                            cardHeaderValue.append(data![i]["\(app_metaData!["flow"][ls_taskName!]["fields"][j][k]["key"])"].string ?? "")
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                        switch j {
                        case 0:
                            for i in 0 ..< cardHeaderValue.count {
                                switch i {
                                case 0:
                                    CardView.Headinglabel01.text = cardHeaderValue[0]
                                case 1:
                                    CardView.Headinglabel02.text = cardHeaderValue[1]
                                case 2:
                                    CardView.Headinglabel03.text = cardHeaderValue[2]
                                default:
                                    break
                                }
                            }
                            
                            
                        case 1:
                            switch cardHeaderLabel.count {
                            case 1:
                                CardView.Headinglabel10.text = cardHeaderLabel[0]
                                CardView.Headinglabel12.text = ""
                                CardView.Headinglabel14.text = ""
                                CardView.Headinglabel16.text = ""
                            case 2:
                                CardView.Headinglabel10.text = cardHeaderLabel[0]
                                CardView.Headinglabel12.text = cardHeaderLabel[1]
                                CardView.Headinglabel14.text = ""
                                CardView.Headinglabel16.text = ""
                            case 3:
                                CardView.Headinglabel10.text = cardHeaderLabel[0]
                                CardView.Headinglabel12.text = cardHeaderLabel[1]
                                CardView.Headinglabel14.text = cardHeaderLabel[2]
                                CardView.Headinglabel16.text = ""
                            case 4:
                                CardView.Headinglabel10.text = cardHeaderLabel[0]
                                CardView.Headinglabel12.text = cardHeaderLabel[1]
                                CardView.Headinglabel14.text = cardHeaderLabel[2]
                                CardView.Headinglabel16.text = cardHeaderLabel[3]
                            default:
                                CardView.Headinglabel10.text = ""
                                CardView.Headinglabel12.text = ""
                                CardView.Headinglabel14.text = ""
                                CardView.Headinglabel16.text = ""
                            }
                            
                            switch cardHeaderValue.count {
                            case 1:
                                CardView.Headinglabel11.text = cardHeaderValue[0]
                                CardView.Headinglabel13.text = ""
                                CardView.Headinglabel15.text = ""
                                CardView.Headinglabel17.text = ""
                            case 2:
                                CardView.Headinglabel11.text = cardHeaderValue[0]
                                CardView.Headinglabel13.text = cardHeaderValue[1]
                                CardView.Headinglabel15.text = ""
                                CardView.Headinglabel17.text = ""
                            case 3:
                                CardView.Headinglabel11.text = cardHeaderValue[0]
                                CardView.Headinglabel13.text = cardHeaderValue[1]
                                CardView.Headinglabel15.text = cardHeaderValue[2]
                                CardView.Headinglabel17.text = ""
                            case 4:
                                CardView.Headinglabel11.text = cardHeaderValue[0]
                                CardView.Headinglabel13.text = cardHeaderValue[1]
                                CardView.Headinglabel15.text = cardHeaderValue[2]
                                CardView.Headinglabel17.text = cardHeaderValue[3]
                            default:
                                CardView.Headinglabel11.text = ""
                                CardView.Headinglabel13.text = ""
                                CardView.Headinglabel15.text = ""
                                CardView.Headinglabel17.text = ""
                            }
                            
                            
                        case 2:
                            CardView.Headinglabel21.text = cardHeaderLabel[0]
                        default :
                            break
                            
                        }
                    }
                    
                    cardViewStack.addArrangedSubview(CardView)
                    CardView.translatesAutoresizingMaskIntoConstraints = false
                    
                }
            }
            
            
            if data!.count == 0 {
                delegate?.hideUnhideComponenet(componentName: ls_taskName!, Status: false)
            }else{
                delegate?.hideUnhideComponenet(componentName: ls_taskName!, Status: true)
            }
        }
        else{
            delegate?.hideUnhideComponenet(componentName: ls_taskName!, Status: false)
        }
        
        delegate?.refreshIndividualView(TaskId: ls_taskName!)
        
    }
    
    private func getScreenData(){
        
        let dataBodyDictionary = ["appId":"\(app_metaData!["appId"].stringValue)","workFlowTask":"\(ls_taskName ?? "")","deviceType":"mobile","qP":["from":0,"size":app_metaData!["flow"][ls_taskName!]["rows"].stringValue]] as [String : Any]
        
        self.larr_ScreenData.removeAll()
        self.filterArray.removeAll()
        
        ConnectManager.shared.getScreenData(dataBodyDictionary: dataBodyDictionary) { [self] (dataResponse) in
            
            switch dataResponse {
            case .success(let dataJson):
                self.larr_ScreenData.removeAll()
                self.SelectedData = dataJson["data"].arrayValue
                
                let ls_filterBy = self.app_metaData!["flow"][self.ls_taskName!]["fields"][0]["filterBy"].string
                
                if ls_filterBy != nil {
                    for i in 0..<self.SelectedData.count {
                        var larrData:[JSON] = self.larr_ScreenData["\(self.SelectedData[i]["\(ls_filterBy!)"])"] ?? []
                        
                        larrData.append(self.SelectedData[i])
                        
                        self.larr_ScreenData["\(self.SelectedData[i]["\(ls_filterBy!)"])"] = larrData
                    }
                }
                
                if self.app_metaData!["flow"][ls_taskName!]["fields"].count > 0 {
                    ConnectManager.shared.appendDynamicData(Meta: app_metaData!["flow"][ls_taskName!]["fields"][0].arrayValue, Data: SelectedData) { (ResultData) in
                        self.SelectedData = ResultData
                        self.renderCardUI()
                    }
                }
                
            case .failure(let error):
                self.delegate?.hideUnhideComponenet(componentName: ls_taskName!, Status: false)
                self.SelectedData = []
                self.renderCardUI()
                print(error.description)
                
            case .failureJson(let errorJson):
                self.delegate?.hideUnhideComponenet(componentName: ls_taskName!, Status: false)
                self.SelectedData = []
                self.renderCardUI()
                print(errorJson)
            }
        }
    }
    
}

extension cardsViewComponentView:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if app_metaData?["flow"][ls_taskName!]["layout"]["hideTabs"] == true {
            self.collectionViewHeight.constant = 0
        }else if filterArray.count == 1 {
            self.collectionViewHeight.constant = 70
        }else if filterArray.count  % 3 == 0 {
            self.collectionViewHeight.constant = CGFloat((filterArray.count/3) * 40) + 50
        }else{
            self.collectionViewHeight.constant = CGFloat((filterArray.count/3) * 40) + 80
        }
        return filterArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        tabCollectionView.register(UINib.init(nibName: "TabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: TabCollectionViewCell.identifier)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionViewCell.identifier, for: indexPath) as! TabCollectionViewCell
        cell.tag = indexPath.row
        cell.config(ls_CardSelectedTab: ls_SelectedCardTab ?? 0)
        cell.lbl_TabValue.text = filterArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.ls_SelectedCardTab = indexPath.row
        delegate?.UpdateCardFilter(SelectedTab: indexPath.row)
        self.updateComponent(data: larr_ScreenData[filterArray[indexPath.row]])
        tabCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: tabCollectionView.frame.width/3.5, height:40)
    }
}


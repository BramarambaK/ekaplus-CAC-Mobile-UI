//
//  SlicerViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 04/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit

protocol SlicerDelegate : AnyObject {
    func selectedSlicerFilters(_ filters:[String:[String:Any]],_ dateFilters:[String:[String:Any]])
}

final class SlicerViewController: GAITrackedViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,CollapsibleCollectionHeaderDelegate, PickerViewSelectionDelegate , HUDRenderer{
    
    //MARK: - IBOutlet
    @IBOutlet weak var lblInsightTitle: UILabel!
    @IBOutlet weak var collectionView:UICollectionView!
    
    //MARK: - Variable
    weak var delegate:SlicerDelegate?
    private var slicerOptions = [ChartOptionsModel](){
        didSet{
            
            if slicerOptions.count == slicerIds.count{
                collectionView.reloadData()
            }
        }
    }
    
    var slicerIds:[String]!//Fed from Container VC
    var insight:Insight! //Fed from previous VC
    
    //    var sectionCollapsedLookUp = [Int:Bool]()
    var slicerFilters = [String:[String:Any]]() //To be passed to container vc on clicking apply
    var selectedRows = [ String: [Int] ]() { //[SlicerId:[selected rows indices]]
        didSet{
            for slicer in slicerOptions {
                
                let slicerId = slicer.dataViewID!
                
                if let selectedRowIndices = selectedRows[slicerId]{
                    //Prepare structure in the below format
                    //[slicerDataviewID: [array of selected values for this slicer]]
                    
                    let slicerValues = slicer.slicerOptions["values"].arrayValue.map{$0.stringValue}
                    
                    var dict:[String:Any] = ["selectedValues": selectedRowIndices.map{slicerValues[$0]}]
                    
                    if let dateFormat = slicer.slicerOptions["dateFormat"].string {
                        dict.updateValue(dateFormat, forKey: "dateFormat")
                    }
                    
                    if let customDateFormat = slicer.slicerOptions["customDateFormat"].string{
                        dict.updateValue(customDateFormat, forKey: "customDateFormat")
                    }
                    
                    slicerFilters[slicerId] = dict
                } else {
                    slicerFilters[slicerId] = [:] //To reset filters when remove all tapped
                }
            }
        }
    }
    
    var slicerDateFilters = [String:[String:Any]]()
    
    var selectedDateRows = [ String: [String] ]() { //[SlicerId:[selected rows indices]]
        didSet{
            for slicer in slicerOptions {
                
                let slicerId = slicer.dataViewID!
                
                if let selectedRowValue = selectedDateRows[slicerId]{
                    let dict:[String:Any] = ["selectedValues":selectedRowValue]
                    slicerDateFilters[slicerId] = dict
                } else {
                    slicerDateFilters[slicerId] = [:] //To reset filters when remove all tapped
                }
            }
        }
    }
    
    var affectedDataViewForSlicer = [String:[String]]() //[SlicerId:AffectedDataViewName]
    
    let dispatchGroup = DispatchGroup()
    
    //MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.slicer
        
        collectionView.register(UINib.init(nibName: "SlicerTitleHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleHeader")
        lblInsightTitle.text = insight.name
        
        
        self.showActivityIndicator()
        
        var errorMessage = ""
        
        slicerIds.forEach { (slicerId) in
            
            dispatchGroup.enter()
            DataViewApiConroller.shared.chainedApiRequestForDataView(slicerId) { (response) in
                
                switch response {
                case .success(let chartOptions):
                    
                    if chartOptions.type == .ComboSlicer || chartOptions.type == .CheckSlicer || chartOptions.type == .RadioSlicer || chartOptions.type == .TagSlicer || chartOptions.type == .DateRangeSlicer{
                        self.slicerOptions.append(chartOptions)
                    }
                case .failure(let error):
                    errorMessage = error.description
                    break
                case .failureJson(_):
                    break
                }
                
                self.dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        InsightListAPIController.shared.getDataViewIdAndNamesMapForInsight(insight.id, { (response) in
            switch response {
            case .success(let json):
                
                let actions = self.insight.actions!
                let dataViewIdAndNamesMap = json
                
                for action in actions {
                    let sourceDataViewId = action["sourceDataViewId"].stringValue
                    let targetDataViewId = action["targetDataViewId"].stringValue
                    if var array = self.affectedDataViewForSlicer[sourceDataViewId], array.count > 0{
                        array.append(dataViewIdAndNamesMap[targetDataViewId].stringValue)
                        self.affectedDataViewForSlicer[sourceDataViewId] = array
                    } else {
                        self.affectedDataViewForSlicer[sourceDataViewId] = [dataViewIdAndNamesMap[targetDataViewId].stringValue]
                    }
                }
                
                self.collectionView.reloadData()
                
            case .failure(let message):
                //                    print(message)
                errorMessage = message.description
            case .failureJson(_):
                break
            }
            self.dispatchGroup.leave()
        })
        
        
        dispatchGroup.notify(queue: .main) {
            
            self.hideActivityIndicator()
            
            guard errorMessage == "" else {
                self.showAlert(message: errorMessage)
                return
            }
            
            //If there are any cached values, load it
            if let cachedValues = DataCacheManager.shared.selectedSlicerFiltersCache {
                self.selectedRows = cachedValues
                self.collectionView.reloadData()
            } else {
                self.preparePreSelectedSlicerValuesIfAny()
            }
            
            //If there are any cached values, load it
            if let cachedValues = DataCacheManager.shared.selectedDateFilterCache {
                self.selectedDateRows = cachedValues
                self.collectionView.reloadData()
            }
            
        }
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func preparePreSelectedSlicerValuesIfAny(){
        //In case of slicer with preselected value, we need to provide the preselected value for slicer to display the selection. Need to give it in the required format selectedIndices.
        //
        //Get all the slicers which has a default value
        let preSelectedSlicers = insight.contents["dataviews"].arrayValue.filter{$0.dictionary?["default"] != nil} //.map{$0["dataViewId"].stringValue}
        
        var selectedIndices = [String:[Int]]()
        var selectedValue = [String:[String]]()
        
        for slicer in preSelectedSlicers{
            
            let slicerId = slicer["dataViewId"].stringValue
            
            //Get the default values for slicer
            let defaultValues = slicer["default"]["value"].arrayValue.map{$0.stringValue}
            
            switch slicer["chartType"] {
            case "DateRangeSlicer":
                selectedValue[slicerId] = defaultValues
            default:
                //get the indexes of default values for each slicer
                var valueIndices = [Int]()
                
                for val in defaultValues {
                    let slicerValues = slicerOptions.filter{$0.dataViewID == slicerId}.first!.slicerOptions["values"].arrayValue.map{$0.stringValue}
                    if let index = slicerValues.firstIndex(of: val){
                        let valueIndex = slicerValues.startIndex.distance(to:index)
                        valueIndices.append(valueIndex)
                    }
                }
                
                selectedIndices[slicerId] = valueIndices
            }
            
        }
        
        self.selectedRows = selectedIndices
        self.selectedDateRows = selectedValue
        collectionView.reloadData()
    }
    
    //comboslicer callback method- to present picker
    func toggleSection(_ header: SlicerDropDownHeader?, section: Int) {
        
        let slicerId = slicerIds[section]
        let slicer = slicerOptions.filter{$0.dataViewID == slicerId}.first!
        
        let comboSlicerOptions = slicer.slicerOptions["values"].arrayValue.map{$0.stringValue}
        
        let pickerVC = self.storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        pickerVC.modalPresentationStyle = .overCurrentContext
        pickerVC.dataSource = comboSlicerOptions
        pickerVC.filterIndex = section
        pickerVC.pickerTilte = NSLocalizedString("Slicer Options", comment: "Slicer Options description")
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    //Picker callback on value selection - for comboslicer
    func selectedPickerValue(_ value:String, filterIndex:Int){
        let section = filterIndex
        let slicerId = slicerIds[section]
        let slicer = slicerOptions.filter{$0.dataViewID == slicerId}.first!
        let comboSlicerOptions = slicer.slicerOptions["values"].arrayValue.map{$0.stringValue}
        
        if let selectedValueIndex = comboSlicerOptions.firstIndex(of: value){
            selectedRows[slicerId] = [selectedValueIndex]
        }
        collectionView.reloadSections(IndexSet.init(integer: section))
    }
    
    //MARK: - IBAction
    
    @IBAction func applyTapped(_ sender: UIButton) {
        delegate?.selectedSlicerFilters(slicerFilters, slicerDateFilters)
        DataCacheManager.shared.selectedSlicerFiltersCache = self.selectedRows
        DataCacheManager.shared.selectedDateFilterCache = self.selectedDateRows
        self.dismiss(nil)
    }
    
    @IBAction func dismiss(_ sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeAllTapped(_ sender: UIButton) {
        
        self.showAlert(title: NSLocalizedString("Confirmation", comment: "Confirmation"), message: NSLocalizedString("Do you want to Remove All slicer?", comment: "Confirmation message"), okButtonText: NSLocalizedString("Ok", comment: "accept"), cancelButtonText: NSLocalizedString("Cancel", comment: "cancel")) { (accepted) in
            if accepted{
                self.selectedRows = [ String : [Int] ]() //calling selectedRows.removeAll() wouldn't call didSet resulting in wrong calculation of slicer filters
                self.selectedDateRows = [ String: [String] ]()
                
                self.delegate?.selectedSlicerFilters(self.slicerFilters, self.slicerDateFilters)
                DataCacheManager.shared.selectedSlicerFiltersCache = self.selectedRows
                DataCacheManager.shared.selectedDateFilterCache = self.selectedDateRows
                self.dismiss(nil)
            }
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return slicerOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let slicerId = slicerIds[section]
        
        guard let slicer = slicerOptions.filter({$0.dataViewID == slicerId}).first else {
            return 0
        }
        
        if slicer.type == .ComboSlicer {
            return 0
        }
        
        if slicer.type == .TagSlicer || slicer.type == .DateRangeSlicer {
            return 1
        }
        
        return slicer.slicerOptions["values"].arrayValue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let slicerId = slicerIds[indexPath.section]
        let slicer = slicerOptions.filter{$0.dataViewID == slicerId}.first!
        
        let slicerValues = slicer.slicerOptions["values"].arrayValue.map{$0.stringValue}
        
        switch slicer.type {
        case .RadioSlicer:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RadioSlicerCollectionViewCell.identifier, for: indexPath) as! RadioSlicerCollectionViewCell
            cell.lblTitle.text = slicerValues[indexPath.item]
            cell.btnRadio.isSelected = (self.selectedRows[slicerId] != nil && self.selectedRows[slicerId]!.contains(indexPath.row))
            return cell
        case .CheckSlicer:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CheckSlicerCollectionViewCell.identifier, for: indexPath) as! CheckSlicerCollectionViewCell
            cell.lblTitle.text = slicerValues[indexPath.item]
            cell.btnCheckBox.isSelected = (self.selectedRows[slicerId] != nil && self.selectedRows[slicerId]!.contains(indexPath.row))
            return cell
        case .TagSlicer:
            let tagCell = collectionView.dequeueReusableCell(withReuseIdentifier: TagSlicerCollectionViewCell.identifier, for: indexPath) as! TagSlicerCollectionViewCell
            tagCell.delegate = self
            tagCell.slicerId = slicerId
            tagCell.larr_dropDownValue = slicer.slicerOptions["values"].rawValue as? [String]
            tagCell.selectedValue = self.selectedRows[slicerId] ?? []
            tagCell.config()
            return tagCell
        case .DateRangeSlicer:
            let dateRangecell = collectionView.dequeueReusableCell(withReuseIdentifier: DateRangeSlicerCollectionViewCell.identifier, for: indexPath) as! DateRangeSlicerCollectionViewCell
            dateRangecell.delegate = self
            dateRangecell.slicerId = slicerId
            dateRangecell.selectedValue = self.selectedDateRows[slicerId] ?? []
            dateRangecell.config()
            return dateRangecell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let slicerId = slicerIds[indexPath.section]
        let slicer = slicerOptions.filter{$0.dataViewID == slicerId}.first!
        
        switch slicer.type {
        case .RadioSlicer:
            selectedRows[slicerId] = [indexPath.row]
        case .ComboSlicer,.DateRangeSlicer:
            return
        default:
            //checkbox selection
            if let selectedRows = selectedRows[slicerId] {
                
                if selectedRows.contains(indexPath.row), let index = selectedRows.firstIndex(of: indexPath.row)  {
                    self.selectedRows[slicerId]!.remove(at: index)
                } else {
                    self.selectedRows[slicerId]!.append(indexPath.row)
                }
                
            } else {
                //Adding for the first time
                selectedRows[slicerId] = [indexPath.row]
            }
        }
        
        collectionView.reloadSections(IndexSet(integer:indexPath.section))
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let slicerId = slicerIds[section]
        let affectedDvNames = affectedDataViewForSlicer[slicerId] ?? [NSLocalizedString("No Dataviews affected", comment: "No Dataviews affected")]
        let text = affectedDvNames.joined(separator: ",")
        let height = text.heightWithConstrainedWidth(width: collectionView.frame.size.width, font: UIFont.systemFont(ofSize: 17))
        
        return CGSize(width: collectionView.frame.size.width , height:height + 50)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let slicerId = slicerIds[section]
        guard let slicer = slicerOptions.filter({$0.dataViewID == slicerId}).first else {
            return CGSize(width: collectionView.frame.width, height: 0)
        }
        
        if slicer.type == .ComboSlicer {
            return CGSize(width: collectionView.frame.width, height: 100)
        }
        return CGSize(width: collectionView.frame.width, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let slicerId = slicerIds[indexPath.section]
        let slicer = slicerOptions.filter{$0.dataViewID == slicerId}.first!
        let slicerValues = slicer.slicerOptions["values"].arrayValue.map{$0.stringValue}
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader :
            if slicer.type == .ComboSlicer {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! SlicerDropDownHeader
                
                header.lblSlicerTitle.text = slicer.name
                
                if let selectedIndex = selectedRows[slicerId]?.first{
                    let selectedValue = slicerValues[selectedIndex]
                    header.lblSelectedOption.text = selectedValue
                } else {
                    header.lblSelectedOption.text = NSLocalizedString("Select slicer value", comment: " ")
                }
                
                //To set the arrow orientation
                //                    if let collapsed = sectionCollapsedLookUp[indexPath.section] {
                //                         header.setCollapsed(collapsed)
                //                    }
                
                header.delegate = self
                header.section = indexPath.section
                return header
            } else {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TitleHeader", for: indexPath) as! SlicerTitleHeader
                header.lblTitle.text = slicer.name
                return header
            }
            
            
        case UICollectionView.elementKindSectionFooter:
            
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath)
            
            
            if let label = footer.viewWithTag(2) as? UILabel, let slicerId = slicer.dataViewID {
                let affectedDvNames = affectedDataViewForSlicer[slicerId] ?? [NSLocalizedString("No Dataviews affected", comment: "No Dataviews affected")]
                label.numberOfLines = 0
                label.text = affectedDvNames.joined(separator: ",")
            }
            
            
            return footer
            
        default:
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let slicerId = slicerIds[indexPath.section]
        let slicer = slicerOptions.filter{$0.dataViewID == slicerId}.first!
        
        switch slicer.type {
        case .TagSlicer:
            return CGSize(width: collectionView.frame.width, height: 44)
        case .DateRangeSlicer:
            return CGSize(width: collectionView.frame.width, height: 150)
        default:
            return CGSize(width: collectionView.frame.width, height: 50)
        }
    }
}

//MARK: -  Tag Slicer

extension SlicerViewController: TagSlicerDelegate{
    
    func tagPicker(sender: UITextField,delegate:MultiSelectDelegate,dropDownValue:[String],selectedValue:[Int]) {
        let multiSelectVc = MultiSelectViewController(nibName: "MultiSelectViewController", bundle: nil) as MultiSelectViewController
        multiSelectVc.dropdownValue = dropDownValue
        multiSelectVc.selectedValue = selectedValue
        multiSelectVc.delegate = delegate
        multiSelectVc.modalPresentationStyle = .overCurrentContext
        self.present(multiSelectVc, animated: true, completion: nil)
    }
    
    func updateTagSlicerValue(Id: String, selectedValue: [Int]) {
        self.selectedRows[Id] = []
        for each in selectedValue {
            self.selectedRows[Id]?.append(each)
        }
    }
    
}

//MARK: - Date Range Slicer
extension SlicerViewController: DateRangeSlicerDelegate {
    
    func dateRangePicker(sender: UITextField, delegate: DateRangeDelegate) {
        let dateRangeVc = DateRangeViewController(nibName: "DateRangeViewController", bundle: nil) as DateRangeViewController
        dateRangeVc.modalPresentationStyle = .overCurrentContext
        dateRangeVc.delegate = delegate
        dateRangeVc.activeTextField = sender
        self.present(dateRangeVc, animated: true, completion: nil)
    }
    
    func updateDateSlicerValue(Id: String, selectedValue: [String]) {
        self.selectedDateRows[Id] = []
        self.selectedDateRows[Id] = selectedValue
    }
    
}

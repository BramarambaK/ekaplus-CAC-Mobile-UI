//
//  AdvancedFilterViewController.swift
//  EkaAnalytics
//
//  Created by Nithin on 17/01/18.
//  Copyright © 2018 Eka Software Solutions. All rights reserved.
//

import UIKit
import Foundation

enum DateOperators:String,CustomStringRawRepresentable {
    case on = "On"
    case notOn = " Not on"
    case onOrAfter = "On or After"
    case before = "Before"
    case isBlank = "Is blank"
    case isNotBlank = "Is not blank"
    
    var actualValue:String{
        switch self {
        case .on:
            return "on"
        case .notOn:
            return "notOn"
        case .onOrAfter:
            return "onOrAfter"
        case .before:
            return "before"
        case .isBlank:
            return "isBlank"
        case .isNotBlank:
            return "isNotBlank"
        }
    }
    
    init(actualValue:String){
        switch actualValue {
        case "on","На","Na","On":
            self = .on
        case "notOn","Не на","Nie dalej"," Not on":
            self = .notOn
        case "onOrAfter","Вкл. Или после","Włącz lub po","On or After":
            self = .onOrAfter
        case "before","До","Przed","Before":
            self = .before
        case "isBlank","Не заполнено","Jest pusty","Is blank":
            self = .isBlank
        case "isNotBlank","Не пуст","Nie jest puste","Is not blank":
            self = .isNotBlank
        default:
            self = .on
        }
    }
    
    static let allValues = [on, notOn, onOrAfter, before, isBlank, isNotBlank].map{NSLocalizedString($0.rawValue, comment: "")}
}

enum NumberOperators:String,CustomStringRawRepresentable{
    case lessThan = "Less than"
    case greaterThanOrEqual = "Greater than or equal"
    case equal = "Equals"
    case notEqual = "Not equal"
    case isBlank = "Is blank"
    case isNotBlank = "Is not blank"
    case top = "Top"
    case bottom = "Bottom"
    
    var actualValue:String{
        switch self {
        case .lessThan:
            return "lessThan"
        case .greaterThanOrEqual:
            return "greaterThanOrEqual"
        case .equal:
            return "equal"
        case .notEqual:
            return "notEqual"
        case .isBlank:
            return "isBlank"
        case .isNotBlank:
            return "isNotBlank"
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        }
    }
    
    init(actualValue:String){
        switch actualValue{
        case "lessThan","Mniej niż","Меньше, чем","Less than":
            self = .lessThan
        case "greaterThanOrEqual","Większe lub równe","Больше или равно","Greater than or equal":
            self = .greaterThanOrEqual
        case "equal","Equals","Равно","Równa się":
            self = .equal
        case "notEqual","Nie równe","Не равный","Not equal":
            self = .notEqual
        case "isBlank","Не заполнено","Jest pusty","Is blank":
            self = .isBlank
        case "isNotBlank","Не пуст","Nie jest puste","Is not blank":
            self = .isNotBlank
        case "top","Top","верхний":
            self = .top
        case "bottom","Dolny","Дно","Bottom":
            self = .bottom
        default:
            self = .lessThan
        }
    }
    
    static let allValues = [lessThan, greaterThanOrEqual, equal, notEqual,isBlank, isNotBlank, top, bottom].map{NSLocalizedString($0.rawValue, comment: "")}
    
    static let farmerConnectValues = [lessThan, greaterThanOrEqual, equal, notEqual,isBlank, isNotBlank].map{NSLocalizedString($0.rawValue, comment: "")}
}

enum StringOperators:String,CustomStringRawRepresentable{
    
    case contains = "Contains"
    case notContains = "Does not contain"
    case startsWith = "Starts with"
    case notStartsWith = "Does not start with"
    case equal = "Equals"
    case notEqual = "Not equal"
    case isBlank = "Is blank"
    case isNotBlank = "Is not blank"
    case isIn = "in"
    
    
    var actualValue:String{
        switch  self {
        case .contains:
            return "contains"
        case .notContains:
            return "notContains"
        case .startsWith:
            return "startsWith"
        case .notStartsWith:
            return "notStartsWith"
        case .equal:
            return "equal"
        case .isBlank:
            return "isBlank"
        case .isNotBlank:
            return "isNotBlank"
        case .isIn:
            return "in"
        case .notEqual:
            return "notEqual"
        }
    }
    
    init(actualValue:String){
        switch actualValue{
        case "contains","Содержит","Zawiera","Contains":
            self = .contains
        case "notContains","Does not contain","Nie zawiera","Не содержит":
            self = .notContains
        case "startsWith","Начинается с","Zaczynać z","Starts with":
            self = .startsWith
        case "notStartsWith","Does not start with","Не начинается с","Nie zaczyna się od":
            self = .notStartsWith
        case "equal","Equals","Równa się","Равно":
            self = .equal
        case "isBlank","Не заполнено","Jest pusty","Is blank":
            self = .isBlank
        case "isNotBlank","Не пуст","Nie jest puste","Is not blank":
            self = .isNotBlank
        case "in","в","w":
            self = .isIn
        case "notEqual","Не равный","Nie równe","Not equal":
            self = .notEqual
            
        default:
            self = .contains
        }
    }
    
//    static let allValues = [contains, notContains, startsWith, notStartsWith, equal, isBlank,isNotBlank, isIn, notEqual].map{NSLocalizedString($0.rawValue, comment: "")}
    
    static let allValues = [contains, notContains, startsWith, notStartsWith, equal, isBlank,isNotBlank, notEqual].map{NSLocalizedString($0.rawValue, comment: "")}
}

enum ColumnFormatType:Int{
    case strings
    case numbers
    case date
    
    init?(rawValue:Int){
        switch rawValue{
        case -1,2,5: self = .numbers
        case 1: self = .strings
        case 3: self = .date
        default : return nil
        }
    }
}

protocol CustomStringRawRepresentable{
    var rawValue:String{get}
    var actualValue:String{get}
}

class AdvancedFilterViewController: GAITrackedViewController,PickerViewSelectionDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var filterTwoStackView: UIStackView!
    
    @IBOutlet weak var btnFilter1Operator: UIButton!
    
    @IBOutlet weak var btnFilter1Cancel: UIButton!
    
    @IBOutlet weak var txfFilter1: UITextField!
    
    @IBOutlet weak var btnAnd: UIButton!
    
    @IBOutlet weak var btnOr: UIButton!
    
    @IBOutlet weak var btnFilter2Operator: UIButton!
    
    @IBOutlet weak var btnFilter2Clear: UIButton!
    
    @IBOutlet weak var txfFilter2: UITextField!
    
    
    @IBOutlet weak var btnCalendar1: UIButton!
    
    @IBOutlet weak var btnCalendar2: UIButton!
    
    @IBOutlet weak var filter1TextFieldBorderView: UIView!
    
    @IBOutlet weak var filter2TextFieldBorderView: UIView!
    
    var columnFormatType:ColumnFormatType!
    
    var filterSourceData:JSON!//Filter source data
    
    var selectedFilter : JSON!//If any temporary cache exists, it'll be passed from previous vs to this. So in viewDidLoad, we check if any cache is passed and load it. We use the same property to capture any changes user has made and send it back in getSelectedFilters method.
    
    var selectedLogicalOperator = "and"
    
    var isFarmerConnectFilter = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.screenName = ScreenNames.advancedFilters
        
        let columnType = filterSourceData["columnType"].intValue
        
        if let type = ColumnFormatType(rawValue: columnType) {
            if filterSourceData["configZone"] == "values" {
                self.columnFormatType = ColumnFormatType(rawValue: 2)
            }else{
            self.columnFormatType = type
            }
        } else {
            fatalError("Unexpected columnType found in \(self)")
        }
        
        setUp()
        
        if selectedFilter != nil {
            loadViewWithCachedFilters(selectedFilter)
        } else {
            loadInitialViewState()
        }
        
    }
    
    deinit {
        print("deinit of \(String(describing:self))")
    }
    
    
    func setUp(){
        txfFilter1.addDoneToolBarButton()
        txfFilter2.addDoneToolBarButton()
        
        switch columnFormatType {
        case .date?:
            txfFilter1.placeholder = "dd/mm/yyyy"
            txfFilter2.placeholder = "dd/mm/yyyy"
            filter1TextFieldBorderView.layer.borderColor = UIColor.white.cgColor
            filter2TextFieldBorderView.layer.borderColor = UIColor.white.cgColor
            
            txfFilter1.inputView = datePickerWithTag(0)
            txfFilter2.inputView = datePickerWithTag(1)
            
        case .numbers?:
            txfFilter1.keyboardType = .numbersAndPunctuation
            txfFilter2.keyboardType = .numbersAndPunctuation
            txfFilter1.delegate = self
            txfFilter2.delegate = self
            btnCalendar1.isHidden = true
            btnCalendar2.isHidden = true
            
        case .strings?:
            btnCalendar1.isHidden = true
            btnCalendar2.isHidden = true
            
        default: break
        }
        loadInitialViewState()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if case .numbers = self.columnFormatType! {
//            let currentText = textField.text ?? ""
            //            let prospectiveText = (currentText as! NSString).replacingCharacters(in: range, with: string)
            
            if string == "" {
                return true
            }
            
            let allowedCharacterset = CharacterSet(charactersIn: "0123456789.,-")
            return string.rangeOfCharacter(from: allowedCharacterset) != nil
        }
        return true
    }
    
    func loadInitialViewState(){
        filterTwoStackView.isHidden = true
        btnFilter1Cancel.isHidden = true
        btnFilter2Clear.isHidden = true
        btnFilter1Operator.setTitle(NSLocalizedString("Select operator", comment: ""), for: .normal)
        btnFilter1Operator.setTitleColor(Utility.appThemeColor, for: .normal)
        txfFilter1.text = ""
        
        btnFilter2Operator.setTitle(NSLocalizedString("Select operator", comment: ""), for: .normal)
        btnFilter2Operator.setTitleColor(Utility.appThemeColor, for: .normal)
        txfFilter2.text = ""
        
        txfFilter1.isEnabled = false
        txfFilter2.isEnabled = false
        
        btnCalendar1.isEnabled = false
        btnCalendar2.isEnabled = false
        
        selectLogicalAnd()
    }
    
    func loadViewStateWithFirstFilterValueSelected(){
        btnCalendar1.isEnabled = true
        txfFilter1.isEnabled = true
        
        btnFilter1Cancel.isHidden = false
        filterTwoStackView.isHidden = false
    }
    
    func loadViewStateWithSecondFilterValueSelected(){
        btnCalendar2.isEnabled = true
        txfFilter2.isEnabled = true
        btnFilter2Clear.isHidden = false
    }
    
    func loadViewWithCachedFilters(_ filter:JSON){
        
        if let firstFilter = filter["firstFilter"].dictionary{
            
            let operatorValue = firstFilter["operator"]!.stringValue
            
            var operatorString:CustomStringRawRepresentable!
            
            switch columnFormatType{
            case .date?:
                operatorString = DateOperators(actualValue: operatorValue)
                
            case .numbers?:
                operatorString = NumberOperators(actualValue: operatorValue)
                
            case .strings?:
                operatorString = StringOperators(actualValue: operatorValue)
                
            default:
                fatalError("Unexpected columnType found in \(self)")
                
            }
            
            btnFilter1Operator.setTitle( NSLocalizedString(operatorString.rawValue, comment: ""), for: .normal)
            btnFilter1Operator.setTitleColor(.black, for: .normal)
            txfFilter1.text = firstFilter["value"]?.arrayValue.first?.stringValue
            loadViewStateWithFirstFilterValueSelected()
            
        }
        
        if let secondFilter = filter["secondFilter"].dictionary{
            let logicalOperator = filter["logicalOperator"].stringValue
            
            if logicalOperator == "and"{
                selectLogicalAnd()
            } else {
                selectLogicalOr()
            }
            
            let operatorValue = secondFilter["operator"]!.stringValue
            
            var operatorString:CustomStringRawRepresentable!
            
            switch columnFormatType{
            case .date?:
                operatorString = DateOperators(actualValue: operatorValue)
                
            case .numbers?:
                operatorString = NumberOperators(actualValue: operatorValue)
                
            case .strings?:
                operatorString = StringOperators(actualValue: operatorValue)
                
            default:
                fatalError("Unexpected columnType found in \(self)")
                
            }
            
            btnFilter2Operator.setTitle( NSLocalizedString(operatorString.rawValue, comment: ""), for: .normal)
            btnFilter2Operator.setTitleColor(.black, for: .normal)
            txfFilter2.text = secondFilter["value"]?.arrayValue.first?.stringValue
            loadViewStateWithSecondFilterValueSelected()
        }
    }
    
    func datePickerWithTag(_ tag:Int)->UIDatePicker{
        let datePicker: UIDatePicker = UIDatePicker()
        datePicker.tag = tag
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return datePicker
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        
        // Set date format
        dateFormatter.dateFormat = "yyyy-MM-dd'T'00:00:00"
        
        // Apply date format
        let selectedDate: String = dateFormatter.string(from: sender.date)
        
        if sender.tag == 0 {
            txfFilter1.text = selectedDate
            loadViewStateWithFirstFilterValueSelected()
        } else {
            txfFilter2.text = selectedDate
            loadViewStateWithSecondFilterValueSelected()
        }
        
    }
    
    @IBAction func selectOperatorTapped(_ sender: UIButton) {
        
        let filterIndex = sender.tag
        self.view.endEditing(true)
        
        let pickerVC = self.storyboard?.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        pickerVC.modalPresentationStyle = .overCurrentContext
        
        switch columnFormatType{
        case .date?:
            pickerVC.dataSource = DateOperators.allValues
            
        case .numbers?:
            if isFarmerConnectFilter {
                pickerVC.dataSource = NumberOperators.farmerConnectValues
            } else {
                pickerVC.dataSource = NumberOperators.allValues
            }
            
        case .strings?:
            pickerVC.dataSource = StringOperators.allValues
            
        default:
            fatalError("Unexpected columnType found in \(self)")
            
        }
        
        pickerVC.filterIndex = filterIndex
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    //Pickerview delegate
    func selectedPickerValue(_ value: String, filterIndex:Int) {
        if filterIndex == 0{
            btnFilter1Operator.setTitle(value, for: .normal)
            loadViewStateWithFirstFilterValueSelected()
            
            if columnFormatType == .date{
                let oper = DateOperators(actualValue: value)
                if oper == .isBlank || oper == .isNotBlank {
                    txfFilter1.isEnabled = false
                    btnCalendar1.isEnabled = false
                    txfFilter1.text = ""
                } else {
                    txfFilter1.isEnabled = true
                    btnCalendar1.isEnabled = true
                }
            } else if columnFormatType == .strings{
                let oper = StringOperators(actualValue: value)
                if oper == .isBlank || oper == .isNotBlank {
                    txfFilter1.isEnabled = false
                    btnCalendar1.isEnabled = false
                    txfFilter1.text = ""
                } else {
                    txfFilter1.isEnabled = true
                    btnCalendar1.isEnabled = true
                }
            }
            
        } else {
            btnFilter2Operator.setTitle(value, for: .normal)
            loadViewStateWithSecondFilterValueSelected()
            
            if columnFormatType == .date{
                let oper = DateOperators(actualValue: value)
                if oper == .isBlank || oper == .isNotBlank {
                    txfFilter2.isEnabled = false
                    btnCalendar2.isEnabled = false
                    txfFilter2.text = ""
                } else {
                    txfFilter2.isEnabled = true
                    btnCalendar2.isEnabled = true
                }
            } else if columnFormatType == .strings{
                let oper = StringOperators(actualValue: value)
                if oper == .isBlank || oper == .isNotBlank {
                    txfFilter2.isEnabled = false
                    btnCalendar2.isEnabled = false
                    txfFilter2.text = ""
                } else {
                    txfFilter2.isEnabled = true
                    btnCalendar2.isEnabled = true
                }
            }
        }
    }
    
    
    @IBAction func clearOperatorTapped(_ sender: UIButton) {
        sender.isHidden = true
        self.view.endEditing(true)
        
        if sender.tag == 0 {
            
            //If first filter is cleared, we clear all filters because, it doesn't make sense to have a second filter with out the first one.
            clearAllFilters()
            
        } else {
            btnFilter2Operator.setTitle(NSLocalizedString("Select operator", comment: ""), for: .normal)
            btnFilter2Operator.setTitleColor(Utility.appThemeColor, for: .normal)
            txfFilter2.text = ""
            txfFilter2.isEnabled = false
            btnCalendar2.isEnabled = false
        }
    }
    
    @IBAction func logicalOperatorsTapped(_ sender: UIButton) {
        if sender.tag == 0 { //And
            selectLogicalAnd()
        } else {//Or
            selectLogicalOr()
        }
        
    }
    
    @IBAction func calendarButtonTapped(_ sender: UIButton) {
        if sender.tag == 0 {
            txfFilter1.becomeFirstResponder()
        } else {
            txfFilter2.becomeFirstResponder()
        }
    }
    
    func selectLogicalAnd(){
        btnAnd.backgroundColor = Utility.appThemeColor
        btnAnd.setTitleColor(.white, for: .normal)
        btnAnd.layer.borderColor = Utility.appThemeColor.cgColor
        
        btnOr.backgroundColor = .white
        btnOr.setTitleColor(.black, for: .normal)
        btnOr.layer.borderColor = UIColor.black.cgColor
        selectedLogicalOperator = "and"
    }
    
    func selectLogicalOr(){
        btnAnd.backgroundColor = .white
        btnAnd.setTitleColor(.black, for: .normal)
        btnAnd.layer.borderColor = UIColor.black.cgColor
        
        btnOr.backgroundColor = Utility.appThemeColor
        btnOr.setTitleColor(.white, for: .normal)
        btnOr.layer.borderColor = Utility.appThemeColor.cgColor
        selectedLogicalOperator = "or"
    }
    
    //This method is called when first advanced operater is cleared or when user tapped on reset button-- (From SubPreDefinedFilterVC)
    func clearAllFilters(){
        selectedFilter = nil
        setUp()
        loadInitialViewState()
    }
    
    func getSelectedFilters()->JSON?{
        
        if (txfFilter1.text != nil && txfFilter1.text != "") || (btnFilter1Operator.title(for: .normal) == "Is blank" || btnFilter1Operator.title(for: .normal) == "Is not blank") {
            
            //initial 3 fields in selected filter should contain the same fields as of filterSourceData
            selectedFilter = filterSourceData
            selectedFilter["type"] = "advanced"
            
            selectedFilter["firstFilter"] = filterSourceData
            if columnFormatType == .date{
                selectedFilter["firstFilter"]["dateFormat"].stringValue = "yyyy-MM-dd'T'HH:mm:ss"
            }
            
            var operatorString:CustomStringRawRepresentable!
            
            switch columnFormatType{
            case .date?:
                operatorString = DateOperators.init(actualValue: btnFilter1Operator.title(for: .normal)!)
                
                selectedFilter["firstFilter"]["operator"].string = operatorString.actualValue
                selectedFilter["firstFilter"]["value"].arrayObject = [txfFilter1.text!]
                
            case .numbers?:
                
                operatorString = NumberOperators(actualValue:btnFilter1Operator.title(for: .normal)!)
                
                selectedFilter["firstFilter"]["operator"].string = operatorString.actualValue
                selectedFilter["firstFilter"]["value"].arrayObject = [Double(txfFilter1.text!)!]
                
            case .strings?:
                operatorString = StringOperators(actualValue: btnFilter1Operator.title(for: .normal)!)
                
                selectedFilter["firstFilter"]["operator"].string = operatorString.actualValue
                selectedFilter["firstFilter"]["value"].arrayObject = [txfFilter1.text!]
                
            default:
                fatalError("Unexpected columnType found in \(self)")
                
            }
            
            
            
            
            
            if (txfFilter2.text != nil && txfFilter2.text != "") || (btnFilter2Operator.title(for: .normal) == "Is blank" || btnFilter2Operator.title(for: .normal) == "Is not blank") {
                selectedFilter["logicalOperator"].stringValue = selectedLogicalOperator
                
                selectedFilter["secondFilter"] = filterSourceData
                if columnFormatType == .date{
                    selectedFilter["secondFilter"]["dateFormat"].stringValue = "yyyy-MM-dd'T'HH:mm:ss"
                }
                
                var operatorString:CustomStringRawRepresentable!
                
                switch columnFormatType{
                case .date?:
                    operatorString = DateOperators.init(actualValue: btnFilter2Operator.title(for: .normal)!)
                    
                    selectedFilter["secondFilter"]["operator"].string = operatorString.actualValue
                    selectedFilter["secondFilter"]["value"].arrayObject = [txfFilter2.text!]
                    
                case .numbers?:
                    operatorString = NumberOperators(actualValue: btnFilter2Operator.title(for: .normal)!)
                    
                    selectedFilter["secondFilter"]["operator"].string = operatorString.actualValue
                    selectedFilter["secondFilter"]["value"].arrayObject = [Double(txfFilter2.text!)!]
                    
                case .strings?:
                    operatorString = StringOperators(actualValue: btnFilter2Operator.title(for: .normal)!)
                    
                    selectedFilter["secondFilter"]["operator"].string = operatorString.actualValue
                    selectedFilter["secondFilter"]["value"].arrayObject = [txfFilter2.text!]
                    
                default:
                    fatalError("Unexpected columnType found in \(self)")
                    
                }
                
                
                
            }
            
        }
        
        return selectedFilter
    }
    
}

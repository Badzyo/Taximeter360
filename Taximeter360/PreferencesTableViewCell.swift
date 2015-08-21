//
//  PreferencesTableViewCell.swift
//  Taximeter360
//
//  Created by Denys Badzo on 01.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import UIKit


class PreferencesTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    var delegate: PreferencesTableViewController?
    var priceType: billingTypes?
    enum distCellType: Int {
        case DistUnit
        case DistPrepaidUnits
        case DistPrepayPrice
        case DistUnitPrice
        case DistIdlePrice
        case DistIdleThershold
        case DistWaitingPrice
        static var count: Int { return self.DistWaitingPrice.rawValue + 1}
    }
    
    enum timeCellType: Int {
        case TimePrepaid
        case TimePrepayPrice
        case TimeMinutePrice
        static var count: Int { return self.TimeMinutePrice.rawValue + 1}
    }
        

    var control: UIControl?
    var rownumber = 0
    let controlBgColor = UIColor(white: 0.4, alpha: 1)
    let controlTintColor = UIColor.orangeColor()
    let textfieldBgColor = UIColor(white: 0.9, alpha: 1)

    let textFrame = CGRect(x: 0, y: 0, width: 125, height: 30)
    let segmentFrame = CGRect(x: 0, y: 0, width: 125, height: 30)
    let stepperFrame = CGRect(x: 29, y: 0, width: 96, height: 29)
    
    @IBOutlet weak var controlView: UIView?
    @IBOutlet weak var content: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func prepayedUnitsStepperChanged() {
        let stepper = control! as! UIStepper
        delegate!.currentTariff.distPrepaid = stepper.value
        self.textLabel?.text = "Prepaid \(delegate!.currentTariff.distPrepaid) \(delegate!.currentTariff.unitShortText)"
    }
    
    func idleThresholdStepperChanged() {
        let stepper = control! as! UIStepper
        delegate!.currentTariff.distIdleThreshold = stepper.value
        self.textLabel?.text = "Idle speed threshold: \(stepper.value)"
    }
    
    func prepayedTimeStepperChanged() {
        let stepper = control! as! UIStepper
        delegate!.currentTariff.timePrepaid = stepper.value
        self.textLabel?.text = "Prepaid \(stepper.value) minutes"
    }
    
    func distanceUnitChanged() {
        let segmented = control! as! UISegmentedControl
        if let unit = distanceUnits(rawValue: segmented.selectedSegmentIndex) {
            delegate!.currentTariff.distanceUnit = unit
        }
        let cell = delegate!.preferencesTableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        cell?.textLabel?.text = "Prepaid \(delegate!.currentTariff.distPrepaid) \(delegate!.currentTariff.unitShortText)"
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

        if priceType == .Distance {
            
            switch distCellType(rawValue: rownumber)! {
            case .DistPrepayPrice:
                delegate!.currentTariff.distBasicPrice = NSString(string: textField.text).doubleValue
            case .DistUnitPrice:
                delegate!.currentTariff.distPriceForUnit = NSString(string: textField.text).doubleValue
            case .DistIdlePrice:
                delegate!.currentTariff.distIdlePrice = NSString(string: textField.text).doubleValue
            case .DistWaitingPrice:
                delegate!.currentTariff.distWaitingPrice = NSString(string: textField.text).doubleValue
            default:
                ()
            }
        } else {
            
            switch timeCellType(rawValue: rownumber)! {
            case .TimePrepayPrice:
                delegate!.currentTariff.timeBasicPrice = NSString(string: textField.text).doubleValue
            case .TimeMinutePrice:
                delegate!.currentTariff.timePriceForMinute = NSString(string: textField.text).doubleValue
            default:
                ()
            }
            
        }
    }
    
    
    func setContentOfType(billType: billingTypes, withID rownum: Int, delegate: PreferencesTableViewController) {
        self.delegate = delegate
        rownumber = rownum
        var text: String
        priceType = billType
        switch billType {
        case .Distance:
            let cellType = distCellType(rawValue: rownum)
            switch cellType! {
            case .DistUnit:
                text = "Unit"
                var control = UISegmentedControl(items: ["Km","Mi"])
                if delegate.currentTariff.distanceUnit == .Kilometers {
                    control.selectedSegmentIndex = 0
                } else {
                    control.selectedSegmentIndex = 1
                }
                control.selected = true
                control.addTarget(self, action: "distanceUnitChanged", forControlEvents: .ValueChanged)
                self.control = control
                self.control!.frame = segmentFrame
                self.control!.backgroundColor = controlBgColor
                self.control!.tintColor = controlTintColor
                self.controlView!.addSubview(self.control!)
            case .DistPrepaidUnits:
                text = "Prepaid \(delegate.currentTariff.distPrepaid) \(delegate.currentTariff.unitShortText)"
                let stepper = UIStepper(frame: stepperFrame)
                stepper.value = delegate.currentTariff.distPrepaid
                control = stepper
                control!.backgroundColor = controlBgColor
                control!.tintColor = controlTintColor
                control!.addTarget(self, action: "prepayedUnitsStepperChanged", forControlEvents: .ValueChanged)
                self.controlView!.addSubview(control!)
            case .DistPrepayPrice:
                text = "Basic price"
                let textField = createTextField()
                textField.text! = "\(delegate.currentTariff.distBasicPrice)"
                control = textField
                self.controlView!.addSubview(control!)
            case .DistUnitPrice:
                text = "Unit price"
                let textField = createTextField()
                textField.text! = "\(delegate.currentTariff.distPriceForUnit)"
                control = textField
                self.controlView!.addSubview(control!)
            case .DistIdlePrice:
                text = "Minute of idle"
                let textField = createTextField()
                textField.text! = "\(delegate.currentTariff.distIdlePrice)"
                control = textField
                self.controlView!.addSubview(control!)
            case .DistIdleThershold:
                text = "Idle speed threshold: \(delegate.currentTariff.distIdleThreshold)"
                let stepper = UIStepper(frame: stepperFrame)
                stepper.value = delegate.currentTariff.distIdleThreshold
                control = stepper
                control!.backgroundColor = controlBgColor
                control!.tintColor = controlTintColor
                control!.addTarget(self, action: "idleThresholdStepperChanged", forControlEvents: .ValueChanged)
                self.controlView!.addSubview(control!)
            case .DistWaitingPrice:
                text = "Minute of waiting"
                let textField = createTextField()
                textField.text! = "\(delegate.currentTariff.distWaitingPrice)"
                control = textField
                self.controlView!.addSubview(control!)
            default:
                text = "unknown"
                let textField = createTextField()
                control = textField
                self.controlView!.addSubview(control!)
            }
            self.textLabel!.text = text
        case .Time:
            let cellType = timeCellType(rawValue: rownum)
            switch cellType! {
            case .TimePrepaid:
                text = "Prepaid \(delegate.currentTariff.timePrepaid) minutes"
                let stepper = UIStepper(frame: stepperFrame)
                stepper.value = delegate.currentTariff.timePrepaid
                control = stepper
                control!.backgroundColor = controlBgColor
                control!.tintColor = controlTintColor
                control!.addTarget(self, action: "prepayedTimeStepperChanged", forControlEvents: .ValueChanged)
                self.controlView!.addSubview(control!)
            case .TimePrepayPrice:
                text = "Basic price"
                let textField = createTextField()
                textField.text! = "\(delegate.currentTariff.timeBasicPrice)"
                control = textField
                self.controlView!.addSubview(control!)
            case .TimeMinutePrice:
                text = "Price per minute"
                let textField = createTextField()
                textField.text! = "\(delegate.currentTariff.timePriceForMinute)"
                control = textField
                self.controlView!.addSubview(control!)
            default:
                text = "unknown"
                control = UITextField(frame: textFrame)
                self.controlView!.addSubview(control!)
            }
            self.textLabel!.text = text
        default:
            ()
        }

    }
    
    func createTextField() -> UITextField {
        
        let textField = UITextField(frame: textFrame)
        textField.delegate = self
        
        textField.borderStyle = .RoundedRect
        
        textField.keyboardType = .DecimalPad
        
        textField.backgroundColor = textfieldBgColor
        
        textField.tintColor = controlTintColor
        
        return textField
    }

}

//
//  PreferencesTableViewController.swift
//  Taximeter360
//
//  Created by Denys Badzo on 01.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import UIKit

class PreferencesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var preferencesTableView: UITableView!
    @IBOutlet weak var billingTypeSelector: UISegmentedControl!
    let prefsCellIdentifier: String = "prefsCell"
    var currentTariff = Tariff()

    @IBAction func billingTypeChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            currentTariff.billingType = .Distance
        case 1:
            currentTariff.billingType = .Time
        default:
            ()
        }
        
        var rows = preferencesTableView.numberOfRowsInSection(0)

        preferencesTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }
    
    @IBAction func saveButtonPressed(sender: UIBarButtonItem) {
        var errorsCount: Int = 0
        var currentTariff = Tariff()
        currentTariff.billingType = billingTypes(rawValue: billingTypeSelector.selectedSegmentIndex)!
        let maxindex = preferencesTableView.numberOfRowsInSection(0) - 1
        for row in 0...maxindex {
            let currentRow = preferencesTableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? PreferencesTableViewCell
            
            switch currentRow!.priceType! {
            case .Distance:
                ()
                switch PreferencesTableViewCell.distCellType(rawValue: row)! {
                case .DistUnit:
                    var control = currentRow!.control as! UISegmentedControl
                    var selected = control.selectedSegmentIndex
                    if let unit = distanceUnits(rawValue: control.selectedSegmentIndex) {
                        currentTariff.distanceUnit = unit
                    } else {
                        errorsCount++
                        showAlertWhithTitle("Incorrect input", withMessage: "Choose a distance measuring unit, please!")
                    }
                case .DistPrepaidUnits:
                    var control = currentRow!.control as! UIStepper
                    currentTariff.distPrepaid = control.value
                case .DistPrepayPrice:
                    var control = currentRow!.control as! UITextField
                    currentTariff.distBasicPrice =  NSString(string: control.text).doubleValue
                    control.text = "\(currentTariff.distBasicPrice)"
                case .DistUnitPrice:
                    var control = currentRow!.control as! UITextField
                    currentTariff.distPriceForUnit =  NSString(string: control.text).doubleValue
                    control.text = "\(currentTariff.distPriceForUnit)"
                case .DistIdleThershold:
                    var control = currentRow!.control as! UIStepper
                    currentTariff.distIdleThreshold = control.value
                case .DistIdlePrice:
                    var control = currentRow!.control as! UITextField
                    currentTariff.distIdlePrice =  NSString(string: control.text).doubleValue
                    control.text = "\(currentTariff.distIdlePrice)"
                case .DistWaitingPrice:
                    var control = currentRow!.control as! UITextField
                    currentTariff.distWaitingPrice =  NSString(string: control.text).doubleValue
                    control.text = "\(currentTariff.distWaitingPrice)"
                default:
                    ()
                }
            case .Time:
                switch PreferencesTableViewCell.timeCellType(rawValue: row)! {
                case .TimePrepaid:
                    var control = currentRow!.control as! UIStepper
                    currentTariff.timePrepaid = control.value
                case .TimePrepayPrice:
                    var control = currentRow!.control as! UITextField
                    currentTariff.timeBasicPrice =  NSString(string: control.text).doubleValue
                    control.text = "\(currentTariff.timeBasicPrice)"
                case .TimeMinutePrice:
                    var control = currentRow!.control as! UITextField
                    currentTariff.timePriceForMinute =  NSString(string: control.text).doubleValue
                    control.text = "\(currentTariff.timePriceForMinute)"
                default:
                    ()
                }
            default:
                ()
            }
        }
        

        if errorsCount == 0 {
            self.currentTariff = currentTariff
            let defaults = NSUserDefaults.standardUserDefaults()
            if let archivedTariffs = defaults.objectForKey("Tariffs") as? NSData {
                var tariffs = NSKeyedUnarchiver.unarchiveObjectWithData(archivedTariffs) as? [Tariff]
                tariffs![0] = self.currentTariff
                let archivedData = NSKeyedArchiver.archivedDataWithRootObject(tariffs!)
                defaults.setObject(archivedData, forKey: "Tariffs")
            } else {
                var tariffs = Array<Tariff>()
                tariffs.append(self.currentTariff)
                let archivedData = NSKeyedArchiver.archivedDataWithRootObject(tariffs)
                defaults.setObject(archivedData, forKey: "Tariffs")
            }

//            printPriceFor(currentTariff)
        } else {
            println("\(errorsCount) errors occured")
        }
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.preferencesTableView.endEditing(true)
    }
    
    func printPriceFor(price: Tariff) {
        println("Billing type: \(price.billing)")
        if price.billing == 0 {
            println("Unit: \(price.unit)")
            println("Prepaid: \(price.distPrepaid)")
            println("Basic price: \(price.distBasicPrice)")
            println("Unit price: \(price.distPriceForUnit)")
            println("Idle threshold: \(price.distIdleThreshold)")
            println("Idle minute price: \(price.distIdlePrice)")
            println("Waiting minute price: \(price.distWaitingPrice)")
        } else {
            println("Prepaid: \(price.timePrepaid)")
            println("Basic price: \(price.timeBasicPrice)")
            println("Minute price: \(price.timePriceForMinute)")
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tarif = PassageManager.sharedManager().getActialTariff() {
            currentTariff = tarif
        }
        
        billingTypeSelector.selectedSegmentIndex = currentTariff.billingType.rawValue

    }
    
//// SHOW CUSTOM ALERT
    func showAlertWhithTitle(title: String, withMessage: String) {
        var alert = UIAlertController(title: title, message: withMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil ))
        alert.view.backgroundColor = UIColor.clearColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }

//// START TableView protocol
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentTariff.billingType == .Distance {
            return PreferencesTableViewCell.distCellType.count
        } else {
            return PreferencesTableViewCell.timeCellType.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.preferencesTableView.dequeueReusableCellWithIdentifier(prefsCellIdentifier) as! PreferencesTableViewCell
        for view in cell.controlView!.subviews {
            view.removeFromSuperview()
        }
        cell.setContentOfType(currentTariff.billingType, withID: indexPath.row, delegate: self)
        return cell
    }
//// END TableView protocol

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



class preferencesTableView: UITableView {
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.endEditing(true)
    }
    
}

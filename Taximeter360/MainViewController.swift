//
//  MainViewController.swift
//  Taximeter360
//
//  Created by Denys Badzo on 01.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import UIKit
import Foundation

class MainViewController: UIViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var waitingTimeLabel: UILabel!
    @IBOutlet weak var idleTimeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var tariffsBuilderButton: UIBarButtonItem!
    
    @IBAction func clearTariffs() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("Tariffs")
    }
    @IBAction func startStopButtonPressed(sender: UIButton) {
        
        if sender.titleLabel!.text == "Start" {
            clearScreenValues()
            PassageManager()
            let start = PassageManager.sharedManager().startNewPassage()
            if start.type().code == 0 {
                PassageManager.sharedManager().addObserver(self, forKeyPath: "speed", options: .New, context: nil)
                PassageManager.sharedManager().currentPassage.addObserver(self, forKeyPath: "distance", options: .New, context: nil)
                PassageManager.sharedManager().currentPassage.addObserver(self, forKeyPath: "time", options: .New, context: nil)
                PassageManager.sharedManager().currentPassage.addObserver(self, forKeyPath: "idleTime", options: .New, context: nil)
                PassageManager.sharedManager().currentPassage.addObserver(self, forKeyPath: "waitingTime", options: .New, context: nil)
                PassageManager.sharedManager().currentPassage.addObserver(self, forKeyPath: "price", options: .New, context: nil)
                PassageManager.sharedManager().addObserver(self, forKeyPath: "locationManagerIsInitialising", options: .New, context: nil)
                tariffsBuilderButton.enabled = false
                pauseButton.enabled = true
                activityIndicator.startAnimating()
                sender.setTitle("Stop", forState: .Normal)
                
            } else {
                showAlertWhithTitle(start.type().title, withMessage: start.type().details)
            }
        } else {
            PassageManager.sharedManager().removeObserver(self, forKeyPath: "speed")
            PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "distance")
            PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "time")
            PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "price")
//            PassageManager.sharedManager().removeObserver(self, forKeyPath: "locationManagerIsInitialising")
            PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "idleTime")
            PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "waitingTime")
            tariffsBuilderButton.enabled = true
            let stop = PassageManager.sharedManager().stopPassage()
            if stop.type().code == 0 {
                pauseButton.enabled = false
                sender.setTitle("Start", forState: .Normal)
            } else {
                showAlertWhithTitle(stop.type().title, withMessage: stop.type().details)
            }
        }

    }
 
    @IBAction func pauseButtonPressed(sender: UIBarButtonItem) {
        if sender.title! == "Wait" {
            PassageManager.sharedManager().waitingChanger(true)
            pauseButton.title! = "Drive!"
        } else {
            PassageManager.sharedManager().waitingChanger(false)
            pauseButton.title! = "Wait"
        }
    }
    
    func clearScreenValues() {
        distanceLabel.text = "0"
        waitingTimeLabel.text = "00:00:00"
        priceLabel.text = "0.00"
        idleTimeLabel.text = "00:00:00"
        timeLabel.text = "00:00:00"
        speedLabel.text = "0"
    }
    
    
    //// SHOW CUSTOM ALERT
    func showAlertWhithTitle(title: String, withMessage: String) {
        var alert = UIAlertController(title: title, message: withMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil ))
        alert.view.backgroundColor = UIColor.clearColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func printPriceFor(price: Tariff) {
        println("Billing type: \(price.billingType)")
        if price.billingType == .Distance {
            println("Unit: \(price.distanceUnit)")
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
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        
        if let theObject = object as? Passage {
            switch keyPath {
            case "distance":
                distanceLabel.text! = "\(formatDouble(theObject.distance)) \(theObject.tariff.unitShortText)"
            case "price":
                priceLabel.text! = "\(formatDouble(theObject.price))"
            case "idleTime":
                idleTimeLabel.text! = "\(theObject.idleTimeFormatted)"
            case "waitingTime":
                waitingTimeLabel.text! = "\(theObject.waitTimeFormatted)"
            case "time":
                  timeLabel.text! = "\(theObject.timeFormatted)"
            default:
                ()
            }

        } else {
            if let theObject = object as? PassageManager {
                switch keyPath {
                case "speed":
                    speedLabel.text! = "\(formatDouble(theObject.speed)) \(theObject.currentPassage.tariff.unitShortText)ph"
                case "locationManagerIsInitialising":
                    if theObject.locationManagerIsInitialising {
                        activityIndicator.startAnimating()
                    } else {
                        activityIndicator.stopAnimating()
                        PassageManager.sharedManager().removeObserver(self, forKeyPath: "locationManagerIsInitialising")
                        
                    }
                default:
                    ()
                }
            }
        }
            
    }
    

    func formatDouble(number: Double) -> String {
        return DoubleFormatter.sharedInstance.stringFromNumber(number)!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        pauseButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    deinit {
        PassageManager.sharedManager().removeObserver(self, forKeyPath: "speed")
        PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "distance")
        PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "time")
        PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "price")
        PassageManager.sharedManager().removeObserver(self, forKeyPath: "locationManagerIsInitialising")
        PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "idleTime")
        PassageManager.sharedManager().currentPassage.removeObserver(self, forKeyPath: "waitingTime")
        
        
    }
    

}

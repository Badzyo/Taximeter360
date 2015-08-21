//
//  PassageManager.swift
//  Taximeter360
//
//  Created by Denys Badzo on 02.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation
import CoreLocation

class PassageManager: NSObject, CLLocationManagerDelegate {
    
    static var manager: PassageManager!
    var passageTimer: NSTimer!
    var locationManager: CLLocationManager!
    var currentPassage: Passage!
    var tariffExists: Bool = false
    var isWaiting: Bool = false
    var isIdle: Bool = false
    var lastDistance: Double = 0.0
    var tarificatedDistance: Double = 0.0
    dynamic var speed: Double = 0.0
    var route: Route!
    dynamic var locationManagerIsInitialising: Bool = false
    
    func getActialTariff() -> Tariff? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let archivedTariffs = defaults.objectForKey("Tariffs") as? NSData {
            var tariffs = NSKeyedUnarchiver.unarchiveObjectWithData(archivedTariffs) as? [Tariff]
            return(tariffs!.first!)
        } else {
            return nil
        }
    }
    
// STARTING NEW PASSAGE
    func startNewPassage() -> (PassageManagerError) {
        var error = PassageManagerError.OK
        
        // TRY TO GET TARIFF FROM Defaults
        if let tariff = getActialTariff() {
            self.tariffExists = true
            // INIT NEW PASSAGE 
            currentPassage = Passage(currentTariff: tariff)
            
            if currentPassage.tariff.billingType == .Distance {
                // INIT LOCATION MANAGER
                route = nil
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManagerIsInitialising = true
                route = Route()
                locationManager.startUpdatingLocation()
                
                // START TIMER
                
            } else {
                
            }
            
            passageTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "didUpdatePassageTimer", userInfo: nil, repeats: true)
            
        } else {
            
            self.tariffExists = false
            error = PassageManagerError.TariffNotExists
        }
        return error
    }
    
    func stopPassage() -> (PassageManagerError) {
        var error = PassageManagerError.OK
        locationManager.stopUpdatingLocation()
        passageTimer.invalidate()
        route = nil
        currentPassage = nil
        isWaiting = false
        isIdle = false
        tarificatedDistance = 0.0
        lastDistance = 0.0
        speed = 0.0
        locationManager = nil
        
        return error
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManagerIsInitialising = false
        var userLocation: CLLocation = locations.last! as! CLLocation
        route.waypoints.append(userLocation)
        let index = route.waypoints.count - 1
        if index > 2 {

            currentPassage.distance = currentPassage.distance + route.waypoints[index].distanceFromLocation(route.waypoints[index-1]) * currentPassage.tariff.distanceMultiplyer / 1000
            
        }
       
    }
    
    func waitingChanger(state: Bool) {
        isWaiting = state
    }
    
    
    func didUpdatePassageTimer() {
        currentPassage.time += 1
       
        if currentPassage.tariff.billingType == .Distance {
            updateSpeed()
            if isIdle {
                currentPassage.idleTime += 1
            }
            if isWaiting {
                currentPassage.waitingTime += 1
            }
        }
        updatePrice()
       
    }
    
    func updatePrice() {
        var tempPrice: Double = 0.0
        switch currentPassage.tariff.billingType {
        case .Distance:
            tempPrice = currentPassage.tariff.distBasicPrice
            
            if !isIdle && !isWaiting {
                tarificatedDistance += currentPassage.distance - lastDistance
            }
            lastDistance = currentPassage.distance

            var distance = tarificatedDistance - currentPassage.tariff.distPrepaid
            if distance > 0 {
                tempPrice += currentPassage.tariff.distPriceForUnit * distance
            }
            tempPrice += currentPassage.tariff.distWaitingPrice * currentPassage.waitingTime / 60
            tempPrice += currentPassage.tariff.distIdlePrice * currentPassage.idleTime / 60
           
        case .Time:
            tempPrice = currentPassage.tariff.timeBasicPrice
            var interval = currentPassage.time - currentPassage.tariff.timePrepaid
            if interval > 0 {
                tempPrice += currentPassage.tariff.timePriceForMinute * interval / 60
            }
        }
        currentPassage.price = tempPrice
    }
    
    func updateSpeed() {
        if let speed = route.waypoints.last?.speed {
            self.speed =  speed * currentPassage.tariff.distanceMultiplyer * 3.6
            
            if speed < currentPassage.tariff.distIdleThreshold && !isWaiting && currentPassage.time > 20 {
                isIdle = true
            } else {
                isIdle = false
            }
        }
    }
    
    class func sharedManager() -> PassageManager {
        self.manager = (self.manager ?? PassageManager())
        return self.manager
    }


    
    
}
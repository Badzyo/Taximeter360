//
//  Passage.swift
//  Taximeter360
//
//  Created by Denys Badzo on 02.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation

extension Passage {
    
    private func stringFromTimeInterval(interval: NSTimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var timeFormatted: String {
        return stringFromTimeInterval(time)
    }
    
    var waitTimeFormatted: String {
        return stringFromTimeInterval(waitingTime)
    }
    
    var idleTimeFormatted: String {
        return stringFromTimeInterval(idleTime)
    }
}

class Passage: NSObject, NSCoding {

    dynamic var price: Double
    dynamic var distance: Double
    dynamic var time: Double
    dynamic var waitingTime: Double
    dynamic var idleTime: Double
    dynamic var tariff: Tariff
//    var route: Route
    
    
    init (currentTariff: Tariff) {
        self.price = 0.0
        self.distance = 0.0
        self.time = 0.0
        self.waitingTime = 0.0
        self.idleTime = 0.0
        self.tariff = currentTariff
//        self.route = Route()
    }

    
    
    func startNewPassageWith(tariff: Tariff) -> Passage {
        let passage = Passage(currentTariff: tariff)
        
        return passage
    }
    
    required init(coder decoder: NSCoder) {
        self.price = decoder.decodeObjectForKey("price") as! Double
        self.distance = decoder.decodeObjectForKey("distance") as! Double
        self.time = decoder.decodeObjectForKey("time") as! Double
        self.waitingTime = decoder.decodeObjectForKey("waitingTime") as! Double
        self.idleTime = decoder.decodeObjectForKey("idleTime") as! Double
        self.tariff = decoder.decodeObjectForKey("tariff") as! Tariff
//        self.route = decoder.decodeObjectForKey("route") as! Route
        
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(price, forKey: "price")
        encoder.encodeObject(distance, forKey: "distance")
        encoder.encodeObject(time, forKey: "time")
        encoder.encodeObject(waitingTime, forKey: "waitingTime")
        encoder.encodeObject(idleTime, forKey: "idleTime")
        encoder.encodeObject(tariff, forKey: "tariff")
//        encoder.encodeObject(route, forKey: "route")
        
    }
    
    
}

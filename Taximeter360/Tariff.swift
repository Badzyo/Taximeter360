//
//  Tariff.swift
//  Taximeter360
//
//  Created by Denys Badzo on 27.07.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import UIKit
import Foundation

enum billingTypes: Int {
    case Distance
    case Time
}

enum distanceUnits: Int {
    case Kilometers
    case Miles
}

extension Tariff {
    var billingType: billingTypes {
        get {
            return billingTypes(rawValue: billing)!
            
        }
        
        set {
            billing = newValue.rawValue
        }
    }
    
    var distanceUnit: distanceUnits {
        get {
            return distanceUnits(rawValue: unit)!
        }
        
        set {
            unit = newValue.rawValue
        }
    }
    
    var distanceMultiplyer: Double {
        return (unit == 0) ? 1.0 : 0.6213
    }
    
    var unitShortText: String {
        return (unit == 0) ? "km" : "mi"
    }
    

}

class Tariff: NSObject, NSCoding {
    
    // Billing type
    var billing: Int = 0
    
    // Distance tariff
    var unit: Int = 0
    var distPrepaid: Double = 0.0
    var distBasicPrice: Double = 0.0
    var distPriceForUnit: Double = 0.0
    var distWaitingPrice: Double = 0.0
    var distIdlePrice: Double = 0.0
    var distIdleThreshold: Double = 0.0
    
    // Time tariff
    var timePrepaid: Double = 0.0
    var timeBasicPrice: Double = 0.0
    var timePriceForMinute: Double = 0.0
    
    override init() {
        self.billing = 0
        self.unit = 0
        self.distPrepaid = 0.0
        self.distBasicPrice = 0.0
        self.distPriceForUnit = 0.0
        self.distWaitingPrice = 0.0
        self.distIdlePrice = 0.0
        self.distIdleThreshold = 0.0
        self.timePrepaid = 0.0
        self.timeBasicPrice = 0.0
        self.timePriceForMinute = 0.0
    }

//// BEGIN NSCoding protocol ////
    required init(coder decoder: NSCoder) {
                super.init()
        self.billing = decoder.decodeObjectForKey("billing") as! Int
        self.unit = decoder.decodeObjectForKey("unit") as! Int
        self.distPrepaid = decoder.decodeObjectForKey("distPrepaid") as! Double
        self.distBasicPrice = decoder.decodeObjectForKey("distBasicPrice") as! Double
        self.distPriceForUnit = decoder.decodeObjectForKey("distPriceForUnit") as! Double
        self.distWaitingPrice = decoder.decodeObjectForKey("distWaitingPrice") as! Double
        self.distIdlePrice = decoder.decodeObjectForKey("distIdlePrice") as! Double
        self.distIdleThreshold = decoder.decodeObjectForKey("distIdleThreshold") as! Double
        self.timePrepaid = decoder.decodeObjectForKey("timePrepaid") as! Double
        self.timeBasicPrice = decoder.decodeObjectForKey("timeBasicPrice") as! Double
        self.timePriceForMinute = decoder.decodeObjectForKey("timePriceForMinute") as! Double
        

    }
    
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(billing, forKey: "billing")
        encoder.encodeObject(unit, forKey: "unit")
        encoder.encodeObject(distPrepaid, forKey: "distPrepaid")
        encoder.encodeObject(distBasicPrice, forKey: "distBasicPrice")
        encoder.encodeObject(distPriceForUnit, forKey: "distPriceForUnit")
        encoder.encodeObject(distWaitingPrice, forKey: "distWaitingPrice")
        encoder.encodeObject(distIdlePrice, forKey: "distIdlePrice")
        encoder.encodeObject(distIdleThreshold, forKey: "distIdleThreshold")
        encoder.encodeObject(timePrepaid, forKey: "timePrepaid")
        encoder.encodeObject(timeBasicPrice, forKey: "timeBasicPrice")
        encoder.encodeObject(timePriceForMinute, forKey: "timePriceForMinute")
        
    }
//// END NSCoding protocol ////
    
    
}

//
//  Route.swift
//  Taximeter360
//
//  Created by Denys Badzo on 02.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation
import CoreLocation

class Route: NSObject, NSCoding {
    
    var waypoints: [CLLocation] = []
    var distance: Double {
        var calculatedDistance: Double = 0.0
        if waypoints.count > 1 {
            for index in 1...waypoints.count {
                calculatedDistance += waypoints[index].distanceFromLocation(waypoints[index - 1])
            }
            
        }
        return calculatedDistance
    }
    
    override init () {
        
    }
    
    required init(coder decoder: NSCoder) {
        self.waypoints = decoder.decodeObjectForKey("route") as! [CLLocation]

        
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(waypoints, forKey: "route")

        
    }
    
}
//
//  NuberFormatter.swift
//  Taximeter360
//
//  Created by Denys Badzo on 02.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation

class DoubleFormatter: NSNumberFormatter {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        self.locale = NSLocale.currentLocale()
        self.maximumFractionDigits = 2
        self.roundingMode = .RoundHalfUp
        self.groupingSeparator = " "
        self.numberStyle = .DecimalStyle
    }
    

    static let sharedInstance = DoubleFormatter()
}

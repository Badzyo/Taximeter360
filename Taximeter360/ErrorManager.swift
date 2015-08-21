//
//  ErrorManager.swift
//  Taximeter360
//
//  Created by Denys Badzo on 02.08.15.
//  Copyright (c) 2015 Denys Badzo. All rights reserved.
//

import Foundation
import UIKit

class ErrorManager: NSObject {

}

enum PassageManagerError {
    case TariffNotExists
    case CanNotGetUserLocation
    case ErrorWritingData
    case ErrorReadingDataFromArchive
    case OK
    
    func type() -> ErrorType {
        switch self {
        case .TariffNotExists:
            return ErrorType(code: 1, title: "Tariff Not Exists", details: "Choose a tariff, please")
        case .CanNotGetUserLocation:
            return ErrorType(code: 2, title: "Can't get location", details: "Error occured while getting your location")
        case .ErrorWritingData:
            return ErrorType(code: 3, title: "Write error", details: "Writing data error")
        case .ErrorReadingDataFromArchive:
            return ErrorType(code: 4, title: "Load error", details: "An error occured while loading data from archive")
        case .OK:
            return ErrorType(code: 0, title: "OK", details: "Everything seems OK")
        }
    }
}

struct ErrorType {
    var code: Int
    var title: String
    var details: String
}
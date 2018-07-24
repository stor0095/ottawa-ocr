//
//  BusStop.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-08-26.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

struct BusStop {
    var StopDescription: String
    var StopNo: String
    
    init(dictionary: [String:Any]) {
        StopDescription =  dictionary["StopDescription"] as! String
        StopNo = dictionary["StopNo"] as! String
    }
}

struct BusStopDetails {
    let RouteHeading: String?
    let RouteDirection: String?
    let RouteNo: Int?
    let TripStartTime: [JSON]?
    let TripStartTime_SECONDARY: [String:JSON]?
    
    init(busDetails: [String : JSON]) {
        RouteHeading = busDetails["RouteHeading"]?.stringValue ?? ""
        RouteDirection = busDetails["Direction"]?.stringValue ?? ""
        RouteNo = busDetails["RouteNo"]?.intValue ?? 0
        TripStartTime = busDetails["Trips"]?.arrayValue ?? []
        TripStartTime_SECONDARY =  busDetails["Trips"]?.dictionary ?? [:]
    }
}


//
//  HandleOCStopTimes.swift
//  OCVR
//
//  Created by Geemakun Storey on 2018-07-11.
//  Copyright © 2018 geemakunstorey@storeyofgee.com. All rights reserved.
//

import Foundation
import SwiftyJSON

class HandleStopTimes: NSObject {
    
    public static func handleAdjustedScheduleTime(tripStartTime: [JSON], secondary_tripStartTime: [String:JSON]) -> String {
        var timeString = String()
        var stopDictionary = [String: Int]()
        var dateArray = [Date]()
        
        if !tripStartTime.isEmpty {
            for y in tripStartTime {
                let startTime = y["TripStartTime"].stringValue
                let adjustedTime = y["AdjustedScheduleTime"].intValue
                stopDictionary[startTime] = adjustedTime
            }
        }
        
        if !secondary_tripStartTime.isEmpty {
            for y in secondary_tripStartTime {
                for i in y.value {
                    let startTime = i.1["TripStartTime"].stringValue
                    let adjustedTime = i.1["AdjustedScheduleTime"].intValue
                    stopDictionary[startTime] = adjustedTime
                }
            }
        } else if tripStartTime.isEmpty && secondary_tripStartTime.isEmpty {
            timeString = "No buses scheduled for the next 4 hours"
        }
        
        
        // NOTE: AdjustedScheduleTime is the minutes for when the bus comes from the moment you made the API call
        guard let startApiCstall = OCServerAPI.sharedInstance.get_API_CALL_START_TIME() else {return ""}
        let calendar = Calendar.current
        
        // Setup date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        
        for (_,value) in stopDictionary {
            let apiCallStartDate = calendar.date(byAdding: .minute, value: value, to: startApiCstall)
            dateArray.append(apiCallStartDate!)
        }
        // Sort timeString from highest to lowest
        let sortedDates = dateArray.sorted(by: { $0.compare($1) == .orderedAscending })
        for x in sortedDates {
            let finalBusScheduledTime = dateFormatter.string(from: x)
            timeString += finalBusScheduledTime + "     "
        }
        
        return timeString
    }
    
}

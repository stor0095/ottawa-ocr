////
////  File.swift
////  OCVR
////
////  Created by Geemakun Storey on 2018-07-10.
////  Copyright © 2018 geemakunstorey@storeyofgee.com. All rights reserved.
////
//
//import Foundation
//// If value + last 2 digits is greater than 60 -> add 1 hour
//// If value + last 2 digits is greater than 120 -> add 2 hours
//if value < 60 {
//    //var hourIntValue = Int()
//    
//    
//    //                if newAdjustedMinutes >= 60 {
//    //                    hourIntValue = (hour as NSString).integerValue + 1
//    //                } else {
//    //                    hourIntValue = (hour as NSString).integerValue
//    //                }
//    
//    
//    var finalTime = String()
//    //                if newAdjustedMinutes < 10 {
//    //                    finalTime = "\(hourIntValue):0\(newAdjustedMinutes)"
//    //                } else {
//    //                    finalTime = "\(hourIntValue):\(newAdjustedMinutes)"
//    //                }
//    let calendar = Calendar.current
//    let apiCallStartDate = calendar.date(byAdding: .minute, value: value, to: currentDateTime)
//    let newtest = dateFormatter.string(from: apiCallStartDate!)
//    
//    finalTime = newtest
//    
//    timeString += finalTime + "     "
//    
//}
//else if value >= 60 && value < 120 {
//    // Concatante new time
//    //    var hourIntValue = Int()
//    //  print("MINUTES: \(newAdjustedMinutes)")
//    //let newMV = newAdjustedMinutes - 60
//    //                if newMV >= 60 {
//    //                    hourIntValue = (hour as NSString).integerValue + 1
//    //                } else {
//    //                    hourIntValue = (hour as NSString).integerValue
//    //                }
//    
//    var finalTime = String()
//    let calendar = Calendar.current
//    let apiCallStartDate = calendar.date(byAdding: .minute, value: value, to: currentDateTime)
//    let newtest = dateFormatter.string(from: apiCallStartDate!)
//    
//    finalTime = newtest
//    //              //  print("NEW MINUTES: \(newMV)")
//    //
//    //
//    //                var finalTime = String()
//    //
//    //                if newMV < 10 {
//    //                    finalTime = "\(hourIntValue):0\(newMV)"
//    //                } else {
//    //                    finalTime = "\(hourIntValue):\(newMV)"
//    //                }
//    
//    timeString += finalTime + "     "
//    
//} else if value >= 120 && value < 180 {
//    // Concatante new time
//    //var hourIntValue = Int()
//    //  print("MINUTES: \(newAdjustedMinutes)")
//    //let newMV = newAdjustedMinutes - 120
//    
//    //                if newMV >= 120 {
//    //                    hourIntValue = (hour as NSString).integerValue + 1
//    //                } else {
//    //                    hourIntValue = (hour as NSString).integerValue
//    //                }
//    
//    var finalTime = String()
//    let calendar = Calendar.current
//    let apiCallStartDate = calendar.date(byAdding: .minute, value: value, to: currentDateTime)
//    let newtest = dateFormatter.string(from: apiCallStartDate!)
//    
//    finalTime = newtest
//    
//    //                var finalTime = String()
//    //
//    //                if newMV < 10 {
//    //                    finalTime = "\(hourIntValue):0\(newMV)"
//    //                } else {
//    //                    finalTime = "\(hourIntValue):\(newMV)"
//    //                }
//    //
//    timeString += finalTime + "     "
//    
//} else if value >= 180 && value < 300 {
//    var hourIntValue = Int()
//    //  print("MINUTES: \(newAdjustedMinutes)")
//    let newMV = value - 180
//    //                if newMV >= 180 {
//    //                    hourIntValue = (hour as NSString).integerValue + 1
//    //                } else {
//    //                    hourIntValue = (hour as NSString).integerValue
//    //                }
//    
//    var finalTime = String()
//    let calendar = Calendar.current
//    let apiCallStartDate = calendar.date(byAdding: .minute, value: newMV, to: currentDateTime)
//    let newtest = dateFormatter.string(from: apiCallStartDate!)
//    
//    finalTime = newtest
//    
//    //                if newMV < 10 {
//    //                    finalTime = "\(hourIntValue):0\(newMV)"
//    //                } else {
//    //                    finalTime = "\(hourIntValue):\(newMV)"
//    //                }
//    
//    timeString += finalTime + "     "
//}
//else {
////    let finalTime = "\(String(hour))\(value)"
////    //    print("FINAL TIME: ",finalTime)
////    timeString += finalTime + "     "
////}            let currentDateTime = Date()
//let dateFormatter = DateFormatter()
//dateFormatter.dateFormat = "hh:mm"
//dateFormatter.timeZone = TimeZone(identifier: "America/New_York")


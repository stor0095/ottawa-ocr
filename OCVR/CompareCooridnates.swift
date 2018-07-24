//
//  CompareCooridnates.swift
//  OCVR
//
//  Created by Geemakun Storey on 2018-07-17.
//  Copyright © 2018 geemakunstorey@storeyofgee.com. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit
import CoreLocation

class CompareCoordinates: NSObject {
    
    fileprivate let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate var stopsDict: [JSON]?
    fileprivate static var stopNumber: String = ""
    
    public func setStopNumber(stopNu: String) {
        CompareCoordinates.stopNumber = stopNu
    }
    
    public static func getStopNumber() -> String {
        return stopNumber
    }
    
    public func prepareLocation() {
        setStopNumber(stopNu: "")
        appDelegate.setOneTimeLocation()
    }
    
    public func loopBusStopCoordinates() {
        var stopsArray = [CLLocation]()
        if let path = Bundle.main.path(forResource: "stops", ofType: "json")
        {
            do{
                let pathAsData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
                let json = JSON(data: pathAsData as Data)
                
                let stopsObject = json.array
                stopsDict = json.array
                
                for x in stopsObject! {
                    let dict = x.dictionaryObject
                    // Set bus stop coordinates
                    let lat = dict!["stop_lat"] as! CLLocationDegrees
                    let long = dict!["stop_lon"] as! CLLocationDegrees

                    let coord = CLLocation(latitude: lat, longitude: long)
                    stopsArray.append(coord)
                }
                compareUsersLocation(stops: stopsArray)
            } catch{
                print("Some error")
            }
        }
    }
    
    public func compareUsersLocation(stops: [CLLocation]) {
        
        guard let lat = appDelegate.lat else {
            delay(bySeconds: 2.5, closure: {
                self.compareUsersLocation(stops: stops)
            })
            print("****** LAT IS NIL --> RETURN *******")
            return
        }
        guard let long = appDelegate.long else {
            delay(bySeconds: 2.5, closure: {
                self.compareUsersLocation(stops: stops)
            })
            print("****** LONG IS NIL --> RETURN *******")
            return
        }
        
        let usersLocation = CLLocation(latitude: lat, longitude: long)
        // https://stackoverflow.com/questions/44141720/loop-through-coordinates-and-find-the-closest-shop-to-a-point-swift-3
        let closest = stops.min(by:
        { $0.distance(from: usersLocation) < $1.distance(from: usersLocation) })
        
        // Get bus stop number from closets coordinate value
        let closetsLat = closest!.coordinate.latitude
        let closestLong = closest!.coordinate.longitude
        
        // Get distance in meters from users location
        let distanceInMeters = usersLocation.distance(from: closest!)
        print("Distance in Meters: \(distanceInMeters)")
        if distanceInMeters > 12.0 {//12.0
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
            DispatchQueue.main.async {
                showAlert(title: NSLocalizedString("Unable to read image", comment: ""), message: NSLocalizedString("Please try again later or enter 4 digit bus stop code.", comment: ""))
            }
            return
        }
        if distanceInMeters < 11.9 {//11.9
            for x in stopsDict! {
                let dict = x.dictionaryObject
                let lat = dict!["stop_lat"] as! CLLocationDegrees
                let long = dict!["stop_lon"] as! CLLocationDegrees
                // Loop through stops to find stop code
                if lat == closetsLat && long == closestLong {
                    let stopNumber = String(describing: dict!["stop_code"]!)
                    print(stopNumber)
                    setStopNumber(stopNu: stopNumber)
                }
            }
        }
    }
}

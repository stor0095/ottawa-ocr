//
//  OCServerAPI.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-08-25.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

final class OCServerAPI: NSObject {
    
    // Can't init is singleton
    private override init() { }
    
    static let sharedInstance = OCServerAPI()
    
    private let APP_ID: String = "appID=d33c0b25&"
    private let API_KEY: String = "apiKey=20bbeeabb4b5e179871d2f47e21b4a17&"
    private var STOP_NUMBER: String = ""
    private let FORMAT: String = "format=JSON"
    public var TEMPERORARY_USER_CHOSEN_STOPNUMBER: String = ""
    public var USER_REFRESHED_SCHEDULE: Int = 0
    public var API_CALL_START_TIME: Date?
    public var refreshTimer: Date?
    public var segueFromMapViewController: Bool = false
    
    lazy var BUS_STOP = BusStop(dictionary: [:])
    lazy var stopDetails: [BusStopDetails] = []
    lazy var details: [JSON] = []
    
    func requestBusData(stopNumber: String) {
        DispatchQueue.global(qos: .background).async {
            var request = URLRequest(url: URL(string: "https://api.octranspo1.com/v1.2/GetNextTripsForStopAllRoutes")!)
            request.httpMethod = "POST"
            
            self.STOP_NUMBER = "stopNo=" + stopNumber + "&"
            
            let params = self.APP_ID + self.API_KEY + self.STOP_NUMBER + self.FORMAT
            
            request.httpBody = params.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    self.handleOCError()
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                    self.handleOCError()
                    return
                }
                self.set_API_CALL_START_TIME()
                let swiftyJson = JSON(data: data)
                self.handleOCTranspoResponse(responseJSON: swiftyJson)
            }
            task.resume()
        }
    }
    
    fileprivate func handleOCTranspoResponse(responseJSON: JSON) {
        guard let summaryForBusStopDictionary = responseJSON["GetRouteSummaryForStopResult"].dictionaryObject else {return}
        guard let routes = responseJSON["GetRouteSummaryForStopResult"].dictionary else {return}
        guard let route = routes["Routes"]?.dictionary else {return}
        
        var t: JSON?
        self.details = []
        
        for (_,v) in route {
            t = v
        }
        
        for x in t! {
            details.append(x.1)
        }
        
        self.BUS_STOP = BusStop(dictionary: summaryForBusStopDictionary)
        if t?.count == 5 {//2391
            if let tDictionary = t?.dictionary {
                self.stopDetails.append(BusStopDetails(busDetails: tDictionary))
            } else {
                for x in details {
                    if x.dictionary != nil {
                        self.stopDetails.append(BusStopDetails(busDetails: (x.dictionary)!))
                    }
                }
            }
        } else {
            for x in details {
                if x.dictionary != nil {
                    self.stopDetails.append(BusStopDetails(busDetails: (x.dictionary)!))
                }
            }
        }
        
        DispatchQueue.main.async {
            if self.USER_REFRESHED_SCHEDULE == 0 {
                if self.segueFromMapViewController {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segueToBusControllerFromMapViewController"), object: nil)
                    self.segueFromMapViewController = false
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "segueToBusController"), object: nil)
                }
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateStopTimeColor"), object: nil)
            }
            self.USER_REFRESHED_SCHEDULE = 0
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTableViewCells"), object: nil)
    }
    
    fileprivate func handleOCError() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
        DispatchQueue.main.async {
            showAlert(title: NSLocalizedString("Unable to get bus schedules.", comment: ""), message: NSLocalizedString("Please try again later.", comment: ""))
        }
    }
    
    public func get_API_CALL_START_TIME() -> Date? {
        return API_CALL_START_TIME
    }
    
    fileprivate func set_API_CALL_START_TIME() {
        let currentDateTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
        
        API_CALL_START_TIME = currentDateTime
    }
    public func resetBusData() {
        BUS_STOP.StopDescription = ""
        BUS_STOP.StopNo = ""
        stopDetails = []
        details = []
        TEMPERORARY_USER_CHOSEN_STOPNUMBER = ""
    }
}

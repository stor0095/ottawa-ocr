//
//  BusResultsController.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-08-25.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit
import SwiftyJSON

class BusResultsController: UITableViewController {

    fileprivate let cellID = "cellID"
    fileprivate let OC_API = OCServerAPI.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .done, target: self, action: #selector(dismissSchedule))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Refresh", comment: ""), style: .done, target: self, action: #selector(handleRefresh))
        tableView.register(BusResultsCell.self, forCellReuseIdentifier: cellID)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableViewCells), name: NSNotification.Name(rawValue: "refreshTableViewCells"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.OC_API.USER_REFRESHED_SCHEDULE = 0
        self.tableView.backgroundView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "\(NSLocalizedString("Stop", comment: "")) \(OC_API.TEMPERORARY_USER_CHOSEN_STOPNUMBER)"
    }

    func dismissSchedule() {
        
        self.navigationController?.popViewController(animated: true)
        resetBusData()
    }
    
    func handleRefresh() {
        // Return if refresh timer is below 30 seconds
        if OC_API.refreshTimer != nil {
            let timeSince = NSDate().timeIntervalSince(OC_API.refreshTimer!)
            if timeSince < 30.0 {
                print("refreshTimer TIMER IS LESS THAN 30 SECONDS.")
                informUserAboutRefreshLimit()
                return
            }
        }
        setRefreshTimer()
        OC_API.stopDetails.removeAll()
        OC_API.USER_REFRESHED_SCHEDULE = OC_API.USER_REFRESHED_SCHEDULE + 1
        
        DispatchQueue.global(qos: .background).async {
            if self.OC_API.stopDetails.isEmpty {
                self.OC_API.requestBusData(stopNumber: self.OC_API.TEMPERORARY_USER_CHOSEN_STOPNUMBER)
            } else {
                self.OC_API.requestBusData(stopNumber: self.OC_API.TEMPERORARY_USER_CHOSEN_STOPNUMBER)
            }
        }
    }
    
    func refreshTableViewCells() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if OC_API.stopDetails.isEmpty {
            return 0
        } else {
            return OC_API.stopDetails.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        label.textColor = .white
        label.textAlignment = .center
        label.text = OC_API.BUS_STOP.StopDescription.uppercased()
        label.layer.addBorder(edge: .bottom, color: .white, thickness: 7.0)
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BusResultsCell
        cell.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        cell.busDestionation.text = self.OC_API.stopDetails[indexPath.row].RouteHeading
        cell.busNumber.text = String(describing: self.OC_API.stopDetails[indexPath.row].RouteNo!)
        
        cell.busDirection.text = self.OC_API.stopDetails[indexPath.row].RouteDirection
        
        guard let tripStartTime = self.OC_API.stopDetails[indexPath.row].TripStartTime else {return cell}
        guard let secondary_tripStartTime = self.OC_API.stopDetails[indexPath.row].TripStartTime_SECONDARY else {return cell}
        
        var timeString = HandleStopTimes.handleAdjustedScheduleTime(tripStartTime: tripStartTime, secondary_tripStartTime: secondary_tripStartTime)
        cell.busTimes.text = timeString
        
        if timeString == "" || timeString == "No buses scheduled for the next 4 hours" {
            cell.busDirection.text = ""
        }
        timeString = ""
        
        return cell
    }
    
    fileprivate func setRefreshTimer() {
        let now = NSDate()
        let nowDateValue = now as Date
        OC_API.refreshTimer = nowDateValue
    }
    
    fileprivate func resetBusData() {
        OC_API.resetBusData()
        OC_API.refreshTimer = nil
    }
    
    fileprivate func informUserAboutRefreshLimit() {
        DispatchQueue.main.async {
            showAlert(title: NSLocalizedString("Refresh Limit", comment: ""), message: NSLocalizedString("OC Transpo times are only updated once every 30 seconds.", comment: ""))
        }
    }
}

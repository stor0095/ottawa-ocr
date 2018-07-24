//
//  MapViewController.swift
//  OCVR
//
//  Created by Geemakun Storey on 2018-07-13.
//  Copyright © 2018 geemakunstorey@storeyofgee.com. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import SwiftyJSON
import Cluster

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let OC_API = OCServerAPI.sharedInstance
    let custom_AnimationView = CustomLoadingAnimation()
    let clusterManager = ClusterManager()
    let manager = CLLocationManager()
    var setRegion: Bool = false
    var requestCounter: Int8 = 0
    var monitorRequest: Timer?
    
    @IBOutlet weak var mapKitOutlet: MKMapView!
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            askUserForLocationPermission()
        default:
            break
        }
    }
    
    fileprivate func askUserForLocationPermission() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: NSLocalizedString("Enable Location Services", comment: ""), message: NSLocalizedString("For a better experience of our app please enable Location Services in Settings.", comment: ""), preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default) { (action) in
                let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
                if let url = settingsUrl {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: { (success) in
                        print(success)
                    })
                }
            }
            alertController.addAction(settingsAction)
            let OKAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            alertController.addAction(OKAction)
            alertController.show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKitOutlet.delegate = self
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        // When zoom level is quite close to the pins, disable clustering in order to show individual pins and allow the user to interact with them via callouts.
        clusterManager.cellSize = nil
        clusterManager.maxZoomLevel = 17
        clusterManager.minCountForClustering = 3
        clusterManager.clusterPosition = .nearCenter
        mapKitOutlet.clipsToBounds = false
        
        navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .done, target: self, action: #selector(removeNastyMapMemory))
        
        let buttonItem = MKUserTrackingBarButtonItem(mapView: mapKitOutlet)
        self.navigationItem.rightBarButtonItem = buttonItem
        
        intializeMap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeLoadingView), name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoadingView), name: NSNotification.Name(rawValue: "showLoadingView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(segueToBusControllerFromMapViewController), name: NSNotification.Name(rawValue: "segueToBusControllerFromMapViewController"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .black
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !setRegion {
            var region = MKCoordinateRegion()
            region.center = mapView.userLocation.coordinate
            region.span.latitudeDelta = 0.01
            region.span.longitudeDelta = 0.01
            mapView.setRegion(region, animated: true)
            setRegion = true
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let rightButton: AnyObject! = UIButton(type:UIButtonType.infoLight)
        
        if let annotation = annotation as? ClusterAnnotation {
            guard let style = annotation.style else { return nil }
            let identifier = "Cluster"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let view = view as? BorderedClusterAnnotationView {
                view.annotation = annotation
                view.style = style
                view.configure()
            } else {
                view = BorderedClusterAnnotationView(annotation: annotation, reuseIdentifier: identifier, style: style, borderColor: .white)
            }
            view?.isEnabled = true
            view?.canShowCallout = true
            view?.clipsToBounds = false
            view?.rightCalloutAccessoryView = rightButton as? UIView
            
            return view
        } else {
            guard let annotation = annotation as? Annotation, let style = annotation.style else { return nil }
            let identifier = "Pin"
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if let view = view {
                view.annotation = annotation
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            if #available(iOS 9.0, *), case let .color(color, _) = style {
                view?.pinTintColor =  color
            } else {
                view?.pinTintColor = .red
            }
            view?.isEnabled = true
            view?.canShowCallout = true
            view?.clipsToBounds = false
            view?.rightCalloutAccessoryView = rightButton as? UIView
            
            return view
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let title = view.annotation?.subtitle!
            OC_API.segueFromMapViewController = true
            handleBusStopNumberFromPin(busStopTitle: title!)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        clusterManager.reload(mapView: mapView) { finished in
            print(finished)
        }
    }
    
    fileprivate func getStopNumber(stopTitle: String) -> String {
        let stopNumber = String(stopTitle.suffix(4))
        return stopNumber
    }
    
    fileprivate func handleBusStopNumberFromPin(busStopTitle: String) {
        let stopNo = getStopNumber(stopTitle: busStopTitle)
        OC_API.requestBusData(stopNumber: stopNo)
        OC_API.TEMPERORARY_USER_CHOSEN_STOPNUMBER = stopNo
        DispatchQueue.main.async {
            self.showLoadingView()
        }
    }
    
    func removeMappAnnotations() {
        if mapKitOutlet.annotations.count != 0 {
            for annoation in mapKitOutlet.annotations {
                mapKitOutlet.removeAnnotation(annoation)
            }
        }
    }
    
    func removeNastyMapMemory() {
        self.navigationController?.popToRootViewController(animated: true)
        mapKitOutlet.delegate = nil
        mapKitOutlet.removeFromSuperview()
        mapKitOutlet = nil
    }
    
    func addPinsToMap() {
        removeMappAnnotations()
        if let path = Bundle.main.path(forResource: "stops", ofType: "json")
        {
            do{
                let pathAsData = try NSData(contentsOfFile: path, options: NSData.ReadingOptions.mappedIfSafe)
                let json = JSON(data: pathAsData as Data)
                
                let stopsObject = json.array
                for x in stopsObject! {
                    let annotation = Annotation()
                    let dict = x.dictionaryObject
                    // Set title
                    let title = "\(dict!["stop_name"]!)"
                    annotation.title = title
                    annotation.subtitle = String(describing: dict!["stop_code"]!)
                    
                    // Set bus stop coordinates
                    let lat = dict!["stop_lat"] as! CLLocationDegrees
                    let long = dict!["stop_lon"] as! CLLocationDegrees
                    let CLLCoordType = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    annotation.coordinate = CLLCoordType
                    let color = UIColor.red//UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
                    annotation.style = .color(color, radius: 25)
                    
                    // Add annoation to mapview
                    clusterManager.add(annotation)
                }
            } catch{
                print("Some error")
            }
        }
    }
    
    func segueToBusControllerFromMapViewController() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
        }
        let busResultsVC = BusResultsController()
        self.navigationController?.pushViewController(busResultsVC, animated: false)
    }
    
    fileprivate func intializeMap() {
        addPinsToMap()
    }
}

extension MapViewController {
    // MARK: Handle User Interface Methods
    func showLoadingView() {
        DispatchQueue.main.async {
            self.startTimer()
            self.view.addSubview(self.custom_AnimationView)
            self.custom_AnimationView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.custom_AnimationView.loadingAnimation()
        }
    }

    func startTimer() {
        guard monitorRequest == nil else { return }
        monitorRequest = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(test), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        guard monitorRequest != nil else { return }
        monitorRequest?.invalidate()
        monitorRequest = nil
    }
    
    func test() {
        self.requestCounter = self.requestCounter + 1
        print(self.requestCounter)
        if self.requestCounter >= 15 {
            self.requestCounter = 0
            self.removeLoadingView()
            self.stopTimer()
            showAlert(title: NSLocalizedString("Unable to process request.", comment: ""), message: NSLocalizedString("Please try again.", comment: ""))
        }
    }
    
    func removeLoadingView() {
        DispatchQueue.main.async {
            self.stopTimer()
            self.custom_AnimationView.removeFromSuperview()
        }
    }
}

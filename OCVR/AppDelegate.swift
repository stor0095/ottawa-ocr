
//
//  AppDelegate.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-08-22.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreLocation
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let manager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let navVC = UINavigationController(rootViewController: ViewController())
        window?.rootViewController = navVC
        
        window?.addSubview(wallPaperView)
        wallPaperView.anchor(top: window?.topAnchor, left: window?.leftAnchor, bottom: window?.bottomAnchor, right: window?.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        UITableView.appearance().backgroundColor = UIColor.clear
        
        // Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        IQKeyboardManager.shared.enable = true
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        
        BITHockeyManager.shared().configure(withIdentifier: "6cf3cc84ea644187a64911a9cf36dc78")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation() // This line is obsolete in the crash only builds
        
        return true
    }
    
    func setOneTimeLocation() {
        print("REQUESTING LOCATION")
        lat = nil
        long = nil
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestLocation()
    }
    
    var lat: CLLocationDegrees? = nil
    var long: CLLocationDegrees? = nil
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        lat = locValue.latitude
        long = locValue.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    let wallPaperView: GradientView = {
        let view = GradientView()
//        view.topColor = UIColor.rgb(red: 255, green: 38, blue: 216)
//        view.bottomColor = UIColor.rgb(red: 29, green: 95, blue: 166)
        //27,109,193
        view.topColor = UIColor.rgb(red: 27, green: 109, blue: 193)
        view.bottomColor = UIColor.rgb(red: 24, green: 40, blue: 72)
        view.shadowColor = UIColor.rgb(red: 255, green: 38, blue: 216)
        
        
        view.startPointX = 0.0
        view.endPointX = 1.0
        
        view.startPointY = 1.0
        view.endPointY = 0.0
        
        view.shadowX = 0.0
        view.shadowY = 12.0
        view.shadowBlur = 17.0
        
        view.cornerRadius = 4.0
        
        return view
    }()

}


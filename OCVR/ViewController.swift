//
//  ViewController.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-08-22.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit
import SwiftyJSON

//public var stopsDictForMap = [String:Any]()

class ViewController: UIViewController, UITextFieldDelegate {

    let OC_API = OCServerAPI.sharedInstance
    let numberToolbar: UIToolbar = UIToolbar()
    let custom_AnimationView = CustomLoadingAnimation()
    var requestCounter: Int8 = 0
    var monitorRequest: Timer?
    
    let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "camera1600").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        return button
    }()
    
    let mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Map", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        button.tintColor = .white
        button.layer.borderWidth = 3.0
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(segueToMapView), for: .touchUpInside)
        return button
    }()
    
    let busStopTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "3017",
                                                   attributes: [NSForegroundColorAttributeName: UIColor.gray])
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.keyboardType = .numberPad
        tf.returnKeyType = .done
        tf.backgroundColor = .white
        tf.textColor = .black
        tf.textAlignment = .center
        return tf
    }()
    
    let takePhotoLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Take photo of bus stop sign", comment: "")
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    let enterLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Enter the 4 digit bus stop number", comment: "")
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    let orLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("OR", comment: "")
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    fileprivate func setupNumberPad() {
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismissNumberPad)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: UIBarButtonItemStyle.plain, target: self, action: #selector(handleTextInputBusStop))
        ]
        numberToolbar.sizeToFit()
        busStopTextField.inputAccessoryView = numberToolbar
    }
    
    func handleTextInputBusStop() {
        if (busStopTextField.text?.isEmpty)! {
            busStopTextField.resignFirstResponder()
            return
        }
        if busStopTextField.text?.characters.count != 4 {
            // Inform user only four digit bus code is accepted
            self.busStopTextField.text = ""
            DispatchQueue.main.async {
                showAlert(title: NSLocalizedString("Whoops!", comment: ""), message: NSLocalizedString("Please enter the 4 digit bus stop number.", comment: ""))
            }
            return
        } else {
            guard let stopNo = busStopTextField.text else {return}
            OC_API.requestBusData(stopNumber: stopNo)
            OC_API.TEMPERORARY_USER_CHOSEN_STOPNUMBER = stopNo
            
            DispatchQueue.main.async {
                self.showLoadingView()
                self.busStopTextField.text = ""
            }
        }
        busStopTextField.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        busStopTextField.delegate = self
        setupNumberPad()
        setupNotificationObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        busStopTextField.text = ""
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        busStopTextField.resignFirstResponder()
    }
    
    func handleCamera() {
        DispatchQueue.main.async {
            let cameraController = CameraController()
            self.present(cameraController, animated: true, completion: nil)
        }
    }
    
    fileprivate func setupView() {
        
        navigationItem.title = "Ottawa OCR"
        
        view.addSubview(takePhotoLabel)
        view.addSubview(cameraButton)
        view.addSubview(orLabel)
        view.addSubview(enterLabel)
        view.addSubview(busStopTextField)
        view.addSubview(mapButton)
        
        takePhotoLabel.anchor(top: nil, left: nil, bottom: cameraButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 3, paddingRight: 0, width: 225, height: 45)
        takePhotoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        cameraButton.anchor(top: takePhotoLabel.bottomAnchor, left: nil, bottom: orLabel.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 45, paddingRight: 0, width: 65, height: 65)
        cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        orLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 25)
        orLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        orLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        enterLabel.anchor(top: orLabel.bottomAnchor, left: nil, bottom: busStopTextField.topAnchor, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 3, paddingRight: 0, width: 250, height: 45)
        enterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        busStopTextField.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 65, height: 44)
        busStopTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapButton.anchor(top: busStopTextField.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 50)
        mapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func dismissNumberPad() {
        busStopTextField.text = ""
        busStopTextField.resignFirstResponder()
    }
    
    fileprivate func setupNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(removeLoadingView), name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(segueToBusController), name: NSNotification.Name(rawValue: "segueToBusController"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoadingView), name: NSNotification.Name(rawValue: "showLoadingView"), object: nil)
    }
    
    func segueToBusController() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
        }
        let busResultsVC = BusResultsController()
        self.navigationController?.pushViewController(busResultsVC, animated: false)
    }
    
    @objc fileprivate func segueToMapView() {
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapView") as? MapViewController {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension ViewController {
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
        self.requestCounter = 0
    }
    
    func test() {
        self.requestCounter = self.requestCounter + 1
        print(self.requestCounter)
        if self.requestCounter >= 19 {
            self.requestCounter = 0
            self.removeLoadingView()
            self.stopTimer()
            showAlert(title: NSLocalizedString("Unable to process request.", comment: ""), message: NSLocalizedString("Please try again later.", comment: ""))
        }
    }
    
    func removeLoadingView() {
        DispatchQueue.main.async {
            self.stopTimer()
            self.custom_AnimationView.removeFromSuperview()
        }
    }
}


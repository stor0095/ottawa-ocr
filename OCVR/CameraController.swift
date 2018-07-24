//
//  CameraController.swift
//  InstagramFireBase
//
//  Created by Geemakun Storey on 2017-06-08.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit
import AVFoundation

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate {
    
    let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    let customAnimationPresenter = CustomAnimationPresenter()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.rgb(red: 109, green: 213, blue: 250)
        button.layer.cornerRadius = 0.5 * 50
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Place 4 Digit Bus Stop Number Here", comment: "")
        
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 0
        //savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        return label
    }()
    
    let cameraFocusIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "cameraFocus").withRenderingMode(.alwaysTemplate)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.tintColor = .white//UIColor.rgb(red: 75, green: 108, blue: 183)
        return iv
    }()
    
    // MARK: User Denied Access to Camera View
    let deniedAccessLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Take photos of bus stop signs", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
       // label.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        return label
    }()
    
    let deniedAccessLabelSecondary: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Allow Ottawa OCR access to your camera to take photos with the app.", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let cameraAccessButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("Allow Camera Access", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(handleCameraAccessButton), for: .touchUpInside)
        return button
    }()
    
    func handleCameraAccessButton() {
        let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString)
        if let url = settingsUrl {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: { (success) in
                print(success)
            })
        }
    }
    
    func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
     //   button.setImage(#imageLiteral(resourceName: "capture_photo").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        transitioningDelegate = self
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.prepareOCRFailureBackup()
                    self.setupCaptureSession()
                    self.setupHUD()
                }
            } else {
                // Setup view if user declined access
                DispatchQueue.main.async {
                    self.setupDeniedAccessView()
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleDismiss), name: NSNotification.Name(rawValue: "handleDismiss"), object: nil)
    }
    
    fileprivate func prepareOCRFailureBackup() {
        let compare = CompareCoordinates()
        compare.prepareLocation()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationPresenter
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return customAnimationDismisser
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    fileprivate func setupHUD() {
        view.addSubview(infoLabel)
        view.addSubview(capturePhotoButton)
        view.addSubview(cameraFocusIcon)
        view.addSubview(dismissButton)
        view.addSubview(infoLabel)
        
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 65, height: 65)
        capturePhotoButton.layer.cornerRadius = 65/2
        capturePhotoButton.clipsToBounds = true
        capturePhotoButton.layer.borderWidth = 6.5
        capturePhotoButton.layer.borderColor = UIColor.rgb(red: 109, green: 213, blue: 250).cgColor
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        } else {
            // Fallback on earlier versions
            dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        }
        
        infoLabel.center = self.view.center
        
        cameraFocusIcon.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 220, height: 220)
        cameraFocusIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraFocusIcon.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    fileprivate func setupDeniedAccessView() {
        view.addSubview(dismissButton)
        view.addSubview(deniedAccessLabel)
        view.addSubview(deniedAccessLabelSecondary)
        view.addSubview(cameraAccessButton)
        
        if #available(iOS 11.0, *) {
            dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        } else {
            // Fallback on earlier versions
            dismissButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 50)
        }
        
        deniedAccessLabel.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        deniedAccessLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deniedAccessLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        deniedAccessLabelSecondary.anchor(top: deniedAccessLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 17, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 325, height: 0)
        deniedAccessLabelSecondary.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        cameraAccessButton.anchor(top: deniedAccessLabelSecondary.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 17, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 75)
        cameraAccessButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func handleCapturePhoto() {
        let setttings = AVCapturePhotoSettings()
        setttings.flashMode = .auto
        
        guard let previewFormatType = setttings.availablePreviewPhotoPixelFormatTypes.first else {return}
        setttings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        output.capturePhoto(with: setttings, delegate: self)
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        // Finished processing photo sample buffer...
        
        let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        
        let previewImage = UIImage(data: imageData!)
        
        let containerView = PreviewPhotoContainerView()
        containerView.previewImageView.image = previewImage
        view.addSubview(containerView)
        containerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        
    }
    
    let output = AVCapturePhotoOutput()
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        // 1. setup inputs
        do {
            let input = try  AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            try captureDevice?.lockForConfiguration()
            let zoomFactor: CGFloat = 2
            captureDevice?.videoZoomFactor = zoomFactor
            captureDevice?.unlockForConfiguration()
            
        } catch let err {
            print("Could not setup camera input: ", err)
        }
        
        // 2. setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // 3. setup output preview
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {return}
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = view.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            
            if let device = captureDevice {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = focusPoint
                    //device.focusMode = .continuousAutoFocus
                    device.focusMode = .autoFocus
                    //device.focusMode = .locked
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    // just ignore
                }
            }
        }
    }
    
    
}

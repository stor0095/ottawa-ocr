//
//  MicrosoftOCR.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-08-30.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MicrosoftOCR: NSObject {

    private override init() { }
    
    static let sharedInstance = MicrosoftOCR()
    
    let OC_API = OCServerAPI.sharedInstance
    
    lazy var OCR_BUS_STOP_RESPONSE: [Int] = []
    lazy var OCR_LINES: [JSON] = []
    lazy var OCR_WORDS: [JSON] = []
    
    func getImageForAzure(image: UIImage?) {
        if let img = image {
            if let data:Data = UIImagePNGRepresentation(img) {
                guard let newImage = UIImage(data: data) else {return}
                let croppedImage = CropImage.cropToBounds(image: newImage, width: 75, height: 75)
                guard let convertToJPG = UIImageJPEGRepresentation(croppedImage, 1.0) else {return}

                sendImageToAzure(imageData: convertToJPG)
            } else if let data:Data = UIImageJPEGRepresentation(img, 1.0) {
                guard let newImage = UIImage(data: data) else {return}
                let croppedImage = CropImage.cropToBounds(image: newImage, width: 75, height: 75)
                guard let convertToJPG = UIImageJPEGRepresentation(croppedImage, 1.0) else {return}
                
                sendImageToAzure(imageData: convertToJPG)
            }
        }
    }
    
    func sendImageToAzure(imageData: Data) {
        // Handle operations with data here...
        DispatchQueue.global(qos: .background).async {
        let headers = [
            "content-type": "application/octet-stream",
            "ocp-apim-subscription-key": "72acf35d5c1f4515a61452cab529f364",
            "cache-control": "no-cache"
        ]
        let request = NSMutableURLRequest(url: NSURL(string: "https://canadacentral.api.cognitive.microsoft.com/vision/v1.0/ocr?language=en")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = imageData
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                // Inform user of error
                self.handleOCRError()
            } else {
                guard let OCRReponse = JSON(data: data!).dictionary else {return}
                self.handleOCRResponse(azureReponse: OCRReponse)
            }
        })
        dataTask.resume()
        }
    }
    
    fileprivate func handleOCRResponse(azureReponse: [String : JSON]) {
        let OCRReponse = azureReponse
        // regions -> lines -> words -> text
        guard let OCR_REGIONS = OCRReponse["regions"]?.array else {return}
        
        self.OCR_LINES = []
        self.OCR_WORDS = []
        for region in OCR_REGIONS {
            let line = region.dictionary?["lines"]!
            OCR_LINES.append(line!)
        }
        
        for line in OCR_LINES {
            for w in line.array! {
                let yWords = w.dictionary?["words"]
                OCR_WORDS.append(yWords!)
            }
        }
        
        for word in OCR_WORDS {
            for y in word.array! {
                guard let text = y.dictionary?["text"]?.stringValue else {return}
                let textCounter = text.characters.count
                var busStopResponse_OCR: Int
                if textCounter == 4 {
                    if isStringAnInt(string: text) {
                        busStopResponse_OCR = Int(text)!
                        self.OCR_BUS_STOP_RESPONSE.append(busStopResponse_OCR)
                    }
                }
            }
        }
        print("OCR Response Count: \(self.OCR_BUS_STOP_RESPONSE.count)")
        if self.OCR_BUS_STOP_RESPONSE.count == 0 {
            // Let user know that stop number not found from photo
            // Try to get stop number from users location
            DispatchQueue.main.async {
                let compare = CompareCoordinates()
                compare.loopBusStopCoordinates()
            }
            startTimer()
        } else {
            guard let stopNumber = self.OCR_BUS_STOP_RESPONSE.first else {return}
            print("STOP_NUMBER: \(stopNumber)")
            self.OC_API.requestBusData(stopNumber: String(stopNumber))
            self.OC_API.TEMPERORARY_USER_CHOSEN_STOPNUMBER = String(stopNumber)
            self.OCR_BUS_STOP_RESPONSE = []
        }
    }
    
    var timer: Timer?
    func startTimer() {
        DispatchQueue.main.async {
            guard self.timer == nil else { return }
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.handleOCRFallBack), userInfo: nil, repeats: true)
        }
    }
    
    @objc func handleOCRFallBack() {
        let fallBackNumber = CompareCoordinates.getStopNumber()
        if fallBackNumber == "" {
            return
        } else {
            resetTimer()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
            // Ask user if this is their stop number before requesting stop
            DispatchQueue.main.async {
                self.confirmBusStopFromFallback(stopNu: fallBackNumber)
            }
        }
    }
    
    fileprivate func confirmBusStopFromFallback(stopNu: String) {
        let alertController = UIAlertController(title: NSLocalizedString("Stop \(stopNu)", comment:
        ""), message: NSLocalizedString("Is this the bus stop number on the sign?", comment: ""), preferredStyle: .alert)
        
        let proceedAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default) { (_) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showLoadingView"), object: nil)
            self.OC_API.requestBusData(stopNumber: stopNu)
            self.OC_API.TEMPERORARY_USER_CHOSEN_STOPNUMBER = stopNu
            self.OCR_BUS_STOP_RESPONSE = []
        }
        alertController.addAction(proceedAction)
        let OKAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(OKAction)
        alertController.show()
    }
    
    fileprivate func resetTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    fileprivate func handleOCRError() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "removeLoadingView"), object: nil)
        DispatchQueue.main.async {
            showAlert(title: NSLocalizedString("Unable to read image", comment: ""), message: NSLocalizedString("Please try again later.", comment: ""))
        }
    }
}

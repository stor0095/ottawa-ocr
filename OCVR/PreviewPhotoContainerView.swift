
//
//  PreviewPhotoContainerView.swift
//  InstagramFireBase
//
//  Created by Geemakun Storey on 2017-06-08.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit
import Photos

class PreviewPhotoContainerView: UIView {

    let OCR_Azure = MicrosoftOCR.sharedInstance
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.rgb(red: 109, green: 213, blue: 250)
        button.layer.cornerRadius = 0.5 * 50
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "right_arrow_shadow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.rgb(red: 109, green: 213, blue: 250)
        button.layer.cornerRadius = 0.5 * 55
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    func handleSave() {
            DispatchQueue.main.async {
                let savedLabel = UILabel()
                savedLabel.text = NSLocalizedString("Sent Successfully", comment: "")
                
                savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
                savedLabel.textColor = .white
                savedLabel.numberOfLines = 0
                savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
                savedLabel.textAlignment = .center
                
                savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
                savedLabel.center = self.center
                
                self.addSubview(savedLabel)
                
                savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { 
                    
                    savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
                    
                }, completion: { (completed) in
                    //completed
                    
                    UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { 
                        
                        savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                        savedLabel.alpha = 0
                        
                    }, completion: { (_) in
                        savedLabel.removeFromSuperview()
                        self.handleCompleteion()
                    })
                    
                })
            }
    }
    
    func handleDismiss() {
        self.removeFromSuperview()
    }
    
    fileprivate func handleCompleteion() {
        
        let size = CGSize(width: 300, height: 200)
        //let image = UIImage(named: "my_great_photo")?.crop(size)
        
        guard let previewImage =  self.previewImageView.image else {return}
        let croppedImage = previewImage.crop(to: size)
        //prepareOCRFailureBackup()
        self.OCR_Azure.getImageForAzure(image: croppedImage)
        self.handleDismiss()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showLoadingView"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleDismiss"), object: nil)
        self.previewImageView.image = nil
    }
    
//    fileprivate func prepareOCRFailureBackup() {
//        let compare = CompareCoordinates()
//        compare.prepareLocation()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(previewImageView)
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(cancelButton)
        if #available(iOS 11.0, *) {
            cancelButton.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        } else {
            // Fallback on earlier versions
            cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        }
        addSubview(saveButton)
        if #available(iOS 11.0, *) {
            saveButton.anchor(top: nil, left: nil, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 24, width: 55, height: 55)
        } else {
            // Fallback on earlier versions
            saveButton.anchor(top: nil, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 24, width: 55, height: 55)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  BusResultsCell.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-08-25.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit

class BusResultsCell: UITableViewCell {
    
    let busStopName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    let busStopNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }()
    
    let busNumber: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .white
        return label
    }()
    
    let busDestionation: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    let busDirection: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let busTimes: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .green
        label.numberOfLines = 0
        //label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let backGroundCardView: UIView = {
        let v = UIView()
        return v
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
            createCardLayout()
            setupBusCell()
        NotificationCenter.default.addObserver(self, selector: #selector(updateStopTimeColor), name: NSNotification.Name(rawValue: "updateStopTimeColor"), object: nil)
    }
    
    fileprivate func createCardLayout() {
        addSubview(backGroundCardView)
        backGroundCardView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        backGroundCardView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backGroundCardView.layer.cornerRadius = 3.0
        backGroundCardView.layer.masksToBounds = false
        backGroundCardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        backGroundCardView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backGroundCardView.layer.shadowOpacity = 0.8
    }
    
    
    fileprivate func setupBusCell() {
//        addSubview(busStopName)
//        addSubview(busStopNumber)
        addSubview(busNumber)
        addSubview(busDestionation)
        addSubview(busTimes)
        addSubview(busDirection)
        
//        busStopName.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 4, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: 120, height: 15)
//        
//        busStopNumber.anchor(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 55, height: 15)
        
        
        busNumber.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: busDestionation.leftAnchor, paddingTop: 5, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 55, height: 25)
        
        busDestionation.anchor(top: topAnchor, left: busNumber.rightAnchor, bottom: busTimes.topAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 0, paddingBottom: 8, paddingRight: 4, width: 0, height: 25)
        
        
        
        
        busTimes.anchor(top: busNumber.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: busDirection.leftAnchor, paddingTop: 8, paddingLeft: 5, paddingBottom: 7, paddingRight: 0, width: 0, height: 15)
        
        busDirection.anchor(top: busDestionation.bottomAnchor, left: nil, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 7, paddingRight: 5, width: 0, height: 15)
    }
    
    @objc func updateStopTimeColor() {
        DispatchQueue.main.async {
            self.busTimes.textColor = .white
        }
        delay(bySeconds: 1.5, dispatchLevel: .main) {
            self.busTimes.textColor = .green
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

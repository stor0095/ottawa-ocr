//
//  CustomLoadingAnimation.swift
//  OCVR
//
//  Created by Geemakun Storey on 2017-09-01.
//  Copyright © 2017 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit

class CustomLoadingAnimation: UIView {

    weak var shapeLayer: CAShapeLayer?
    weak var shapeLayer2: CAShapeLayer?
    weak var flagLayer: CAShapeLayer?
    
    let animationView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear//UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.9)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.9)
        addSubview(animationView)
        animationView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width:300, height: 300)
        animationView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        animationView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    //UIScreen.main.bounds.width
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadingAnimation() {
        // remove old shape layer if any
        self.shapeLayer?.removeFromSuperlayer()
        self.shapeLayer2?.removeFromSuperlayer()
        self.flagLayer?.removeFromSuperlayer()
        // create whatever path you want
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 75, y: 150))
        
        // Add first hump on left side
        path.addLine(to: CGPoint(x: 80, y: 140))
        path.addLine(to: CGPoint(x: 90, y: 140))
        path.addLine(to: CGPoint(x: 95, y: 150))
        
        // Continue straight line
        path.addLine(to: CGPoint(x: 110, y: 150))
        
        // second hump left side
        path.addLine(to: CGPoint(x: 115, y: 140))
        path.addLine(to: CGPoint(x: 125, y: 140))
        path.addLine(to: CGPoint(x: 130, y: 150))
        
        // continue straight line
        path.addLine(to: CGPoint(x: 200, y: 150))
        
        // third hump right side
        //205
        path.addLine(to: CGPoint(x: 205, y: 140))
        path.addLine(to: CGPoint(x: 215, y: 140))
        path.addLine(to: CGPoint(x: 220, y: 150))
        
        // continue straight line
        path.addLine(to: CGPoint(x: 230, y: 150))
        
        // fourth hump right side
        path.addLine(to: CGPoint(x: 235, y: 140))
        path.addLine(to: CGPoint(x: 245, y: 140))
        path.addLine(to: CGPoint(x: 250, y: 150))
        
        // Finish drawing the rectangle building
        path.addLine(to: CGPoint(x: 250, y: 150))
        path.addLine(to: CGPoint(x: 250, y: 200))
        path.addLine(to: CGPoint(x: 75, y: 200))
        path.addLine(to: CGPoint(x: 75, y: 150))
        
        // Flag Path
        let flagPath = UIBezierPath()
        flagPath.move(to: CGPoint(x: 164, y: 80))
        flagPath.addLine(to: CGPoint(x: 164, y: 50))
        flagPath.addLine(to: CGPoint(x: 180, y: 50))
        flagPath.addLine(to: CGPoint(x: 180, y: 58))
        flagPath.addLine(to: CGPoint(x: 164, y: 58))
        
        // Draw peace tower
        let path2 = UIBezierPath()
        path2.move(to: CGPoint(x: 152, y: 200))
        path2.addLine(to: CGPoint(x: 177, y: 200))
        path2.addLine(to: CGPoint(x: 177, y: 110))
        
        path2.addLine(to: CGPoint(x: 167, y: 80))
        
        path2.addLine(to: CGPoint(x: 162, y: 80))
        
        path2.addLine(to: CGPoint(x: 152, y: 110))
        path2.addLine(to: CGPoint(x: 152, y: 200))
        
        // create shape layer for that path
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.path = path.cgPath
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer2.strokeColor = UIColor.white.cgColor
        shapeLayer2.lineWidth = 4
        shapeLayer2.path = path2.cgPath
        
        let flag = CAShapeLayer()
        flag.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        flag.strokeColor = UIColor.white.cgColor
        flag.lineWidth = 2
        flag.path = flagPath.cgPath
        
        // animate it
        
        animationView.layer.addSublayer(shapeLayer)
        animationView.layer.addSublayer(shapeLayer2)
        animationView.layer.addSublayer(flag)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 2.0
        animation.repeatCount = .infinity
        shapeLayer.add(animation, forKey: "MyAnimation")
        
        let animation2 = CABasicAnimation(keyPath: "strokeEnd")
        animation2.fromValue = 0
        animation2.duration = 2.0
        animation2.repeatCount = .infinity
        shapeLayer2.add(animation2, forKey: "MyAnimation")
        
        // save shape layer
        self.shapeLayer = shapeLayer
        self.shapeLayer2 = shapeLayer2
        self.flagLayer = flag
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 164.5,y: 120), radius: CGFloat(7), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        let shapeLayer3 = CAShapeLayer()
        shapeLayer3.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer3.fillColor = UIColor.clear.cgColor
        //you can change the stroke color
        shapeLayer3.strokeColor = UIColor.white.cgColor
        //you can change the line width
        shapeLayer3.lineWidth = 2.0
        
        let animation3 = CABasicAnimation(keyPath: "strokeEnd")
        animation3.fromValue = 0
        animation3.duration = 2.0
        animation3.repeatCount = .infinity
        shapeLayer3.add(animation3, forKey: "MyAnimation")
        
        let flagAnimation = CABasicAnimation(keyPath: "strokeEnd")
        flagAnimation.fromValue = 0
        flagAnimation.duration = 2.0
        flagAnimation.repeatCount = .infinity
        flag.add(flagAnimation, forKey: "MyAnimation")
        
        animationView.layer.addSublayer(shapeLayer3)
    }


}

//
//  HudView.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 05/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class HudView: UIView {
    
    var text = ""
    
    // convenience constructor
    class func hudInView(view: UIView, aminated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        
        hudView.opaque = false
        
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        
        hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        return hudView
    }
    
    // MARK : override
    
    
    // drawRect
    
    override func drawRect(rect: CGRect) {
        // create square
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        // calculate position for the hud
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth)/2), y: ((bounds.size.height - boxHeight)/2), width: boxWidth, height: boxHeight)
        
        // rectangle doesnt leave box
        let roundRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundRect.fill()
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.drawAtPoint(imagePoint)
        }
    }
    
    
}

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
    
    // MARK :convenience constructor
    class func hudInView(view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        
        hudView.opaque = false
        
        view.addSubview(hudView)
        view.userInteractionEnabled = false
        
        hudView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        hudView.showAnimated(animated)
        return hudView
    }
    
    
    // MARK: func's
    
    func showAnimated(animated: Bool) {
        if animated {
            // 1 - set up inital state of the view before animation
            alpha = 1
            transform = CGAffineTransformMakeScale(1.3, 1.3)
            
            //2 - call to set animation
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            // 3 - new state
                self.alpha = 1
                self.transform = CGAffineTransformIdentity
            
            }, completion: nil)
        }
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
        let attribs =  [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let textSize = text.sizeWithAttributes(attribs)
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.drawAtPoint(textPoint, withAttributes: attribs)
    }
    
    
}

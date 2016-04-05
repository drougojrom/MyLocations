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
    
    
}

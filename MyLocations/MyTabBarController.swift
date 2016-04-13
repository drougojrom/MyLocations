//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 13/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
        
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return nil
    }
    
}

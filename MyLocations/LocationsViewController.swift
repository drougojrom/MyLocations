//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 06/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    // MARK: var and let
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: func's
    
    // MARK: override func's
    
    // tableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath)
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = "If you can see it"
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        addressLabel.text = "Then it works!"
        
        return cell
    }
}

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
    var locations = [Location]()
    var locationToEdit: Location?
    
    // MARK: func's
    
    // MARK: override func's
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1 - object which describes which objects you're going to fetch from the data store
        let fetchRequest = NSFetchRequest()
        
        // 2 - looking for location entities
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        // 3 - sort data attributes in ascending order
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // 4 - returns an array with the sorted objects
        
        do {
            let foundObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
            
            // 5 - assign the context of foundObjects array to Location
            locations = foundObjects as! [Location]
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    
    // tableView
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath) as! LocationCell
        
        let location = locations[indexPath.row]
        cell.configureForLocation(location)
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let location = locations[indexPath.row]
                controller.locationToEdit = location
            }
        }
    }
}

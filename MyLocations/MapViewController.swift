//
//  MapViewController.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 07/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    // MARK : outlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK : var and let
    var managedObjectContext : NSManagedObjectContext!
    var locations = [Location]()
    
    // MARK : @IBActions
    @IBAction func showUser(){
        
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations(){
        
    }
    
    // MARK : func's
    
    func updateLocation(){
        
        mapView.removeAnnotations(locations)
        
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: managedObjectContext)
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.executeFetchRequest(fetchRequest) as! [Location]
        mapView.addAnnotations(locations)
        
    }
    
    // MARK : override func's
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocation()
    }
    
    
}

extension MapViewController : MKMapViewDelegate {


}
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
    var managedObjectContext : NSManagedObjectContext! {
        didSet {
            NSNotificationCenter.defaultCenter().addObserverForName(
                NSManagedObjectContextObjectsDidChangeNotification,
                object: managedObjectContext,
                queue: NSOperationQueue.mainQueue()) { notification in
                    if self.isViewLoaded() {
                        self.updateLocation()
                }
            }
        }
    }
    var locations = [Location]()
    
    // MARK : @IBActions
    @IBAction func showUser(){
        
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations(){
        
        let region = regionForAnnotation(locations)
        mapView.setRegion(region, animated: true)
        
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
    
    func regionForAnnotation(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        /*
        * Has three situation to handle: uses switch - statement to look at number of annotations
        * and then chooses a case:
        * - no annotation: center on user
        * - only one: center map on it
        * - many: calculates extent of their reach and shows more close
        */
        var region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.latitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.latitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            let span = MKCoordinateSpan(
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
    
    // MARK : override func's
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocation()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditLocation" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = locations[button.tag]
            
            controller.locationToEdit = location
        }
    }
    
    
}

extension MapViewController : MKMapViewDelegate {
    
    // MARK : extension func's
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 1 - check if annotation is location object
        guard annotation is Location else {
            return nil
        }
        
        // 2 - just like with cell in table, but with pins.
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            // 3 - configure look an feel of pins
            annotationView.enabled = true
            annotationView.canShowCallout = true
            annotationView.animatesDrop =  false
            annotationView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            annotationView.tintColor = UIColor(white: 0.0, alpha: 0.5)
            
            // 4 - button for location details
            let rightButton = UIButton(type: .DetailDisclosure)
            rightButton.addTarget(self,
                                  action: Selector("showLocationDetails:"),
                                  forControlEvents: .TouchUpInside)
            annotationView.rightCalloutAccessoryView = rightButton
        } else {
            annotationView.annotation = annotation
        }
        
        // 5 - obtain a reference to that detail disclosure button to see detailed view
        let button = annotationView.rightCalloutAccessoryView as! UIButton
        if let index = locations.indexOf(annotation as! Location) {
            button.tag = index
        }
        return annotationView
    }
    
    func showLocationDetails(sender: UIButton){
        
        performSegueWithIdentifier("EditLocation", sender: sender)
        
    }

}

extension MapViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
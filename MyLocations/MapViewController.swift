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
    }
    
    
}

extension MapViewController : MKMapViewDelegate {


}
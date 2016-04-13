//
//  FirstViewController.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 01/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK : - Outlets
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    
    // var and let
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: NSError?
    var timer: NSTimer?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var managedObjectContext: NSManagedObjectContext!
    
    @IBAction func getLocation(){
        
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .Denied || authStatus == .Restricted {
            showLocationServiceDeniedAlert()
            return
        }
        
        if updatingLocation {
            stopLocationManager()
        } else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
        configureGetButton()
        
    }
    
    // MARK : update labels
    
    func updateLabels(){
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            
            tagButton.hidden = false
            messageLabel.text = ""
            
            if let placemark = placemark {
                addressLabel.text = stringFromPlacemark(placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for address"
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error finding address"
            } else {
                addressLabel.text = "No address found"
            }
            
            latitudeTextLabel.hidden = false
            longitudeTextLabel.hidden = false
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            
            tagButton.hidden = true
            messageLabel.text = "Tap 'Get Location' to start"
            
            // show that app is trying to obtain a location fix
            
            let statusMessage: String
            if let error = lastLocationError {
                if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location service disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get Location' to start"
            }
            
            latitudeTextLabel.hidden = true
            longitudeTextLabel.hidden = true
            messageLabel.text = statusMessage
        } 
    }
    
    func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var line1 = ""
        line1.addText(placemark.subThoroughfare)
        line1.addText(placemark.thoroughfare, withSeparator: " ")
        
        var line2 = ""
        line2.addText(placemark.locality)
        line2.addText(placemark.administrativeArea, withSeparator: " ")
        line2.addText(placemark.postalCode, withSeparator: " ")
        
        line1.addText(line2, withSeparator: "\n")
        
        return line1
    }
    
    
    // more user- friendly alert
    func showLocationServiceDeniedAlert(){
        let alert = UIAlertController(title: "Location service disabled", message: "Please activate location service for this app in Settings", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            updatingLocation = true
            
            timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: Selector("didTimeOut"), userInfo: nil, repeats: false)
        }
        
    }
    
    // stop updating locations
    func stopLocationManager(){
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer {
                timer.invalidate()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateLabels()
        configureGetButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK : - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Did fail with error \(error)")
        
        if error.code == CLError.LocationUnknown.rawValue {
            return
        }
        
        lastLocationError = nil
        stopLocationManager()
        updateLabels()
        configureGetButton()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("Updated location \(newLocation)")
        
        // 1 - if location was taken long ago (5 sec), ignore it
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        
        // 2 - determine whether new readings are more accurate, use horizontal accuracy
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        // calculates distance between new reading and previous reading
        var distance = CLLocationDistance(DBL_MAX)
        if let location = location {
            distance = newLocation.distanceFromLocation(location)
        }
        
        if location == nil ||
            location!.horizontalAccuracy > newLocation.horizontalAccuracy {
                // 4 - check new location
                lastLocationError = nil
                location = newLocation
                updateLabels()
            
            // 5 - check for desired accuracy
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("We are done!")
                stopLocationManager()
                configureGetButton()
                
                // done recording for this destination
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }
            
            performingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
            
                placemarks, error in
                print("Found placemarks \(placemarks), error: \(error)")
                
                self.lastGeocodingError = error
                if error == nil, let p = placemarks where !p.isEmpty {
                    self.placemark = p.last!
                } else {
                    self.placemark = nil
                }
                
                self.performingReverseGeocoding = false
                self.updateLabels()
                
            })
            // stop if 10 seconds passed
        } else if distance < 1.0 {
            let timeInterval = newLocation.timestamp.timeIntervalSinceDate(location!.timestamp)
            if timeInterval > 10 {
                print("Force done!")
                stopLocationManager()
                updateLabels()
                configureGetButton()
            }
        }
    }
    
    // MARK : - timeOut function for good enough location
    // always called after one minute
    
    func didTimeOut(){
        print("Thime is out!")
        
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            updateLabels()
            configureGetButton()
        }
    }
    
    // get-button func
    
    func configureGetButton(){
        if updatingLocation {
            getButton.setTitle("Stop", forState: .Normal)
        } else {
            getButton.setTitle("Get My Location", forState: .Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
}


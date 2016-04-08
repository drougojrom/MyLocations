//
//  Location.swift
//  MyLocations
//
//  Created by Roman Ustiantcev on 05/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Location: NSManagedObject, MKAnnotation {

// Insert code here to add functionality to your managed object subclass

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
    
    var title: String? {
        if locationDescription.isEmpty {
            return ("No Description")
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String? {
        return category
    }
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoPath: String {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.integerValue).jpg"
        return (applicationDocumentDirectory as NSString).stringByAppendingPathComponent(filename)
    }
    
}

//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 17/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit
import MapKit
import CoreData


@objc(Pin)

class Pin: NSManagedObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(latitude), longitude: Double(longitude))
    }
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var pictures: [Picture]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
//    func setPicturesArray(pictures: [Picture]) {
//        self.pictures = pictures
//        delegate?.pin(self, didUpdatePictures: pictures)
//    }
}




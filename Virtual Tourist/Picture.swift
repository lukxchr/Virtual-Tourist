//
//  Picture.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 25/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import CoreData

@objc(Picture)

class Picture: NSManagedObject, Printable {
    
    
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(downloadURL: String, context: NSManagedObjectContext) {
        //self.imagePath = imagePath
        
        let entity =  NSEntityDescription.entityForName("Picture", inManagedObjectContext: context)!
        
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        let uniqueIdentifier = FlickrAPIClient.identifierFromDownloadURL(downloadURL)
        imagePath = "/\(uniqueIdentifier)"
    }
    
//    init(identifier: String) {
//        imagePath = "/\(identifier)"
//    }
    
    var downloadURL: String {
        //let path: String?
        if let path = imagePath {
            let len = count(path)-1
            let identifier = path[1...len]
            return FlickrAPIClient.downloadURLFromIdentifier(identifier)
        }
        return ""
    }
    
    
    
    var image: UIImage? {
        get {
            return FlickrAPIClient.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            FlickrAPIClient.imageCache.storeImage(newValue, withIdentifier: imagePath!)
        }
    }
}

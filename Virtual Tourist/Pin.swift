//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 17/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit
import MapKit

protocol PinDelegate
{
    //called whenever array of associated pictures is changed
    func pin(pin: Pin, didUpdatePictures pictures: [Picture])
}


class Pin: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var delegate: PinDelegate?
    
    var latitude: Double
    var longitude: Double
    var pictures = [Picture]()
//        {
//        didSet {
//            delegate?.pin(self, didUpdatePictures: pictures)
//        }
//    }
    
    init(latitude: Double, longitude: Double) {
        //self.coordinate = coordinate
        self.latitude = latitude
        self.longitude = longitude
        super.init()
        
        FlickrAPIClient.sharedInstance.getPhotosForCoordinate(latitude: latitude, longitude: longitude) {
            (urls, error) in
            let pictures = urls.map({Picture(downloadURL: $0)})
            self.setPicturesArray(pictures)
        }
    }
    
    func setPicturesArray(pictures: [Picture]) {
        self.pictures = pictures
        delegate?.pin(self, didUpdatePictures: pictures)
    }
    
    func removePicture(atIndexPath indexPath: NSIndexPath) {
        let ix = indexPath.indexAtPosition(1)
        
        //setting image to nil will remove the file from Documents dir
        pictures[ix].image = nil
        
        pictures.removeAtIndex(ix)
        delegate?.pin(self, didUpdatePictures: pictures)
    }
}


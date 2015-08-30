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

class Picture: Printable {
    
    
    var imagePath: String?
    var pin: Pin?
    
    init(downloadURL: String) {
        //self.imagePath = imagePath
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
    
    var description: String {
        return imagePath ?? "no path"
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

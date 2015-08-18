//
//  FlickrAPIClient.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 17/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FlickrAPIClient
{
    static var debugData: NSData? {
        didSet {
            println("debugData set")
            println(debugData)
        }
    }
    
    static var debugURL: String?
    
    //static let sharedInstance = FlickrAPIClient()
    
//    https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=dcb5068aee190f19de1af574115bd94c&lat=40.7449848176185&lon=-74.0517848356299&format=json&nojsoncallback=1
    
    private struct Constants {
        static let baseURL = "https://api.flickr.com/services/rest/"
        static let apiKey = "7bd217c4083a255029f56a7f2b628af1"
        static let secret = "366b27ff3c567f05"
        static let format = "json"
        static let noJSONCallback = 1
    }
    
    private struct Methods {
        static let searchPhotos = "flickr.photos.search"
    }
    
    static func getPhotosForCoordinate(#latitude: Double, longitude: Double) {
        
        let parameters =
            ["method" : Methods.searchPhotos,
            "api_key" : Constants.apiKey,
            "lat" : latitude,
            "lon" : longitude,
            "format" : Constants.format,
            "nojsoncallback" : 1]
        
      
        Alamofire.request(.GET, Constants.baseURL, parameters: parameters as? [String:AnyObject] )
            .responseJSON { request, response, json, error in
                if(error != nil) {
                    NSLog("Error: \(error)")
                    println(request)
                    println(response)
                }
                else {
                    //NSLog("Success: \(url)")
                    let json = JSON(json!)
                    //println(json)
                    let photosArray = json["photos"]["photo"]
                    //println(photosArray)
                    var flickrURLs = [String]()
                    for (index: String, photo: JSON) in photosArray {
                        let farm = photo["farm"]
                        let server = photo["server"]
                        let id = photo["id"]
                        let secret = photo["secret"]
                        let flickrURL = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
                        //println(flickrURL)
                        flickrURLs.append(flickrURL)
                    }
                    //self.getImageDataForFlickrURL(flickrURLs[0])
                    self.debugURL =  flickrURLs[0]
                    
                }
        }
    }
    
    static func getImageDataForFlickrURL(url: String) {
//        let destination = Alamofire.Request.suggestedDownloadDestination(directory: .DocumentDirectory, domain: .UserDomainMask)
//        let downloadRequest = Alamofire.download(.GET, url, destination: destination)
//            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
//                println(totalBytesRead)
//            }
//            .response { request, response, _, error in
//                println(response)
//        }
//        println("downloadRequest \(downloadRequest)")
        
        println(url)
        Alamofire.request(.GET, url).response() {
            (_, _, data, _) in
                println("data from reponse is nil: \(data == nil)")
            
                self.debugData = data
        }
        
    }
    

}
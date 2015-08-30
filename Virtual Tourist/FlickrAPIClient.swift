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
    
    static let sharedInstance = FlickrAPIClient()
    static let imageCache = ImageCache()
    
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
    
    //urls: download urls for <=250 flickr photos with specified latitude and longitude
    //returns Alamofire.request that can be .cancel() if data is not longer needed
    func getPhotosForCoordinate(#latitude: Double, longitude: Double, completionHandler: (urls: [String], error: NSError?) -> Void) {
        
        var parameters: [String:AnyObject] =
            ["method" : Methods.searchPhotos,
            "api_key" : Constants.apiKey,
            "lat" : latitude,
            "lon" : longitude,
            "format" : Constants.format,
            "nojsoncallback" : 1]
        
        
       
        Alamofire.request(.GET, Constants.baseURL, parameters: parameters).responseJSON {
            (_, _, json, _) in
            let json = JSON(json!)
            let numPages = json["photos"]["pages"].int ?? 1 //if something went wrong when parsing json assume there's just one page
            let randomPage = Int(arc4random_uniform(UInt32(numPages)))
            println("randomPage=\(randomPage)")
            parameters["page"] = randomPage
            
            Alamofire.request(.GET, Constants.baseURL, parameters: parameters)
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
                        //shuffle array
                        flickrURLs.sort() {_, _ in arc4random() % 2 == 0}
                        completionHandler(urls: flickrURLs, error: error)
                    }
            }
        }
        
      
        
    }
    
    //returns Alamofire.request that can be .cancel() if image is not longer needed
    func getImageDataForFlickrURL(url: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> Alamofire.Request {
        return Alamofire.request(.GET, url).response() {
            (_, _, data, error) in
                completionHandler(imageData: data, error: error)
        }
    }
    
    //MARK: Helper
    //functions below convert between downloadURLs (used to download image from flickr) and unique identifiers (used as file names)
    //example downloadURL: https://farm1.staticflickr.com/768/20889510575_188ba59bfd.jpg
    //corresponding unique identifier: 1_768_20889510575_188ba59bfd.jpg
    static func downloadURLFromIdentifier(identifier: String) -> String {
        let elements = split(identifier) { $0 == "_" }
        let downloadURL =  "https://farm\(elements[0]).staticflickr.com/\(elements[1])/\(elements[2])_\(elements[3])"
        return downloadURL
    }
    
    static func identifierFromDownloadURL(url: String) -> String {
        let elements = split(url) { $0 == "/" }
        let farm = elements[1][4]
        let identifer = "\(farm)_\(elements[2])_\(elements[3])"
        return identifer
    }
    
}
//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 17/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import Alamofire

extension Photo {
    static let debugLoggingEnabled = false
    func p(sth: String) {
        if !Photo.debugLoggingEnabled { return }
        println(sth)
    }
}


class Photo
{
    private var state: State {
        didSet {
            switch state {
            case .WaitingForImage:
                p("state changed to WaitingForImage")
                activityIndicator.startAnimating()
                imageView.image = UIImage.imageWithColor(UIColor.grayColor())
            case .ImageDownloaded:
                p("state changed to ImageDownloaded")
                activityIndicator.stopAnimating()
                if let path = self.filePath {
                    p("Path when reading= \(path)")
                    let data = NSData(contentsOfURL: path)
                    imageView.image = UIImage(data: data!)
                } else {
                    state = .FailedToDownloadImage
                }
            case .FailedToDownloadImage:
                p("state changed to FailedToDownloadImage")
                activityIndicator.stopAnimating()
                imageView.image = UIImage.imageWithColor(UIColor.redColor())
            }
        }
    }
    
    private let downloadURL: String
    //reference to image download request (can call cancel if image is not longer needed)
    var request: Alamofire.Request!
    
    private var fileName: String!
    //appends fileName to the DocumentDirectory's path
    private var filePath: NSURL? {
        let fileManager = NSFileManager()
        if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
            return docsDir.URLByAppendingPathComponent("\(self.fileName)")
        } else {
            return nil
        }
      
    }
    //reference to imageView in which display placeholder and then downloaded image
    var imageView: UIImageView!
    
    private let activityIndicator: UIActivityIndicatorView!
    
    private func downloadImage() {
        p("Started downloading image")
        request = Alamofire.request(.GET, self.downloadURL)
        request.response() {
            (_, _, data, error) in
            if error != nil {
                self.p("Failed to download image")
                self.state = .FailedToDownloadImage
                return
            }
            //save received data in DocumentDirectory
            let fileManager = NSFileManager()
            if let docsDir = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as? NSURL {
                let uniqueName = NSDate.timeIntervalSinceReferenceDate()
                let url = docsDir.URLByAppendingPathComponent("\(uniqueName)")
                if let path = url.absoluteString {
                    if data!.writeToURL(url, atomically: true) {
                        self.p("Path when writing= \(url)")
                        self.fileName = "\(uniqueName)"
                        self.state = .ImageDownloaded
                        self.p("Image downloaded successfully")
                        return
                    }
                }
            }
            assert(self.fileName == nil)
            self.state = .FailedToDownloadImage
        }
    }
    
    init(downloadURL: String, imageView: UIImageView) {
        self.downloadURL = downloadURL
        state = .WaitingForImage
        self.imageView = imageView
        
        //add spinning wheel in the centre of the UIImageView
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = CGPointMake(imageView.bounds.size.width / 2,
        imageView.bounds.size.height / 2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        imageView.addSubview(activityIndicator)
        
        //additional setup since didSet is not called when properties are set from the initilizer
        imageView.image = UIImage.imageWithColor(UIColor.grayColor())
        
        downloadImage()
    }
    
    private enum State {
        case WaitingForImage //request or saving to file in progress
        case ImageDownloaded //sucessfully downloaded and saved to file
        case FailedToDownloadImage //failed to download or save to file
    }
}

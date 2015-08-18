//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 17/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewController: UIViewController
{
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func refresh(sender: UIButton) {
        var url = FlickrAPIClient.debugURL ?? ""
        if arc4random_uniform(10) > 5 {
            url = "invalid_url"
        }
        //let img = UIImage(contentsOfFile: "19932562451_0895c2e8eb.jpg")
        let photo = Photo(downloadURL: url, imageView: imageView)
        //photo.request.cancel()
        //imageView.image = photo.image!
//        println("data is nil: \(data == nil)")
//        if let data = data {
//            let img = UIImage(data: data)
//            imageView.image = img
//        }

    }
    
    @IBAction func printDocuments() {
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // now lets get the directory contents (including folders)
        if let directoryContents =  NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsUrl.path!, error: nil) {
            println(directoryContents)
        }
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            println(directoryUrls)
        }
    }
    
    
}
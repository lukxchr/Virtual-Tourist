//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 17/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate
{
    
    var pin: Pin!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //set in viewDidLoad; reloads collectionView, deals with a situtation when user drops a new pin a clicks on it i.e. moves to corresponding photo collection view before urls of pictures for given location are downloaded
    var reloadTimer: NSTimer?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        reloadTimer?.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "reload", userInfo: nil, repeats: true)
    }
    
    // MARK: - UICollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.pictures.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        configureCell(cell, withPicture: pin.pictures[indexPath.indexAtPosition(1)])
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let picture = self.pin.pictures[indexPath.indexAtPosition(1)]
        picture.image = nil
        //delete persisted picture
        sharedContext.deleteObject(picture)
        sharedContext.save(nil)
        //delete cell with nice animation
        collectionView.deleteItemsAtIndexPaths([indexPath])
    }
    
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCell, withPicture picture: Picture) {
        if let localImage = picture.image {
            cell.imageView.image = localImage
        }
        else if picture.imagePath == nil || picture.imagePath == "" {
            cell.imageView.image = UIImage.imageWithColor(UIColor.grayColor())
        }
        else {
            //set placeholder while the image is being downloaded
            cell.imageView.image = UIImage.imageWithColor(UIColor.grayColor())
            cell.activityIndicator.startAnimating()
            
            let downloadURL = picture.downloadURL
            
            let request = FlickrAPIClient.sharedInstance.getImageDataForFlickrURL(downloadURL) {
                (data, _) in
                if data == nil { return }
                let image = UIImage(data: data!)
                picture.image = image //stores on the disk
                cell.imageView.image = image
                cell.activityIndicator.stopAnimating()
          
            }
            cell.requestToCancel = request
        }
    }
    
    @IBAction func newCollection(sender: UIBarButtonItem) {
        
        //delete current photos
        let pictures = self.pin.pictures
        for picture in pictures {
            picture.image = nil
            sharedContext.deleteObject(picture)
        }
        sharedContext.save(nil)
        
        //get new photos
        let latitude = Double(self.pin.latitude)
        let longitude = Double(self.pin.longitude)
        FlickrAPIClient.sharedInstance.getPhotosForCoordinate(latitude: latitude, longitude: longitude) {
            (urls, error) in
            
            let pictures = urls.map({Picture(downloadURL: $0, context: self.sharedContext)})
            //println("\(pictures.count) pictures for this pin")
            
            for picture in pictures {
                picture.pin = self.pin
                picture.image = nil
            }
            
            var error: NSError?
            self.sharedContext.save(&error)
            if error != nil {
                println("Error while adding pin")
            }
            
            self.collectionView.reloadData()
        }
    }
    
    //delete pin and all photos
    @IBAction func deleteCurrentPin(sender: UIBarButtonItem) {
    
        let pictures = self.pin.pictures
        //setting image to nil deletes file
        for picture in pictures {
            picture.image = nil
        }
        //delete pin and all associates Pictures from CoreData        
        sharedContext.deleteObject(self.pin)
        sharedContext.save(nil)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func reload() {
        collectionView.reloadData()
        //no need to keep reloading if already loaded pictures
        if !self.pin.pictures.isEmpty {
            reloadTimer?.invalidate()
        }
    }
    
    
}
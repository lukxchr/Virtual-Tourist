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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
            sharedContext.deleteObject(picture)
        }
        sharedContext.save(nil)
        
        //get new photos
        let latitude = Double(self.pin.latitude)
        let longitude = Double(self.pin.longitude)
        FlickrAPIClient.sharedInstance.getPhotosForCoordinate(latitude: latitude, longitude: longitude) {
            (urls, error) in
            
            let pictures = urls.map({Picture(downloadURL: $0, context: self.sharedContext)})
            println("\(pictures.count) pictures for this pin")
            
            for picture in pictures {
                picture.pin = self.pin
            }
            
            var error: NSError?
            self.sharedContext.save(&error)
            if error != nil {
                println("Error while adding pin")
            }
            
            self.collectionView.reloadData()
        }
    }
    
  
    //MARK: debug
    func pin(pin: Pin, didUpdatePictures pictures: [Picture]) {
        self.collectionView.reloadData()
        println("didUpdatePictures delegate method called")
    }
    
    
    @IBAction func re(sender: AnyObject) {
        //println("first one in pictures array: \(self.pin?.pictures[0])")
        collectionView.reloadData()
    }
    
    
}
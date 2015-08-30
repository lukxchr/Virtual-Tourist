//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 17/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit
//d
import Alamofire

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PinDelegate
{
    
    var pin: Pin!
    
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
        pin.delegate = self
    }
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
//        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.pictures.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
      
        configureCell(cell, withPicture: pin.pictures[indexPath.indexAtPosition(1)])
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("selected cell at indexPath=\(indexPath)")
        //collectionView.deleteItemsAtIndexPaths([indexPath])
        //deleteCell(atIndex: indexPath)
        self.countDocuments()
        self.pin.pictures[indexPath.indexAtPosition(1)].image = nil
        self.pin.pictures.removeAtIndex(indexPath.indexAtPosition(1))
        self.countDocuments()
    }
    
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCell, withPicture picture: Picture) {
        
//        println("configureCell thr_m: \(NSThread.isMainThread())")
    
        
//        cell.imageView.image = UIImage.imageWithColor(UIColor.grayColor())
        
        
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
        
        
//        cell.imageView.image = UIImage.imageWithColor(UIColor.blackColor())
        
    }
    
    
    @IBAction func newCollection(sender: UIBarButtonItem) {
        
        //self.pin.pictures = [Picture]()
        //self.collectionView.reloadData()
        //println("_newCollection_: \(NSThread.currentThread())")
        
        FlickrAPIClient.sharedInstance.getPhotosForCoordinate(latitude: self.pin.latitude, longitude: self.pin.longitude) {
            (urls, error) in
            self.pin.pictures = urls.map({Picture(downloadURL: $0)})
            //self.collectionView.reloadData()
            
        }
    }
    
    func pin(pin: Pin, didUpdatePictures pictures: [Picture]) {
        self.collectionView.reloadData()
        println("didUpdatePictures delegate method called")
    }
    
    
    @IBAction func re(sender: AnyObject) {
        println("first one in pictures array: \(self.pin?.pictures[0])")
        collectionView.reloadData()
    }
    
    
}
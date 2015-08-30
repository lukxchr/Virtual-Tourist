//
//  TravelLocationsMapView.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 16/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit
import MapKit
//debug
import Alamofire
import SwiftyJSON



class TravelLocationsMapView: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadMapRegion()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //debug
        //FlickrAPIClient.getPhotosForCoordinate(latitude: 40.7449848176185, longitude: -74.0517848356299)
        
        // We need just to get the documents folder url
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // now lets get the directory contents (including folders)
        if let directoryContents =  NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsUrl.path!, error: nil) {
            println("documents count: \(directoryContents.count)")
        }
        // if you want to filter the directory contents you can do like this:
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            //println(directoryUrls)
        }
    }
    
    //MARK: mapView delegate methods
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? Pin {
            let identifier = "pin"
            let view: MKPinAnnotationView
            if let deququedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
                deququedView.annotation = annotation
                view = deququedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.pinColor = .Purple
                view.animatesDrop = true
            }
            return view
        }
        return nil
    }

    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        //deselct so that this method gets called again if user goes back from photo collection
        //and clicks on the same annotation view
        mapView.deselectAnnotation(view.annotation, animated: false)
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoCollectionViewController") as! PhotoCollectionViewController
        vc.pin = view.annotation as! Pin
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
//        println("deselected \(view.annotation.coordinate.latitude)")
//        
//    }
    
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
        println("saveMapRegion()")
    }
    
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        //println("Long tap detected!")
        
//        let touchPoint = sender.locationInView(self.mapView)
//        let mapLocation = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
//        
//        let newAnnotation = MKPointAnnotation()
//        newAnnotation.coordinate = mapLocation
//        mapView.addAnnotation(newAnnotation)
        
        switch sender.state {
        case .Changed: fallthrough
        case .Ended:
            //println("_Long tap detected!")
            let touchPoint = sender.locationInView(self.mapView)
            let mapLocation = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            //let newAnnotation = MKPointAnnotation()
            let latitude = mapLocation.latitude
            let longitude = mapLocation.longitude
            let newAnnotation = Pin(latitude: latitude, longitude: longitude)
            //let newAnnotation = MKPinAnnotationView()
            //newAnnotation.coordinate = mapLocation
            mapView.addAnnotation(newAnnotation)
        default: break
        }
        
    }
    
    private func saveMapRegion() {
        let region = mapView.region
        
        let centerLatitude = region.center.latitude as Double
        let centerLongitude = region.center.longitude as Double
        let latitudeDelta = region.span.latitudeDelta as Double
        let longitudeDelta = region.span.longitudeDelta as Double
        
        //let defaults = NSUserDefaults.standardUserDefaults().defaults //setFloat(22.5 forKey: “myValue”)
        NSUserDefaults.standardUserDefaults().setDouble(centerLatitude, forKey: "centerLatitude")
        NSUserDefaults.standardUserDefaults().setDouble(centerLongitude, forKey: "centerLongitude")
        NSUserDefaults.standardUserDefaults().setDouble(latitudeDelta, forKey: "latitudeDelta")
        NSUserDefaults.standardUserDefaults().setDouble(longitudeDelta, forKey: "longitudeDelta")
    }
    
    private func loadMapRegion() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        //use objectForKey (returns nil if key doesn't exist) instead of doubleForKey (throws expecption)
        if let centerLatitude = defaults.objectForKey("centerLatitude") as? Double,
            centerLongitude = defaults.objectForKey("centerLongitude") as? Double,
            latitudeDelta = defaults.objectForKey("latitudeDelta") as? Double,
            longitudeDelta = defaults.objectForKey("longitudeDelta") as? Double {
                mapView.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude),
                    span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        }
    }
    
    
    @IBAction func del(sender: AnyObject) {
//        NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        // now lets get the directory contents (including folders)
        if let directoryContents =  NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsUrl.path!, error: nil) {
            println("documents count: \(directoryContents.count)")
        }
    }
    

}


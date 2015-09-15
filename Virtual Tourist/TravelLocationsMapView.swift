//
//  TravelLocationsMapView.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 16/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        loadMapRegion()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        fetchPins()
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
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .Changed: fallthrough
        case .Ended:
            let touchPoint = sender.locationInView(self.mapView)
            let mapLocation = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            let latitude = mapLocation.latitude
            let longitude = mapLocation.longitude
            addPin(latitude: latitude, longitude: longitude)
        default: break
        }
    }
    
    private func saveMapRegion() {
        let region = mapView.region
        let centerLatitude = region.center.latitude as Double
        let centerLongitude = region.center.longitude as Double
        let latitudeDelta = region.span.latitudeDelta as Double
        let longitudeDelta = region.span.longitudeDelta as Double
        
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
    
    private func addPin(#latitude: Double, longitude: Double) {
        let pin = Pin(latitude: latitude, longitude: longitude, context: sharedContext)
        mapView.addAnnotation(pin)
        
        FlickrAPIClient.sharedInstance.getPhotosForCoordinate(latitude: latitude, longitude: longitude) {
                (urls, error) in
            let pictures = urls.map({Picture(downloadURL: $0, context: self.sharedContext)})
            println("\(pictures.count) pictures for this pin")
            
            for picture in pictures {
                picture.pin = pin
            }
            
            var error: NSError?
            self.sharedContext.save(&error)
            if error != nil {
                println("Error while adding pin")
            }
        }
    }
    
    private func fetchPins() {
        let request = NSFetchRequest(entityName: "Pin")
        var error: NSError?
        let pins = sharedContext.executeFetchRequest(request, error: &error) as! [Pin]
        
        println("Fetched \(pins.count) pins")
        
        mapView.addAnnotations(pins)
        if error != nil {
            println("Error while fetching pins")
        }
        
        
        let req = NSFetchRequest(entityName: "Picture")
        let pics = sharedContext.executeFetchRequest(req, error: nil)
        println("# all pics fetched: \(pics?.count)")
    }
    
    
    @IBAction func del(sender: AnyObject) {
        
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        if let directoryContents =  NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentsUrl.path!, error: nil) {
            println("documents count: \(directoryContents.count)")
        }
    }
    

}


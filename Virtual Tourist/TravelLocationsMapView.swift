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
//    var mapRegion: MKCoordinateRegion {
//        return mapView.region
//    }
    
//    var mapRegionFilePath : String {
//        let manager = NSFileManager.defaultManager()
//        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
//        return url.URLByAppendingPathComponent("mapRegion").path!
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        loadMapRegion()
        //println(mapRegionFilePath)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        println("selected \(view.annotation.coordinate.latitude)")
    }
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
        println("saveMapRegion()")
    }
    
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        println("Long tap detected!")
        
//        let touchPoint = sender.locationInView(self.mapView)
//        let mapLocation = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
//        
//        let newAnnotation = MKPointAnnotation()
//        newAnnotation.coordinate = mapLocation
//        mapView.addAnnotation(newAnnotation)
        
        switch sender.state {
        case .Changed: fallthrough
        case .Ended:
            println("_Long tap detected!")
            let touchPoint = sender.locationInView(self.mapView)
            let mapLocation = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = mapLocation
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
        
        //use objectForKey (returns nil if key doesn't exist)and as? instead of doubleForKey (throws expecption)
        if let centerLatitude = defaults.objectForKey("centerLatitude") as? Double,
            centerLongitude = defaults.objectForKey("centerLongitude") as? Double,
            latitudeDelta = defaults.objectForKey("latitudeDelta") as? Double,
            longitudeDelta = defaults.objectForKey("longitudeDelta") as? Double {
                mapView.region = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude),
                    span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        }
        
        
        
    }


}


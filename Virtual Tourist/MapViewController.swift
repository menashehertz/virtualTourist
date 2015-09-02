//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Steven Hertz on 9/2/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    

    // MARK: - Life Cycle
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreMapRegion(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        
        // Did this because the the Began state also fired off this function
        if sender.state == .Ended {
            
            let location = sender.locationInView(self.mapView)
            let locCoord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = locCoord
            annotation.title = "Store"
            annotation.subtitle = "Anything"
            
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    // MARK: - Save the zoom level helpers
    
    
    // A convenient property
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    
    // This gets fired off when the focus or region of the map changes
    func saveMapRegion() {
        
        // Place the "center" and "span" of the map into a dictionary
        // The "span" is the width and height of the map in degrees.
        // It represents the zoom level of the map.
        
        let dictionary = [
            "latitude" : mapView.region.center.latitude,
            "longitude" : mapView.region.center.longitude,
            "latitudeDelta" : mapView.region.span.latitudeDelta,
            "longitudeDelta" : mapView.region.span.longitudeDelta
        ]
        
        // Archive the dictionary into the filePath
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    
    // This gets fired off in viewDidLoad (or maybe When coming in this screen)
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        if let regionDictionary = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [String : AnyObject] {
            
            let longitude = regionDictionary["longitude"] as! CLLocationDegrees
            let latitude = regionDictionary["latitude"] as! CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = regionDictionary["latitudeDelta"] as! CLLocationDegrees
            let latitudeDelta = regionDictionary["longitudeDelta"] as! CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            println("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
        }
    }
    
}
    /**
    *  This extension comforms to the MKMapViewDelegate protocol. This allows
    *  the view controller to be notified whenever the map region changes. So
    *  that it can save the new region.
    */
    
    extension MapViewController : MKMapViewDelegate {
        
        func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
            saveMapRegion()
        }
        
        // Setup the pins on the map
        func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
            
            let reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.animatesDrop = true
                // pinView!.canShowCallout = true
                pinView!.pinColor = .Green
                // pinView!.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
            }
            else {
                pinView!.annotation = annotation
            }
            println("did a pin")
            return pinView
        }
        
        func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            println("pin clicked")
            
            
                // Instantiate the ViewController Screen Using Storyboard ID
                let pictureCollectionViewController = storyboard!.instantiateViewControllerWithIdentifier("showpictures") as! PictureCollectionViewController
                pictureCollectionViewController.msgText = "Yes from me"
                
                // Create a UINavigationController object and push the "nextScreenViewController"
                let nextScreenNavigationController = UINavigationController()
                
                // Push on stack
                nextScreenNavigationController.pushViewController(pictureCollectionViewController, animated: false)
                
                // present the navigation View Controller
                presentViewController(nextScreenNavigationController, animated: true, completion: nil)
                

            
           // view.annotation
            //let pin = view.annotation as! Pin
            //performSegueWithIdentifier("showAlbum", sender: view.annotation)
        }
        
        
        // Responds to taps. It opens the system browser to the URL specified in the annotationViews subtitle property.
        //        func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //
        //            if control == annotationView.rightCalloutAccessoryView {
        //                let app = UIApplication.sharedApplication()
        //                app.openURL(NSURL(string: annotationView.annotation.subtitle!)!)
        //            }
        //        }
        //
        

    
}






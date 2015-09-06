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

    // MARK: - Variables
    
    var pin: MKAnnotationView!

        
    // A filepath property
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    // MARK: - Screen Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restoreMapRegion(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       // navigationController!.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // navigationController!.navigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Screen Actions

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
    
    
    // MARK: - What to do result of getting photos
    
    func gotoNextScreen() {
        // Instantiate the ViewController Screen Using Storyboard ID
        let pictureCollectionViewController = storyboard!.instantiateViewControllerWithIdentifier("showpictures") as! PictureCollectionViewController
        pictureCollectionViewController.pin = pin
        
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
    
    func displayError(errorString: String?) {
        if let errorString = errorString {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                let action = UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: {(paramAction:UIAlertAction!) in println("The Done button was tapped - " + paramAction.title)})
                
                alertController.addAction(action)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
        }
    }
    
    
    // MARK: - Save and Restore the map focus and region
    
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
        
        // MARK: - Extension to conform to MapViewDelegate
        
        // save the map info when user changes it
        func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
            saveMapRegion()
        }
        
        // Customize the pin going on to the map
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
            var newPin = Pin(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
            println("did a pin")
            return pinView
        }
        
        // React to a pin click
        func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
            mapView.deselectAnnotation(view.annotation, animated: false)
            println("pin clicked \(view.annotation.coordinate.latitude)")
            
            
            Flickr.oneSession.latitude  = view.annotation.coordinate.latitude
            Flickr.oneSession.longitude = view.annotation.coordinate.longitude
            
            pin = view
            
            Flickr.oneSession.getImageFromFlickr(){ (success, errorString) in
                if success {
                    self.gotoNextScreen()
                } else {
                    self.displayError(errorString)
                }
            }
        }

        
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
           //     var vc = segue.destinationViewController.childViewControllers[0] as! AlbumViewController
            //    vc.pin = sender as! Pin
                println("in prepare for seg")
            }
        

        

    
}






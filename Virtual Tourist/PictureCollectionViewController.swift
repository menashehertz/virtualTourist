//
//  PictureCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Steven Hertz on 9/2/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PictureCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {

    
    var pin: MKAnnotationView!
    var currentPin: Pin!
    
    // A filepath property
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    // shared context property
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    // MARK: - Screen Outlets

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: - Screen Actions
    
    @IBAction func button(sender: AnyObject) {
        
        // theImage.image = UIImage(named: "zxc")
    }

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        println("this is from pin \(pin.annotation.coordinate.latitude)")
        println("this is from currnt pin number of photos \(currentPin.photos.count)")
        println("this is from current pin latitude \(currentPin.latitude)")

        restoreMapRegion(false)

        self.navigationItem.title = "the pictures"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "⬅︎OK", style: .Plain, target: self, action: "cancelAuth")
        
       // Flickr.oneSession.latitude  = 27.9881
       // Flickr.oneSession.longitude = 86.9253
       // Flickr.oneSession.getImageFromFlickr()
        //println("number of photos \(Flickr.oneSession.listofPhotos.count)")

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Core Data Convenience
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    // MARK: - Restore Map region
    
    // This gets fired off in viewDidLoad (or maybe When coming in this screen)
    func restoreMapRegion(animated: Bool) {
        
        // if we can unarchive a dictionary, we will use it to set the map back to its
        // previous center and span
        
        
        
        // add the map pin
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = pin.annotation.coordinate
        annotation.title = "Store"
        annotation.subtitle = "Anything"
        
        self.mapView.addAnnotation(annotation)

        
        // mapView.addAnnotation(pin as! MKAnnotation)

//
            let longitude = pin.annotation.coordinate.longitude as CLLocationDegrees
            let latitude = pin.annotation.coordinate.latitude as CLLocationDegrees
            let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let longitudeDelta = 10 as CLLocationDegrees
            let latitudeDelta =  12 as CLLocationDegrees
            let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            
            let savedRegion = MKCoordinateRegion(center: center, span: span)
            
            println("lat: \(latitude), lon: \(longitude), latD: \(latitudeDelta), lonD: \(longitudeDelta)")
            
            mapView.setRegion(savedRegion, animated: animated)
//        }
    }
    
    
    func cancelAuth() {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    // MARK: - CollectionView functions
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentPin.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        // var label = cell.viewWithTag(1) as! UILabel
        //label.text = Flickr.oneSession.listofPhotos[indexPath.row].title
        
        var img = cell.viewWithTag(2) as! UIImageView
        let myPhoto = currentPin.photos[indexPath.row]
        img.image = myPhoto.photoImage

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("did select this number \(indexPath.row)")
        let myPhoto = currentPin.photos[indexPath.row]
        myPhoto.pin = nil
        collectionView.deleteItemsAtIndexPaths([indexPath])
        
        sharedContext.deleteObject(myPhoto)
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    
}


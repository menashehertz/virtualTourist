//
//  PictureCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Steven Hertz on 9/2/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import UIKit
import MapKit

class PictureCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {

    
    
    var pin: MKAnnotationView!

    
    // A filepath property
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("mapRegionArchive").path!
    }
    
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    @IBAction func button(sender: AnyObject) {
        
        // theImage.image = UIImage(named: "zxc")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        println("this is from pin \(pin.annotation.coordinate.latitude)")

        restoreMapRegion(false)

        self.navigationItem.title = "the pictures"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "⬅︎OK", style: .Plain, target: self, action: "cancelAuth")
        
       // Flickr.oneSession.latitude  = 27.9881
       // Flickr.oneSession.longitude = 86.9253
       // Flickr.oneSession.getImageFromFlickr()
        println("number of photos \(Flickr.oneSession.listofPhotos.count)")

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Flickr.oneSession.listofPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        var label = cell.viewWithTag(1) as! UILabel
        label.text = Flickr.oneSession.listofPhotos[indexPath.row].title
        
        var img = cell.viewWithTag(2) as! UIImageView
        img.image = Flickr.oneSession.listofPhotos[indexPath.row].photoImage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("did select this number \(indexPath.row)")
        Flickr.oneSession.listofPhotos.removeAtIndex(indexPath.row)
        collectionView.deleteItemsAtIndexPaths([indexPath])
    }
    

    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


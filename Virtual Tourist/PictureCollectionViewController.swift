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

class PictureCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
    NSFetchedResultsControllerDelegate {
    
    var pinMK: MKAnnotationView!
    var pin: Pin!
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    
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
    
    // Mark: - Fetched Results Controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    

    
    // MARK: - Screen Outlets
    
    @IBOutlet weak var activityInd: UIActivityIndicatorView!

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionPic: UICollectionView!
    
    // MARK: - Screen Actions
    
    @IBAction func button(sender: AnyObject) {
        //collectionPic.hidden = true
        let pinPhotoArray = pin.photos
       
        for pinPhoto in pinPhotoArray{
            pinPhoto.pin = nil
            //collectionView.deleteItemsAtIndexPaths([indexPath])
            pinPhoto.deleteImage()
            sharedContext.deleteObject(pinPhoto)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        //collectionPic.hidden = false
        Flickr.oneSession.getImageFromFlickr(pin){ (success, errorString) in
            if success {
                println("From button - Got the FlickR data")
                self.collectionPic.reloadData()
            } else {
                println("From button - didn't get FlickR data")
            }
        }

        
        
        
        // theImage.image = UIImage(named: "zxc")
    }

    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        println("this is from pin \(pinMK.annotation.coordinate.latitude)")
        println("this is from currnt pin number of photos \(pin.photos.count)")
        println("this is from current pin latitude \(pin.latitude)")

        restoreMapRegion(false)

        self.navigationItem.title = "Pictures"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "⬅︎OK", style: .Plain, target: self, action: "cancelAuth")
        
        // Start the fetched results controller
        var error: NSError?
        fetchedResultsController.performFetch(&error)
        
        if let error = error {
            println("Error performing initial fetch: \(error)")
        }
        fetchedResultsController.delegate = self
        
        // activityInd.startAnimating()


        
        
        
       // Flickr.oneSession.latitude  = 27.9881
       // Flickr.oneSession.longitude = 86.9253
       // Flickr.oneSession.getImageFromFlickr()
        //println("number of photos \(Flickr.oneSession.listofPhotos.count)")

        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // do not get new pictures if there are saved old ones
        if pin.photos.count < 1 {
            Flickr.oneSession.getImageFromFlickr(pin){ (success, errorString) in
                if success {
                    println("From button - Got the FlickR data")
                    dispatch_async(dispatch_get_main_queue()){
                        self.collectionPic.reloadData()
                    }
                } else {
                    println("From button - didn't get FlickR data")
                }
            }
        }
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
        
        annotation.coordinate = pinMK.annotation.coordinate
        annotation.title = "Store"
        annotation.subtitle = "Anything"
        
        self.mapView.addAnnotation(annotation)

        
        // mapView.addAnnotation(pin as! MKAnnotation)

//
            let longitude = pinMK.annotation.coordinate.longitude as CLLocationDegrees
            let latitude = pinMK.annotation.coordinate.latitude as CLLocationDegrees
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        
        println("number Of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! UICollectionViewCell
        // var label = cell.viewWithTag(1) as! UILabel
        //label.text = Flickr.oneSession.listofPhotos[indexPath.row].title
        
        var img = cell.viewWithTag(2) as! UIImageView
        img.image = UIImage(named: "placeHolder")

        // Here is how to replace the actors array using objectAtIndexPath
        let myPhoto = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        img.image = myPhoto.photoImage
        if myPhoto.photoImage != nil {
            println("***** the photo not nil")
        } else {
            println("----- the photo  nil")           
        }

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("did select this number \(indexPath.row)")
        
        // Here is how to replace the actors array using objectAtIndexPath
        let myPhoto = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        //let myPhoto = currentPin.photos[indexPath.row]

        // myPhoto.pin = nil
        // collectionView.deleteItemsAtIndexPaths([indexPath])
        myPhoto.deleteImage()
        
        sharedContext.deleteObject(myPhoto)
        CoreDataStackManager.sharedInstance().saveContext()
        
    }
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        println("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            println("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            println("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            println("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            println("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        println("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionPic.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionPic.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionPic.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionPic.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
    }
    
    
    
    
}


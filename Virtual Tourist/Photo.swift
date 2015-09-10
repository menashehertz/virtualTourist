//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Steven Hertz on 9/2/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import UIKit
import Foundation
import CoreData

@objc(Photo)

class Photo: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var url: String
    @NSManaged var id: String
    
    
    /// The associated pin
    @NSManaged var pin: Pin?
    


    // var img : UIImage!  not sure maybe this should be a calculated field
    
    // 5. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init( photoDictionary:[String: AnyObject], context: NSManagedObjectContext) {
        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        

        self.title = photoDictionary["title"] as! String
        self.url =  photoDictionary["url_m"] as! String
        self.id = photoDictionary["id"] as! String
    }
    
    var actualFileName: String {
        get{
            return self.url.lastPathComponent
        }
    }

    
    var photoImage: UIImage? {
        get {
            let path = pathForIdentifier(actualFileName)
            return UIImage(contentsOfFile: path)
        }
        set {
           storeImage(newValue, withIdentifier: actualFileName)
        }
    }
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        // If the identifier is nil, or empty, return nil
        if identifier == nil || identifier! == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        var data: NSData?

        // Next Try the hard drive
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    // MARK: - Saving images
    
    func doesItExist() {
        let path = pathForIdentifier(actualFileName)
        println("the poster path is \(path) ")
        let filemgr = NSFileManager.defaultManager()
        if filemgr.fileExistsAtPath(path) {
            println("-- **Executing doesItExist and File exists")
        } else {
            println("-- **Executing doesItExist and File not found")
        }

    }
    
    
    // MARK: - Saving images
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        println("the poster path is \(path) ")
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
    }

    // MARK: - Saving images
    
    func deleteImage() {
        let path = pathForIdentifier(actualFileName)
        println("the poster path to delete is \(path) ")
        
        // And in documents directory
        let filemgr = NSFileManager.defaultManager()
        var error: NSError?
        
        if filemgr.removeItemAtPath(path, error: &error) {
            println("Remove successful")
        } else {
            println("Remove failed: \(error!.localizedDescription)")
        }
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }

}

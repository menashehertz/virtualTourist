//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Steven Hertz on 9/2/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import UIKit
import Foundation

class Photo {
    var title: String
    var url: String
    var id: String

    // var img : UIImage!  not sure maybe this should be a calculated field
    
    init( photoDictionary:[String: AnyObject]) {
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
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        let path = pathForIdentifier(identifier)
        println("the poster path is \(path) ")
        
        // And in documents directory
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
    }
    
    // MARK: - Helper
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }

}

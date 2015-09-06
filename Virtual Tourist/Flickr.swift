//
//  Flickr.swift
//  SleepingInTheLibrary
//
//  Created by Steven Hertz on 9/2/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit
import CoreData


let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "b611588e1ecf600ab10d88c0d36e99bd"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let BOUNDING_BOX_HALF_WIDTH = 0.5
let BOUNDING_BOX_HALF_HEIGHT = 0.5
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0


class Flickr {
    
    static let oneSession = Flickr()
    
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    
    var listofPhotos = [Photo]()
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }

    
    
    func getImageFromFlickr(pin: Pin, completionHandler: ( success: Bool, errorString: String) -> Void) {
        
        /* 2 - API method arguments */
        let methodArguments = [
            "method": METHOD_NAME,
            "api_key": API_KEY,
            "bbox": createBoundingBoxString(),
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                /* 5 - Success! Parse the data */
                var parsingError: NSError? = nil
                let parsedResult: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
                
                if let photosDictionary = parsedResult.valueForKey("photos") as? NSDictionary {
                    if let photoArray = photosDictionary.valueForKey("photo") as? [[String: AnyObject]] {
                        var numOfPicsCntr = 0
                        // TODO: - Need to release the phot objects when deleting the array
                        self.listofPhotos.removeAll(keepCapacity: false)
                        for photoDictionary in photoArray {
                            numOfPicsCntr++
                            if numOfPicsCntr > 26 {
                                break
                            }
//                            println("the dict \(photoDictionary)")
//                            println(photoDictionary["title"] as? String)
//                            println(photoDictionary["url_m"] as? String)
//                            println(photoDictionary["id"] as? String)
                            var newPhoto = Photo(photoDictionary: photoDictionary, context: self.sharedContext)
                            
                            let imageURL = NSURL(string: (photoDictionary["url_m"] as? String)!)
                            if let imageData = NSData(contentsOfURL: imageURL!) {
                                newPhoto.photoImage = UIImage(data: imageData)
                            }
                            newPhoto.pin = pin
                            self.listofPhotos.append(newPhoto)
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                        
                        completionHandler(success: true, errorString: "everything good" )
                        // TODO: - Need to clean up the code

                        
//                        /* 6 - Grab a single, random image */
//                        let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
//                        let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
//                        
//                        /* 7 - Get the image url and title */
//                        let photoTitle = photoDictionary["title"] as? String
//                        let imageUrlString = photoDictionary["url_m"] as? String
//                        let imageURL = NSURL(string: imageUrlString!)
                        
                        /* 8 - If an image exists at the url, set the image and title */
//                        if let imageData = NSData(contentsOfURL: imageURL!) {
//                            dispatch_async(dispatch_get_main_queue(), {
//                                //                                self.photoImageView.image = UIImage(data: imageData)
//                                //                                self.photoTitle.text = photoTitle
//                            })
//                        } else {
//                            println("Image does not exist at \(imageURL)")
//                        }
                    } else {
                        println("Cant find key 'photo' in \(photosDictionary)")
                        completionHandler(success: false, errorString: "Cant find key 'photo' in \(photosDictionary)")
                    }
                } else {
                    println("Cant find key 'photos' in \(parsedResult)")
                    completionHandler(success: false, errorString: "Cant find key 'photos' in \(parsedResult)")
                }
            }
        }
        
        /* 9 - Resume (execute) the task */
        task.resume()
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    func createBoundingBoxString() -> String {
        
        //        let latitude = (self.latitudeTextField.text as NSString).doubleValue
        //        let longitude = (self.longitudeTextField.text as NSString).doubleValue
        
        //        let latitude : Double = 40.6590256406114
        //        let longitude : Double = -73.9473275428209
        
        // let latitude : Double = 27.9881
        // let longitude : Double = 86.9253
        
        let latitude = self.latitude
        let longitude = self.longitude
        
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    
    
}

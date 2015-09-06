//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Steven Hertz on 9/4/15.
//  Copyright (c) 2015 Steven Hertz. All rights reserved.
//

import Foundation
import MapKit

class Pin {

    var latitude: Double
    var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude as Double, longitude as Double)
        }
    }
    
    init(latitude: Double, longitude: Double ) {
        self.latitude = latitude
        self.longitude = latitude
    }
    


}
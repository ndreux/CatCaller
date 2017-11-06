//
//  Pin.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 03/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import MapKit

class Pin: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate

        super.init()
    }
}

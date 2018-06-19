//
//  Location.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 09/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import Foundation

class Location {

    var latitude: Double!
    var longitude: Double!
    var address: String?

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

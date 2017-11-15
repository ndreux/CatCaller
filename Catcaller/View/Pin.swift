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
    let report: Report

    init(report: Report) {
        self.report = report
        self.coordinate = CLLocationCoordinate2D(
            latitude: report.harassment.location.latitude,
            longitude: report.harassment.location.longitude
        )

        super.init()
    }
}

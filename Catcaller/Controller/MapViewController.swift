//
//  ViewController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 26/10/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import MapKit
import UIKit
import SwiftyJSON

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var addReportButton: UIButton!

    var activityIndicator: UIActivityIndicatorView!
    var locationManager: CLLocationManager?
    var catcallerApi: CatcallerApiWrapper!
    var displayedReports: Dictionary<String, MKAnnotation>!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView!.delegate = self
        self.displayedReports = [:]

        catcallerApi = CatcallerApiWrapper()
        catcallerApi.from = self

        locationManager = CLLocationManager()
        locationManager!.delegate = self

        checkLocationAuthorizationStatus()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.hidesWhenStopped = true
    }

    /**
     Check if the app has the authorization to use user location.
     Use user location if true, ask for it if not.
     */
    func checkLocationAuthorizationStatus() -> Void {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager!.startUpdatingLocation()
            mapView.showsUserLocation = true
        } else {
            locationManager!.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) -> Void {
        switch status {
        case .notDetermined:
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            locationManager!.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) -> Void {

        let location = locations.first!
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)

        mapView.setRegion(coordinateRegion, animated: true)
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) -> Void {
        print("Failed to initialize GPS: ", error.localizedDescription)
    }

    @IBAction func refreshReportsAction(_ sender: Any) {
        self.loadReports()
    }

    /**
     Load reports in the displayed area
     */
    func loadReports() -> Void {
        print("loadReports - START")
        self.startLoading()
        let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
        let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)

        catcallerApi.loadReportsInArea(minLat: southWest.latitude, minLong: southWest.longitude, maxLat: northEast.latitude, maxLong: northEast.longitude)

        print("loadReports - END")
    }

    /**
     This function is called after loadind reports.
     Add a pin for each report.
     - parameter reports: JSON object containing the reports
     */
    func displayReports(reports: [String : JSON]) -> Void {
        print("displayReports - START")

        for (_,subJson):(String, JSON) in reports["hydra:member"]! {

            let latitude = subJson["harassment"]["location"]["latitude"].double!
            let longitude = subJson["harassment"]["location"]["longitude"].double!

            self.addPin(latitude: latitude, longitude: longitude)
        }
        self.stopLoading()
        print("displayReports - END")
    }

    /**
     Add a pin to the given location
     - parameter latitude: Latitude of the pin
     - parameter longitude: Longitude of the pin
     */
    func addPin(latitude: Double, longitude: Double) -> Void {
        print("MapViewController.addPin - START")
        let pin: MKAnnotation = Pin(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))

        if self.displayedReports["\(latitude)\(longitude)"] == nil {
            print("MapViewController.addPin - the pin does not exist")
            mapView.addAnnotation(pin)
            displayedReports["\(latitude)\(longitude)"] = pin
        } else {
            print("MapViewController.addPin - the pin already exists")
        }
        print("MapViewController.addPin - END")
    }
    
    /**
     Load the pin displayed in the view after it has been moved.
     */
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) -> Void {
        print("mapViewDidFinishLoadingMap - START")
        self.mapView = mapView

        loadReports()
        print("mapViewDidFinishLoadingMap - END")
    }

    func startLoading() {
        self.activityIndicator.startAnimating()
        self.navItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
    }

    func stopLoading() {
        self.activityIndicator.stopAnimating()
        self.navItem.rightBarButtonItem = self.refreshButton
    }
}


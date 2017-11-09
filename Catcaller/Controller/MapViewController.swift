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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!

    @IBOutlet weak var addReportButton: UIButton!

    @IBOutlet weak var summaryBar: UIView!
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var bottomPanel: UIView!
    @IBOutlet weak var reportTypeLabel: UILabel!
    @IBOutlet weak var reportDatetimeLabel: UILabel!

    var activityIndicator: UIActivityIndicatorView!

    var locationManager: CLLocationManager?
    var catcallerApi: CatcallerApiWrapper!

    // todo (ndreux - 2017-11-09) Find a better way to avoid reloding
    var doReload: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView!.delegate = self

        catcallerApi = CatcallerApiWrapper()
        catcallerApi.from = self

        locationManager = CLLocationManager()
        locationManager!.delegate = self

        checkLocationAuthorizationStatus()

        self.hideBottomPanel()
        self.hideSummaryBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.hidesWhenStopped = true
        self.summaryLabel.textColor = .white
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
        
        let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
        let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)

        if isRegionTooBig(minLat: southWest.latitude, minLong: southWest.longitude, maxLat: northEast.latitude, maxLong: northEast.longitude) {
            print("Region is too big")
            self.mapView.removeAnnotations(self.mapView.annotations)
            return
        }

        self.startLoading()
        self.hideSummaryBar()

        catcallerApi.loadReportsInArea(minLat: southWest.latitude, minLong: southWest.longitude, maxLat: northEast.latitude, maxLong: northEast.longitude)

        print("loadReports - END")
    }

    private func isRegionTooBig (minLat: CLLocationDegrees, minLong: CLLocationDegrees, maxLat: CLLocationDegrees, maxLong: CLLocationDegrees) -> Bool {

        let latitudeDifference = abs(minLat - maxLat)
        let longitudeDifference = abs(minLong - maxLong)

        let maxDifferenceAccepted = 0.2

        return latitudeDifference > maxDifferenceAccepted || longitudeDifference > maxDifferenceAccepted
    }

    private func isRegionTooBig () -> Bool {

        let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
        let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)

        return self.isRegionTooBig (minLat: southWest.latitude, minLong: southWest.longitude, maxLat: northEast.latitude, maxLong: northEast.longitude)
    }

    /**
     This function is called after loadind reports.
     Add a pin for each report.
     - parameter reports: JSON object containing the reports
     */
    func displayReports(reports: [Report]) -> Void {
        print("displayReports - START")

        let oldAnnotations = self.mapView.annotations

        for report:Report in reports {
            self.addPin(report: report)
        }

        self.mapView.removeAnnotations(oldAnnotations)

        // todo (ndreux - 2017-11-09) Use localisation
        self.summaryLabel.text = "There are \(reports.count) report(s) in this area"
        self.showSummaryBar()
        self.stopLoading()
        print("displayReports - END")
    }

    /**
     Add a pin to the given location
     - parameter latitude: Latitude of the pin
     - parameter longitude: Longitude of the pin
     */
    func addPin(report: Report) -> Void {
        print("MapViewController.addPin - START")

        let pin: MKAnnotation = Pin(
            coordinate: CLLocationCoordinate2D(
                latitude: report.harassment.location.latitude,
                longitude: report.harassment.location.longitude
            ),
            report: report
        )
        mapView.addAnnotation(pin)

        print("MapViewController.addPin - END")
    }


    /**
     Loads the pins of the new region after it was changed
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        print("regionDidChange - START")

        if !self.doReload {
            print("Do not reload")
            return
        }

        if isRegionTooBig() {
            self.refreshButton.isEnabled = false
            self.summaryLabel.text = "This area is to big to be scanned"
        }

        self.mapView = mapView

        loadReports()
        print("regionDidChange - STOP")
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.doReload = false

        let report = (view.annotation as! Pin).report

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        self.reportTypeLabel.text = report.type
        self.reportDatetimeLabel.text = formatter.string(from: report.harassment.datetime)

        self.mapView.setCenter((view.annotation?.coordinate)!, animated: true)

        self.showBottomPanel()
        self.hideSummaryBar()
        self.hideAddButton()
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.doReload = true
        self.hideBottomPanel()
        self.showSummaryBar()
        self.showAddButton()
    }

    /**
     This function starts animating the activity indicator and hides the refresh button
     */
    private func startLoading() -> Void {
        self.activityIndicator.startAnimating()
        self.navItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
    }

    /**
     This function stops the activity indicator and show the refresh button
     */
    private func stopLoading() -> Void {
        self.activityIndicator.stopAnimating()
        self.navItem.rightBarButtonItem = self.refreshButton
    }

    private func showBottomPanel() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomPanel.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }

    private func hideBottomPanel() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomPanel.transform = CGAffineTransform(translationX: 0, y: 150)
        })
    }

    private func showAddButton() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.addReportButton.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }

    private func hideAddButton() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.addReportButton.transform = CGAffineTransform(translationX: 0, y: 100)
        })
    }

    private func showSummaryBar() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.summaryBar.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }

    private func hideSummaryBar() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.summaryBar.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }
}


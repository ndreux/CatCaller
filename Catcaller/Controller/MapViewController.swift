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

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var harassmentTypesTableView: UITableView!

    @IBOutlet weak var addReportButton: UIButton!

    @IBOutlet weak var summaryBar: UIView!
    @IBOutlet weak var summaryLabel: UILabel!

    @IBOutlet weak var bottomPanel: UIView!
    @IBOutlet weak var reportTypeLabel: UILabel!
    @IBOutlet weak var harassmentDatetimeLabel: UILabel!
    @IBOutlet weak var harassmentTypesLabel: UILabel!

    var activityIndicator: UIActivityIndicatorView!
    var refreshButton: UIBarButtonItem!

    var locationManager: CLLocationManager?
    var catcallerApi: CatcallerApiWrapper!

    var userLocation: CLLocation?
    var selectedAnnotation: Pin?

    var harassmentTypes: [HarassmentType]!
    var selectedHarassmentTypes: [Int:HarassmentType]!

    // MARK: Main view loading functions

    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView!.delegate = self

        self.catcallerApi = CatcallerApiWrapper()
        self.catcallerApi.from = self

        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self

        self.harassmentTypesTableView.delegate = self
        self.harassmentTypesTableView.dataSource = self

        self.harassmentTypes = [HarassmentType]()
        self.selectedHarassmentTypes = [Int:HarassmentType]()

        checkLocationAuthorizationStatus()

        self.loadHarassmentTypes()

        self.hideBottomPanel()
        self.hideSummaryBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.hideBottomPanel()
        self.hideMenu()
        self.loadReports()


        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.hidesWhenStopped = true

        self.refreshButton =  UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(MapViewController.refreshReportsAction(_:)))
        self.navItem.rightBarButtonItem = self.refreshButton

        self.summaryLabel.textColor = .white
    }

    // MARK: User location management

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

        self.userLocation = manager.location
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.userLocation!.coordinate, 500, 500)

        mapView.setRegion(coordinateRegion, animated: true)
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) -> Void {
        print("Failed to initialize GPS: ", error.localizedDescription)
    }

    @objc func refreshReportsAction(_ sender: Any) {
        self.loadReports()
    }

    // MARK: Reports

    /**
     Load reports in the displayed area
     */
    func loadReports() -> Void {

        print("load reports")
        print("Selected harassment types : \(self.selectedHarassmentTypes)")

        if self.selectedHarassmentTypes.count == 0 {
            self.mapView.removeAnnotations(self.mapView.annotations)
            print("Remove all annotations")
            return

        }

        let northEast = mapView.convert(CGPoint(x: mapView.bounds.width, y: 0), toCoordinateFrom: mapView)
        let southWest = mapView.convert(CGPoint(x: 0, y: mapView.bounds.height), toCoordinateFrom: mapView)

        if isRegionTooBig(minLat: southWest.latitude, minLong: southWest.longitude, maxLat: northEast.latitude, maxLong: northEast.longitude) {
            self.mapView.removeAnnotations(self.mapView.annotations)
            return
        }

        self.startLoading()
        self.hideSummaryBar()

        catcallerApi.loadReportsInArea(minLat: southWest.latitude, minLong: southWest.longitude, maxLat: northEast.latitude, maxLong: northEast.longitude, harassmentTypes: self.selectedHarassmentTypes)
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
        var oldAnnotations: [MKAnnotation] = [MKAnnotation]()

        for annotation in self.mapView.annotations {
            let annotationIsNotSelected = (annotation as? Pin)?.report.id != self.selectedAnnotation?.report.id
            if annotationIsNotSelected {
                oldAnnotations.append(annotation)
            }
        }

        for report:Report in reports {
            let annotationIsNotSelected = report.id != self.selectedAnnotation?.report.id
            if annotationIsNotSelected {
                self.addPin(report: report)
            }
        }

        self.mapView.removeAnnotations(oldAnnotations)

        // TODO: (ndreux - 2017-11-09) Use localization
        self.summaryLabel.text = "There are \(reports.count) report(s) in this area"
        self.showSummaryBar()
        self.stopLoading()
    }

    /**
     Add a pin to the given location
     - parameter latitude: Latitude of the pin
     - parameter longitude: Longitude of the pin
     */
    func addPin(report: Report) -> Void {
        mapView.addAnnotation(Pin(report: report))
    }

    // MARK: MapViewDelegate functions

    /**
     Loads the pins of the new region after it was changed
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isRegionTooBig() {
            self.refreshButton.isEnabled = false
            self.summaryLabel.text = "This area is to big to be scanned"
        }

        self.mapView = mapView

        loadReports()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let annotation = view.annotation as? Pin {
            self.selectedAnnotation = annotation
            let report = annotation.report

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy HH:mm"

            self.reportTypeLabel.text = report.type
            self.harassmentDatetimeLabel.text = formatter.string(from: report.harassment.datetime)
            let arrayMap: Array = report.harassment.types.map(){ $0.description }
            self.harassmentTypesLabel.text = arrayMap.joined(separator: ", ")

            self.mapView.setCenter((view.annotation?.coordinate)!, animated: true)

            self.hideMenu()
            self.showBottomPanel()
            self.hideSummaryBar()
            self.hideAddButton()
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.selectedAnnotation = nil
        self.hideBottomPanel()
        self.showSummaryBar()
        self.showAddButton()
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CreateReportTableController {
            if self.userLocation != nil {
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(self.userLocation!){
                    (placemarks, error) -> Void in
                    let placeArray = placemarks as [CLPlacemark]!
                    let placeMark: CLPlacemark! = placeArray?[0]

                    if let locationName = placeMark.addressDictionary?["Name"] as? String {
                        destinationVC.harassmentLocation.append(locationName)
                    }

                    if let city = placeMark.addressDictionary?["City"] as? String {
                        destinationVC.harassmentLocation.append(" \(city)")
                    }

                    if let zip = placeMark.addressDictionary?["ZIP"] as? String {
                        destinationVC.harassmentLocation.append(" \(zip)")
                    }

                    if let country = placeMark.addressDictionary?["Country"] as? String {
                        destinationVC.harassmentLocation.append(" \(country)")
                    }
                }
            }
        }
    }

    // MARK: Helpers

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
        self.bottomPanel.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomPanel.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height - self.bottomPanel.frame.size.height + 30 )
        })
    }

    private func hideBottomPanel() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomPanel.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
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

    func loadHarassmentTypes() {
        self.catcallerApi.loadHarassmentTypes()
    }

    @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
        self.menuView.isHidden ? self.showMenu() : self.hideMenu()
    }

    @IBAction func touchMap(_ sender: UITapGestureRecognizer) {
        if !self.menuView.isHidden {
            self.hideMenu()
        }
    }

    private func showMenu() -> Void {
        self.menuView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.menuView.transform = CGAffineTransform(translationX: 0, y: 0)
        })

    }

    private func hideMenu() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.menuView.transform = CGAffineTransform(translationX: -self.menuView.frame.width, y: 0)
        }, completion: { (finished: Bool) in
            self.menuView.isHidden = true
        })
    }

    func updateHarassmentTypeList(harassmentTypes: [HarassmentType]) {
        self.harassmentTypes = harassmentTypes
        for harassmentType in harassmentTypes {
            self.selectedHarassmentTypes[harassmentType.id] = harassmentType
        }
        self.harassmentTypesTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.harassmentTypes.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HarassmentTypeMenuCell", for: indexPath)

        cell.textLabel?.text = self.harassmentTypes[indexPath.row].label

        if self.selectedHarassmentTypes[self.harassmentTypes[indexPath.row].id] != nil {
            cell.accessoryType = .checkmark
        }

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.harassmentTypesTableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                self.selectedHarassmentTypes.removeValue(forKey: self.harassmentTypes[indexPath.row].id)
            }
            else{
                cell.accessoryType = .checkmark
                self.selectedHarassmentTypes[self.harassmentTypes[indexPath.row].id] = self.harassmentTypes[indexPath.row]
            }
            self.loadReports()
        }
    }
}


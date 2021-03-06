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

extension MapViewController: CLLocationManagerDelegate {

    // MARK: CLLocationManagerDelegate functions

    /**
     Check if the app has the authorization to use user location.
     Use user location if true, ask for it if not.
     */
    func checkLocationAuthorizationStatus() -> Void {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager!.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        } else {
            self.locationManager!.requestWhenInUseAuthorization()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) -> Void {
        if status == .authorizedWhenInUse {
            self.locationManager!.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) -> Void {
        self.userLocation = manager.location

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.userLocation!.coordinate, 500, 500)
        mapView.setRegion(coordinateRegion, animated: true)

        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }
}

extension MapViewController: MKMapViewDelegate {
    // MARK: MapViewDelegate functions

    /**
     Loads the pins of the new region after it was changed
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if isRegionTooBig() {
            self.refreshButton.isEnabled = false
            self.summaryBar.updateSummary(reportsCount: nil)
        }

        self.loadReports()
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        if let annotation = view.annotation as? Pin {
            self.selectedAnnotation = annotation
            let report = annotation.report

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy HH:mm"

            self.bottomPanel.reportType.text = "\(report.type!)"
            self.bottomPanel.harassmentDate.text = report.harassment.datetime!
            self.bottomPanel.harassmentTypes.text = report.harassment.types.map(){ $0.label }.joined(separator: ", ")

            mapView.setCenter((view.annotation?.coordinate)!, animated: true)

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
}

extension MapViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: TableViewDelegate/DataSource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.harassmentTypes != nil) ? self.harassmentTypes!.count : 0
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HarassmentTypeMenuCell", for: indexPath)

        cell.textLabel?.text = self.harassmentTypes![indexPath.row].label

        if self.selectedHarassmentTypes![self.harassmentTypes![indexPath.row].id] != nil {
            cell.accessoryType = .checkmark
        }

        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.harassmentTypesTableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                self.deselectHarassmentType(harassmentType: self.harassmentTypes![indexPath.row])
            }
            else{
                cell.accessoryType = .checkmark
                self.selectHarassmentType(harassmentType: self.harassmentTypes![indexPath.row])
            }
            self.updateHarassmentTypeSwitchStatus()
            self.loadReports()
        }
    }
}

extension MapViewController: CatCallerApiGetHarassmentTypesDelegate {

    func getHarassmentTypesSuccess(harassmentTypes: [HarassmentType]) {
        self.harassmentTypes = harassmentTypes

        UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: harassmentTypes), forKey: "harassmentTypes")

        self.loadSelectedHarassmentTypes()
        self.harassmentTypesTableView.reloadData()

        self.updateHarassmentTypeSwitchStatus()
        self.stopLoading()
        self.loadReports()
    }

    func getHarassmentTypesError() {
        self.stopLoading()
    }
}

extension MapViewController: CatCallerApiGetReportsDelegate {
    func getReportsSuccess(reports: [Report]) {
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

        self.summaryBar.updateSummary(reportsCount: reports.count)
        self.showSummaryBar()
        self.stopLoading()
    }

    func getReportsError(error: Error) {}
}

class MapViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var onlyMyReportsSwitch: UISwitch!
    @IBOutlet weak var harassmentTypesSwitch: UISwitch!
    @IBOutlet weak var harassmentTypesTableView: UITableView!

    @IBOutlet weak var addReportButton: UIButton!
    @IBOutlet weak var summaryBar: SummaryBar!
    @IBOutlet weak var bottomPanel: BottomPanel!

    var activityIndicator: UIActivityIndicatorView!
    var refreshButton: UIBarButtonItem!

    var locationManager: CLLocationManager?
    var catcallerApi: CatcallerApiWrapper!
    var authenticationHelper: AuthenticationHelper!

    var userLocation: CLLocation?
    var selectedAnnotation: Pin?

    var harassmentTypes: [HarassmentType]?
    var selectedHarassmentTypes: [Int:HarassmentType]?
    var toBeCreatedReportLocation: Location?

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.authenticationHelper = AuthenticationHelper()

        self.mapView!.delegate = self
        self.mapView.isRotateEnabled = false

        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self

        self.harassmentTypesTableView.delegate = self
        self.harassmentTypesTableView.dataSource = self

        self.catcallerApi = CatcallerApiWrapper()
        self.catcallerApi.delegate = self

        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.hidesWhenStopped = true
        self.refreshButton =  UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(MapViewController.refreshReportsAction(_:)))

        self.checkLocationAuthorizationStatus()

        if !self.authenticationHelper.isUserAuthenticated() {
            self.showAuthenticationNavigationController()
            return
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navItem.rightBarButtonItem = self.refreshButton

        self.hideAccessoryViews()

        self.view.isHidden = false
        if !self.authenticationHelper.isUserAuthenticated() {
            self.view.isHidden = true
            return
        }

        DispatchQueue.main.async {
            self.loadHarassmentTypes()
            self.loadReports()
        }
    }

    /**
     Hide menu, summary bar and bottom panel
     */
    func hideAccessoryViews() {
        self.menuView.isHidden = true
        self.bottomPanel.isHidden = true
        self.summaryBar.isHidden = true
        self.hideMenu()
        self.hideBottomPanel()
        self.hideSummaryBar()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        AuthenticationHelper().logout()
        self.cleanSavedData()
        self.showAuthenticationNavigationController()
    }

    func cleanSavedData() {
        UserDefaults.standard.setValue(nil, forKey: "harassmentTypes")
        UserDefaults.standard.setValue(nil, forKey: "selectedHarassmentTypes")
    }

    func showAuthenticationNavigationController() {
        self.performSegue(withIdentifier: "showAuthenticationController", sender: self)
    }

    @objc func refreshReportsAction(_ sender: Any) {
        self.loadReports()
    }

    // MARK: Reports

    /**
     Load reports in the displayed area
     */
    func loadReports() -> Void {

        if self.selectedHarassmentTypes == nil || self.selectedHarassmentTypes!.count == 0 {
            self.summaryBar.updateSummary(reportsCount: 0)
            self.mapView.removeAnnotations(self.mapView.annotations)
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

        self.catcallerApi.getReports(minLat: southWest.latitude, minLong: southWest.longitude, maxLat: northEast.latitude, maxLong: northEast.longitude, harassmentTypes: self.selectedHarassmentTypes!, onlyMyReports: self.onlyMyReportsSwitch.isOn)
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

    func addPin(report: Report) -> Void {
        self.mapView.addAnnotation(Pin(report: report))
    }

    // MARK: Gesture recognisers
    @IBAction func touchMap(_ sender: UITapGestureRecognizer) {
        if !self.menuView.isHidden {
            self.hideMenu()
        }
    }

    @IBAction func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state  == .began {
            let coordinate = self.mapView.convert(sender.location(in: self.mapView), toCoordinateFrom: self.mapView)
            self.getAddressFromCoordinate(coordinate: coordinate, completionHandler: { (address, error) -> Void in

                self.mapView.setCenter(coordinate, animated: true)

                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                self.mapView.addAnnotation(annotation)
                self.mapView.selectAnnotation(annotation, animated: true)

                self.presentCreateReportActionSheet(annotation: annotation, address: address)
            })
        }
    }

    private func presentCreateReportActionSheet(annotation: MKPointAnnotation, address: String) {
        let actionSheet: UIAlertController = UIAlertController(title: NSLocalizedString("action_sheet.create_report.title", comment: ""), message: address, preferredStyle: .actionSheet)

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.mapView.removeAnnotation(annotation)
            self.toBeCreatedReportLocation = nil
        }
        actionSheet.addAction(cancelActionButton)

        let createActionButton = UIAlertAction(title: "Create", style: .default) { _ in
            let coordinate = annotation.coordinate
            self.toBeCreatedReportLocation = Location(latitude: coordinate.latitude, longitude: coordinate.longitude)
            self.toBeCreatedReportLocation!.address = address
            self.performSegue(withIdentifier: "showCreateReportTableController", sender: self)
            self.mapView.removeAnnotation(annotation)
        }
        actionSheet.addAction(createActionButton)

        self.present(actionSheet, animated: true, completion: nil)
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CreateReportTableController {
            destinationVC.harassmentTypes = self.harassmentTypes

            if self.toBeCreatedReportLocation != nil {
                destinationVC.harassmentLocation = self.toBeCreatedReportLocation!.address
                destinationVC.report.harassment.location = self.toBeCreatedReportLocation
                self.toBeCreatedReportLocation = nil

                return
            }

            if self.userLocation != nil {
                self.getAddressFromLocation(location: self.userLocation!,  completionHandler: { (address, error) -> Void in
                    destinationVC.harassmentLocation = address
                })
            }
        }
    }

    private func getAddressFromCoordinate(coordinate: CLLocationCoordinate2D, completionHandler : @escaping (_ address : String, _ error : Error?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.getAddressFromLocation(location: location, completionHandler: completionHandler)
    }

    private func getAddressFromLocation(location: CLLocation, completionHandler : @escaping (_ address : String, _ error : Error?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location){
            (placemarks, error) -> Void in

            let placeMark: CLPlacemark! = (placemarks as [CLPlacemark]!)?[0]
            let address: String = self.getAddressFromPlacemark(placeMark: placeMark)

            completionHandler(address, error)
        }
    }

    private func getAddressFromPlacemark(placeMark: CLPlacemark) -> String {
        var addressData = [String]()

        let neededData = ["Name", "City", "ZIP", "Country"]
        for data in neededData {
            if placeMark.addressDictionary?[data] is String {
                addressData.append(placeMark.addressDictionary?[data] as! String)
            }
        }

        return addressData.joined(separator: ", ")
    }

    // MARK: Helpers

    /**
     This function starts animating the activity indicator and hides the refresh button
     */
    private func startLoading() -> Void {
        self.activityIndicator.startAnimating()
        self.refreshButton.isEnabled = true
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

        self.bottomPanel.isHidden = false
        self.bottomPanel.setNeedsLayout()
        self.bottomPanel.layoutIfNeeded()

        UIView.animate(withDuration: 0.3, animations: {
            self.bottomPanel.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height - self.bottomPanel.frame.size.height + 80 )
        })
    }

    private func hideBottomPanel() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.bottomPanel.transform = CGAffineTransform(translationX: 0, y: self.view.frame.size.height)
        })
    }

    private func showAddButton() -> Void {
        self.summaryBar.isHidden = false
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
        self.summaryBar.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.summaryBar.transform = CGAffineTransform(translationX: 0, y: 0)
        })
    }

    private func hideSummaryBar() -> Void {
        UIView.animate(withDuration: 0.3, animations: {
            self.summaryBar.transform = CGAffineTransform(translationX: 0, y: -20)
        })
    }

    // MARK: Menu

    func loadHarassmentTypes() {

        self.startLoading()

        if self.harassmentTypes == nil {
            self.harassmentTypes = [HarassmentType]()
        }

        if let harassmentTypesData = UserDefaults.standard.value(forKey: "harassmentTypes") as? Data {
            if let harassmentTypes = NSKeyedUnarchiver.unarchiveObject(with: harassmentTypesData) as? [HarassmentType] {
                self.getHarassmentTypesSuccess(harassmentTypes: harassmentTypes)
            }
        } else {
            self.catcallerApi.getHarassmentTypes()
        }
    }

    @IBAction func toggleMenu(_ sender: UIBarButtonItem) {
        self.menuView.isHidden ? self.showMenu() : self.hideMenu()
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

    func loadSelectedHarassmentTypes() {
        self.selectedHarassmentTypes = [Int:HarassmentType]()
        if let selectedHarassmentTypesData = UserDefaults.standard.value(forKey: "selectedHarassmentTypes") as? Data {
            if let selectedHarassmentTypes = NSKeyedUnarchiver.unarchiveObject(with: selectedHarassmentTypesData) as? [Int:HarassmentType] {
                self.selectHarassmentTypes(harassmentTypes: selectedHarassmentTypes)
            }
        } else {
            self.selectAllHarassmentTypes()
        }
    }

    @IBAction func toggleHarassmentTypesSwitch(_ sender: UISwitch) {
        sender.isOn = !sender.isOn
        sender.isOn ? self.selectAllHarassmentTypes() : self.deselectAllHarassmentTypes()
        DispatchQueue.main.async {
            self.harassmentTypesTableView.reloadData()
            self.loadReports()
        }
    }

    private func selectHarassmentTypes(harassmentTypes: [Int:HarassmentType]) {
        for (row, harassmentType) in harassmentTypes {
            self.selectHarassmentType(harassmentType: harassmentType)
            self.harassmentTypesTableView.cellForRow(at: IndexPath(row: row, section: 0))?.accessoryType = .checkmark
        }
    }

    private func selectAllHarassmentTypes() {
        if self.harassmentTypes == nil {
            return
        }

        for (row, harassmentType) in self.harassmentTypes!.enumerated() {
            self.selectHarassmentType(harassmentType: harassmentType)
            let cell = self.harassmentTypesTableView.cellForRow(at: IndexPath(row: row, section: 0))
            cell?.accessoryType = .checkmark
        }
    }

    private func deselectAllHarassmentTypes() {
        if self.harassmentTypes == nil {
            return
        }

        for (row, harassmentType) in self.harassmentTypes!.enumerated() {
            self.deselectHarassmentType(harassmentType: harassmentType)
            let cell = self.harassmentTypesTableView.cellForRow(at: IndexPath(row: row, section: 0))
            cell?.accessoryType = .none
        }
    }

    private func selectHarassmentType(harassmentType: HarassmentType) {
        self.selectedHarassmentTypes![harassmentType.id] = harassmentType
        self.updateHarassmentTypeSwitchStatus()

        DispatchQueue.main.async(execute: {
            let selectedHarassmentTypesData = NSKeyedArchiver.archivedData(withRootObject: self.selectedHarassmentTypes as Any)
            UserDefaults.standard.set(selectedHarassmentTypesData, forKey: "selectedHarassmentTypes")
        })
    }

    private func deselectHarassmentType(harassmentType: HarassmentType) {
        self.selectedHarassmentTypes!.removeValue(forKey: harassmentType.id)
        self.updateHarassmentTypeSwitchStatus()

        DispatchQueue.main.async(execute: {
            let selectedHarassmentTypesData = NSKeyedArchiver.archivedData(withRootObject: self.selectedHarassmentTypes as Any)
            UserDefaults.standard.set(selectedHarassmentTypesData, forKey: "selectedHarassmentTypes")
        })
    }

    /**
     If all harassment types are selected, activates the switch. Deactivates it otherwise.
     */
    func updateHarassmentTypeSwitchStatus() {
        if self.harassmentTypes == nil {
            return
        }

        self.harassmentTypesSwitch.isOn = self.harassmentTypes!.count == self.selectedHarassmentTypes!.count
    }

    @IBAction func toggleOnlyMyReportsSwitch(_ sender: UISwitch) {
        self.loadReports()
    }
}


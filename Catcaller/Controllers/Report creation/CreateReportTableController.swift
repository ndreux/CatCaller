//
//  CreateReportTableController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit
import Alamofire
import MapKit

extension CreateReportTableController: CatCallerApiCreateReportDelegate {
    // MARK: CatCallerApiCreateReportDelegate
    func createReportSuccess() {
        self.activityIndicator.stopAnimating()
        self.navigationBar.rightBarButtonItem = self.saveReportButton
        self.navigationController?.popViewController(animated: true)
    }

    func createReportError() {
        self.activityIndicator.stopAnimating()
        self.navigationBar.rightBarButtonItem = self.saveReportButton
    }
}

extension CreateReportTableController: UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Report Type - UIPicker

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.reportType.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.reportType[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TableViewCellTextField

        if row == 0 {
            cell.textField.text = self.sections[0][0]
            cell.textField.textColor = UIColor.lightGray
        } else {
            cell.textField.textColor = UIColor.black
            cell.textField.text = "you are a \(self.reportType[row]) of street harassment".lowercased().firstUppercased
        }

        self.report.type = self.reportType[row]
        self.updateSaveButtonState()
    }
}

extension CreateReportTableController: UITextViewDelegate {
    // MARK: HarassmentNote - TextView

    func textViewDidChange(_ textView: UITextView) {
        self.report.harassment.note = textView.text
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == self.sections[1][3] {
            textView.text.removeAll()
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = self.sections[1][3]
            textView.textColor = UIColor.lightGray
        }
    }
}

extension CreateReportTableController: HarassmentTypesControllerDelegate {
    func selectHarassmentTypesSuccess(harassmentTypes: [Int : HarassmentType]) {

        let indexPath = IndexPath(row: 2, section: 1)
        let cell = self.tableView.cellForRow(at: indexPath)

        switch harassmentTypes.count {
        case 0:
            cell?.textLabel?.text = self.sections[1][2]
            cell?.textLabel?.textColor = UIColor.lightGray
        case 1:
            cell?.textLabel?.text = harassmentTypes.first!.value.label
            cell?.textLabel?.textColor = UIColor.black
        default:
            cell?.textLabel?.text = "\(harassmentTypes.first!.value.label) and \(harassmentTypes.count - 1) more"
            cell?.textLabel?.textColor = UIColor.black
        }

        self.selectedHarassmentTypes = harassmentTypes
        self.report.harassment.types = harassmentTypes.map {$0.value}

        self.updateSaveButtonState()
    }
}

extension CreateReportTableController: HarassmentLocationControllerDelegate {
    func getHarassmentLocationSuccess(placemark: MKPlacemark) {
        self.harassmentLocation = placemark.title!
        let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 1))
        cell?.textLabel?.text = self.harassmentLocation
        cell?.textLabel?.textColor = UIColor.black
        self.report.harassment.location = Location(latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)

        self.updateSaveButtonState()
    }


}

class CreateReportTableController: UITableViewController {

    var apiWrapper: CatcallerApiWrapper!
    var pickerView: UIPickerView!
    var datepickerView: UIDatePicker!
    var dateFormatter: DateFormatter!
    var activityIndicator: UIActivityIndicatorView!

    let reportType: [String] = ["", "Victim", "Witness"]
    let sections = [["You are ?"],["Datetime", "Place", "Harassment types", "Note"]]
    var harassmentTypes: [HarassmentType]!
    var selectedHarassmentTypes: [Int:HarassmentType]!
    var harassmentLocation: String = String()

    var report: Report!

    @IBOutlet weak var saveReportButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.report = Report(reporter: AuthenticationHelper().getUserId()!)

        self.apiWrapper = CatcallerApiWrapper()
        self.apiWrapper.delegate = self
        self.apiWrapper.getHarassmentTypes()

        self.pickerView = UIPickerView()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self

        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .short

        self.selectedHarassmentTypes = [Int:HarassmentType]()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50

        self.updateSaveButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.hidesWhenStopped = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    @IBAction func saveReport(_ sender: UIBarButtonItem) {
        self.activityIndicator.startAnimating()
        self.navigationBar.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
        self.apiWrapper.createReport(report: self.report)
    }

    func updateSaveButtonState() {
        let hasReportType = !self.report.type.isEmpty
        let hasPlace = self.report.harassment.location != nil
        let hasTypes = !self.report.harassment.types.isEmpty

        self.saveReportButton.isEnabled = (hasReportType && hasTypes && hasPlace)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Report Type (Witness/Victim)
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportTypeCell", for: indexPath) as! TableViewCellTextField

            cell.textField.text = sections[indexPath.section][indexPath.row]
            cell.textField.textColor = UIColor.lightGray
            cell.textField.inputView = self.pickerView

            return cell
        }

        switch indexPath.row {
        // DateTime
        case 0:

            let cell = tableView.dequeueReusableCell(withIdentifier: "HarassmentDateTimeCell", for: indexPath) as! TableViewCellDatePicker

            let now = Date()
            self.report.harassment.datetime = now
            cell.textField.text = self.dateFormatter.string(from: now)
            cell.textField.textColor = UIColor.black

            return cell
        // Note
        case 3:

            let cell = tableView.dequeueReusableCell(withIdentifier: "HarassmentNoteCell", for: indexPath) as! TableViewCellTextView
            cell.textView?.text = sections[indexPath.section][indexPath.row]
            cell.textView?.textColor = UIColor.lightGray
            cell.textView.delegate = self
            cell.accessoryType = .none


            return cell
        default:

            let cell = tableView.dequeueReusableCell(withIdentifier: "CreateReportCell", for: indexPath)
            cell.textLabel?.text = sections[indexPath.section][indexPath.row]
            cell.textLabel?.textColor = UIColor.lightGray
            cell.accessoryType = .disclosureIndicator

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let segueIdentifier: String
        
        if indexPath.section == 1 {
            switch indexPath.row {

            case 1:
                segueIdentifier = "harassmentLocationSegue"
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            case 2:
                segueIdentifier = "harassmentTypesSegue"
                self.performSegue(withIdentifier: segueIdentifier, sender: self)

            default: break
            }
        }

    }

    // MARK: Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? HarassmentTypesController {
            destinationVC.delegate = self
            destinationVC.harassmentTypes = self.harassmentTypes
            destinationVC.selectedHarassmentTypes = self.selectedHarassmentTypes
        }

        if let destinationVC = segue.destination as? HarassmentLocationController {
            destinationVC.delegate = self
            destinationVC.searchString = self.harassmentLocation
        }
    }

    // MARK: Harassment DateTime - DatePicker

    @IBAction func textEditing(_ sender: UITextField) {

        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.minuteInterval = 10
        datePickerView.maximumDate = Date()

        sender.inputView = datePickerView

        datePickerView.addTarget(self, action: #selector(CreateReportTableController.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }

    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as! TableViewCellDatePicker
        cell.textField.text = self.dateFormatter.string(from: sender.date)
        self.report.harassment.datetime = sender.date

        self.updateSaveButtonState()
    }
}

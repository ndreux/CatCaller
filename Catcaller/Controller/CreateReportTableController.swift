//
//  CreateReportTableController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit
import Alamofire

class CreateReportTableController: UITableViewController {

    var apiWrapper: CatcallerApiWrapper!
    let dateFormatter: DateFormatter = DateFormatter()
    let sections = [
        ["You are ?"],
        ["Location", "Place", "Harassment types", "Note"]
    ]
    var harassmentTypes: [HarassmentType]!

    override func viewDidLoad() {
        apiWrapper = CatcallerApiWrapper()
        apiWrapper.from = self

        self.dateFormatter.dateFormat = "MMM d, yyyy HH:mm"

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateReportCell", for: indexPath)

        cell.textLabel?.text = sections[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.lightGray

        if indexPath.section == 0 {

            cell.accessoryType = .disclosureIndicator

        } else {
            switch indexPath.row {
            case 0:
                cell.textLabel?.textColor = UIColor.black
                cell.textLabel?.text = self.dateFormatter.string(from: Date())

            case 3:
                cell.accessoryType = .none
            default:
                cell.accessoryType = .disclosureIndicator
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let segueIdentifier: String
        
        if indexPath.section == 0 {
            segueIdentifier = "reportTypeSegue"
        } else {
            switch indexPath.row {
            case 0:
                segueIdentifier = "harassmentDateSegue"
            case 1:
                segueIdentifier = "harassmentLocationSegue"
            case 2:
                segueIdentifier = "harassmentTypesSegue"

            default:
                segueIdentifier = "non"
            }
        }
        print("Performe SEGUE")
        self.performSegue(withIdentifier: segueIdentifier, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare")
        if let destinationVC = segue.destination as? HarassmentTypesController {
            destinationVC.harassmentTypes = [1, 2, 3, 4, 5, 6]
            print("Prepared")
        }
    }

}

//
//  HarassmentTypesController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

protocol HarassmentTypesControllerDelegate {
    func selectHarassmentTypesSuccess(harassmentTypes: [Int:HarassmentType])
}

class HarassmentTypesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var harassmentTypes: [HarassmentType]!
    var selectedHarassmentTypes: [Int: HarassmentType]!
    var delegate: HarassmentTypesControllerDelegate?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func done(_ sender: UIBarButtonItem) {
        if let presenter = self.delegate as? HarassmentTypesControllerDelegate {
            presenter.selectHarassmentTypesSuccess(harassmentTypes: self.selectedHarassmentTypes)
        }
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.harassmentTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HarassmentTypesCell", for: indexPath)

        cell.textLabel?.text = self.harassmentTypes[indexPath.row].label

        if (self.selectedHarassmentTypes[self.harassmentTypes[indexPath.row].id] != nil) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)

        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            if cell.accessoryType == .checkmark{
                cell.accessoryType = .none
                self.selectedHarassmentTypes.removeValue(forKey: self.harassmentTypes[indexPath.row].id)
            }
            else{
                cell.accessoryType = .checkmark
                self.selectedHarassmentTypes[self.harassmentTypes[indexPath.row].id] = self.harassmentTypes[indexPath.row]
            }
        }
    }
}

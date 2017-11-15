//
//  HarassmentTypesController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

class HarassmentTypesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var harassmentTypes: [Int]!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

    }

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        print("Count : \(self.harassmentTypes.count)")

        return self.harassmentTypes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HarassmentTypesCell", for: indexPath)

        cell.textLabel?.text = "\(harassmentTypes[indexPath.row])"

        return cell
    }

}

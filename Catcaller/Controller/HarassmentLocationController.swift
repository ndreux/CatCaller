//
//  HarassmentLocationController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 17/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit
import MapKit

class HarassmentLocationController: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    let completer: MKLocalSearchCompleter = MKLocalSearchCompleter()
    var addresses: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    var searchString: String = String()
    var from: UIViewController!

    // MARK: IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.delegate = self

        self.searchResultTableView.delegate = self
        self.searchResultTableView.dataSource = self

        self.searchBar.text = self.searchString

        self.completer.delegate = self
        self.completer.queryFragment = self.searchString

    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.addresses = completer.results
        self.searchResultTableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.completer.queryFragment = searchText
    }

    // MARK: Search Result Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = self.addresses[indexPath.row].title
        cell.detailTextLabel?.text = self.addresses[indexPath.row].subtitle
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addresses.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let address = self.addresses[indexPath.row]
        let searchRequest = MKLocalSearchRequest(completion: address)
        let search = MKLocalSearch(request: searchRequest)

        search.start { (response, error) in
            if let presenter = self.from as? CreateReportTableController {
                print("Send data to presenter")
                presenter.updateHarassmentLocation(placemark: (response?.mapItems[0].placemark)!)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    // MARK: IBAction
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

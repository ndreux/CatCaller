//
//  HarassmentLocationController.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 17/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit
import MapKit

protocol HarassmentLocationControllerDelegate {
    func getHarassmentLocationSuccess(placemark: MKPlacemark)
}

extension HarassmentLocationController: UISearchBarDelegate {
    // MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchBarText = searchBar.text else { return }
        self.completer.queryFragment = searchBarText
    }
    
}

extension HarassmentLocationController: MKLocalSearchCompleterDelegate {
    // MARK: MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.addresses = completer.results
        self.searchResultTableView.reloadData()
    }
}

extension HarassmentLocationController: UITableViewDelegate, UITableViewDataSource{
    // MARK: Search Result Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = self.searchResultTableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)

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
            if let presenter = self.delegate {
                presenter.getHarassmentLocationSuccess(placemark: (response?.mapItems[0].placemark)!)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

class HarassmentLocationController: UIViewController {

    // MARK: Properties
    let searchBar = UISearchBar()
    let completer: MKLocalSearchCompleter = MKLocalSearchCompleter()
    var addresses: [MKLocalSearchCompletion] = [MKLocalSearchCompletion]()
    var searchString: String = String()
    var delegate: HarassmentLocationControllerDelegate?

    // MARK: IBOutlet
    @IBOutlet var searchResultTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.sizeToFit()
        self.searchBar.delegate = self
        self.searchBar.text = self.searchString

        self.searchResultTableView.delegate = self
        self.searchResultTableView.dataSource = self

        self.completer.delegate = self
        self.completer.queryFragment = self.searchString

        self.searchResultTableView.tableHeaderView = self.searchBar
    }

    // MARK: IBAction
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

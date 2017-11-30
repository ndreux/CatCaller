//
//  HarassmentLocationSearchTable.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 30/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit
import MapKit

extension HarassmentLocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HarassmentLocationSearchCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = ""
        return cell
    }
}

extension HarassmentLocationSearchTable: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }


}

class HarassmentLocationSearchTable: UITableViewController {

    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

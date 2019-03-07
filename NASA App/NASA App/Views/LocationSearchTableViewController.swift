//
//  LocationSearchTableViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/6/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {

	var resultsList: [MKMapItem] = [MKMapItem]()
	var mapView: MKMapView? = nil
	
	override func viewDidLoad() {
		self.tableView.delegate = self
		self.tableView.dataSource = self
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchCell")
		tableView.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return resultsList.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
		var cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
		cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "searchCell")
		cell.backgroundColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
		
		let selectedItem = resultsList[indexPath.row].placemark
		cell.textLabel?.text = selectedItem.name
		cell.textLabel!.textColor = UIColor.white
		cell.detailTextLabel!.textColor = UIColor.lightGray
		cell.detailTextLabel?.text = LocationManager.parseAddress(selectedItem: selectedItem)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedLocation = resultsList[indexPath.row].placemark
		
		EarthSearch.earthSearch.latitude = selectedLocation.coordinate.latitude
		EarthSearch.earthSearch.longitude = selectedLocation.coordinate.longitude
		
		self.dismiss(animated: true, completion: nil)
	}
}

// update results for search table
extension LocationSearchTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let mapView = mapView,
			let searchBarText = searchController.searchBar.text else { return }
		
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchBarText
		request.region = mapView.region
		let search = MKLocalSearch(request: request)
		
		search.start { response, _ in
			guard let response = response else {
				return
			}
			self.resultsList = response.mapItems
			self.tableView.reloadData()
		}
	}

}

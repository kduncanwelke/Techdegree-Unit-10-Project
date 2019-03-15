//
//  EarthViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/28/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Nuke
import ContactsUI

class EarthViewController: UIViewController, UITableViewDelegate {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var image: UIImageView! 
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var coordinatesLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var importButton: UIButton!
	
	
	// MARK: Variables
	
	var usingCurrentLocation = true
	var locationFromMapTap = false
	let locationManager = CLLocationManager()
	var photo: UIImage?
	var date: String?
	var searchController = UISearchController(searchResultsController: nil)
	

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		locationManager.delegate = self
		mapView.delegate = self
		
		importButton.layer.cornerRadius = 10
		
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestLocation()
		locationManager.startUpdatingLocation()
		
		image.image = photo
		coordinatesLabel.text = "Lat: \(EarthSearch.earthSearch.latitude), Long: \(EarthSearch.earthSearch.longitude)"
		let displayDate = date?.prefix(10)
		dateLabel.text = String(displayDate ?? "No date")
		
		// set up search bar
		let resultsTableController = LocationSearchTableViewController()
		
		resultsTableController.tableView.delegate = resultsTableController
		resultsTableController.mapView = mapView
		resultsTableController.delegate = self
		
		searchController = UISearchController(searchResultsController: resultsTableController)
		searchController.searchResultsUpdater = resultsTableController
		searchController.searchBar.autocapitalizationType = .none
		
		searchController.searchBar.placeholder = "Type to search . . ."
		searchController.delegate = self
		searchController.searchBar.delegate = self // Monitor when the search button is tapped.
		
		image.addSubview(self.activityIndicator)
    }
	
	// set searchcontroller here, otherwise it won't load right
	override func viewDidAppear(_ animated: Bool) {
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		definesPresentationContext = true
	}
	
	
	// MARK: Custom functions
	
	func updateLocation(location: MKPlacemark) {
		usingCurrentLocation = false
		mapView.removeAnnotations(mapView.annotations)
		
		let coordinate = CLLocationCoordinate2D(latitude: EarthSearch.earthSearch.latitude, longitude: EarthSearch.earthSearch.longitude)
		
		let regionRadius: CLLocationDistance = 1000
		
		let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
		
		let annotation = MKPointAnnotation()
		
		// if location came from map tap, parse address to assign it to title for pin
		if self.locationFromMapTap {
			let locale = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
			let geocoder = CLGeocoder()
			
			geocoder.reverseGeocodeLocation(locale, completionHandler: { (placemarks, error) in
				if error == nil {
					guard let firstLocation = placemarks?[0] else { return }
					annotation.title = LocationManager.parseAddress(selectedItem: firstLocation)
				}
				else {
					// an error occurred during geocoding
					self.showAlert(title: "Error geocoding", message: "Location could not be parsed")
				}
			})
		} else {
			// otherwise use location that was included with location object
			annotation.title = location.title
		}
		
		annotation.coordinate = coordinate
		mapView.addAnnotation(annotation)
		mapView.setRegion(region, animated: true)
		
		self.activityIndicator.startAnimating()
		DataManager<Earth>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					let url = UrlHandling.getURL(imageUrl: photo.url)
					guard let urlToLoad = url else { return }
					Nuke.loadImage(with: urlToLoad, into: self.image) { response, _ in
						self.image?.image = response?.image
						self.activityIndicator.stopAnimating()
					}
					self.dateLabel.text = "\(photo.date)"
					self.locationLabel.text = annotation.title
					self.coordinatesLabel.text = "\(EarthSearch.earthSearch.latitude), \(EarthSearch.earthSearch.longitude)"
				}
			case .failure(let error):
				DispatchQueue.main.async {
					switch error {
					case Errors.networkError:
						self.showAlert(title: "Networking failed", message: "\(Errors.networkError.localizedDescription)")
					default:
						self.showAlert(title: "Networking failed", message: "\(error.localizedDescription)")
					}
				}
			}
		}
	}

	// MARK: IBActions
	
	@IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
		if sender.state == .ended {
			let tappedLocation = sender.location(in: mapView)
			let coordinate = mapView.convert(tappedLocation, toCoordinateFrom: mapView)
			let placemark = MKPlacemark(coordinate: coordinate)
			EarthSearch.earthSearch.latitude = placemark.coordinate.latitude
			EarthSearch.earthSearch.longitude = placemark.coordinate.longitude
			locationFromMapTap = true
			updateLocation(location: placemark)
		}
	}
	
	
	@IBAction func importContactButtonTapped(_ sender: UIButton) {
		let contactPicker = CNContactPickerViewController()
		contactPicker.delegate = self
		self.present(contactPicker, animated: true, completion: nil)
	}
	
}


// add location functionality
extension EarthViewController: CLLocationManagerDelegate, MKMapViewDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		// only show location on map if no location was chosen
		if usingCurrentLocation {
			if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude, let location = locations.last {
				print("current location: \(lat) \(long)")
				let regionRadius: CLLocationDistance = 1000
				
				let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
				mapView.setRegion(region, animated: true)
				
				if let lastLocation = self.locationManager.location {
					let geocoder = CLGeocoder()
					
					// look up the location name
					geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
						if error == nil {
							guard let firstLocation = placemarks?[0] else { return }
							self.locationLabel.text = LocationManager.parseAddress(selectedItem: firstLocation)
						}
						else {
							// an error occurred during geocoding
							print("error")
						}
					})
				} else {
					showAlert(title: "Geolocation failed", message: "Coordinates could not be found. Please check that location services are enabled.")
				}
			}
		} else {
			return
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		showAlert(title: "Geolocation failed", message: "\(error)")
	}
}

extension EarthViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
	// function needed to satisfy compiler
	func updateSearchResults(for searchController: UISearchController) {
	}
}

extension EarthViewController: MapUpdaterDelegate {
	func updateMapLocation(for location: MKPlacemark) {
		updateLocation(location: location)
	}
}

extension EarthViewController: CNContactPickerDelegate {
	func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
		guard let address = contact.postalAddresses.first?.value else { return }
		locationFromMapTap = false
		
		let geocoder = CLGeocoder()
		geocoder.geocodePostalAddress(address) { (placemarks, error) in
			if error == nil {
				guard let placemark = placemarks?[0], let location = placemark.location else { return }
					let locale = MKPlacemark(coordinate: location.coordinate, postalAddress: address)
				
					EarthSearch.earthSearch.latitude = locale.coordinate.latitude
					EarthSearch.earthSearch.longitude = locale.coordinate.longitude
					self.updateLocation(location: locale)
					print("did geocoding")
					return
				} else {
				self.showAlert(title: "Location not found", message: "The location could not be found, please try another selection")
			}
		}
	}
}

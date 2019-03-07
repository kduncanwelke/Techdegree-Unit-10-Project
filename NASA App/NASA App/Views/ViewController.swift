//
//  ViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var dailyPhoto: UIImageView!
	@IBOutlet weak var roverPhoto: UIImageView!
	@IBOutlet weak var earthPhoto: UIImageView!
	
	@IBOutlet weak var dailyPhotoTitle: UILabel!
	@IBOutlet weak var marsPhotoTitle: UILabel!
	@IBOutlet weak var earthPhotoTitle: UILabel!
	
	
	// MARK: Variables
	
	var currentDaily: Daily?
	var currentRover: Mars?
	var currentEarth: Earth?
	let locationManager = CLLocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		print(MarsSearch.marsSearch.rover)
		print(MarsSearch.marsSearch.sol)
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestLocation()
		locationManager.startUpdatingLocation()
		
		DataManager<Daily>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				//print(response)
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					self.currentDaily = photo
					self.dailyPhoto.getImage(imageUrl: photo.url)
					self.dailyPhotoTitle.text = photo.title
					self.dailyPhotoTitle.adjustsFontSizeToFitWidth = true
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
		
		DataManager<Mars>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				//print(response)
				DispatchQueue.main.async {
					guard let image = response.first?.photos.first?.imgSrc else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					self.currentRover = response.first
					self.roverPhoto.getImage(imageUrl: image)
					guard let title = response.first?.photos.first else { return }
					self.marsPhotoTitle.text = "\(title.rover.name), \(title.earthDate)"
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
		
		DataManager<Earth>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				//print(response)
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					self.currentEarth = photo
					self.earthPhoto.getImage(imageUrl: photo.url)
					self.earthPhotoTitle.text = "\(EarthSearch.earthSearch.latitude), \(EarthSearch.earthSearch.longitude)"
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
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is APODViewController {
			let destinationViewController = segue.destination as? APODViewController
			guard let current = currentDaily else { return }
			destinationViewController?.dailyPhoto = current
			destinationViewController?.photo = dailyPhoto.image
		} else if segue.destination is MarsRoverViewController {
			let destinationViewController = segue.destination as? MarsRoverViewController
			guard let current = currentRover else { return }
			destinationViewController?.photo = roverPhoto.image
			destinationViewController?.roverTitle = current.photos.first?.rover.name
			destinationViewController?.date = current.photos.first?.earthDate
			if let martianYear = current.photos.first?.sol {
				destinationViewController?.sol = String(martianYear)
			}
			destinationViewController?.cameraName = current.photos.first?.camera.name
			destinationViewController?.fullCameraName = current.photos.first?.camera.fullName
		} else if segue.destination is EarthViewController {
			let destinationViewController = segue.destination as? EarthViewController
			guard let current = currentEarth else { return }
			destinationViewController?.photo = earthPhoto.image
			destinationViewController?.date = current.date
		}
	}
	
	// MARK: IBActions
	
	@IBAction func dailyPhotoTapped(_ sender: Any) {
		performSegue(withIdentifier: "showAPOD", sender: Any?.self)
	}
	
	@IBAction func marsPhotoTapped(_ sender: Any) {
		performSegue(withIdentifier: "showMars", sender: Any?.self)
	}
	
	@IBAction func earthPhotoTapped(_ sender: Any) {
		performSegue(withIdentifier: "showEarth", sender: Any?.self)
	}
}

extension ViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude, let location = locations.last {
			print("current location: \(lat) \(long)")
			
			EarthSearch.earthSearch.latitude = lat
			EarthSearch.earthSearch.longitude = long
			
			earthPhotoTitle.text = "\(lat), \(long)"
			print("\(lat) \(long)")
		} else {
			showAlert(title: "Geolocation failed", message: "Coordinates could not be found. Please check that location services are enabled.")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		showAlert(title: "Geolocation failed", message: "\(error)")
	}
}

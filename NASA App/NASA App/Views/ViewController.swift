//
//  ViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreLocation
import Nuke
import WebKit

class ViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var dailyPhoto: UIImageView!
	@IBOutlet weak var roverPhoto: UIImageView!
	@IBOutlet weak var earthPhoto: UIImageView!
	
	@IBOutlet weak var dailyPhotoTitle: UILabel!
	@IBOutlet weak var marsPhotoTitle: UILabel!
	@IBOutlet weak var earthPhotoTitle: UILabel!
	
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var webview: WKWebView!
	
	
	@IBOutlet weak var dailyPhotoActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var roverPhotoActivityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var earthPhotoActivityIndicator: UIActivityIndicatorView!
	
	
	// MARK: Variables
	
	var currentDaily: Daily?
	var currentRover: Mars?
	var currentEarth: Earth?
	let locationManager = CLLocationManager()
	
	var isVideo = false
	var videoURL: URLRequest?
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		print(MarsSearch.marsSearch.rover)
		print(MarsSearch.marsSearch.sol)
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		//locationManager.requestLocation()
		locationManager.startUpdatingLocation()
		
		dailyPhotoActivityIndicator.startAnimating()
		DataManager<Daily>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					
					self.currentDaily = photo
					
					if photo.mediaType == "video" {
						self.isVideo = true
						guard let url = URL(string: photo.url) else { return }
						let request = URLRequest(url: url)
						self.videoURL = request
						self.webview?.load(request)
						self.dailyPhoto.isHidden = true
						self.dailyPhotoActivityIndicator.stopAnimating()
					} else {
						self.isVideo = false
						self.webview.isHidden = true
						self.currentDaily = photo
						let url = UrlHandling.getURL(imageUrl: photo.url)
						guard let urlToLoad = url else { return }
						Nuke.loadImage(with: urlToLoad, options: ImageInfo.options, into: self.dailyPhoto) { response, _ in
							self.dailyPhoto?.image = response?.image
							self.dailyPhotoActivityIndicator.stopAnimating()
						}
					}
				
					self.dailyPhotoTitle.text = photo.title
					self.dailyPhotoTitle.adjustsFontSizeToFitWidth = true
				}
			case .failure(let error):
				DispatchQueue.main.async {
					switch error {
					case Errors.networkError:
						self.dailyPhotoActivityIndicator.stopAnimating()
						self.showAlert(title: "Networking failed", message: "\(Errors.networkError.localizedDescription)")
					default:
						self.dailyPhotoActivityIndicator.stopAnimating()
						self.showAlert(title: "Networking failed", message: "\(error.localizedDescription)")
					}
				}
			}
		}
		
		getRandomMarsPhoto()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	// MARK: Custom functions
	
	func getEarthPhoto() {
		earthPhotoActivityIndicator.startAnimating()
		DataManager<Earth>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					self.currentEarth = photo
					let url =  UrlHandling.getURL(imageUrl: photo.url)
					guard let urlToLoad = url else { return }
					Nuke.loadImage(with: urlToLoad, options: ImageInfo.options, into: self.earthPhoto) { response, _ in
						self.earthPhoto?.image = response?.image
						self.earthPhotoActivityIndicator.stopAnimating()
					}
					
					self.earthPhotoTitle.text = "\(EarthSearch.earthSearch.latitude), \(EarthSearch.earthSearch.longitude)"
				}
			case .failure(let error):
				DispatchQueue.main.async {
					switch error {
					case Errors.networkError:
						self.earthPhotoActivityIndicator.stopAnimating()
						self.showAlert(title: "Networking failed", message: "\(Errors.networkError.localizedDescription)")
					default:
						self.earthPhotoActivityIndicator.stopAnimating()
						self.showAlert(title: "Networking failed", message: "\(error.localizedDescription)")
					}
				}
			}
		}
	}
	
	func getRandomMarsPhoto() {
		roverPhotoActivityIndicator.startAnimating()
		DataManager<Mars>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let image = response.first?.photos.first?.imgSrc else {
						//self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						
						MarsSearch.marsSearch.sol = Int.random(in: 0...2200)
						print("re-randomized results")
						self.getRandomMarsPhoto()
						return
					}
					self.currentRover = response.first
					let url =  UrlHandling.getURL(imageUrl: image)
					guard let urlToLoad = url else { return }
					Nuke.loadImage(with: urlToLoad, options: ImageInfo.options, into: self.roverPhoto) { response, _ in
						self.roverPhoto?.image = response?.image
						self.roverPhotoActivityIndicator.stopAnimating()
					}
					
					guard let title = response.first?.photos.first else { return }
					self.marsPhotoTitle.text = "\(title.rover.name), \(title.earthDate)"
				}
			case .failure(let error):
				DispatchQueue.main.async {
					switch error {
					case Errors.networkError:
						self.roverPhotoActivityIndicator.stopAnimating()
						self.showAlert(title: "Networking failed", message: "\(Errors.networkError.localizedDescription)")
					default:
						self.roverPhotoActivityIndicator.stopAnimating()
						self.showAlert(title: "Networking failed", message: "\(error.localizedDescription)")
					}
				}
			}
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is APODViewController {
			let destinationViewController = segue.destination as? APODViewController
			guard let current = currentDaily else { return }
			destinationViewController?.dailyPhoto = current
			destinationViewController?.photo = dailyPhoto.image
			destinationViewController?.isVideo = isVideo
			if isVideo {
				destinationViewController?.videoURL = videoURL
			}
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
			
			getEarthPhoto()
			
			earthPhotoTitle.text = "\(lat), \(long)"
			
			locationManager.stopUpdatingLocation()
		} else {
			showAlert(title: "Geolocation failed", message: "Coordinates could not be found. Please check that location services are enabled.")
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		showAlert(title: "Geolocation failed", message: "\(error)")
	}
}

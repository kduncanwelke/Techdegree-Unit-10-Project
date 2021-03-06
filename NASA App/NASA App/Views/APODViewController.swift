//
//  APODViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/28/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import Nuke
import WebKit

class APODViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var webview: WKWebView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var explanationLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var webActivityIndicator: UIActivityIndicatorView!
	
	
	// MARK: Variables
	
	let firstDate = Date()
	var currentDateDisplayed = Date()
	let dateFormatter = DateFormatter()
	var isVideo = false
	var videoURL: URLRequest?
	
	var photo: UIImage?
	var photoTitle: String?
	var date: String?
	var explanation: String?
	
	var dailyPhoto: Daily?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		guard let currentPhoto = dailyPhoto else { return }
		titleLabel.text = currentPhoto.title
		dateLabel.text = currentPhoto.date
		explanationLabel.text = currentPhoto.explanation
		
		// set up view depending on if APOD is video or not
		if isVideo {
			image.isHidden = true
			webview.isHidden = false
			guard let url = videoURL else { return }
			self.webview?.load(url)
		} else {
			image.isHidden = false
			webview.isHidden = true
			image.image = photo
		}
    }

	
	// MARK: Custom functions
	
	// when selection is changed, reconfigure view
	func updateUI(for photo: Daily) {
		if photo.mediaType == "video" {
			activityIndicator.stopAnimating()
			webActivityIndicator.startAnimating()
			isVideo = true
			image.isHidden = true
			webview.isHidden = false
			guard let url = URL(string: photo.url) else { return }
			let request = URLRequest(url: url)
			self.videoURL = request
			self.webview?.load(request)
			webActivityIndicator.stopAnimating()
		} else {
			isVideo = false
			image.isHidden = false
			webview.isHidden = true
			let url = UrlHandling.getURL(imageUrl: photo.url)
			guard let urlToLoad = url else { return }
			
			// load image with Nuke
			Nuke.loadImage(with: urlToLoad, options: ImageInfo.options, into: image) { [unowned self] response, _ in
				self.image?.image = response?.image
				self.activityIndicator.stopAnimating()
			}
		}
		titleLabel.text = photo.title
		dateLabel.text = photo.date
		explanationLabel.text = photo.explanation
	}
	
	// get new APOD result
	func executeFetch() {
		self.activityIndicator.startAnimating()
		DataManager<Daily>.fetch(with: nil) { [unowned self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					self.dailyPhoto = photo
					
					guard let currentPhoto = self.dailyPhoto else { return }
					self.updateUI(for: currentPhoto)
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
	
	// turn date into string to pass into search
	func getDate(date: Date?) {
		guard let dateToStringify = date else { return }
		let dateString = dateFormatter.string(from: dateToStringify)
		print(dateString)
		currentDateDisplayed = dateToStringify
		
		DailyPhotoSearch.photoSearch.date = dateString
		executeFetch()
	}
	
	
	// MARK: Navigation
	
	// shows view where user can zoom on photo
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is ZoomViewController {
			let destinationViewController = segue.destination as? ZoomViewController
			destinationViewController?.image = image.image
		}
	}
	
	// MARK: IBActions
	
	@IBAction func nextButtonPressed(_ sender: Any) {
		let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDateDisplayed)
		getDate(date: previousDay)
	}
	
	@IBAction func searchButtonPressed(_ sender: Any) {
		performSegue(withIdentifier: "searchByDate", sender: Any?.self)
	}

	@IBAction func backButtonPressed(_ sender: Any) {
		if currentDateDisplayed == firstDate {
			print("dates equal")
			// don't go back a day if there is no more recent result
			return
		} else {
			let soonerDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDateDisplayed)
			getDate(date: soonerDay)
		}
	}
	
	@IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
		performSegue(withIdentifier: "showPhoto", sender: Any?.self)
	}
	
	// if returning from search, reload view
	@IBAction func unwindToAPOD(segue: UIStoryboardSegue) {
		executeFetch()
	}
	
}



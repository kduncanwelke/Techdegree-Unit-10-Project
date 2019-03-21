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
		guard let currentPhoto = dailyPhoto else { return }
		titleLabel.text = currentPhoto.title
		dateLabel.text = currentPhoto.date
		explanationLabel.text = currentPhoto.explanation
		
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
	
		self.activityIndicator.hidesWhenStopped = true
		
		image.addSubview(self.activityIndicator)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: Custom functions
	
	func updateUI(for photo: Daily) {
		if photo.mediaType == "video" {
			isVideo = true
			image.isHidden = true
			webview.isHidden = false
			guard let url = URL(string: photo.url) else { return }
			let request = URLRequest(url: url)
			self.videoURL = request
			self.webview?.load(request)
			self.activityIndicator.stopAnimating()
		} else {
			isVideo = false
			image.isHidden = false
			webview.isHidden = true
			let url = UrlHandling.getURL(imageUrl: photo.url)
			guard let urlToLoad = url else { return }
			Nuke.loadImage(with: urlToLoad, options: ImageInfo.options, into: image) { [unowned self] response, _ in
				self.image?.image = response?.image
				self.activityIndicator.stopAnimating()
			}
		}
		titleLabel.text = photo.title
		dateLabel.text = photo.date
		explanationLabel.text = photo.explanation
	}
	
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is ZoomViewController {
			let destinationViewController = segue.destination as? ZoomViewController
			destinationViewController?.image = image.image
		}
	}
	
	// MARK: IBActions
	
	@IBAction func nextButtonPressed(_ sender: Any) {
		let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDateDisplayed)
		guard let dateToStringify = previousDay else { return }
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let dateString = dateFormatter.string(from: dateToStringify)
		print(dateString)
		currentDateDisplayed = dateToStringify
		
		DailyPhotoSearch.photoSearch.date = dateString
		executeFetch()
	}
	

	@IBAction func backButtonPressed(_ sender: Any) {
		if currentDateDisplayed == firstDate {
			print("dates equal")
			return
		} else {
			let soonerDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDateDisplayed)
			guard let dateToStringify = soonerDay else { return }
			dateFormatter.dateFormat = "yyyy-MM-dd"
			let dateString = dateFormatter.string(from: dateToStringify)
			print(dateString)
			currentDateDisplayed = dateToStringify
			
			DailyPhotoSearch.photoSearch.date = dateString
			executeFetch()
		}
	}
	
	@IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
		performSegue(withIdentifier: "showPhoto", sender: Any?.self)
	}
	
}



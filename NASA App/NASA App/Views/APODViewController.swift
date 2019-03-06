//
//  APODViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/28/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class APODViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var explanationLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	let firstDate = Date()
	var currentDateDisplayed = Date()
	let dateFormatter = DateFormatter()
	
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
		image.image = photo
	
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
	
	func updateUI(for photo: Daily) {
		image.getImage(imageUrl: photo.url)
		titleLabel.text = photo.title
		dateLabel.text = photo.date
		explanationLabel.text = photo.explanation
	}
	
	func executeFetch() {
		self.activityIndicator.startAnimating()
		DataManager<Daily>.fetch(with: nil) { result in
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
					
					self.activityIndicator.stopAnimating()
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
	
}



//
//  ViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var dailyPhoto: UIImageView!
	@IBOutlet weak var roverPhoto: UIImageView!
	@IBOutlet weak var earthPhoto: UIImageView!
	
	@IBOutlet weak var dailyPhotoTitle: UILabel!
	@IBOutlet weak var marsPhotoTitle: UILabel!
	@IBOutlet weak var earthPhotoTitle: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		DataManager<Daily>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				print(response)
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
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
				print(response)
				DispatchQueue.main.async {
					guard let image = response.first?.photos.first?.imgSrc else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
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
				print(response)
				DispatchQueue.main.async {
					guard let photo = response.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
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
}


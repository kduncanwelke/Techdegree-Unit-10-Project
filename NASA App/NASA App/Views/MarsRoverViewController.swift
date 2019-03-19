//
//  MarsRoverViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/28/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import Nuke

class MarsRoverViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var cameraLabel: UILabel!
	@IBOutlet weak var fullCameraNameLabel: UILabel!
	@IBOutlet weak var solLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	@IBOutlet weak var randomizeButton: UIButton!
	@IBOutlet weak var refineSearchButton: UIButton!
	@IBOutlet weak var postcardButton: UIButton!
	
	
	// MARK: Variables
	
	var marsPhotos: [Photo] = []
	var currentPage = 1
	
	var photo: UIImage?
	var roverTitle: String?
	var date: String?
	var sol: String?
	var cameraName: String?
	var fullCameraName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
		currentPage = 1
		
		collectionView.delegate = self
		collectionView.dataSource = self
		collectionView.prefetchDataSource = self

        // Do any additional setup after loading the view.
		image.image = photo
		titleLabel.text = roverTitle
		dateLabel.text = date
		solLabel.text = sol
		cameraLabel.text = cameraName
		fullCameraNameLabel.text = fullCameraName
		
		randomizeButton.layer.cornerRadius = 10
		refineSearchButton.layer.cornerRadius = 10
		postcardButton.layer.cornerRadius = 10
		
		loadData()
    }
	
	
	// MARK: Custom functions
	
	func loadData() {
		DataManager<Mars>.fetch(with: currentPage) { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let response = response.first?.photos, let first = response.first else {
						//self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						MarsSearch.marsSearch.sol = Int.random(in: 0...2200)
						print("re-randomized results")
						self.loadData()
						return
					}
					
					self.loadUI(photo: first)
					for photo in response {
						self.marsPhotos.append(photo)
					}
					self.collectionView.reloadData()
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
	
	func loadUI(photo: Photo) {
		activityIndicator.startAnimating()
		let url = UrlHandling.getURL(imageUrl: photo.imgSrc)
		guard let urlToLoad = url else { return }
		Nuke.loadImage(with: urlToLoad, options: ImageInfo.options, into: image) { response, _ in
			self.image?.image = response?.image
			self.activityIndicator.stopAnimating()
		}
		titleLabel.text = photo.rover.name
		dateLabel.text = photo.earthDate
		solLabel.text = "\(photo.sol)"
		cameraLabel.text = photo.camera.name
		fullCameraNameLabel.text = photo.camera.fullName
	}
	
	func fetchMorePhotos() {
		currentPage += 1
		DataManager<Mars>.fetch(with: currentPage) { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let response = response.first?.photos else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					
					for photo in response {
						self.marsPhotos.append(photo)
						self.collectionView.insertItems(at: [IndexPath(item: self.marsPhotos.count - 1, section: 0)])
					}

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is PostcardViewController {
			let destinationViewController = segue.destination as? PostcardViewController
			destinationViewController?.photo = image.image
			destinationViewController?.roverName = roverTitle
			destinationViewController?.date = date
		} else if segue.destination is ZoomViewController {
			let destinationViewController = segue.destination as? ZoomViewController
			destinationViewController?.image = image.image
		}
	}
	
	// MARK: IBActions
	
	@IBAction func unwindToRover(segue: UIStoryboardSegue) {
		marsPhotos.removeAll()
		viewDidLoad()
	}

	
	@IBAction func randomizeButtonPressed(_ sender: UIButton) {
		sender.animateButton()
		
		MarsSearch.marsSearch.sol = Int.random(in: 0...2200)
		MarsSearch.marsSearch.rover = {
			let randomRover = Int.random(in: 1...3)
			if randomRover == 1 {
				return MarsSearch.Rover.curiosity
			} else if randomRover == 2 {
				return MarsSearch.Rover.opportunity
			} else if randomRover == 3 {
				return MarsSearch.Rover.spirit
			} else {
				return MarsSearch.Rover.noSelection
			}
		}()
		
		// reset pagination
		currentPage = 1
		marsPhotos.removeAll()
		
		loadData()
		if marsPhotos.count > 0 {
			collectionView.scrollsToTop = true
		}
	}
	
	@IBAction func refineSearchButtonPressed(_ sender: UIButton) {
		sender.animateButton()
		performSegue(withIdentifier: "refineSearch", sender: Any?.self)
	}
	
	@IBAction func postcardButtonPressed(_ sender: UIButton) {
		sender.animateButton()
		performSegue(withIdentifier: "makePostcard", sender: Any?.self)
	}
	
	@IBAction func photoTapped(_ sender: UITapGestureRecognizer) {
		performSegue(withIdentifier: "zoomPhoto", sender: Any?.self)
	}
}

extension MarsRoverViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return marsPhotos.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "marsCell", for: indexPath) as! MarsCollectionViewCell
		let url = UrlHandling.getURL(imageUrl: marsPhotos[indexPath.row].imgSrc)
		
		cell.cellActivityIndicator.startAnimating()
		if let urlToLoad = url {
			Nuke.loadImage(with: urlToLoad, options: ImageInfo.options, into: cell.image) { response, _ in
				cell.image?.image = response?.image
				cell.cellActivityIndicator.stopAnimating()
			}
		}
		return cell
	}
	
}

extension MarsRoverViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		fetchMorePhotos()
	}
}

extension MarsRoverViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		loadUI(photo: marsPhotos[indexPath.row])
	}
}

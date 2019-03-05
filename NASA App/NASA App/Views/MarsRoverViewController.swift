//
//  MarsRoverViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/28/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class MarsRoverViewController: UIViewController {
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var cameraLabel: UILabel!
	@IBOutlet weak var fullCameraNameLabel: UILabel!
	@IBOutlet weak var solLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
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
		image.getImage(imageUrl: photo.imgSrc)
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

}

extension MarsRoverViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return marsPhotos.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "marsCell", for: indexPath) as! MarsCollectionViewCell
		cell.image.getImage(imageUrl: marsPhotos[indexPath.row].imgSrc)
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

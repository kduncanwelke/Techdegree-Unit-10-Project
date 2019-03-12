//
//  PostcardViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/11/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreImage

class PostcardViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var collectionView: UICollectionView!
	
	// MARK: Variables
	
	var photo: UIImage?
	let context = CIContext()
	var currentFilter = ImageFilters.filters.first

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		collectionView.delegate = self
		collectionView.dataSource = self
		
		image.image = photo
		
		applyProcessing(photoToProcess: image)
    }
	
	func applyProcessing(photoToProcess: UIImageView) {
		//currentFilter?.setValue(intensity.value, forKey: kCIInputIntensityKey)
		guard let currentImage = photoToProcess.image else { return }
		let imageToUse = CIImage(image: currentImage)
		currentFilter?.setValue(imageToUse, forKey: kCIInputImageKey)
		
		guard let filter = currentFilter, let output = filter.outputImage else { return }
		if let cgImage = context.createCGImage(output, from: output.extent) {
			let processedImage = UIImage(cgImage: cgImage)
			photoToProcess.image = processedImage
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
	
	// MARK: IBActions
	
	@IBAction func cancelButtonTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}

}

extension PostcardViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return ImageFilters.filters.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postcardCell", for: indexPath) as! PostcardCollectionViewCell
		cell.imageView.image = photo
		cell.label.text = ImageFilters.filters[indexPath.row].name
		cell.activityIndicator.startAnimating()
		currentFilter = ImageFilters.filters[indexPath.row]
		applyProcessing(photoToProcess: cell.imageView)
		cell.activityIndicator.stopAnimating()
		return cell
	}
}

extension PostcardViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let currentCell = collectionView.cellForItem(at: indexPath) as! PostcardCollectionViewCell
		
		image.image = currentCell.imageView.image
	}
}

//
//  PostcardViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/11/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreImage
import CoreGraphics

class PostcardViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var textField: UITextField!
	
	
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
	
	func textToImage(text: String, image: UIImage) -> UIImage {
		UIGraphicsBeginImageContext(image.size)
		
		image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
	
		let font = UIFont(name: "Helvetica-Bold", size: 32)!
		let textStyle = NSMutableParagraphStyle()
		textStyle.alignment = NSTextAlignment.center
		let textColor = UIColor.white
		let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: textStyle, NSAttributedString.Key.foregroundColor: textColor]
		
		//vertically center (depending on font)
		let textHeight = font.lineHeight
		let textY = (image.size.height) / 2
		let textRect = CGRect(x: 0, y: textY, width: image.size.width, height: textHeight)
		text.draw(in: textRect.integral, withAttributes: attributes)
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
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

	@IBAction func applyTextButtonPressed(_ sender: UIButton) {
		guard let imageToUse = image.image, let text = textField.text else { return }
		let newImage = textToImage(text: text, image: imageToUse)
		
		image.image = newImage
		
		textField.text = nil
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

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
import MessageUI

class PostcardViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var resetButton: UIButton!
	@IBOutlet weak var emailButton: UIButton!
	

	// MARK: Variables
	
	var photo: UIImage?
	var roverName: String?
	var date: String?
	let context = CIContext()
	var currentFilter = ImageFilters.filters.first

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		collectionView.delegate = self
		collectionView.dataSource = self
		
		resetButton.layer.cornerRadius = 10
		emailButton.layer.cornerRadius = 10
		
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
		let scale = UIScreen.main.scale
		UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
		
		image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
	
		let fontScaling = max(0.05 * image.size.width, 3.0)
		if let font = UIFont(name: "Helvetica-Bold", size: fontScaling) {
			let textStyle = NSMutableParagraphStyle()
			textStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
			textStyle.alignment = NSTextAlignment.center
			let textColor = UIColor.white
			let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: textStyle, NSAttributedString.Key.foregroundColor: textColor]
			
			// vertically center text
			let textHeight = font.lineHeight
			let textYPosition = (image.size.height / 2) - textHeight
			let textRect = CGRect(x: 0, y: textYPosition, width: image.size.width, height: image.size.height)
			text.draw(in: textRect.integral, withAttributes: attributes)
		}
			
			let roverFontScaling = max(0.02 * image.size.width, 3.0)
			if let roverFont = UIFont(name: "Helvetica-Bold", size: roverFontScaling) {
				let textColor = UIColor.white
				let textHeight = roverFont.lineHeight
				let roverAttributes = [NSAttributedString.Key.font: roverFont, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(), NSAttributedString.Key.foregroundColor: textColor]
				let roverInfoRect = CGRect(x: image.size.width / 10, y: (image.size.height / 4) - textHeight, width: image.size.width, height: image.size.height)
				
				
				if let name = roverName, let day = date {
					let roverInfoString = "\(name), \(day)"
					roverInfoString.draw(in: roverInfoRect.integral, withAttributes: roverAttributes)
				}
			}

			let newImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			return newImage!
		}
	
	func sendEmail() {
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			mail.setToRecipients(["darkhorse357@gmail.com"])
			mail.setSubject("Mars Rover Postcard")
			mail.setMessageBody("Image from NASA app", isHTML: false)
			guard let currentImage = image.image else { return }
			guard let imageData: Data = currentImage.pngData() else { return }
			mail.addAttachmentData(imageData, mimeType: "image/png", fileName: "RoverPhoto.png")
			present(mail, animated: true, completion: nil)
		} else {
			showAlert(title: "Email not available", message: "This device is not set up to send mail")
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

	@IBAction func applyTextButtonPressed(_ sender: UIButton) {
		guard let imageToUse = image.image, let text = textField.text else { return }
		let newImage = textToImage(text: text, image: imageToUse)
		
		image.image = newImage
	}
	
	
	@IBAction func resetButtonTapped(_ sender: UIButton) {
		image.image = photo
		textField.text = nil
	}
	
	
	@IBAction func emailButtonPressed(_ sender: UIButton) {
		sendEmail()
	}
	
}

extension PostcardViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return ImageFilters.filters.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postcardCell", for: indexPath) as! PostcardCollectionViewCell
		cell.imageView.image = photo
		let filterTitle = ImageFilters.filters[indexPath.row].name.dropFirst(2)
		cell.label.text = "\(filterTitle)"
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
		
		// if text field isn't empty, apply text to newly selected image
		if textField.text == "" {
			image.image = currentCell.imageView.image
		} else {
			guard let imageToUse = currentCell.imageView.image, let text = textField.text else { return }
		
			let newImage = textToImage(text: text, image: imageToUse)
			image.image = newImage
		}
	}
}

extension PostcardViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
}

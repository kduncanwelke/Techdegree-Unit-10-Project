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
	var currentFilter = ImageInfo.filters.first

	var photos: [PhotoInfo] = []
	let pendingOperations = PendingOperations()
	

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		collectionView.delegate = self
		collectionView.dataSource = self
		
		resetButton.layer.cornerRadius = 10
		emailButton.layer.cornerRadius = 10
		
		image.image = photo
		
		// create array of ImageInfo objects based on the number of filters that will be applied
		for _ in ImageInfo.filters {
			let imageToFilter = PhotoInfo()
			imageToFilter.image = photo
			photos.append(imageToFilter)
		}

		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
	
	// deal with screen display when keyboard is used
	@objc func keyboardWillShow(notification: NSNotification) {
		if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			if self.view.frame.origin.y == 0 {
				self.view.frame.origin.y -= keyboardSize.height
			}
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		if self.view.frame.origin.y != 0 {
			self.view.frame.origin.y = 0
		}
	}
	
	// use operations to apply filtering to a given image
	func startFiltration(for photo: PhotoInfo, at indexPath: IndexPath) {
		guard pendingOperations.filteringInProgress[indexPath] == nil else {
			return
		}
	
		guard let filterToUse = currentFilter else { return }
		let filterer = ImageFiltration(photo, filter: filterToUse)
		filterer.completionBlock = {
			if filterer .isCancelled {
				return
			}
			
			DispatchQueue.main.async {
				self.pendingOperations.filteringInProgress.removeValue(forKey: indexPath)
				self.collectionView.reloadItems(at: [indexPath])
			}
		}
		
		pendingOperations.filteringInProgress[indexPath] = filterer
		pendingOperations.filtrationQueue.addOperation(filterer)
	}
	
	// handle starting operations is given PhotoInfo object is in placeholder state
	func startOperations(for photo: PhotoInfo, at indexPath: IndexPath) {
		switch (photo.state) {
		case .placeholder:
			startFiltration(for: photo, at: indexPath)
		case .filtered:
			return
		}
	}
	
	// apply text onto image
	func textToImage(text: String, imageToUse: UIImage) -> UIImage {
		let scale = UIScreen.main.scale
		// start graphics context
		UIGraphicsBeginImageContextWithOptions(imageToUse.size, false, scale)
		
		imageToUse.draw(in: CGRect(x: 0, y: 0, width: imageToUse.size.width, height: imageToUse.size.height))
	
		// set font scale and position for entered based on image size to ensure consistency
		let fontScaling = 0.06 * imageToUse.size.height
		if let font = UIFont(name: "Helvetica-Bold", size: fontScaling) {
			// set paragraph style attributes
			let textStyle = NSMutableParagraphStyle()
			textStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
			textStyle.alignment = NSTextAlignment.center
			let textColor = UIColor.white
			let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: textStyle, NSAttributedString.Key.foregroundColor: textColor]
			
			// vertically center text
			let textHeight = font.lineHeight
			let textYPosition = (imageToUse.size.height - textHeight) / 2
			let textRect = CGRect(x: 0, y: textYPosition, width: imageToUse.size.width, height: imageToUse.size.height)
			
			// finally draw text on image
			text.draw(in: textRect.integral, withAttributes: attributes)
		}
		
		// set font scale and position for rover name and photo date text
			let roverFontScaling = 0.02 * imageToUse.size.height
			if let roverFont = UIFont(name: "Helvetica-Bold", size: roverFontScaling) {
				let textColor = UIColor.white
				let textHeight = roverFont.lineHeight
				let roverAttributes = [NSAttributedString.Key.font: roverFont, NSAttributedString.Key.paragraphStyle: NSMutableParagraphStyle(), NSAttributedString.Key.foregroundColor: textColor]
				let roverInfoRect = CGRect(x: 0.05 * imageToUse.size.width, y: (0.05 * imageToUse.size.height) - textHeight, width: imageToUse.size.width, height: imageToUse.size.height)
				
				// get rover name and date
				if let name = roverName, let day = date {
					let roverInfoString = "\(name), \(day)"
					
					// draw text on image
					roverInfoString.draw(in: roverInfoRect.integral, withAttributes: roverAttributes)
				}
			}

			// generate new image
			let newImage = UIGraphicsGetImageFromCurrentImageContext()
		
			// end graphics context
			UIGraphicsEndImageContext()
			
			return newImage!
		}
	
	// function to send email
	func sendEmail() {
		if MFMailComposeViewController.canSendMail() {
			let mail = MFMailComposeViewController()
			mail.mailComposeDelegate = self
			
			// ********** set email address here **********
			mail.setToRecipients(["darkhorse357@gmail.com"])
			
			mail.setSubject("Mars Rover Postcard")
			mail.setMessageBody("Image from NASA app", isHTML: false)
			guard let currentImage = image.image else { return }
			
			// turn image into data
			guard let imageData: Data = currentImage.pngData() else { return }
			
			// attach image to email
			mail.addAttachmentData(imageData, mimeType: "image/png", fileName: "RoverPhoto.png")
			
			// open email view
			present(mail, animated: true, completion: nil)
		} else {
			showAlert(title: "Email not available", message: "This device is not set up to send mail")
		}
	}

    // MARK: - Navigation

    // segue to view where user can zoom on image
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is ZoomViewController {
			let destinationViewController = segue.destination as? ZoomViewController
			destinationViewController?.image = image.image
		}
    }
	
	// MARK: IBActions
	
	@IBAction func cancelButtonTapped(_ sender: UIButton) {
		self.dismiss(animated: true, completion: nil)
	}

	// when text is entered into text field and applied, add to image
	@IBAction func applyTextButtonPressed(_ sender: UIButton) {
		guard let imageToUse = image.image, let text = textField.text else { return }
		let newImage = textToImage(text: text, imageToUse: imageToUse)
		
		image.image = newImage
		view.endEditing(true)
	}
	
	// reset all selections (this includes removing filter)
	@IBAction func resetButtonTapped(_ sender: UIButton) {
		sender.animateButton()
		image.image = photo
		textField.text = nil
	}
	
	// email current image
	@IBAction func emailButtonPressed(_ sender: UIButton) {
		sender.animateButton()
		sendEmail()
	}
	
	@IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
		performSegue(withIdentifier: "postcardPreview", sender: Any?.self)
	}
}


extension PostcardViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// show enough collection view cell to match number of filters
		return ImageInfo.filters.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postcardCell", for: indexPath) as! PostcardCollectionViewCell
		
		// photos will be from array of PhotoInfo objects created earlier
		let photoForCell = photos[indexPath.row]
		
		// set filter based on indexpath
		currentFilter = ImageInfo.filters[indexPath.row]
	
		// set title based on filter name
		let filterTitle = ImageInfo.filters[indexPath.row].name.dropFirst(2)
		cell.label.text = "\(filterTitle)"
		
		// switch on PhotoInfo item state, show placeholder if image needs filtering and start operations
		switch (photoForCell.state) {
		case .placeholder:
			cell.imageView.image = UIImage(named: "placeholder")
			cell.activityIndicator.startAnimating()
			startOperations(for: photoForCell, at: indexPath)
		case .filtered:
			// once image has been filtered show in cell and stop indicator
			cell.imageView.image = photoForCell.image
			cell.activityIndicator.stopAnimating()
		}
		
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
			
			// return newly created image with text
			let newImage = textToImage(text: text, imageToUse: imageToUse)
			image.image = newImage
		}
	}

extension PostcardViewController: MFMailComposeViewControllerDelegate {
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
}

//
//  Extensions.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/27/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit

// add reusable alert functionality
extension UIViewController {
	func showAlert(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
}

extension UIImageView {
	func getImage(imageUrl: String) {
		var chosenUrl = ""
		
		if imageUrl.hasPrefix("https") {
			chosenUrl = imageUrl
		} else {
			let http = imageUrl
			let https = "https" + http.dropFirst(4)
			chosenUrl = https
		}
		
		guard let url = URL(string: chosenUrl) else { return }
		
		URLSession.shared.dataTask(with: url) { (data, response, error) -> Void in
			if let error = error {
				print(error)
				return
			}
			DispatchQueue.main.async(execute: { () -> Void in
				let image = UIImage(data: data!)
				self.image = image
			})
		} .resume()
	}
}

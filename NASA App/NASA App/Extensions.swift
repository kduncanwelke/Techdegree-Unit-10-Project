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

extension UIView {
	func animateButton() {
		UIView.animate(withDuration: 0.2, animations: {
			self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
		}, completion: { _ in
			UIView.animate(withDuration: 0.2) {
			self.transform = CGAffineTransform.identity
			}
		})
	}
}

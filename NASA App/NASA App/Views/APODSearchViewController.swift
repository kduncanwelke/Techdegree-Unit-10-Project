//
//  APODSearchViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class APODSearchViewController: UIViewController {
	
	// MARK: Outlets

	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var submitButton: UIButton!
	
	let currentDate = Date()
	let dateFormatter = DateFormatter()
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		submitButton.layer.cornerRadius = 10
		
		// set up date picker
		datePicker.backgroundColor = UIColor.white
		datePicker.maximumDate = currentDate
    }

	
	// MARK: Actions
	
	// when submit is pressed, pass date into search to display new result
	@IBAction func submitButtonPressed(_ sender: UIButton) {
		sender.animateButton()
		let selectedDate = datePicker.date
		let dateString = dateFormatter.string(from: selectedDate)
		DailyPhotoSearch.photoSearch.date = dateString
			
		performSegue(withIdentifier: "unwindToAPOD", sender: self)
	}
	
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

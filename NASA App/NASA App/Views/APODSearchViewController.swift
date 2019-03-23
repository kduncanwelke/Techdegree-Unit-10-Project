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
		datePicker.backgroundColor = UIColor.white
		datePicker.maximumDate = currentDate
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	
	// MARK: Actions
	
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

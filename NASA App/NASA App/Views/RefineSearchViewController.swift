//
//  RefineSearchViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/9/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class RefineSearchViewController: UIViewController {
	
	// MARK: IBOutlets
	
	@IBOutlet weak var roverSelection: UISegmentedControl!
	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var viewResultsButton: UIButton!
	
	// MARK: Variables
	
	let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		datePicker.backgroundColor = UIColor.white
		dateFormatter.dateFormat = "yyyy-MM-dd"
		datePicker.isEnabled = false
		
		viewResultsButton.layer.cornerRadius = 10
    }
	
	
	// MARK: IBActions

	// set rover selection
	@IBAction func roverSelectionPressed(_ sender: UISegmentedControl) {
		switch roverSelection.selectedSegmentIndex {
		case 0:
			MarsSearch.marsSearch.rover = MarsSearch.Rover.curiosity
		case 1:
			MarsSearch.marsSearch.rover = MarsSearch.Rover.opportunity
		case 2:
			MarsSearch.marsSearch.rover = MarsSearch.Rover.spirit
		default:
			break
		}
		
		// reset date so it isn't sent in request
		MarsSearch.marsSearch.earthDate = nil
		MarsSearch.solDate = 1000
		
		// perform fetch based on rover in order to supply max and min dates to select
		DataManager<Mars>.fetch(with: nil) { [unowned self] result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let info = response.first?.photos.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
					
					// set date limitations in date picker
					let minDate = self.dateFormatter.date(from: info.rover.landingDate)
					let maxDate = self.dateFormatter.date(from: info.rover.maxDate)
					self.datePicker.minimumDate = minDate
					self.datePicker.maximumDate = maxDate
					self.datePicker.isEnabled = true
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
	
	// go back to main rover view if all items have been selected
	@IBAction func viewResultsButtonPressed(_ sender: UIButton) {
		sender.animateButton()
		if roverSelection.selectedSegmentIndex == -1 {
			showAlert(title: "Please make a selection", message: "A rover selection is required to narrow results")
		} else {
			 let selectedDate = datePicker.date
			 let dateString = dateFormatter.string(from: selectedDate)
			 MarsSearch.marsSearch.earthDate = dateString
			
			 performSegue(withIdentifier: "unwindToRover", sender: self)
		}
	}
	
	// pop back if search is cancelled
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}

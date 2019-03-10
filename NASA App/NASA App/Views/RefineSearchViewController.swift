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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
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
		
		DataManager<Mars>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				DispatchQueue.main.async {
					guard let info = response.first?.photos.first else {
						self.showAlert(title: "Connection failed", message: "Json response failed, please try again later.")
						return
					}
			   
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
	
	
	@IBAction func viewResultsButtonPressed(_ sender: Any) {
		let selectedDate = datePicker.date
		let dateString = dateFormatter.string(from: selectedDate)
		MarsSearch.marsSearch.earthDate = dateString
		
		performSegue(withIdentifier: "unwindToRover", sender: self)
	}
	
	@IBAction func cancelButtonPressed(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
}

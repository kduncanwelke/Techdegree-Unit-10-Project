//
//  EarthViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/28/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class EarthViewController: UIViewController {
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var locationLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	
	var photo: UIImage?
	var date: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		image.image = photo
		locationLabel.text = "Lat: \(EarthSearch.earthSearch.latitude), Long: \(EarthSearch.earthSearch.longitude)"
		let displayDate = date?.prefix(10)
		dateLabel.text = String(displayDate ?? "No date")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

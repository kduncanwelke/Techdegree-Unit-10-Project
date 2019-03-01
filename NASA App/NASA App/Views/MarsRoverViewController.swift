//
//  MarsRoverViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/28/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class MarsRoverViewController: UIViewController {
	
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var cameraLabel: UILabel!
	@IBOutlet weak var fullCameraNameLabel: UILabel!
	@IBOutlet weak var solLabel: UILabel!
	
	var photo: UIImage?
	var roverTitle: String?
	var date: String?
	var sol: String?
	var cameraName: String?
	var fullCameraName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		image.image = photo
		titleLabel.text = roverTitle
		dateLabel.text = date
		solLabel.text = sol
		cameraLabel.text = cameraName
		fullCameraNameLabel.text = fullCameraName
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

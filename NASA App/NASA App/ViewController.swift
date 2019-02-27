//
//  ViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
	let endpoint = Endpoint.mars
		print(endpoint.url(with: nil))
		DataManager<Mars>.fetch(with: 1) { result in
			switch result {
			case .success(let response):
				print(response)
			case .failure(let error):
				print(error)
			}
		}

		
	}
}


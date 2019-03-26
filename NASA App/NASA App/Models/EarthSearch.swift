//
//  EarthSearch.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// object to provide information for satellite earth imagery
struct EarthSearch {
	var latitude: Double
	var longitude: Double
	var dim: Float

	static var earthSearch = EarthSearch(latitude: 20.0, longitude: 100.0, dim: 0.1)
}

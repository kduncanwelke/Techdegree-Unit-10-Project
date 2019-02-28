//
//  MarsSearch.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct MarsSearch {
	var sol: Int
	var rover: Rover
	
	static var marsSearch = MarsSearch(sol: 50, rover: Rover.curiosity)
	
	enum Rover: String {
		case curiosity = "curiosity"
		case opportunity = "opportunity"
		case spirit = "spirit"
		case noSelection = "noSelection"
	}
}

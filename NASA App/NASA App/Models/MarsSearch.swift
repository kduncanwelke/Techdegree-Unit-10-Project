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
	var earthDate: String?
	
	static var solDate = Int.random(in: 0...2200)
	
	static var chosenRover: Rover = {
		let randomRover = Int.random(in: 1...3)
		if randomRover == 1 {
			return Rover.curiosity
		} else if randomRover == 2 {
			return Rover.opportunity
		} else if randomRover == 3 {
			return Rover.spirit
		} else {
			return Rover.noSelection
		}
	}()
	
	
	static var marsSearch = MarsSearch(sol: solDate, rover: chosenRover, earthDate: nil)
	
	enum Rover: String {
		case curiosity = "curiosity"
		case opportunity = "opportunity"
		case spirit = "spirit"
		case noSelection = "noSelection"
	}
}

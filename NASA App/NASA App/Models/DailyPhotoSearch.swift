//
//  DailyPhotoSearch.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// provide search parameters for APOD search
struct DailyPhotoSearch {
	var date: String
	
	// return today's photo by default, aka no date
	static var photoSearch = DailyPhotoSearch(date: "")
}

//
//  DailyPhotoSearch.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct DailyPhotoSearch {
	var date: String
	
	// return today's photo by default
	static var photoSearch = DailyPhotoSearch(date: "")
}

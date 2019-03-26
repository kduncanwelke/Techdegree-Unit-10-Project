//
//  UrlHandling.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/8/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct UrlHandling {
	// ensure urls come as https, some come in http format and need to be converted
	static func getURL(imageUrl: String) -> URL? {
		var chosenUrl = ""
		
		if imageUrl.hasPrefix("https") {
			chosenUrl = imageUrl
		} else {
			let http = imageUrl
			let https = "https" + http.dropFirst(4)
			chosenUrl = https
		}
		
		let url = URL(string: chosenUrl)
		
		return url
	}
}

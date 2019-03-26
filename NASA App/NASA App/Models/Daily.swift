//
//  Daily.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// daily photo type for APOD parsing
struct Daily: SearchType {
	var date: String
	let title: String
	let explanation: String
	let url: String
	let mediaType: String
	static var endpoint = Endpoint.dailyPhoto
}

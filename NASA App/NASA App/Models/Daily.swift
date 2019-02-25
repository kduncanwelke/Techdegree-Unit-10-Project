//
//  Daily.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Daily: SearchType {
	let copyright: String
	let date: String
	let title: String
	let explanation: String
	let url: String
	static var endpoint = Endpoint.dailyPhoto
}

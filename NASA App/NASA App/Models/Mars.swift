//
//  Mars.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Mars: SearchType {
	let imgSrc: String
	let earthDate: String
	static var endpoint = Endpoint.mars
}

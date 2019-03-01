//
//  Mars.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct Mars: SearchType {
	let photos: [Photo]
	static var endpoint = Endpoint.mars
}

struct Photo: Codable {
	let sol: Int
	let imgSrc: String
	let earthDate: String
	let camera: Camera
	let rover: Rover
}

struct Camera: Codable {
	let name: String
	let fullName: String
}

struct Rover: Codable {
	let name: String
	let landingDate: String
	let maxDate: String
}

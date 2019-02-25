//
//  HandleResponse.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

struct HandleResponse<T: Codable>: Codable {
	var photos: [T]?
}

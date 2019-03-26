//
//  SearchType.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// protocol for search types, used for generics in data manager
protocol SearchType: Codable {
	static var endpoint: Endpoint { get }
}

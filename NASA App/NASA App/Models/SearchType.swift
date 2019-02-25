//
//  SearchType.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

protocol SearchType: Codable {
	static var endpoint: Endpoint { get }
}

//
//  Errors.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

// error to be used in the case of bad access to network
enum Errors: Error {
	case networkError
	
	var localizedDescription: String {
		switch self {
		case .networkError:
			return "The network could not be reached successfully - check your data connection or api key"
		}
	}
}

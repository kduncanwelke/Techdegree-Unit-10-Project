//
//  Result.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

enum Result<Value> {
	case success(Value)
	case failure(Error)
}

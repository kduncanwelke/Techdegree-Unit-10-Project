//
//  Protocols.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/7/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import MapKit

// handle updating map location when locale is changed
protocol MapUpdaterDelegate: class {
	func updateMapLocation(for: MKPlacemark)
}

//
//  ImageFilters.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/12/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreImage

struct ImageFilters {
	static let filters: [CIFilter] = [
		CIFilter(name: "CISepiaTone")!,
		CIFilter(name: "CIColorPolynomial")!,
		CIFilter(name: "CIColorControls")!,
		CIFilter(name: "CIVibrance")!,
		CIFilter(name: "CIColorCube")!,
		CIFilter(name: "CIPhotoEffectNoir")!,
		CIFilter(name: "CIVignetteEffect")!,
		CIFilter(name: "CIColorMatrix")!
	]
}

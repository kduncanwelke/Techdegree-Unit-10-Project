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
		CIFilter(name: "CIVignette")!,
		CIFilter(name: "CIColorMatrix")!,
		CIFilter(name: "CIBoxBlur")!,
		CIFilter(name: "CIColorPosterize")!,
		CIFilter(name: "CICircleSplashDistortion")!,
		CIFilter(name: "CICircularScreen")!,
		CIFilter(name: "CIDotScreen")!,
		CIFilter(name: "CICrystallize")!,
		CIFilter(name: "CIPixellate")!,
		CIFilter(name: "CIKaleidoscope")!
	]
}

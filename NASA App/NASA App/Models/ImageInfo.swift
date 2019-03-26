//
//  ImageFilters.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/12/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import CoreImage
import UIKit
import Nuke

// list of filters included in rover postcard generation
struct ImageInfo {
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
		CIFilter(name: "CICircularScreen")!,
		CIFilter(name: "CIDotScreen")!,
		CIFilter(name: "CICrystallize")!,
		CIFilter(name: "CIPixellate")!,
		CIFilter(name: "CIKaleidoscope")!
	]
	
	// loading options used by Nuke
	static let options = ImageLoadingOptions(placeholder: UIImage(named: "ipad_background_hori_x2"), transition: .fadeIn(duration: 0.33))
}

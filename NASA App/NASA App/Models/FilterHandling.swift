//
//  FilteringHandling.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/25/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

enum PhotoState {
	case placeholder
	case filtered
}

class PhotoInfo {
	var state = PhotoState.placeholder
	var image = UIImage(named: "placeholder")
}

class PendingOperations {
	lazy var filteringInProgress: [IndexPath: Operation] = [:]
	lazy var filtrationQueue: OperationQueue = {
		var queue = OperationQueue()
		queue.name = "image filtration queue"
		return queue
	}()
}

class ImageFiltration: Operation {
	let photoInfo: PhotoInfo
	var filter: CIFilter
	
	init(_ photoInfo: PhotoInfo, filter: CIFilter) {
		self.photoInfo = photoInfo
		self.filter = filter
	}
	
	override func main() {
		if isCancelled {
			return
		}
		
		func applyProcessing(photoToProcess: UIImage, filter: CIFilter) -> UIImage? {
			let imageToUse = CIImage(image: photoToProcess)
			
			if isCancelled {
				return nil
			}
			
			let currentFilter = filter
			currentFilter.setValue(imageToUse, forKey: kCIInputImageKey)
			
			let context = CIContext()
			
			if isCancelled {
				return nil
			}
			
			guard let output = currentFilter.outputImage else { return nil }
			if let cgImage = context.createCGImage(output, from: output.extent) {
				let processedImage = UIImage(cgImage: cgImage)
				let filteredImage = processedImage
				return filteredImage
			} else {
				return nil
			}
		}
		
		if let image = photoInfo.image, let filteredImage = applyProcessing(photoToProcess: image, filter: filter) {
			photoInfo.image = filteredImage
			photoInfo.state = .filtered
		}
	}
}

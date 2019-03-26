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

// object to be used to handle photos and filtering
class PhotoInfo {
	var state = PhotoState.placeholder
	var image = UIImage(named: "placeholder")
}

// management for operations used by filtering process
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
	
	// check if process has been cancelled
	override func main() {
		if isCancelled {
			return
		}
		
		// apply given filter to given image and return filtered image
		func applyProcessing(photoToProcess: UIImage, filter: CIFilter) -> UIImage? {
			let imageToUse = CIImage(image: photoToProcess)
			
			if isCancelled {
				return nil
			}
			
			// set filter
			let currentFilter = filter
			currentFilter.setValue(imageToUse, forKey: kCIInputImageKey)
			
			// create context
			let context = CIContext()
			
			if isCancelled {
				return nil
			}
			
			// create filtered image and return it
			guard let output = currentFilter.outputImage else { return nil }
			if let cgImage = context.createCGImage(output, from: output.extent) {
				let processedImage = UIImage(cgImage: cgImage)
				let filteredImage = processedImage
				return filteredImage
			} else {
				return nil
			}
		}
		
		// assign filtered image to PhotoInfo object and set state to filtered
		if let image = photoInfo.image, let filteredImage = applyProcessing(photoToProcess: image, filter: filter) {
			photoInfo.image = filteredImage
			photoInfo.state = .filtered
		}
	}
}

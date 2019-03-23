//
//  ZoomViewController.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 3/18/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit

class ZoomViewController: UIViewController {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var imageView: UIImageView!
	
	@IBOutlet weak var imageTop: NSLayoutConstraint!
	@IBOutlet weak var imageTrailing: NSLayoutConstraint!
	@IBOutlet weak var imageLeading: NSLayoutConstraint!
	@IBOutlet weak var imageBottom: NSLayoutConstraint!
	
	var image: UIImage?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		scrollView.delegate = self
		
		guard let imageToZoom = image else { return }
		imageView.image = imageToZoom
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
		scrollView.addGestureRecognizer(tap)
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateZoom(view.bounds.size)
	}
	
	
	@objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
		dismiss(animated: true, completion: nil)
	}
	
	
	func updateZoom(_ size: CGSize) {
		let boundsSize = view.bounds.size
		let imageSize = imageView.bounds.size
		
		let xScale = boundsSize.width / imageSize.width
		let yScale = boundsSize.height / imageSize.height
		
		let maxScale = max(xScale, yScale)
		
		scrollView.maximumZoomScale = maxScale
		scrollView.minimumZoomScale = 1
	}
	
	func centerImage() {
		// center the zoom view as it becomes smaller than the size of the screen
		let boundsSize = view.bounds.size
		var frameToCenter = scrollView?.frame ?? CGRect.zero
		
		// center horizontally
		if frameToCenter.size.width < boundsSize.width {
			frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
		} else {
			frameToCenter.origin.x = 0
		}
		
		// center vertically
		if frameToCenter.size.height < boundsSize.height {
			frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2
		} else {
			frameToCenter.origin.y = 0
		}
		
		scrollView?.frame = frameToCenter
	}
}

extension ZoomViewController: UIScrollViewDelegate {
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return imageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		centerImage()
	}
}

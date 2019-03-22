//
//  NASA_AppTests.swift
//  NASA AppTests
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import XCTest
@testable import NASA_App
import CoreLocation
import MapKit

class NASA_AppTests: XCTestCase {
	
	var testSession: URLSession!
	

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
		super.setUp()
		testSession = URLSession(configuration: .default)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
		testSession = nil
		super.tearDown()
    }

    func testFor200Code() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		
		let promise = expectation(description: "Status code: 200")
		let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY")
		var statusCode: Int?
		var responseError: Error?
		
		_ = testSession.dataTask(with: url!) { data, response, error in
			statusCode = (response as? HTTPURLResponse)?.statusCode
			responseError = error
			promise.fulfill()
		} .resume()
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertEqual(statusCode, 200)
    }
	
	func testDailyPhotoParsing() {
		let promise = expectation(description: "Daily item returned")
		var dailyPhoto: Daily?
		var responseError: Error?
		
		DataManager<Daily>.fetch(with: nil) { result in
			switch result {
				case .success(let response):
					dailyPhoto = response.first
					promise.fulfill()
				case .failure(let error):
					responseError = error
			}
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertNotNil(dailyPhoto)
	}
	
	func testEarthParsing() {
		let promise = expectation(description: "Earth item returned")
		var earthPhoto: Earth?
		var responseError: Error?
		
		DataManager<Earth>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				earthPhoto = response.first
				promise.fulfill()
			case .failure(let error):
				responseError = error
			}
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertNotNil(earthPhoto)
	}
	
	func testMarsParsing() {
		let promise = expectation(description: "Mars item returned")
		var marsPhotos: [Mars]?
		var responseError: Error?
		
		DataManager<Mars>.fetch(with: nil) { result in
			switch result {
			case .success(let response):
				marsPhotos = response
				promise.fulfill()
			case .failure(let error):
				responseError = error
			}
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertNotNil(marsPhotos)
	}

	func testGeocoding() {
		let promise = expectation(description: "Location successfully acquired from coordinates")
		var location: String?
		var responseError: Error?
		
		let locale = CLLocation(latitude: 37.787359, longitude: -122.408227)
		let geocoder = CLGeocoder()
		
		geocoder.reverseGeocodeLocation(locale, completionHandler: { (placemarks, error) in
			if error == nil {
				guard let firstLocation = placemarks?[0] else { return }
				location = LocationManager.parseAddress(selectedItem: firstLocation)
				promise.fulfill()
			}
			else {
				responseError = error
			}
		})
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertNotNil(location)
	}
	
	func testForSearchResults() {
		let promise = expectation(description: "Search yields a body of results")
		
		var results: MKLocalSearch.Response?
		let searchText = "starbucks"
		
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchText
		let search = MKLocalSearch(request: request)
		
		search.start { response, _ in
			guard let response = response else {
				return
			}
			results = response
			promise.fulfill()
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNotNil(results)
	}


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

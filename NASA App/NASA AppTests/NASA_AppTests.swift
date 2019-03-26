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

	// test that session returns a 200 results
    func testFor200Code() {
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
	
	// test that networking successfully returns a daily photo (aka APOD) item
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
	
	// test that networking successfully returns an earth satellite item
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
	
	// test that networking successfully returns a mars rover photo response
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

	// test that geocoding returns a location based on coordinates
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
	
	// test that search used in earth satellite imagery search table works
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

	// test that a location is always available
	func testForLocationRetrieval() {
		let promise = expectation(description: "Earth item returns a latitude and longitude")
		var latitude: Double?
		var longitude: Double?
		var responseError: Error?
		
		// this should always return values because defaults are set in earthsearch
		DataManager<Earth>.fetch(with: nil) { result in
			switch result {
			case .success(let _):
				latitude = EarthSearch.earthSearch.latitude
				longitude = EarthSearch.earthSearch.longitude
				promise.fulfill()
			case .failure(let error):
				latitude = EarthSearch.earthSearch.latitude
				longitude = EarthSearch.earthSearch.longitude
				responseError = error
			}
		}
		
		waitForExpectations(timeout: 5, handler: nil)
		XCTAssertNil(responseError)
		XCTAssertNotNil(latitude)
		XCTAssertNotNil(longitude)
	}

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

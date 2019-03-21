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

protocol LocationManager {
	var location:CLLocation? {get}
}

extension CLLocationManager: LocationManager{}

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

	func testLocationAcquisition() {
		let promise = expectation(description: "Latitude and longitude successfully acquired")
		var latitude: Double?
		var longitude: Double?
		var responseError: Error?
		
		class MockLocationManager: LocationManager {
			var location: CLLocation? = CLLocation(latitude: 37.787359, longitude: 122.408227)
		}
		
		func locationManager(_ manager: MockLocationManager, didUpdateLocations locations: [CLLocation]) {
			if let lat = locations.last?.coordinate.latitude, let long = locations.last?.coordinate.longitude, let location = locations.last {
				latitude = lat
				longitude = long
				promise.fulfill()
			}
		}
		
		func locationManager(_ manager: MockLocationManager, didFailWithError error: Error) {
			responseError = error
		}
		
		
		waitForExpectations(timeout: 60, handler: nil)
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

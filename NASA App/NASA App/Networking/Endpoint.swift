//
//  Endpoint.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import Foundation

enum Endpoint {
	case earth
	case mars
	case dailyPhoto
	
	private var baseURL: URL {
		return URL(string: "https://api.nasa.gov/")!
	}
	
	private var key: String {
		return "vBxrgOjlUm93Xn3RWcMHgg3RUNOSAosuRKPMIj0U"
	}
	
	func url(with page: Int?) -> URL {
		switch self {
		case .earth:
			let latitude = EarthSearch.earthSearch.latitude
			let longitude = EarthSearch.earthSearch.longitude
			
			var components = URLComponents(url: baseURL.appendingPathComponent("planetary/earth/imagery"), resolvingAgainstBaseURL: false)
			components!.queryItems = [URLQueryItem(name: "lon", value: "\(longitude)"), URLQueryItem(name: "lat", value: "\(latitude)"), URLQueryItem(name: "api_key", value: "\(key)")]
			return components!.url!
		case .mars:
			let sol = MarsSearch.marsSearch.sol
			let rover = MarsSearch.marsSearch.rover.rawValue
			
			var components = URLComponents(url: baseURL.appendingPathComponent("mars-photos/api/v1/rovers/\(rover)/photos"), resolvingAgainstBaseURL: false)
			components!.queryItems = [URLQueryItem(name: "sol", value: "\(sol)"), URLQueryItem(name: "page", value: "\(page ?? 1)"), URLQueryItem(name: "api_key", value: "\(key)")]
			return components!.url!
		case .dailyPhoto:
			let date = DailyPhotoSearch.photoSearch.date
			
			var components = URLComponents(url: baseURL.appendingPathComponent("planetary/apod"), resolvingAgainstBaseURL: false)
			components!.queryItems = [URLQueryItem(name: "date", value: "\(date)"), URLQueryItem(name: "api_key", value: "\(key)")]
			return components!.url!
		}
	}
}

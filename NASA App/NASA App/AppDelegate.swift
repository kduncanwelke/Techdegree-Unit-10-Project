//
//  AppDelegate.swift
//  NASA App
//
//  Created by Kate Duncan-Welke on 2/23/19.
//  Copyright © 2019 Kate Duncan-Welke. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	let locationManager = CLLocationManager()


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}


extension AppDelegate: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Location monitoring failed with error \(error)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("Location updated")
	}
}


/*

*************************
   Performance testing
*************************

- Used Allocations to detect reference cycles
	- Checked memory graph hierarchy
	- Checked Allocations statistics, found reference cycle
		- EarthViewController and LocationSearchController were connected via an unnecessary delegate (removed delegate, problem solved)
- Used Leaks, debug navigator, and malloc stack to detect memory leaks
	- Found multiple instances of leaking due to references to self in closures
	- Added unowned self to closures; most leaks disappeared, memory usage also dropped
	- Remaining leaks that still show up are caused by a bug in WKWebView
*/

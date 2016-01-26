//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 12/29/15.
//  Copyright © 2015 codingvirtual. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		generateSampleData()
		return true
	}

	func generateSampleData() {
		let context = CoreDataStackManager.sharedInstance().managedObjectContext
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		var pinCount: Int
		
		do {
			pinCount = try context.executeFetchRequest(fetchRequest).count
		} catch _ {
			pinCount = 0
		}
		
		var dictionary: [String : AnyObject]
		var pin: Pin
		
		if pinCount == 0 {
			
			dictionary = [Pin.Keys.ID : pinCount++, Pin.Keys.Latitude : Double(36.116), Pin.Keys.Longitude: Double(-115.100)]
			pin = Pin(dictionary: dictionary, context: context)
			
			dictionary = [Pin.Keys.ID : pinCount++, Pin.Keys.Latitude : Double(36.116), Pin.Keys.Longitude: Double(-115.125)]
			pin = Pin(dictionary: dictionary, context: context)
			
			dictionary = [Pin.Keys.ID : pinCount++, Pin.Keys.Latitude : Double(36.116), Pin.Keys.Longitude: Double(-115.150)]
			pin = Pin(dictionary: dictionary, context: context)
			
			CoreDataStackManager.sharedInstance().saveContext()
		}
	}
	
}


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
	var imageCache: ImageCache = ImageCache()

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
		
		if pinCount == 0 {
			
			let dictionary = [Pin.Keys.ID : pinCount++, Pin.Keys.Latitude : Double(36.116), Pin.Keys.Longitude: Double(-115.100)]
			let pin = Pin(dictionary: dictionary as! [String : AnyObject], context: context)
			context.insertObject(pin)
			CoreDataStackManager.sharedInstance().saveContext()
		}
	}
	
}


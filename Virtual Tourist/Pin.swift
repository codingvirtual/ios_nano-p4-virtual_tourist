	//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 12/29/15.
//  Copyright © 2015 codingvirtual. All rights reserved.
//
// 1. Import Core Data
// 2. Make this a subclass of NSManagedObject
// 3. Add @NSManaged in front of each of the properties/attributes
// 4. Include the standard Core Data init method, which inserts the object into a context
// 5. Write an init method that takes a dictionary and a context.

// 1. Import Core Data
import UIKit
import CoreData
import MapKit

// 2. Make this a subclass of NSManagedObject
class Pin : NSManagedObject {   // 2.
	
	struct Keys {
		static let ID = "id"
		static let Photos = "photos"
		static let Latitude = "lat"
		static let Longitude = "lng"
	}
	
	// 3. Add @NSManaged in front of each of the properties/attributes
	@NSManaged var id: NSNumber?
	@NSManaged var photos: [Photo]
	@NSManaged var latitude: NSNumber
	@NSManaged var longitude: NSNumber
	
	// 4. Include the standard Core Data init method, which inserts the object into a context
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	// 5. Write an init method that takes a dictionary and a context.
	convenience init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		
		// Core Data
		let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
		self.init(entity: entity, insertIntoManagedObjectContext: context)
		
		// Dictionary
//		id = dictionary[Keys.ID] as! NSNumber
		latitude = dictionary[Keys.Latitude] as! NSNumber
		longitude = dictionary[Keys.Longitude] as! NSNumber
	}
	
}
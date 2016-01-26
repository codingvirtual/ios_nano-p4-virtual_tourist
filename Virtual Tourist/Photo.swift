//
//  Photo.swift
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

import CoreData

class Photo : NSManagedObject {
	
	struct Keys {
		static let ImagePath = "image_path"
		static let Location = "location"
	}
	
	@NSManaged var imagePath: String
	@NSManaged var location: Pin
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		
		// Core Data
		let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		// Dictionary
		imagePath = dictionary[Keys.ImagePath] as! String
		location = dictionary[Keys.Location] as! Pin
		
	}
	
}
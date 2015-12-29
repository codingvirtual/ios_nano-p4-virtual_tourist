//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 12/29/15.
//  Copyright © 2015 codingvirtual. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
	
	struct Keys {
		static let ImagePath = "image_path"
	}
	
	@NSManaged var imagePath: String
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		
		// Core Data
		let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		// Dictionary
		imagePath = dictionary[Keys.ImagePath] as! String
		
	}
	
}
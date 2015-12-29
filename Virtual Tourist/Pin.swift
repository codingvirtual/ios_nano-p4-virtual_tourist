//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 12/29/15.
//  Copyright © 2015 codingvirtual. All rights reserved.
//

import UIKit
import CoreData

class Pin: NSManagedObject {
	
	struct Keys {
		static let ID = "id"
	}
	
	@NSManaged var id: NSNumber
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		
		// Core Data
		let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		// Dictionary
		id = dictionary[Keys.ID] as! NSNumber
		
	}
	
}
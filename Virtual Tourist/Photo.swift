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
import UIKit

class Photo : NSManagedObject {
	
	// set the "nextId" value to the current time in millis. Guarantees no overlap in prior values loaded by CoreData
	static var nextId = Int(NSDate().timeIntervalSince1970)
	
	struct Keys {
		static let ImagePath = "url_m"
		static let FilePath = "filePath"
		static let Pin = "pin"
		static let Image = "image"
		static let Id = "id"
	}
	
	@NSManaged var imagePath: String
	@NSManaged var pin: Pin?
	@NSManaged var id: NSNumber?
	@NSManaged var filePath: String?
	
	var image: UIImage?
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		if filePath != nil {
			loadImageDataFromFile()
		}
	}
	
	init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
		
		// Core Data
		let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		// Dictionary
		imagePath = dictionary[Keys.ImagePath] as! String
		pin = dictionary[Keys.Pin] as? Pin
		id = Photo.nextId
		Photo.nextId = Photo.nextId + 1
		if filePath != nil {
			loadImageDataFromFile()
		}
	}
	
	override func prepareForDeletion() {
		super.prepareForDeletion()
		let fileManager = NSFileManager.defaultManager()
		let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		let imageFile = documentsDirectoryURL.URLByAppendingPathComponent((self.id?.stringValue)!)
		do {
			try fileManager.removeItemAtURL(imageFile)
		} catch _ {
			// add error handling
		}
	}
	
	func loadImageDataFromFile() {
		let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		let imageFile = documentsDirectoryURL.URLByAppendingPathComponent((self.id?.stringValue)!)
		self.filePath = imageFile.path
		self.image = UIImage(contentsOfFile: self.filePath!)
	}
	
	func fetchImageData(completionHandler: () -> Void) {
		if let url = NSURL(string: self.imagePath),
			let imgData = NSData(contentsOfURL: url),
			let image = UIImage(data: imgData) {
			self.image = image
			let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
			let imageFile = documentsDirectoryURL.URLByAppendingPathComponent((self.id?.stringValue)!)
			do {
				try imgData.writeToFile(imageFile.path!, options: NSDataWritingOptions.AtomicWrite)
				self.filePath = imageFile.path
				completionHandler()
			} catch _ {
				print("error creating file")
			}
		}
	}
}
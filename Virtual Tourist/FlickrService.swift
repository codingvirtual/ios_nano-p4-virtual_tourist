//
//  FlickrService.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 1/25/16.
//  Copyright © 2016 codingvirtual. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class FlickrService : NSObject {
	
	class func getPhotos(forPin: Pin!, context: NSManagedObjectContext) -> [Photo] {
		var photoAlbum: [Photo] = [Photo]()
		let photoDictionary: [String : AnyObject] = [
			Photo.Keys.ImagePath : "path1",
			Photo.Keys.Location : forPin
		]
		let thePhoto = Photo(dictionary: photoDictionary, context: context)
		photoAlbum.append(thePhoto)
		return [Photo]()
	}
}
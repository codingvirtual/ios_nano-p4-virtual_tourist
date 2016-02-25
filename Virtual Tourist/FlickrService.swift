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

extension String {
	func toDouble() -> Double? {
		return NSNumberFormatter().numberFromString(self)?.doubleValue
	}
}

class FlickrService : NSObject {
	
	typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void
	
	var session: NSURLSession
	
	static let BASE_URL = "https://api.flickr.com/services/rest/"
	static let METHOD_NAME = "flickr.photos.search"
	static let API_KEY = "1cb6b1ec24ea2b3ee72a66be82d894cb"
	static let EXTRAS = "url_m"
	static let SAFE_SEARCH = "1"
	static let DATA_FORMAT = "json"
	static let NO_JSON_CALLBACK = "1"
	static let API_SIG = "cc26ad69f06173637e3d936c05f80647"
	
	override init() {
		session = NSURLSession.sharedSession()
		super.init()
	}
	
	// MARK: - All purpose task method for data
	
	func taskForResource(withPin: Pin, usingContext: NSManagedObjectContext, completionHandler: CompletionHander) -> NSURLSessionDataTask {
		
		let BASE_URL = "https://api.flickr.com/services/rest/"
		let METHOD_NAME = "flickr.photos.search"
		let API_KEY = "1cb6b1ec24ea2b3ee72a66be82d894cb"
		let EXTRAS = "url_m"
		let SAFE_SEARCH = "1"
		let DATA_FORMAT = "json"
		let NO_JSON_CALLBACK = "1"
//		let API_SIG = "cc26ad69f06173637e3d936c05f80647"
		
		let methodArguments = [
			"method": METHOD_NAME,
			"api_key": API_KEY,
			"safe_search": SAFE_SEARCH,
			"extras": EXTRAS,
			"format": DATA_FORMAT,
			"nojsoncallback": NO_JSON_CALLBACK,
			"lat": withPin.latitude,
			"lon": withPin.longitude
		]
		
		let urlString = BASE_URL + FlickrService.escapedParameters(methodArguments)
		let url = NSURL(string: urlString)!
		let request = NSURLRequest(URL: url)
		
		print(url)
		
		let task = session.dataTaskWithRequest(request) {data, response, downloadError in
			
			if let error = downloadError {
				print("Could not complete the request \(error)")
				completionHandler(result: nil, error: error)
			} else {
				print("Step 3 - taskForResource's completionHandler is invoked.")
				FlickrService.parseJSONWithCompletionHandler(data!, usingContext: usingContext, withPin: withPin, completionHandler: completionHandler)
			}
		}
	
		task.resume()
		
		return task
	}
	
	// MARK: - Shared Instance
	
	class func sharedInstance() -> FlickrService {
		
		struct Singleton {
			static var sharedInstance = FlickrService()
		}
		
		return Singleton.sharedInstance
	}
	
	// Parsing the JSON
	
	class func parseJSONWithCompletionHandler(data: NSData, usingContext: NSManagedObjectContext,  withPin: Pin, completionHandler: CompletionHander) {
		var parsingError: NSError? = nil
		
		let parsedResult: AnyObject?
		do {
			parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
		} catch let error as NSError {
			parsingError = error
			parsedResult = nil
		}
		
		if let error = parsingError {
			completionHandler(result: nil, error: error)
		} else {
			print("Step 4 - parseJSONWithCompletionHandler is invoked.")
			if let photosDictionary = parsedResult!.valueForKey("photos") as? [String:AnyObject] {
				
				var totalPhotosVal = 0
				if let totalPhotos = photosDictionary["total"] as? String {
					totalPhotosVal = (totalPhotos as NSString).integerValue
				}
				
				if totalPhotosVal > 9 {
					totalPhotosVal = 9
				}
				if totalPhotosVal > 0 {
					if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
						
						let photosCount = 9
						for index in 0...photosCount {
							var photoDictionary = photosArray[index] as [String: AnyObject]
							
							photoDictionary[Photo.Keys.Pin] = withPin
							//							let imageURL = NSURL(string: imageUrlString!)
							//
							//							if let imageData = NSData(contentsOfURL: imageURL!) {
							//								print(imageURL!)
							//								dispatch_async(dispatch_get_main_queue(), {
							//									// do UI stuff here
							//
							//								})
							//							} else {
							//								print("Image does not exist at \(imageURL)")
							//							}
							let photo = Photo(dictionary: photoDictionary, context: usingContext)
							photo.pin = withPin
//							withPin.photos.append(photo)
							CoreDataStackManager.sharedInstance().saveContext()
						}
					} else {
						print("Cant find key 'photo' in \(photosDictionary)")
					}
				} else {
					
				}
			} else {
				print("Cant find key 'photos' in \(parsedResult)")
			}
			completionHandler(result: parsedResult, error: nil)
		}
	}
	
	func taskForImage(withPhoto: Photo, completionHandler: ((imageData: NSData?, error: NSError?) ->  Void)?) -> NSURLSessionTask {
		
		let url = NSURL(string: withPhoto.imagePath)
		
		print(url)
		
		let request = NSURLRequest(URL: url!)
		
		let task = session.dataTaskWithRequest(request) {data, response, downloadError in
			
			if let error = downloadError {
				print(error)
				if completionHandler != nil {
					completionHandler!(imageData: nil, error: error)
				}
			} else {
				// store the image data to a file here
				withPhoto.image = UIImage(data: data!)
				if completionHandler != nil {
					completionHandler!(imageData: data, error: nil)
				}
			}
		}
		
		task.resume()
		
		return task
	}
	
	
	/* Helper function: Given a dictionary of parameters, convert to a string for a url */
	class func escapedParameters(parameters: [String : AnyObject]) -> String {
		
		var urlVars = [String]()
		
		for (key, value) in parameters {
			
			/* Make sure that it is a string value */
			let stringValue = "\(value)"
			
			/* Escape it */
			let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			
			/* Append it */
			urlVars += [key + "=" + "\(escapedValue!)"]
			
		}
		
		return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
	}
}
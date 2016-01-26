//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 1/19/16.
//  Copyright © 2016 codingvirtual. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set up any additional UI here
		
		//
		do {
			try fetchedResultsController.performFetch()
		} catch {}
		
		// Set the view controller as! the delegate
		fetchedResultsController.delegate = self
		
	}
	
	// MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	// Mark: - Fetched Results Controller
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
			managedObjectContext: self.sharedContext,
			sectionNameKeyPath: nil,
			cacheName: nil)
		return fetchedResultsController
		
	}()

	func dropPin(id:NSNumber!) {
		let dictionary: [String : AnyObject] = [
			Pin.Keys.ID : id
		]
		
		let pinToBeAdded = Pin(dictionary: dictionary, context: sharedContext)
		
		sharedContext.insertObject(pinToBeAdded)
		
		CoreDataStackManager.sharedInstance().saveContext()
	}
	
}

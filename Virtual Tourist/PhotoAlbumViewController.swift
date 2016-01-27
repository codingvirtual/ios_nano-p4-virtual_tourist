//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 1/19/16.
//  Copyright © 2016 codingvirtual. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
	
	var pin: Pin!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
}
	
	// MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	

}

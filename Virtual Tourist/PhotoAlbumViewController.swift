//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 1/19/16.
//  Copyright © 2016 codingvirtual. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
	
	var pin: Pin!
	// The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
	// used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
	// works by searchign through the code for 'selectedIndexes'
	var selectedIndexes = [NSIndexPath]()
	
	// Keep the changes. We will keep track of insertions, deletions, and updates.
	var insertedIndexPaths: [NSIndexPath]!
	var deletedIndexPaths: [NSIndexPath]!
	var updatedIndexPaths: [NSIndexPath]!
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	@IBOutlet weak var buttonNewCollection: UIButton!
	
	@IBOutlet weak var buttonDelete: UIButton!
	
	var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
	let imageCache = (UIApplication.sharedApplication().delegate as! AppDelegate).imageCache
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		// Start the fetched results controller
		do {
			try fetchedResultsController.performFetch()
			print("COUNT:")
			print(fetchedResultsController.fetchedObjects!.count)
		} catch _ {
		print ("core data error")
		}
		
		if fetchedResultsController.fetchedObjects?.count == 0 {
			getPhotos()
		} else {
			print("pin has stored photos")
		}
	}
	// Layout the collection view
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Lay out the collection view so that cells take up 1/3 of the width,
		// with no space in between.
		let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		
		let width = floor(self.collectionView.frame.size.width/3)
		layout.itemSize = CGSize(width: width, height: width)
		collectionView.collectionViewLayout = layout
	}
	
	@IBAction func getNewCollection(sender: AnyObject) {
		let photos = fetchedResultsController.fetchedObjects as! [Photo]
		for aPhoto in photos {
			aPhoto.pin = nil
			sharedContext.deleteObject(aPhoto)
		}
		do {
			try sharedContext.save()
		} catch _ {
			print("error saving context")
		}
		getPhotos()
	}
	
	@IBAction func doPhotoDelete(sender: AnyObject) {
		var photosToDelete = [Photo]()
		
		for indexPath in selectedIndexes {
			photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
		}
		
		for photo in photosToDelete {
			sharedContext.deleteObject(photo)
		}
		
		do {
			try sharedContext.save()
		} catch _ {
			print("error saving context")
		}
		
		selectedIndexes = [NSIndexPath]()
		
		buttonNewCollection.hidden = false
		buttonDelete.hidden = true
	}
	
	// MARK: - Configure Cell
	
	func configureCell(cell: PhotosCollectionViewCell, atIndexPath indexPath: NSIndexPath) {
		let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
		
		if let _ = selectedIndexes.indexOf(indexPath) {
			cell.imageView.alpha = 0.25
		} else {
			cell.imageView.alpha = 1.0
		}
		
		dispatch_async(dispatch_get_main_queue()) {
			cell.imageView!.image = photo.image
		}
		
	}
	
	func getPhotos() {
		FlickrService.sharedInstance().taskForResource(self.pin, usingContext: self.sharedContext) {result, error in
		}
	}
	// MARK: - UICollectionView
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return self.fetchedResultsController.sections?.count ?? 0
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let sectionInfo = self.fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotosCollectionViewCell", forIndexPath: indexPath) as! PhotosCollectionViewCell
		
		self.configureCell(cell, atIndexPath: indexPath)
		
		return cell
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		

		
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotosCollectionViewCell
		
		// Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
		if let index = selectedIndexes.indexOf(indexPath) {
			selectedIndexes.removeAtIndex(index)
			print("found in selectedIndexes")
		} else {
			selectedIndexes.append(indexPath)
			print("added to selectedIndexes")
		}
		
		print(selectedIndexes.count)
		if selectedIndexes.count == 0 {
			buttonNewCollection.hidden = false
			buttonDelete.hidden = true
		} else {
			buttonNewCollection.hidden = true
			buttonDelete.hidden = false
		}
		
		// Then reconfigure the cell
		configureCell(cell, atIndexPath: indexPath)
		
	}
	
	
	// MARK: - NSFetchedResultsController
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		
		let fetchRequest = NSFetchRequest(entityName: "Photo")
		fetchRequest.sortDescriptors = []
		fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin);
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultsController.delegate = self
		
		return fetchedResultsController
	}()
	
	
	// MARK: - Fetched Results Controller Delegate
	
	// Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
	// three fresh arrays to record the index paths that will be changed.
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		// We are about to handle some new changes. Start out with empty arrays for each change type
		insertedIndexPaths = [NSIndexPath]()
		deletedIndexPaths = [NSIndexPath]()
		updatedIndexPaths = [NSIndexPath]()
		
		print("in controllerWillChangeContent")
	}
	
	// The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
	// We store the incex paths into the three arrays.
	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		
		switch type{
			
		case .Insert:
			print("Insert an item")
			// Here we are noting that a new Color instance has been added to Core Data. We remember its index path
			// so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
			// the index path that we want in this case
			insertedIndexPaths.append(newIndexPath!)
			break
		case .Delete:
			print("Delete an item")
			// Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
			// so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
			// value that we want in this case.
			deletedIndexPaths.append(indexPath!)
			break
		case .Update:
			print("Update an item.")
			// We don't expect Color instances to change after they are created. But Core Data would
			// notify us of changes if any occured. This can be useful if you want to respond to changes
			// that come about after data is downloaded. For example, when an images is downloaded from
			// Flickr in the Virtual Tourist app
			updatedIndexPaths.append(indexPath!)
			break
		case .Move:
			print("Move an item. We don't expect to see this in this app.")
		}
		
	}
	
	// This method is invoked after all of the changed in the current batch have been collected
	// into the three index path arrays (insert, delete, and upate). We now need to loop through the
	// arrays and perform the changes.
	//
	// The most interesting thing about the method is the collection view's "performBatchUpdates" method.
	// Notice that all of the changes are performed inside a closure that is handed to the collection view.
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		
		print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
		
		collectionView.performBatchUpdates({() -> Void in
			
			for indexPath in self.insertedIndexPaths {
				self.collectionView.insertItemsAtIndexPaths([indexPath])
			}
			
			for indexPath in self.deletedIndexPaths {
				self.collectionView.deleteItemsAtIndexPaths([indexPath])
			}
			
			for indexPath in self.updatedIndexPaths {
				self.collectionView.reloadItemsAtIndexPaths([indexPath])
			}
			
			}, completion: nil)
	}
	
	// MARK: - Actions and Helpers
	
}

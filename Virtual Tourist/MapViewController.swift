//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 12/29/15.
//  Copyright © 2015 codingvirtual. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController,  MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
	
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		
		// Create the fetch request
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
		
		// Create the Fetched Results Controller
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		// Return the fetched results controller. It will be the value of the lazy variable
		return fetchedResultsController
	} ()
	
	@IBOutlet weak var mapView: MKMapView!
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set up any additional UI here
		do {
			try fetchedResultsController.performFetch()
		} catch {
			print("Unresolved error \(error)")
			abort()
		}
		
		// Change 2. Set this view controller as the fetched results controller's delegate
		fetchedResultsController.delegate = self
		
		for aPin in fetchedResultsController.fetchedObjects as! [Pin] {
			createPin(aPin)
		}
	}
	
	// MARK: - Fetched Results Controller Delegate
	
	//
	// Change 3: Implement the delegate protocol methods
	//
	// These are the four methods that the Fetched Results Controller invokes on this view controller.
	//
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		// This invocation prepares the table to recieve a number of changes. It will store them up
		// until it receives endUpdates(), and then perform them all at once.
		print("controller will change content")
	}
	
	func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
		// Our project does not use sections. So we can ignore these invocations.
	}
	

	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		print(anObject)
		switch type {
		case .Insert:
			createPin(anObject as! Pin)
			self.mapView.reloadInputViews()
		case .Delete:
			deletePin(anObject as! Pin)
		default:
			return
		}
	}
	
	func createPin(pinData: Pin) {
		// refresh the map with the stored pins from CoreData
		let annotation = FlickrAnnotation(withPin: pinData)
		self.mapView.addAnnotation(annotation)
	}
	
	func deletePin(thePin: Pin) {
		// TODO: delete the annotation first.
		sharedContext.deleteObject(thePin)
		CoreDataStackManager.sharedInstance().saveContext()
	}
	
	@IBAction func longPress(sender: AnyObject) {
		print("long press detected")
		let recognizer: UILongPressGestureRecognizer = sender as! UILongPressGestureRecognizer
		let point: CGPoint = recognizer.locationInView(mapView)
		let locCoords: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
		let newPin = Pin(dictionary: [
			Pin.Keys.Longitude : locCoords.longitude,
			Pin.Keys.Latitude : locCoords.latitude
			], context: self.sharedContext)
		sharedContext.insertObject(newPin)
		CoreDataStackManager.sharedInstance().saveContext()
		let annotation = FlickrAnnotation(withPin: newPin)
		self.mapView.addAnnotation(annotation)
	}
	

	// MARK: - MKMapViewDelegate

	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		let annotation = view.annotation as? FlickrAnnotation
		print(annotation?.pin.id.stringValue)
		print(self.fetchedResultsController.indexPathForObject((annotation?.pin)!))
		let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
		controller.pin = annotation?.pin
		self.presentViewController(controller, animated: true, completion: nil)
	}
}


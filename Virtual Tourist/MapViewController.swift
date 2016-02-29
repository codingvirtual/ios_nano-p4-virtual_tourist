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

class MapViewController: UIViewController,  MKMapViewDelegate, NSFetchedResultsControllerDelegate {
	
	// MARK: - Variables and Outlets
	
	enum Mode {
		case Normal, Editing
	}
	
	var currentMode: Mode = Mode.Normal
	
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
	
	@IBOutlet var longPressRecognizer: UILongPressGestureRecognizer!
	
	@IBOutlet weak var editButton: UIButton!
	
	@IBOutlet weak var messageField: UILabel!
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	// MARK: - Controller overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// set up any additional UI here
		do {
			try fetchedResultsController.performFetch()
		} catch {
			print("Unresolved error \(error)")
			abort()
		}
		
		// Change 2. Set this view controller as the fetched results controller's delegate
		fetchedResultsController.delegate = self
		print(fetchedResultsController.fetchedObjects!.count)
		
		// FIXME: the following is a kludge to clear annotations. When you go to the album for an annotation
		// and then return, for some reason a new annotation gets created on the map (but not in CoreData)
		for anAnnotation in self.mapView.annotations {
			self.mapView.removeAnnotation(anAnnotation)
		}
		for aPin in fetchedResultsController.fetchedObjects as! [Pin] {
			self.createPin(aPin)
		}
		
	}
	// MARK: - UI-related Code
	
	@IBAction func handleGesture() {
		print("long press detected")
		if longPressRecognizer.state == UIGestureRecognizerState.Began {
			print("gesture began")
		}
		if longPressRecognizer.state == UIGestureRecognizerState.Ended {
			print("now adding annotation")

			let point: CGPoint = longPressRecognizer.locationInView(self.mapView)
			let locCoords: CLLocationCoordinate2D = self.mapView.convertPoint(point, toCoordinateFromView: mapView)
			let newPin = Pin(dictionary: [
				Pin.Keys.Longitude : locCoords.longitude,
				Pin.Keys.Latitude : locCoords.latitude
				], context: self.sharedContext)
			sharedContext.insertObject(newPin)
			CoreDataStackManager.sharedInstance().saveContext()

			// TODO: add hold to the recognizer process.
		}
	}
	
	@IBAction func enableEditing(sender: AnyObject) {
		print("edit button pressed")
		let title = editButton.attributedTitleForState(UIControlState.Normal)?.mutableCopy() as! NSMutableAttributedString
		switch currentMode {
		case Mode.Normal:
			currentMode = Mode.Editing
			title.replaceCharactersInRange(NSRange(location: 0,length: title.length), withString: "Done")
			UIView.animateWithDuration(0.5, animations: {
				self.mapView.frame.origin.y -= self.messageField.frame.height
				self.messageField.frame.origin.y -= self.messageField.frame.height
			})

		case Mode.Editing:
			currentMode = Mode.Normal
			title.replaceCharactersInRange(NSRange(location: 0,length: title.length), withString: "Edit")
			UIView.animateWithDuration(0.5, animations: {
				self.mapView.frame.origin.y += self.messageField.frame.height
				self.messageField.frame.origin.y += self.messageField.frame.height
			})
			
		}
		editButton.setAttributedTitle(title as NSAttributedString, forState: UIControlState.Normal)
	}
	
	
	// MARK: - Fetched Results Controller Delegate
	
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		// This invocation prepares the table to recieve a number of changes. It will store them up
		// until it receives endUpdates(), and then perform them all at once.
		print("controller will change content")
	}


	func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
		print("controller did change object")
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
	
	// MARK: - Pin Functionality
	
	func createPin(pinData: Pin) {
		// refresh the map with the stored pins from CoreData
		let annotation = FlickrAnnotation(withPin: pinData)
		self.mapView.addAnnotation(annotation)
	}
	
	func deletePin(thePin: Pin) {
		sharedContext.deleteObject(thePin)
		CoreDataStackManager.sharedInstance().saveContext()
	}

	

	// MARK: - MKMapViewDelegate

	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		switch currentMode {
		case Mode.Normal:
			let annotation = view.annotation as? FlickrAnnotation
			let controller = self.storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumViewController") as! PhotoAlbumViewController
			controller.pin = annotation?.pin
			self.showViewController(controller, sender: self)
		case Mode.Editing:
			print("delete this")
			// loop through photos
			let annotation = view.annotation as? FlickrAnnotation
			deletePin((annotation?.pin)!)
			// delete annotation
			self.mapView.removeAnnotation(annotation!)
		}
	}
}

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

class MapViewController: UIViewController,  MKMapViewDelegate, UIGestureRecognizerDelegate {
	
	
	var fetchedResults = [Pin]()
	@IBOutlet weak var mapView: MKMapView!
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStackManager.sharedInstance().managedObjectContext
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set up any additional UI here
		fetchedResults = fetchAllPins()
		print(fetchedResults.count)
		// refresh the map with the stored pins from CoreData
		if fetchedResults.count > 0 {
			for aPin in self.fetchedResults {
					let coords = CLLocationCoordinate2DMake((aPin.latitude as Double), (aPin.longitude as Double))
					let annotation = MKPointAnnotation()
					annotation.coordinate = coords
					self.mapView.addAnnotation(annotation)
				}
		}
	}
	
	@IBAction func longPress(sender: AnyObject) {
		print("long press detected")
		let recognizer: UILongPressGestureRecognizer = sender as! UILongPressGestureRecognizer
		let point: CGPoint = recognizer.locationInView(mapView)
		let locCoords: CLLocationCoordinate2D = mapView.convertPoint(point, toCoordinateFromView: mapView)
		let annotation = MKPointAnnotation()
		annotation.coordinate = locCoords
		self.mapView.addAnnotation(annotation)
	}
	
	
	@IBAction func didClick(sender: AnyObject) {
		print("adding pin")
		addNewPin(27)
	}
	
	@IBAction func fetchPins(sender: AnyObject) {
		print(fetchAllPins().count)
		
	}
	
	func fetchAllPins() -> [Pin] {
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		do {
			return try self.sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
		} catch {
			print("error")
			return [Pin]()
		}
	}
	
	func addNewPin(id:NSNumber!) {
		let dictionary: [String : AnyObject] = [
			Pin.Keys.ID : id
		]
		
		// Now we create a new Person, using the shared Context
		let pinToBeAdded = Pin(dictionary: dictionary, context: sharedContext)
		
		sharedContext.insertObject(pinToBeAdded)
		
		CoreDataStackManager.sharedInstance().saveContext()
		print("pin added")
	}
	
	// MARK: - MKMapViewDelegate
	
	// Here we create a view with a "right callout accessory view".
	//	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
	//
	//		let reuseId = "pin"
	//
	//		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
	//
	//		if pinView == nil {
	//			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
	//			pinView!.canShowCallout = true
	//			pinView!.pinTintColor = UIColor.redColor()
	//			pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
	//		}
	//		else {
	//			pinView!.annotation = annotation
	//		}
	//
	//		return pinView
	//	}
	
	
	// This delegate method is implemented to respond to taps. It opens the system browser
	// to the URL specified in the annotationViews subtitle property.
	func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		
		if control == annotationView.rightCalloutAccessoryView {
			// do something with tap
			
			// if mode = normal, segue to Photo Album
			
			// else if mode = edit, delete pin
			
		}
	}
	
}


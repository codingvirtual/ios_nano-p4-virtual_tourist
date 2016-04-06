//
//  FlickrAnnotation.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 1/27/16.
//  Copyright © 2016 codingvirtual. All rights reserved.
//

import MapKit

class FlickrAnnotation : MKPointAnnotation {
	
	var pin: Pin!
	
	convenience init (withPin: Pin) {
		self.init()
		self.pin = withPin
		let coords = CLLocationCoordinate2DMake((withPin.latitude as Double), (withPin.longitude as Double))
		self.coordinate = coords
	}
}

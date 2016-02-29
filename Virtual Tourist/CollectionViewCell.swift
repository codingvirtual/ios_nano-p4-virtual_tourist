//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Greg Palen on 1/31/16.
//  Copyright © 2016 codingvirtual. All rights reserved.
//

import Foundation
import UIKit

class PhotosCollectionViewCell : UICollectionViewCell {
	
	@IBOutlet weak var imageView: UIImageView!
	
	var image: UIImage {
		set {
			self.imageView.image = newValue
		}
		get {
			return self.imageView.image!
		}
	}
	
	var taskToCancelifCellIsReused: NSURLSessionTask? {
		
		didSet {
			if let taskToCancel = oldValue {
				taskToCancel.cancel()
			}
		}
	}
}
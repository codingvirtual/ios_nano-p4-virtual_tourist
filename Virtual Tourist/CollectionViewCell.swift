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
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var image: UIImage?
	
	var taskToCancelifCellIsReused: NSURLSessionTask? {
		
		didSet {
			if let taskToCancel = oldValue {
				taskToCancel.cancel()
			}
		}
	}
}
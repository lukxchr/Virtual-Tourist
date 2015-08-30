//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Lukasz Chrzanowski on 26/08/2015.
//  Copyright (c) 2015 ___LC___. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PhotoCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //request that is cancelled if the cell is reused
    var requestToCancel: Alamofire.Request? {
        didSet {
            oldValue?.cancel()
        }
    }
    
}
//
//  PhotoCell.swift
//  SimpleFlickr
//
//  Created by Dmytro Hubskyi on 17.10.16.
//  Copyright © 2016 Mitrodan. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {

    var photo: UIImage? {
        didSet {
            photoView?.image = photo
        }
    }

    @IBOutlet var photoView: UIImageView?
    @IBOutlet var loadingIndicator: UIActivityIndicatorView?

}

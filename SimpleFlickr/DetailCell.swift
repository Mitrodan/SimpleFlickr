//
//  DetailCell.swift
//  SimpleFlickr
//
//  Created by Dmytro Hubskyi on 17.10.16.
//  Copyright © 2016 Mitrodan. All rights reserved.
//

import UIKit

class DetailCell: UICollectionViewCell {

    var photo: UIImage? {
        didSet {
            if let image = photo { photoView?.display(image) }
        }
    }

    @IBOutlet var photoView: ImageScrollView?
    @IBOutlet var loadingIndicator: UIActivityIndicatorView?

}

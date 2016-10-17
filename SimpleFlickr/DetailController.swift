//
//  DetailController.swift
//  SimpleFlickr
//
//  Created by Dmytro Hubskyi on 17.10.16.
//  Copyright © 2016 Mitrodan. All rights reserved.
//

import UIKit

protocol PhotosDetail: AnyObject {
    var pages: [Flickr.PhotoPage] {get set}
    var selectedPhoto: Flickr.PhotoItem? {get set}
}

class DetailController: UIViewController, PhotosDetail {

    var pages: [Flickr.PhotoPage] = [] {didSet{photosGallery?.pages = pages}}
    var photosGallery: PhotosDetail? = nil
    var selectedPhoto: Flickr.PhotoItem? = nil {didSet{photosGallery?.selectedPhoto = selectedPhoto}}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emdedDetail" {
            photosGallery = segue.destination as? PhotosDetail
            photosGallery?.pages = pages
            photosGallery?.selectedPhoto = selectedPhoto
        }
    }


}

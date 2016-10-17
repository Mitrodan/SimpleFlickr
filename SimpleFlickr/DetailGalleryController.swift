//
//  DetailGalleryController.swift
//  SimpleFlickr
//
//  Created by Dmytro Hubskyi on 17.10.16.
//  Copyright © 2016 Mitrodan. All rights reserved.
//

import UIKit
import AFNetworking

class DetailGalleryController: UICollectionViewController, PhotosDetail {

    var pages: [Flickr.PhotoPage] = []
    var selectedPhoto: Flickr.PhotoItem? = nil

    let imageDownloader = AFImageDownloader()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCellItemSize()
        for (section, page) in pages.enumerated() {
            if let item = page.photos.index(where: { (photo: Flickr.PhotoItem) -> Bool in
                return photo.photoID == selectedPhoto!.photoID
                })
            {
                let indexPath = IndexPath(item: item, section: section)
                self.collectionView!.scrollToItem(at: indexPath, at: .left, animated: false)
            }
        }
    }

    func updateCellItemSize() {
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let insets = collectionView!.contentInset
            let width = (collectionView!.bounds.width - (insets.left + insets.right))
            let height = (collectionView!.bounds.height - (insets.top + insets.bottom))
            layout.itemSize = CGSize(width: width, height: height)
            layout.invalidateLayout();
            self.collectionView?.layoutIfNeeded()
            self.collectionView?.reloadData()
        }
    }
}

extension DetailGalleryController {

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pages.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let photosPage = pages[section]
        return photosPage.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCell
        let photosPage = pages[indexPath.section]
        let photoItem = photosPage.photos[indexPath.item]

        if let image = self.imageDownloader.imageCache?.imageforRequest(photoItem.photoURLRequest(size: .large), withAdditionalIdentifier: nil) {
            cell.photo = image
            cell.loadingIndicator?.isHidden = true
        }
        else {
            cell.photo = nil
            cell.loadingIndicator?.isHidden = false
            cell.loadingIndicator?.startAnimating()
            self.download(photo: photoItem)
        }

        
        return cell
    }


    private func download(photo: Flickr.PhotoItem)
    {
        let request = photo.photoURLRequest(size: .large)
        if self.imageDownloader.imageCache?.imageforRequest(request, withAdditionalIdentifier: nil) == nil {
            self.imageDownloader.downloadImage(for: request, success: {[unowned self] (request: URLRequest, response: HTTPURLResponse?, image: UIImage) in
                    self.updateImage(on: photo)
                }, failure: { (request: URLRequest, response: HTTPURLResponse?, error: Error) in

                    NSLog("download error = \(error)")
            })
        }
    }

    func updateImage(on photoItem: Flickr.PhotoItem)
    {
        for (section, page) in pages.enumerated() {
            if let item = page.photos.index(where: { (photo: Flickr.PhotoItem) -> Bool in
                return photo.photoID == photoItem.photoID
                })
            {
                let indexPath = IndexPath(item: item, section: section)
                self.collectionView!.reloadItems(at: [indexPath])
            }
        }
    }


    func photo(at indexPath: IndexPath) -> Flickr.PhotoItem? {
//        if indexPath.section < self.searchResultsPages.count
//        {
//            if indexPath.item < self.searchResultsPages[indexPath.section].photos.count {
//                return pages[indexPath.section].photos[indexPath.item]
//            }
//
//        }
        return pages[indexPath.section].photos[indexPath.item]
    }
}


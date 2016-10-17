//
//  ListController.swift
//  SimpleFlickr
//
//  Created by Dmytro Hubskyi on 17.10.16.
//  Copyright © 2016 Mitrodan. All rights reserved.
//

import UIKit
import AFNetworking

protocol PhotosList {
    var numberOfColumns: Int {get set}
    var pages: [Flickr.PhotoPage] {get set}
    var searchOwner: SearchOwner? {get set}
}

class ListController: UICollectionViewController, PhotosList {

    var numberOfColumns: Int = 1 {
        didSet {
            updateCellItemSize()
            self.collectionView?.contentOffset = CGPoint.zero
        }
    }

    var pages: [Flickr.PhotoPage] = [] {
        didSet {
            self.collectionView?.contentOffset = CGPoint.zero
            self.collectionView?.reloadData()
        }
    }

    var photoSize: Flickr.PhotoSize {
        switch numberOfColumns {
            case 1:
                return .large
            case 2:
                return .middle
            default:
                return .small
        }
    }

    var searchOwner: SearchOwner? = nil

    let imageDownloader = AFImageDownloader()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCellItemSize()
    }

    func updateCellItemSize() {
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let insets = collectionView!.contentInset
            let contentWidth = (collectionView!.bounds.width - (insets.left + insets.right))
            let width = contentWidth / CGFloat(numberOfColumns)
            layout.itemSize = CGSize(width: width, height: width)
            layout.invalidateLayout();
            self.collectionView?.layoutIfNeeded()
            self.collectionView?.reloadData()
        }
    }

}

extension ListController {

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pages.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let photosPage = pages[section]
        return photosPage.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        let photosPage = pages[indexPath.section]
        let photoItem = photosPage.photos[indexPath.item]

        if let image = self.imageDownloader.imageCache?.imageforRequest(photoItem.photoURLRequest(size: photoSize), withAdditionalIdentifier: nil) {
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

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.searchOwner?.showDetail(of: photo(at: indexPath)!)

    }

    private func download(photo: Flickr.PhotoItem)
    {
        let request = photo.photoURLRequest(size: photoSize)
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

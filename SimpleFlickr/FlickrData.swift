//
//  FlickrData.swift
//  SimpleFlickr
//
//  Created by Dmytro Hubskyi on 17.10.16.
//  Copyright © 2016 Mitrodan. All rights reserved.
//

import Foundation


struct Flickr {

    internal static let searchParameter = "text"
    internal static let apiParameters = ["method": "flickr.photos.search", "format": "json", "sort": "date-posted-asc", "text": "", "api_key": "0e2b6aaf8a6901c264acb91f151a3350", "nojsoncallback": "1"]

    static let apiURL = "https://api.flickr.com/services/rest/"

    static func searchParameters(with text: String) -> [String: String] {
        var parameters = apiParameters
        parameters[searchParameter] = text
        return parameters
    }

    struct PhotoPage {
        var page: Int
        var pages: Int
        var perPage: Int
        var total: String
        var photos: [PhotoItem] = []

        init(with dict: [String: Any])
        {
            page = dict["page"] as! Int
            pages = dict["pages"] as! Int
            perPage = dict["perpage"] as! Int
            total = dict["total"] as! String
            if let photosDicts = dict["photo"] as! [[String: AnyObject]]?
            {
                photos = photosDicts.map({ (photoDict: [String: AnyObject]) -> PhotoItem in
                    return PhotoItem(with: photoDict)
                })
            }
        }


    }

    struct PhotoItem {
        var photoID: String
        var owner: String
        var secret: String
        var server: String
        var title: String
        var farm: Int

        init(with dict: [String: Any])
        {
            photoID = dict["id"] as! String
            owner = dict["owner"] as! String
            secret = dict["secret"] as! String
            server = dict["server"] as! String
            title = dict["title"] as! String
            farm = dict["farm"] as! Int
        }

            //"https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg"
//        override func isEqual(_ object: Any?) -> Bool
//        {
//            if let otherItem = object as! SFSPhotoItem?
//            {
//                return photoURL(size: .large) == otherItem.photoURL(size: .large)
//            }
//
//            return false;
//        }

        func photoURL(size: PhotoSize) -> String {
            return "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)\(size.rawValue)"
        }

        func photoURLRequest(size: PhotoSize) -> URLRequest {
            return URLRequest(url: URL(string: photoURL(size: size))!)
        }
    }

    enum PhotoSize: String {
        case small = "_m.jpg"
        case middle = "_z.jpg"
        case large = ".jpg"
    }

}

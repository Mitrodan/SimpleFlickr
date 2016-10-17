//
//  SearchController.swift
//  SimpleFlickr
//
//  Created by Dmytro Hubskyi on 17.10.16.
//  Copyright © 2016 Mitrodan. All rights reserved.
//

import UIKit
import AFNetworking

protocol SearchOwner {
    func showDetail(of photo: Flickr.PhotoItem)
}

class SearchController: UIViewController {

    var photoListController: PhotosList?
    let searchManager = AFHTTPSessionManager()
    private let startNumberOfCollumn = 3

    @IBOutlet weak var searchBar: UISearchBar?
    @IBOutlet weak var columnControl: UISegmentedControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        searchManager.requestSerializer = AFHTTPRequestSerializer()
        searchManager.responseSerializer = AFJSONResponseSerializer()

        searchBar?.text = "bertilak"
        performFlickrSearch((searchBar?.text)!)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.columnControl?.selectedSegmentIndex = self.validColumnNumber() - 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emdedPhotoList" {
            photoListController = segue.destination as? PhotosList
            photoListController?.searchOwner = self
        } else if segue.identifier == "showDetail" {
            if let photosGallery = segue.destination as? PhotosDetail {
                photosGallery.pages = (photoListController?.pages)!
                photosGallery.selectedPhoto = sender as? Flickr.PhotoItem
            }
        }
    }

    @IBAction func updateColumnNumber(sender: UISegmentedControl?) {

        if let selectedSegmentIndex = sender?.selectedSegmentIndex {
            photoListController?.numberOfColumns = selectedSegmentIndex + 1
        }

    }

    private func validColumnNumber() -> Int {
        if let columnNumber = self.photoListController?.numberOfColumns {
            return columnNumber
        }
        return startNumberOfCollumn
    }

    @IBAction func unwindToSearch(segue: UIStoryboardSegue) {}

}

extension SearchController: UISearchBarDelegate {

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            performFlickrSearch(searchText)
            searchBar.resignFirstResponder()
        }
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        terminateCurrentSearch()
        searchBar.resignFirstResponder()
        searchBar.text = nil
    }

}

extension SearchController {

    internal func performFlickrSearch(_ searchText: String) {
        terminateCurrentSearch()

        searchManager.get(Flickr.apiURL, parameters: Flickr.searchParameters(with: searchText), progress: nil,
            success: { [unowned self] (task: URLSessionDataTask, response: Any?)  in
                NSLog("response = \(response)")
                if let responseDict = response as! [String: AnyObject]? {
                    if let photosPageDict = responseDict["photos"] as! [String: AnyObject]? {
                        self.photoListController?.pages.append(self.parseResponse(photosPageDict))
                    }
                }
            }, failure: {(task: URLSessionDataTask?, error: Error) in
                NSLog("error = \(error)")
        })

    }

    internal func terminateCurrentSearch() {
        searchManager.operationQueue.cancelAllOperations();
        photoListController?.pages.removeAll()
    }

    private func parseResponse(_ responseDict: [String: AnyObject]) -> Flickr.PhotoPage {
        return Flickr.PhotoPage(with: responseDict)
    }

}

extension SearchController: SearchOwner {

    func showDetail(of photo: Flickr.PhotoItem)
    {
        performSegue(withIdentifier: "showDetail", sender: photo)
    }

}

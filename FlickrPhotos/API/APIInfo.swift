//
//  APIInfo.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 01/05/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

protocol PhotosSearchAPIInfo {
    var path: String {get }
    var apiKey: String {get }
    var photoSearchMethod: String {get}
    var jsonResultsFormat: String {get}
}

struct FlickrPhotosSearchAPIInfo : PhotosSearchAPIInfo {
    var path: String {
        return "https://api.flickr.com/services/rest/"
    }
    var apiKey: String {
        return "3e7cc266ae2b0e0d78e279ce8e361736"
    }
    var photoSearchMethod: String {
        return "flickr.photos.search"
    }
    var jsonResultsFormat: String {
        return "json"
    }
}

//
//  FlickrPhotoSearchRepository.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

struct QueryParams {
    var query: String
    var page: Int
    var perPage: Int
}

protocol PhotoSearchService {
    typealias searchAPIResult = (Result<PhotosList, Error>) -> Void
    func fetchPhotos(params: QueryParams, completion: @escaping searchAPIResult)
}

struct FlickrPhotoSearchService: PhotoSearchService {
    
    private let api: PhotosSearchAPI
    
    init(api: PhotosSearchAPI = FlickrPhotosSearchAPI.init()) {
        self.api = api
    }
    
    func fetchPhotos(params: QueryParams, completion: @escaping PhotoSearchService.searchAPIResult) {
        api.fetchPhotos(queryParams: params) { (result) in
            completion(result)
        }
    }
}

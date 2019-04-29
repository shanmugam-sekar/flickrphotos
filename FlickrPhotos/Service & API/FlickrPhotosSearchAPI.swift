//
//  FlickrPhotosSearchAPI.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
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
    
    init() {
        
    }
}

protocol PhotosSearchAPI {
    init(networkManager: NetworkManager , apiInfo: PhotosSearchAPIInfo)
    func fetchPhotosList(queryParams: QueryParams, completion: @escaping PhotoSearchService.searchAPIResult)
}

struct FlickrPhotosSearchAPI: PhotosSearchAPI {
    
    private let networkManager: NetworkManager
    private var apiInfo: PhotosSearchAPIInfo
    
    init(networkManager: NetworkManager = FlickrPhotosNetworkManager.sharedNetworkManager, apiInfo: PhotosSearchAPIInfo = FlickrPhotosSearchAPIInfo()) {
        self.networkManager = networkManager
        self.apiInfo = apiInfo
    }
    
    func fetchPhotosList(queryParams: QueryParams, completion: @escaping PhotoSearchService.searchAPIResult) {
        
        var parameters: [String: String] = [:]
        parameters["api_key"] = apiInfo.apiKey
        parameters["method"] = apiInfo.photoSearchMethod
        parameters["format"] = apiInfo.jsonResultsFormat
        parameters["nojsoncallback"] = 1.description
        parameters["safe_search"] = 1.description
        parameters["text"] = queryParams.query
        parameters["page"] = queryParams.page.description
        parameters["per_page"] = queryParams.perPage.description
        
        let request = Request(path: apiInfo.path, parameters: parameters, method: .get)
        
        networkManager.get(request: request) { (result) in
            switch result {
            case .success(let data):
                if let response = try? JSONDecoder().decode(FlickrPhotoSearchResponse.self, from: data) {
                    if response.status, let photos = response.photos {
                        completion(.success(photos))
                    } else {
                        if let tempCode = response.code, let message = response.message {
                            let error = NSError.init(domain: Constants.domain, code: tempCode, userInfo: [NSLocalizedDescriptionKey : message])
                            completion(.failure(error))
                        } else {
                            let error = NetworkError.unknown.getErrorObject()
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}




//
//  FlickrPhotosSearchAPI.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

protocol PhotosSearchAPI {
    init(networkManager: NetworkManager , apiInfo: PhotosSearchAPIInfo)
    func fetchPhotos(queryParams: QueryParams, completion: @escaping PhotoSearchService.searchAPIResult)
}

struct FlickrPhotosSearchAPI: PhotosSearchAPI {
    
    private let networkManager: NetworkManager
    private var apiInfo: PhotosSearchAPIInfo
    
    init(networkManager: NetworkManager = FlickrPhotosNetworkManager.sharedNetworkManager, apiInfo: PhotosSearchAPIInfo = FlickrPhotosSearchAPIInfo()) {
        self.networkManager = networkManager
        self.apiInfo = apiInfo
    }
    
    func fetchPhotos(queryParams: QueryParams, completion: @escaping PhotoSearchService.searchAPIResult) {
        
        let parameters = getParametersKeyValues(queryParams: queryParams, apiInfo: apiInfo)
        let request = Request(path: apiInfo.path, parameters: parameters, method: .get)
        networkManager.get(request: request) { (result) in
            switch result {
            case .success(let data):
                do {
                    let response = try Parser<FlickrPhotoSearchResponse>().parse(data: data)
                    if response.status, let photos = response.photos {
                        completion(.success(photos))
                    } else if let tempCode = response.code, let message = response.message {
                        let error = NSError.init(domain: Error.FlickrAPIDomain, code: tempCode, userInfo: [NSLocalizedDescriptionKey: message])
                        if let result = Error.init(error: error) {
                            completion(.failure(result))
                        }
                    }
                } catch {
                    if let error = Error.init(error: error) {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getParametersKeyValues(queryParams: QueryParams, apiInfo: PhotosSearchAPIInfo) -> [String: String] {
        var parameters: [String: String] = [:]
        parameters["api_key"] = apiInfo.apiKey
        parameters["method"] = apiInfo.photoSearchMethod
        parameters["format"] = apiInfo.jsonResultsFormat
        parameters["nojsoncallback"] = 1.description
        parameters["safe_search"] = 1.description
        parameters["text"] = queryParams.query
        parameters["page"] = queryParams.page.description
        parameters["per_page"] = queryParams.perPage.description
        return parameters
    }
}





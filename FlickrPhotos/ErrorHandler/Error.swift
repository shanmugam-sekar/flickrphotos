//
//  Error.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

enum Error: Swift.Error {
    case http(HTTPError)
    case urlLoading(URLLoadingError)
    case flickrApi(Int, String)
    case parsing(String)
    case unknown(String)
    
    var localizedDescription: String {
        let string: String
        switch self {
        case .http(let http):
            string = http.description
        case .urlLoading(let urlLoading):
            string = urlLoading.description
        case .flickrApi(_, let message):
            string = message
        case .parsing(let message):
            string = message
        case .unknown(let message):
            string = message
        @unknown default:
            string = ""
        }
        return string
    }
}

extension Error {
    
    enum HTTPError: CustomStringConvertible {
        case serverError(Int)
        case clientError(Int)
        
        var description: String {
            let string: String
            switch self {
            case .serverError(_):
                string = "Internal server error"
            case .clientError(_):
                string = "API error"
            @unknown default:
                string = "Unknown error occured"
            }
            return string
        }
        
        init?(rawValue: Int) {
            switch rawValue {
            case 400..<500:
                self = .clientError(rawValue)
            case 500..<600:
                self = .serverError(rawValue)
            default:
                return nil
            }
        }
    }
    
    enum URLLoadingError: CustomStringConvertible {
        case notConnectedToInternet
        case badURL
        case cannotConnectToHost
        case cannotFindHost
        case badServerResponse
        case unknown
        
        var description: String {
            let string: String
            switch self {
            case .notConnectedToInternet:
                string = "Please check your internet connection"
            case .badURL:
                string = "URL malformed"
            case .cannotConnectToHost:
                string = "An attempt to connect to a host failed."
            case .cannotFindHost:
                string = "The host name for a URL couldn’t be resolved."
            case .badServerResponse:
                string = "Received bad data from server."
            case .unknown:
                string = "Unknown error occured."
            @unknown default:
                fatalError()
            }
            return string
        }
        
        init(rawValue: Int) {
            let value = -rawValue
            switch value {
            case 1000:
                self = .badURL
            case 1003:
                self = .cannotFindHost
            case 1004:
                self = .cannotConnectToHost
            case 1009:
                self = .notConnectedToInternet
            case 1011:
                self = .badServerResponse
            default:
                self = .unknown
            }
        }
    }
}

extension Error {
    init?(response: URLResponse?) {
        guard let response = response as? HTTPURLResponse, let httpError = Error.HTTPError.init(rawValue: response.statusCode) else {
            return nil
        }
        self = Error.http(httpError)
    }
}

extension Error {
    
    static let FlickrAPIDomain = "com.flickr.api"
    
    init?(error: Swift.Error?) {
        guard let error = error as NSError? else {
            return nil
        }
        if error.domain == NSURLErrorDomain {
            self = Error.urlLoading(Error.URLLoadingError.init(rawValue: error.code))
        } else if error.domain == Error.FlickrAPIDomain {
            self = Error.flickrApi(error.code, error.localizedDescription)
        } else if error is DecodingError {
            self = Error.parsing(error.localizedDescription)
        } else {
            self = Error.unknown(error.localizedDescription)
        }
    }
}


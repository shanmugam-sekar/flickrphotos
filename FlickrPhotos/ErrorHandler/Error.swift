//
//  Error.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

enum Error: Swift.Error {
    // represent status code error.
    case httpError(HTTPError)
    //represent URL loading system defined by apple like no internet.
    case urlLoadingError(URLLoadingError)
    //represent error getting from flickr api
    case apiError(Int, String)
    //represent decodable failure error
    case parsingError(String)
    case noDataError(String)
    case unknownError(String)
    
    var localizedDescription: String {
        let string: String
        switch self {
        case .httpError(let http):
            string = http.description
        case .urlLoadingError(let urlLoading):
            string = urlLoading.description
        case .apiError(_, let message):
            string = message
        case .parsingError(let message):
            string = message
        case .noDataError(let message):
            string = message
        case .unknownError(let message):
            string = message
        @unknown default:
            fatalError()
        }
        return string
    }
}

extension Error {
    
    enum HTTPError: RawRepresentable, CustomStringConvertible {
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
                fatalError()
            }
            return string
        }
        
        typealias RawValue = Int
        
        init?(rawValue: RawValue) {
            switch rawValue {
            case 400..<500:
                self = .clientError(rawValue)
            case 500..<600:
                self = .serverError(rawValue)
            default:
                return nil
            }
        }
        
        var rawValue: RawValue {
            let value: Int
            switch self {
            case .clientError(let number):
                value = number
            case .serverError(let number):
                value = number
            }
            return value
        }
    }
    
    enum URLLoadingError: RawRepresentable, CustomStringConvertible {
        
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
        
        typealias RawValue = Int
        
        init(rawValue: RawValue) {
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
        
        var rawValue: RawValue {
            var value: Int
            switch self {
            case .badURL:
                value = 1000
            case .cannotFindHost:
                value = 1003
            case .cannotConnectToHost:
                value = 1004
            case .notConnectedToInternet:
                value = 1009
            case .badServerResponse:
                value = 1011
            default:
                value = 10000
            }
            value = -value
            return value
        }
    }
}

extension Error {
    init?(response: URLResponse?) {
        guard let response = response as? HTTPURLResponse, let httpError = Error.HTTPError.init(rawValue: response.statusCode) else {
            return nil
        }
        self = Error.httpError(httpError)
    }
}

extension Error {
    
    static let FlickrAPIDomain = "com.flickr.api"
    static let ApplicationDomain = "com.application.flickr"
    
    init?(error: Swift.Error?) {
        guard let error = error as NSError? else {
            return nil
        }
        if error.domain == NSURLErrorDomain {
            self = Error.urlLoadingError(Error.URLLoadingError.init(rawValue: error.code))
        } else if error.domain == Error.FlickrAPIDomain {
            self = Error.apiError(error.code, error.localizedDescription)
        } else if error.domain == Error.ApplicationDomain {
            self = Error.noDataError(error.localizedDescription)
        } else if error is DecodingError {
            self = Error.parsingError(error.localizedDescription)
        } else {
            self = Error.unknownError(error.localizedDescription)
        }
    }
}


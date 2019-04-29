//
//  NetworkManager.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

protocol NetworkManager {
    typealias resultHandler = (Result<Data,NSError>) -> Void
    func configure(session: URLSession)
    func get(request: Request, completion: @escaping resultHandler)
    func download(request: Request, completion: @escaping resultHandler)
}

struct Request {
    var path: String
    var parameters: [String: String]?
    var method: HTTPMethod
}

enum HTTPMethod: String {
    case get = "GET"
}

enum NetworkError: Int, Error {
    case invalidURL = 1000
    case unknown 
    
    var localizedDescription: String {
        var string: String
        switch self {
        case .invalidURL:
            string = "i think given path is not valid."
        case .unknown:
            string = "unknown error occured"
        }
        return string
    }
    
    func getErrorObject() -> NSError {
        return NSError.init(domain: Constants.domain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: self.localizedDescription])
    }
}

class FlickrPhotosNetworkManager: NetworkManager {
    
    static let sharedNetworkManager: NetworkManager = FlickrPhotosNetworkManager()
    private var session: URLSession!
    
    private init() {
        configure()
    }
    
    func configure(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func get(request: Request, completion: @escaping (Result<Data, NSError>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(from: request)
            session.dataTask(with: urlRequest) { (data, response, error) in
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(NetworkError.unknown.getErrorObject()))
                }
            }.resume()
        } catch {
            if let error = error as? NetworkError {
                completion(.failure(error.getErrorObject()))
            }
        }
    }
    
    func download(request: Request, completion: @escaping (Result<Data, NSError>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(from: request)
            session.downloadTask(with: urlRequest) { (url, response, error) in
                if let url = url, let data = try? Data.init(contentsOf: url) {
                    completion(.success(data))
                } else {
                    completion(.failure(NetworkError.unknown.getErrorObject()))
                }
            }.resume()
        } catch {
            if let error = error as? NetworkError {
                completion(.failure(error.getErrorObject()))
            }
        }
    }       
}

extension URLRequest {
    static func prepare(from request: Request) throws -> URLRequest {
        guard let url = URL.init(string: request.path) else {
            throw NetworkError.invalidURL
        }
        var queryItems: [URLQueryItem] = []
        if let data = request.parameters {
            for (key, value) in data {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        guard let resultURL = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        var urlRequest = URLRequest(url: resultURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        return urlRequest
    }
}

//
//  NetworkManager.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

protocol NetworkManager {
    typealias resultHandler = (Result<Data,Error>) -> Void
    func configure(session: URLSession)
    func get(request: Request, completion: @escaping resultHandler)
    func download(request: Request, completion: @escaping resultHandler)
}

struct Request {
    var path: String
    var parameters: [String: String]?
    var method: HTTPMethod
    
    enum HTTPMethod: String {
        case get = "GET"
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
    
    func get(request: Request, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(from: request)
            session.dataTask(with: urlRequest) { (data, response, error) in
                if let responseError = Error.init(response: response) {
                    completion(.failure(responseError))
                } else if let httpError = Error.init(error: error) {
                    completion(.failure(httpError))
                } else if let data = data {
                    completion(.success(data))
                }
            }.resume()
        } catch {
            if let error = Error.init(error: error) {
                completion(.failure(error))
            }
        }
    }
    
    func download(request: Request, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let urlRequest = try URLRequest.prepare(from: request)
            session.downloadTask(with: urlRequest) { (url, response, error) in
                if let responseError = Error.init(response: response) {
                    completion(.failure(responseError))
                } else if let httpError = Error.init(error: error) {
                    completion(.failure(httpError))
                } else if let url = url, let data = try? Data.init(contentsOf: url) {
                    completion(.success(data))
                }
            }.resume()
        } catch {
            if let error = Error.init(error: error) {
                completion(.failure(error))
            }
        }
    }
}

extension URLRequest {
    static func prepare(from request: Request) throws -> URLRequest {
        guard let url = URL.init(string: request.path) else {
            throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        }
        var queryItems: [URLQueryItem] = []
        if let data = request.parameters {
            for (key, value) in data {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        }
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
        }
        guard let resultURL = urlComponents.url else {
            throw NSError.init(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
        }
        var urlRequest = URLRequest(url: resultURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "accept")
        return urlRequest
    }
}

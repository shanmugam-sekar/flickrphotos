//
//  ImageDownloader.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 28/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation
import UIKit.UIImage

class ImageDownloader {
    
    static let sharedImageDownloader = ImageDownloader()
    private var cache: Cache!
    private var networkManager: NetworkManager!
    private init() {
        configure()
    }
    
    func configure(cache: Cache = SimpleCache.sharedCache, networkManager: NetworkManager = FlickrPhotosNetworkManager.sharedNetworkManager) {
        self.cache = cache
        self.networkManager = networkManager
    }
    
    func fetch(path: String, placeHolderImage: UIImage?, completion: @escaping (UIImage) -> Void) {
        if let cachedData = cache.get(key: path), let image = UIImage.init(data: cachedData) {
            completion(image)
            return
        }
        
        let request = Request.init(path: path, parameters: nil, method: .get)
        
        networkManager.download(request: request) { [unowned self] (result) in
            if let data = try? result.get(), let image = UIImage.init(data: data) {
                self.cache.set(data: data, key: request.path)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else if let placeHolderImage = placeHolderImage {
                DispatchQueue.main.async {
                    completion(placeHolderImage)
                }
            } else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }                
            }
        }
    }
}

protocol Cache {
    func configure(maxMemory : Int)
    func get(key: String) -> Data?
    func set(data: Data?, key: String)
    func clear()
}

class SimpleCache: Cache {
    
    static let sharedCache: Cache = SimpleCache()
    
    private let cache: NSCache<NSString, NSData>
    
    private init() {
        cache = NSCache<NSString, NSData>()
        configure(maxMemory: 50*1024*1024)
    }
    
    func configure(maxMemory : Int) {
        cache.totalCostLimit = maxMemory
    }
    
    func get(key: String) -> Data? {
        return cache.object(forKey: NSString.init(string: key)) as Data?
    }
    
    func set(data: Data?, key: String) {
        guard let data = data else {
            return
        }
        let finalData = NSData.init(data: data)
        cache.setObject(finalData, forKey: NSString.init(string: key), cost: finalData.length)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
}


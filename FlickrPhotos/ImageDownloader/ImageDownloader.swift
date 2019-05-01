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
    
    func download(path: String, placeHolderImage: UIImage?, completion: @escaping (UIImage) -> Void) {
        if let cachedData = cache.getData(forKey: path), let image = UIImage.init(data: cachedData) {
            completion(image)
            return
        }
        
        let request = Request.init(path: path, parameters: nil, method: .get)
        
        networkManager.download(request: request) { [unowned self] (result) in
            if let data = try? result.get(), let image = UIImage.init(data: data) {
                self.cache.setData(data, forKey: request.path)
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



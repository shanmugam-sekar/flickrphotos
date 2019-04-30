//
//  Cache.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

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

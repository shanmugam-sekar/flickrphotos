//
//  ImageCacheTests.swift
//  FlickrPhotosTests
//
//  Created by Shanmugam sekar on 28/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import XCTest
@testable import FlickrPhotos

class ImageCacheTests: XCTestCase {

    let imageCache: Cache = SimpleCache.sharedCache
       
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        imageCache.clearData()
    }
    
    func testGettingImageFromCache() {
        let image: UIImage = UIImage.init(named: "uber.jpg", in: Bundle.init(for: ImageCacheTests.self), compatibleWith: nil)!
        let key = "uberlogo"
        let imageData = image.jpegData(compressionQuality: 1.0)
        imageCache.setData(imageData, forKey: key)
        let retrivedImageData = imageCache.getData(forKey: key)
        XCTAssert(retrivedImageData != nil)
        let retrivedImage = UIImage.init(data: retrivedImageData!)
        XCTAssert(retrivedImage != nil)
        XCTAssertEqual(imageData, retrivedImageData)
    }
    
    func testGettingUncachedImageFromCache() {
        let key = "uberlogo2"
        let retrivedImageData = imageCache.getData(forKey: key)
        XCTAssert(retrivedImageData == nil)                        
    }
    
    func testImageCachingFailureWhenMemoryExceeds() {
        
        imageCache.configure(maxMemory: 4*1024) // configured as 3KB
        
        let image: UIImage = UIImage.init(named: "uber.jpg", in: Bundle.init(for: ImageCacheTests.self), compatibleWith: nil)!
        let key = "uberlogo"
        let key2 = "uberlogo2"
        let imageData = image.jpegData(compressionQuality: 1.0)
        imageCache.setData(imageData, forKey: key)
        let retrivedImageData = imageCache.getData(forKey: key)
        XCTAssert(retrivedImageData != nil)
        let retrivedImage = UIImage.init(data: retrivedImageData!)
        XCTAssert(retrivedImage != nil)
        XCTAssertEqual(imageData, retrivedImageData)
        
        let imageDataCopy = Data.init(base64Encoded: imageData!)
        imageCache.setData(imageDataCopy, forKey: key2)
        let retrivedImageData2 = imageCache.getData(forKey: key2)
        XCTAssert(retrivedImageData2 == nil)
        
    }
    
}

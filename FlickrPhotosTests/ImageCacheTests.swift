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
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        imageCache.clear()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testGettingImageFromCache() {
        let image: UIImage = UIImage.init(named: "uber.jpg", in: Bundle.init(for: ImageCacheTests.self), compatibleWith: nil)!
        let key = "uberlogo"
        let imageData = image.jpegData(compressionQuality: 1.0)
        imageCache.set(data:imageData , key: key)
        let retrivedImageData = imageCache.get(key: key)
        XCTAssert(retrivedImageData != nil)
        let retrivedImage = UIImage.init(data: retrivedImageData!)
        XCTAssert(retrivedImage != nil)
        XCTAssertEqual(imageData, retrivedImageData)
    }
    
    func testGettingUncachedImageFromCache() {
        let key = "uberlogo2"
        let retrivedImageData = imageCache.get(key: key)
        XCTAssert(retrivedImageData == nil)                        
    }
    
    func testImageCachingFailureWhenMemoryExceeds() {
        
        imageCache.configure(maxMemory: 4*1024) // configured as 3KB
        
        let image: UIImage = UIImage.init(named: "uber.jpg", in: Bundle.init(for: ImageCacheTests.self), compatibleWith: nil)!
        let key = "uberlogo"
        let key2 = "uberlogo2"
        let imageData = image.jpegData(compressionQuality: 1.0)
        imageCache.set(data:imageData , key: key)
        let retrivedImageData = imageCache.get(key: key)
        XCTAssert(retrivedImageData != nil)
        let retrivedImage = UIImage.init(data: retrivedImageData!)
        XCTAssert(retrivedImage != nil)
        XCTAssertEqual(imageData, retrivedImageData)
        
        let imageDataCopy = Data.init(base64Encoded: imageData!)
        imageCache.set(data: imageDataCopy , key: key2)
        let retrivedImageData2 = imageCache.get(key: key2)
        XCTAssert(retrivedImageData2 == nil)
        
    }
    
}

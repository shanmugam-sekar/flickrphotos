//
//  ParserTests.swift
//  FlickrPhotosTests
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import XCTest
@testable import FlickrPhotos

class ParserTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

    func testParsingWithValidImagesData() {
        let path = Bundle.init(for: ParserTests.self).path(forResource: "images", ofType: "json")
        XCTAssert(path != nil, "Path not found")
        let string = try? String.init(contentsOfFile: path!)
        XCTAssert(string != nil, "Unable to read file contents as String")
        let data = string!.data(using: .ascii)
        XCTAssert(data != nil, "Data not found")
        let result = try? Parser<FlickrPhotoSearchResponse>().parse(data: data!)
        XCTAssert(result != nil, "Parsing Failed")
        XCTAssert(result!.status == true)
        XCTAssert(result!.code == nil)
        XCTAssert(result!.message == nil)
        XCTAssert(result!.photos!.photo.count == 1)
    }
    
    func testParsingWithErrorData() {
        let path = Bundle.init(for: ParserTests.self).path(forResource: "error", ofType: "json")
        XCTAssert(path != nil, "Path not found")
        let string = try? String.init(contentsOfFile: path!)
        XCTAssert(string != nil, "Unable to read file contents as String")
        let data = string!.data(using: .ascii)
        XCTAssert(data != nil, "Data not found")
        do {
            let result = try Parser<FlickrPhotoSearchResponse>().parse(data: data!)
            XCTAssert(result.status == false)
            XCTAssert(result.code != nil)
            XCTAssert(result.message != nil)
            XCTAssert(result.photos == nil)
        } catch {
            XCTFail("JSON Parsing Failed")
        }
    }
    
    func testPhotoPath() {
        let path = Bundle.init(for: ParserTests.self).path(forResource: "images", ofType: "json")
        XCTAssert(path != nil, "Path not found")
        let string = try? String.init(contentsOfFile: path!)
        XCTAssert(string != nil, "Unable to read file contents as String")
        let data = string!.data(using: .ascii)
        XCTAssert(data != nil, "Data not found")
        let result = try? Parser<FlickrPhotoSearchResponse>().parse(data: data!)
        XCTAssert(result != nil, "Parsing Failed")
        XCTAssert(result!.status == true)
        XCTAssert(result!.code == nil)
        XCTAssert(result!.message == nil)
        XCTAssert(result!.photos!.photo.count == 1)
        let photoPath = result!.photos!.photo[0].path
        XCTAssertEqual(photoPath, "http://farm66.static.flickr.com/65535/40769666113_41825e6c49.jpg")
    }
    
}

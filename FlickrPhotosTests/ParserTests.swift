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
    
    func testParsingValidDataFromJSONFileWithImages() {
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
    
    func testParsingDataFromJSONFileWithError() {
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
        
}

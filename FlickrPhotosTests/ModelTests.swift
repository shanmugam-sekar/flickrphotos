//
//  ModelTests.swift
//  FlickrPhotosTests
//
//  Created by Shanmugam sekar on 02/05/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import XCTest
@testable import FlickrPhotos

class ModelTests: XCTestCase {
    
    func testPhotoModelCreationUsingDataFromJSONFile() {
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
        let photo = result!.photos!.photo[0]
        XCTAssert(photo.id == "40769666113", "photo model created with invalid value")
        XCTAssert(photo.owner == "132430068@N03", "photo model created with invalid value")
        XCTAssert(photo.secret == "41825e6c49", "photo model created with invalid value")
        XCTAssert(photo.server == "65535", "photo model created with invalid value")
        XCTAssert(photo.farm == 66, "photo model created with invalid value")
        XCTAssert(photo.title == "IMG_1033 -1", "photo model created with invalid value")
        XCTAssert(photo.ispublic == 1, "photo model created with invalid value")
        XCTAssert(photo.isfamily == 0, "photo model created with invalid value")
        XCTAssert(photo.isfamily == 0, "photo model created with invalid value")
    }

}


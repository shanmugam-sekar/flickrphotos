//
//  ViewModelTests.swift
//  FlickrPhotosTests
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import XCTest
@testable import FlickrPhotos

class ViewModelTests: XCTestCase {

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
    
    func testQueryParams() {
        let viewModel = FlickrPhotosViewModel.init(service: MockPhotoSearchService())
        XCTAssert(viewModel.page == 0)
        XCTAssert(viewModel.previousQuery().isEmpty)
        viewModel.fetchPhotosList(for: "kittens", fetchMode: .initial)
        XCTAssert(viewModel.page == 1)
        XCTAssert(viewModel.previousQuery() == "kittens")
        viewModel.fetchPhotosList(for: "test", fetchMode: .bottom)
        XCTAssert(viewModel.page == 2)
        viewModel.fetchPhotosList(for: "random", fetchMode: .bottom)
        XCTAssert(viewModel.page == 3)
        viewModel.fetchPhotosList(for: "flickr", fetchMode: .manual)
        XCTAssert(viewModel.page == 1)
    }

}

class MockPhotoSearchService: PhotoSearchService {
    func fetchPhotos(params: QueryParams, completion: @escaping PhotoSearchService.searchAPIResult) {
//        completion(.failure(NSError.init(domain: "test", code: 1000, userInfo: [NSLocalizedDescriptionKey: "Testing Purpose"])))
    }
}

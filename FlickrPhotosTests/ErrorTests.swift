//
//  ErrorTests.swift
//  FlickrPhotosTests
//
//  Created by Shanmugam sekar on 02/05/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import XCTest
@testable import FlickrPhotos

class ErrorTests: XCTestCase {

    func testOurErrorEnumWhenPassingErrorCaseFromFlickrAPI() {
        let errorMessage = "Parameterless searches have been disabled"
        let flickrError = NSError.init(domain: Error.FlickrAPIDomain, code: 3, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        if flickrError.domain == Error.FlickrAPIDomain {
            XCTAssert(true)
        } else {
            XCTFail("Error domain mismatch" )
        }
        if let error = Error.init(error: flickrError) {
            switch error {
            case .flickrApi(let code, let message):
                XCTAssert(code == 3, "Error enum created with error code mismatch")
                XCTAssert(message == errorMessage,  "Error enum created with error message mismatch")
                XCTAssert(error.localizedDescription == errorMessage, "Error enum created with error message mismatch")
            default:
                XCTFail("Invalid Error enum created")
            }
        } else {
            XCTFail("Failed to create error enum")
        }        
    }
    
    func testOurErrorEnumWhenPassingURLResponseWithClientError() {
        // Assumption: This url returns response with 401 status code.
        let url = URL.init(string: "https://api.flickr.com/services/rest")
        XCTAssert(url != nil, "invalid url")
        let response: HTTPURLResponse? = HTTPURLResponse.init(url: url!, statusCode: 401, httpVersion: "1.0", headerFields: nil)
        XCTAssert(url != nil, "invalid reponse")
        if let error = Error.init(response: response!) {
            switch error {
            case .http(let httpError) where httpError.rawValue == 401:
                XCTAssert(httpError.description == "API error", "Error enum created with error message mismatch")
                XCTAssert(true)
            default:
                XCTAssert(url != nil, "Invalid error enum created")
            }
        } else {
            XCTFail("Failed to create error enum")
        }
    }
    
    func testOurErrorEnumWhenPassingURLResponseWithServerError() {
        // Assumption: This url returns response with 500 status code.
        let url = URL.init(string: "https://api.flickr.com/services/rest")
        XCTAssert(url != nil, "invalid url")
        let response: HTTPURLResponse? = HTTPURLResponse.init(url: url!, statusCode: 500, httpVersion: "1.0", headerFields: nil)
        XCTAssert(url != nil, "invalid reponse")
        if let error = Error.init(response: response!) {
            switch error {
            case .http(let httpError) where httpError.rawValue == 500:
                XCTAssert(httpError.description == "Internal server error", "Error enum created with error message mismatch")
                XCTAssert(true)
            default:
                XCTAssert(url != nil, "Invalid error enum created")
            }
        } else {
            XCTFail("Failed to create error enum")
        }
    }
    
    func testOurErrorEnumWhenPassingURLResponseWithSuccessStatusCode() {
        // Assumption: This url returns response with 200 status code.
        let url = URL.init(string: "https://api.flickr.com/services/rest")
        XCTAssert(url != nil, "invalid url")
        let response: HTTPURLResponse? = HTTPURLResponse.init(url: url!, statusCode: 200, httpVersion: "1.0", headerFields: nil)
        XCTAssert(url != nil, "invalid reponse")
        if Error.init(response: response!) == nil {
            XCTAssert(true)
        } else {
            XCTFail("Error enum should not be created for response with 200 status code.")
        }
    }
    
    func testOurErrorEnumWhenPassingNilError() {        
        if Error.init(error: nil) == nil {
            XCTAssert(true)
        } else {
            XCTFail("Invalid erroe enum created when passing nil error object")
        }
    }
    
    func testOurErrorEnumWhenPassingURLLoadingError() {
        let internetNotConnectedError = NSError.init(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        if let error = Error.init(error: internetNotConnectedError) {
            switch error {
            case .urlLoading(let urlLoadingError) where urlLoadingError.rawValue == -1009:
                if urlLoadingError.description == "Please check your internet connection" {
                    XCTAssert(true)
                } else {
                    XCTFail("Error enum created with invalid description")
                }
                
            default:
                XCTFail("Invalid error enum created")
            }
        } else {
            XCTFail("Failed to create error enum")
        }
    }
    
    func testOurErrorEnumWhenPassingNoDataError() {
        let message = "no photo matches your query"
        let noDataError = NSError.init(domain: Error.ApplicationDomain, code: 100, userInfo: [NSLocalizedDescriptionKey: message])
        if let error = Error.init(error: noDataError) {
            switch error {
            case .noData(_):
                XCTAssert(true)
            default:
                XCTFail("Invalid error enum created")
            }
        } else {
            XCTFail("Failed to create error enum")
        }
    }

}

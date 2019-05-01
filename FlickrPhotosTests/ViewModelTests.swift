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
    
    let viewModel: PhotosViewModel = FlickrPhotosViewModel.init(service: MockPhotoSearchService())
    
    func testTotalNumberOfPhotos() {
        viewModel.fetchPhotos(fetchMode: FetchMode.refresh("Test"))
        XCTAssert(viewModel.count == 1, "Photos count mismatch")
    }

    func testGettingPhotoViewModelFromPhotoModel() {
        viewModel.fetchPhotos(fetchMode: FetchMode.refresh("Test"))
        let photoViewModel = viewModel.getPhotoViewModel(at: 0)
        XCTAssert(photoViewModel != nil, "Photo viewmodel creation failed")
        XCTAssert(photoViewModel!.path == "http://farm66.static.flickr.com/65535/40769666113_41825e6c49.jpg", "photo viewmodel generated with improper data.")
    }
    
    func testGettingnilPhotoViewModelWhenPassingInvalidIndex() {
        viewModel.fetchPhotos(fetchMode: FetchMode.refresh("Test"))
        let nilPhotoViewModel = viewModel.getPhotoViewModel(at: 1)
        XCTAssert(nilPhotoViewModel == nil , "Photo viewmodel should not generated for invalid index path")
    }
}

class MockPhotoSearchService: PhotoSearchService {
    func fetchPhotos(params: QueryParams, completion: @escaping MockPhotoSearchService.searchAPIResult) {
        let photo = Photo.init(id: "40769666113", owner: "132430068", secret: "41825e6c49", server: "65535", farm: 66, title: "IMG_1033 -1", ispublic: 1, isfriend: 0, isfamily: 0)
        let photoList = PhotosList.init(page: 1, pages: 100, total: "1000", photo: [photo])
        completion(.success(photoList))
    }
}

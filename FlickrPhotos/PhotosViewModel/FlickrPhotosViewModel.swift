//
//  FlickrPhotosViewModel.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

enum FetchMode: Int {
    case initial = 1
    case bottom
    case manual
}

enum ViewState {
    case loading
    case success(FetchMode)
    case error(FetchMode,String)
}

class FlickrPhotosViewModel: NSObject {
    var searchPlaceHolder: String {
        return "Explore your favourites"
    }
    var photosListCellIdentifier: String {
        return "photoCell"
    }
    var initialSearchQuery: String {
        return ""
    }
    private static let perPage = 50
    
    private var photos = [Photo]()
    private var currentPage = 0
    private let service: PhotoSearchService
    private var isLoading: Bool = false
    private var lastQuery: String = ""
    var page: Int {
        return currentPage
    }
    
    var viewState: Observable<ViewState> = Observable<ViewState>(value: .loading)
    
    init(service: PhotoSearchService = FlickrPhotoSearchService()) {
        self.service = service
    }
    
    func canFetchList() -> Bool {
        return !isLoading
    }
    
    func previousQuery() -> String {
        return lastQuery
    }
    
    func getPhotosCount() -> Int {
        return photos.count
    }
    
    func getPhotosCellViewModel(at index: Int) -> FlickrPhotosCell.ViewModel {
        let photo = photos[index]
        var viewModel = FlickrPhotosCell.ViewModel()
        viewModel.path = photo.path
        return viewModel
    }
    
    private func changeViewState(_ state: ViewState) {
        self.viewState.value = state        
    }
    
    func fetchPhotosList(for query: String, fetchMode: FetchMode) {
        switch fetchMode {
        case .initial:
            currentPage = 1
        case .manual:
            currentPage = 1
        default:
            currentPage = currentPage + 1
        }
        viewState.value = .loading
        isLoading = true
        
        service.fetchPhotos(params: QueryParams(query: query, page: currentPage, perPage: FlickrPhotosViewModel.perPage)) { [unowned self] (result) in
            self.isLoading = false
            self.lastQuery = query
            switch result {
            case .success(let data):
                switch fetchMode {
                case .initial:
                    fallthrough
                case .manual:
                    self.photos = data.photo
                case .bottom:
                    self.photos.append(contentsOf: data.photo)
                }
                self.changeViewState(.success(fetchMode))
            case .failure(let error):
                self.changeViewState(.error(fetchMode,error.localizedDescription))
            }
            
        }
    }
}

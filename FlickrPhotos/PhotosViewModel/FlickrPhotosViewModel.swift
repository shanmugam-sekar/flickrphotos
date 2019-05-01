//
//  FlickrPhotosViewModel.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

enum FetchMode {
    case refresh(String)
    case loadMore
}

extension FetchMode : RawRepresentable, Equatable {
    
    typealias RawValue = (Int, String?)
    
    init?(rawValue: FetchMode.RawValue) {
        switch rawValue {
        case (0,let x):
            self = .refresh(x ?? "")
        case (1,_):
            self = .loadMore
        default:
            return nil
        }
    }
 
    var rawValue: (Int, String?) {
        let value: (Int, String?)
        switch self {
        case .refresh(let x):
            value = (0, x)
        case .loadMore:
            value = (1, nil)
        @unknown default:
            return (-1, nil)
        }
        return value
    }
    
    static func == (lhs: FetchMode, rhs: FetchMode) -> Bool {
        return lhs.rawValue.0 == rhs.rawValue.0
    }
}

enum ViewState {
    case launched
    case fetching(FetchMode)
    case success(FetchMode)
    case error(FetchMode, String)
}

extension ViewState: RawRepresentable, Equatable {
    
    typealias RawValue = (Int, FetchMode?, String?)
    
    init?(rawValue: ViewState.RawValue) {
        switch rawValue {
        case (0, _, _):
            self = .launched
        case let (1, mode, _) where mode != nil:
            self = .fetching(mode!)
        case let (2, mode, _) where mode != nil:
            self = .success(mode!)
        case let (3, mode, message) where (mode != nil && message != nil):
            self = .error(mode!, message!)
        default:
            return nil
        }
    }

    var rawValue: ViewState.RawValue {
        let result: ViewState.RawValue
        switch self {
        case .launched:
            result = (0, nil, nil)
        case .fetching(let mode):
            result = (1, mode, nil)
        case .success(let mode):
            result = (2, mode, nil)
        case .error(let mode, let string):
            result = (3, mode, string)
        @unknown default:
            result = (-1, nil, nil)
        }
        return result
    }
    
    func getFetchMode() -> FetchMode? {
        var mode: FetchMode?
        switch self {
        case .fetching(let currentMode):
            mode = currentMode
        case .success(let currentMode):
            mode = currentMode
        case .error(let currentMode, _):
            mode = currentMode
        default:
            return nil
        }
        return mode
    }
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        return lhs.rawValue.0 == rhs.rawValue.0
    }
}

protocol PhotosViewModel: class {
    init(service: PhotoSearchService)
    var count: Int {get}
    var delegate: PhotosViewModelDelegate? {get set}
    func getPhotoViewModel(at index: Int) -> FlickrPhotosCell.ViewModel
    func fetchPhotos(fetchMode: FetchMode)
    func emitEvents()
}

protocol PhotosViewModelDelegate: class {
    func onStateChange(_ state: ViewState)
}

class FlickrPhotosViewModel: PhotosViewModel {
   
    private let perPage = 50
    private var viewState: ViewState
    private var photos: [Photo]
    private var searchQuery: String
    private var currentPage: Int
    private let service: PhotoSearchService
    weak var delegate: PhotosViewModelDelegate?
    
    var count: Int {
        return photos.count
    }
 
    required init(service: PhotoSearchService = FlickrPhotoSearchService()) {
        self.service = service
        self.viewState = ViewState.launched
        self.photos = []
        self.searchQuery = ""
        self.currentPage = 0
    }
    
    func emitEvents() {
        viewState = .launched
        delegate?.onStateChange(viewState)
    }
    
    func getPhotoViewModel(at index: Int) -> FlickrPhotosCell.ViewModel {
        let photo = photos[index]
        var viewModel = FlickrPhotosCell.ViewModel()
        viewModel.path = photo.path
        viewModel.placeholder = "placeholder"
        return viewModel
    }
    
    func fetchPhotos(fetchMode: FetchMode) {
        
        guard canFetchPhotos(viewState: viewState, fetchMode: fetchMode) else {
            return
        }
        
        changeViewState(.fetching(fetchMode))
        currentPage = getPageNumber(fetchMode: fetchMode, currentPage: currentPage)
        searchQuery =  getSearchQuery(fetchMode: fetchMode, currentQuery: searchQuery)
        let queryParams = QueryParams(query: searchQuery, page: currentPage, perPage: perPage)
        
        service.fetchPhotos(params: queryParams) { [unowned self] (result) in
            switch result {
            case .success(let data):
                switch fetchMode {
                case .refresh:
                    self.photos = data.photo
                case .loadMore:
                    self.photos.append(contentsOf: data.photo)
                }
                self.changeViewState(ViewState.success(fetchMode))
            case .failure(let error):
                self.changeViewState(ViewState.error(fetchMode, error.localizedDescription))
            }
        }
    }
    
    func getPageNumber(fetchMode: FetchMode, currentPage: Int) -> Int {
        var pageNumber = 0
        switch fetchMode {
        case .refresh(_):
            pageNumber = 1
        case .loadMore:
            pageNumber = currentPage + 1
        }
        return pageNumber
    }
    
    func getSearchQuery(fetchMode: FetchMode, currentQuery: String) -> String {
        let query: String
        switch fetchMode {
        case .refresh(let x):
            query = x
        case .loadMore:
            query = currentQuery
        }
        return query
    }
    
    private func changeViewState(_ viewState: ViewState) {
        self.viewState = viewState
        self.delegate?.onStateChange(viewState)
    }
    
    private func canFetchPhotos(viewState: ViewState, fetchMode: FetchMode) -> Bool {
        
        //controls triggering multiple api calls by reaching page end when previous call in progress
        if (viewState.getFetchMode() != nil) && (viewState == ViewState.fetching(viewState.getFetchMode()!)) {
            return false
        }
        
        //controls making an api call by reaching an bottom when an api call for search in progress
        if (viewState.getFetchMode() != nil) && (fetchMode == FetchMode.loadMore) && (viewState == ViewState.fetching(viewState.getFetchMode()!)) {
            return false
        }
        return true
    }
}


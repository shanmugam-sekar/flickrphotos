//
//  ViewController.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 28/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import UIKit

class FlickrPhotosViewController: UIViewController {
    
    struct Constants {
        static let searchPlaceHolder = "Explore your favourites"
        static let photosListCellIdentifier = "photoCell"
    }
    
    private var viewModel: PhotosViewModel!
    private var collectionView: UICollectionView!
    private var loader: Loader!
    private var searchBar: UISearchBar!
    private lazy var photoSize: CGSize = {
        let viewWidth = UIScreen.main.bounds.size.width
        let photoWidth = (viewWidth/3) - 10
        return CGSize(width: photoWidth, height: photoWidth)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureViewModel()
    }
    
    override func loadView() {
        super.loadView()
        configureViewModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        setupLoader()
        setupLoaderVisibility(false)
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.emitEvents()
    }
    
    func configureViewModel(_ viewModel: PhotosViewModel = FlickrPhotosViewModel()) {
        self.viewModel = viewModel
    }
    
    private func setupSearchBar() {
        if let navigationController = navigationController {
            let frame = CGRect(origin: .zero, size: navigationController.navigationBar.frame.size)
            let searchBar = UISearchBar(frame: frame)
            searchBar.delegate = self
            searchBar.placeholder = FlickrPhotosViewController.Constants.searchPlaceHolder
            searchBar.returnKeyType = .search
            navigationItem.titleView = searchBar
            self.searchBar = searchBar
        } else {
            fatalError("Intialise viewcontroller with navigation controller")
        }
    }
    
    private func setupCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = photoSize
        return layout
    }
    
    private func setupCollectionView() {
        let photosCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: setupCollectionViewLayout())
        photosCollectionView.backgroundColor = UIColor.white
        photosCollectionView.register(UINib.init(nibName: "FlickrPhotosCell", bundle: nil), forCellWithReuseIdentifier: FlickrPhotosViewController.Constants.photosListCellIdentifier)
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        photosCollectionView.bounces = false
        
        view.addSubview(photosCollectionView)
        
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: 0))
        
        collectionView = photosCollectionView
    }

    private func setupLoader() {
        let loader = Loader.init(frame: .zero)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.backgroundColor = UIColor.blue
        loader.layer.cornerRadius = 5.0
        loader.clipsToBounds = true
        view.addSubview(loader)
        
        loader.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loader.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        loader.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loader.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

        self.loader = loader
    }
    
    private func setupLoaderVisibility(_ visibility: Bool) {
        loader.isHidden = !visibility
        visibility ? loader.startAnimating() : loader.stopAnimating()
    }
    
    private func showAlert(_ message: String) {
        let controller = UIAlertController.init(title: NSLocalizedString("alert_title", comment: ""), message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
}

extension FlickrPhotosViewController: PhotosViewModelDelegate {
    func onStateChange(_ state: ViewState) {
        DispatchQueue.main.async { [weak self] in
            if let self = self {
                switch state {
                case .launched:
                    self.searchBar.becomeFirstResponder()
                case .empty(let message):
                    self.setupLoaderVisibility(false)
                    self.collectionView.reloadData()
                    self.showAlert(message)
                case .fetching(_):
                    self.setupLoaderVisibility(true)
                case .error(_, let message):
                    self.setupLoaderVisibility(false)
                    self.showAlert(message)
                case .success(let mode):
                    self.setupLoaderVisibility(false)
                    if mode == .refresh("") {
                        CATransaction.begin()
                        self.collectionView.reloadData()
                        CATransaction.setCompletionBlock({
                            self.collectionView.scrollRectToVisible(CGRect(origin: .zero, size: self.photoSize), animated: false)
                        })
                        CATransaction.commit()
                    } else {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension FlickrPhotosViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.fetchPhotos(fetchMode: .refresh(searchBar.text ?? ""))
    }
}

extension FlickrPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FlickrPhotosViewController.Constants.photosListCellIdentifier, for: indexPath)
        if let photoCell = cell as? FlickrPhotosCell {
            photoCell.feedCell(with: viewModel.getPhotoViewModel(at: indexPath.row))
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isPhotosViewReachedBottom(scrollView) {
            viewModel.fetchPhotos(fetchMode: .loadMore)
        }
    }

    private func isPhotosViewReachedBottom(_ scrollView: UIScrollView) -> Bool {
        return round(scrollView.frame.size.height  + scrollView.contentOffset.y) >= round(scrollView.contentSize.height)
    }
}



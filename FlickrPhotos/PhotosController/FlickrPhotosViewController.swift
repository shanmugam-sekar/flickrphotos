//
//  ViewController.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 28/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import UIKit

class FlickrPhotosViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var loader: UIActivityIndicatorView!
    private lazy var photoSize: CGSize = {
        let viewWidth = UIScreen.main.bounds.size.width
        let photoWidth = (viewWidth/3) - 10
        return CGSize(width: photoWidth, height: photoWidth)
    }()
    var viewModel: FlickrPhotosViewModel = FlickrPhotosViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        setupActivityIndicatorView()
        viewModel.viewState.valueChanged = { [weak self] (value) in
            guard let value = value, let self = self else {
                return
            }
            switch value {
            case .loading:
                self.loader.startAnimating()
            case .success(let mode):
                self.loader.stopAnimating()
                if mode == .manual {
                    CATransaction.begin()
                    self.collectionView.reloadData()
                    CATransaction.setCompletionBlock({
                        self.collectionView.scrollRectToVisible(CGRect(origin: .zero, size: self.photoSize), animated: false)
                    })
                    CATransaction.commit()
                } else {
                    self.collectionView.reloadData()
                }
            case .error(_,let error):
                self.loader.stopAnimating()
                self.showAlert(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPhotosList(for: viewModel.initialSearchQuery, fetchMode: .initial)
    }

    private func setupSearchBar() {
        if let navigationController = navigationController {
            let frame = CGRect(origin: .zero, size: navigationController.navigationBar.frame.size)
            let searchBar = UISearchBar(frame: frame)
            searchBar.delegate = self
            searchBar.placeholder = viewModel.searchPlaceHolder
            searchBar.returnKeyType = .search
            navigationItem.titleView = searchBar
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
        photosCollectionView.register(UINib.init(nibName: "FlickrPhotosCell", bundle: nil), forCellWithReuseIdentifier: viewModel.photosListCellIdentifier)
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photosCollectionView.dataSource = self
        photosCollectionView.delegate = self
        photosCollectionView.bounces = false
        
        view.addSubview(photosCollectionView)
        
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: photosCollectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: -40))
        
        collectionView = photosCollectionView
    }

    private func setupActivityIndicatorView() {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .gray)
        activityIndicatorView.color = UIColor.red
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicatorView)
        
        view.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1.0, constant: 0))
        
        loader = activityIndicatorView
    }
    
    private func showAlert(_ message: String) {
        let controller = UIAlertController.init(title: NSLocalizedString("alert_title", comment: ""), message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
}

extension FlickrPhotosViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.fetchPhotosList(for: searchBar.text ?? "", fetchMode: .manual)
    }
}

extension FlickrPhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.photosListCellIdentifier, for: indexPath)
        if let photoCell = cell as? FlickrPhotosCell {
            photoCell.setup(viewModel: viewModel.getPhotosCellViewModel(at: indexPath.row))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getPhotosCount()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isPhotosViewReachedBottom(scrollView) && viewModel.canFetchList() {
            viewModel.fetchPhotosList(for: viewModel.previousQuery(), fetchMode: .bottom)
        }
    }
    
    private func isPhotosViewReachedBottom(_ scrollView: UIScrollView) -> Bool {
        return round(scrollView.frame.size.height  + scrollView.contentOffset.y) >= round(scrollView.contentSize.height)
    }
}


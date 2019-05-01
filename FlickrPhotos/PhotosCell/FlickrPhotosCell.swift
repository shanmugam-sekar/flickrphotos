//
//  FlickrPhotosCell.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import UIKit

class FlickrPhotosCell: UICollectionViewCell {
    
    struct ViewModel {
        var path: String?
        var placeholder: String?
    }

    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var image: UIImageView!
    private var viewModel: ViewModel!
    private var downloader: ImageDownloader! = ImageDownloader.sharedImageDownloader
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loader.stopAnimating()
        self.image.image = UIImage()
    }
    
    func feedCell(with viewModel: ViewModel) {
        self.viewModel = viewModel
        guard let path = viewModel.path else {
            return
        }
        let placehoder: UIImage? = (viewModel.placeholder != nil) ? UIImage.init(named: viewModel.placeholder!) : nil
        loader.startAnimating()
        downloader.download(path: path, placeHolderImage: placehoder) { [weak self] (image) in
            if let self = self, path == viewModel.path {
                self.loader.stopAnimating()
                self.image.image = image
            }
        }
    }

}

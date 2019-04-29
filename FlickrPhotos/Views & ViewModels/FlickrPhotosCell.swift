//
//  FlickrPhotosCell.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import UIKit

struct FlickrPhotosCellViewModel {
    var path: String?    
}

class FlickrPhotosCell: UICollectionViewCell {

    @IBOutlet weak var image: UIImageView!
    private var viewModel: FlickrPhotosCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.image.image = UIImage()
    }
    
    func setup(viewModel: FlickrPhotosCellViewModel) {
        self.viewModel = viewModel
        guard let path = viewModel.path else {
            return
        }
        ImageDownloader.sharedImageDownloader.fetch(path: path, placeHolderImage: UIImage.init(named: "placeholder")) { [weak self] (image) in
            if let self = self, path == viewModel.path {
                self.image.image = image
            }
        }
    }

}

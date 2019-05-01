//
//  Loader.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 02/05/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation
import UIKit

class Loader: UIView {
    
    private var loader: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        let activityIndicatorView = UIActivityIndicatorView.init(style: .gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.tintColor = UIColor.white
        addSubview(activityIndicatorView)
        
        let label = UILabel.init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading"
        label.textColor = UIColor.white
        addSubview(label)
        
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityIndicatorView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10.0).isActive = true
        
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        loader = activityIndicatorView
    }
    
    func startAnimating() {
        loader.startAnimating()
    }
    
    func stopAnimating() {
        loader.stopAnimating()
    }
}

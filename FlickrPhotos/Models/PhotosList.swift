//
//  PhotosList.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

struct PhotosList: Decodable {
    let page: Int
    let pages: Int
    let total: String
    let photo: [Photo]
}

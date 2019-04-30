//
//  Photo.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

struct Photo: Decodable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    var path: String {
        let path = "http://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
        return path
    }
}

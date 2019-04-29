//
//  Models.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 29/04/19.
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

struct PhotosList: Decodable {
    let page: Int
    let pages: Int
    let total: String
    let photo: [Photo]
}

struct FlickrPhotoSearchResponse: Decodable {
    let status: Bool
    let photos: PhotosList?
    let code: Int?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case stat
        case photos
        case code
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tempStat = try container.decode(String.self, forKey: .stat)
        status = tempStat == "ok"
        photos = try! container.decode(PhotosList.self, forKey: .photos)
        code = try? container.decode(Int.self, forKey: .code)
        message = try? container.decode(String.self, forKey: .message)
    }
}

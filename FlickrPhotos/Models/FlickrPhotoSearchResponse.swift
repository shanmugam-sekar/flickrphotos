//
//  FlickrPhotoSearchResponse.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 30/04/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

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
        photos = try? container.decode(PhotosList.self, forKey: .photos)
        code = try? container.decode(Int.self, forKey: .code)
        message = try? container.decode(String.self, forKey: .message)
    }
}

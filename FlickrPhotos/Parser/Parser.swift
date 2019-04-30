//
//  Parser.swift
//  FlickrPhotos
//
//  Created by Shanmugam sekar on 01/05/19.
//  Copyright © 2019 Shanmugam sekar. All rights reserved.
//

import Foundation

struct Parser<T: Decodable> {
    func parse(data: Data) throws -> T  {
        var result: T
        do {
            result = try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
        return result
    }
}

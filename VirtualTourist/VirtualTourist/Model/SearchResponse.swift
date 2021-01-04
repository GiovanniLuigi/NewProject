//
//  SearchResponse.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 03/01/21.
//  Copyright © 2021 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation

import Foundation

// MARK: - SearchResponse
struct SearchResponse: Codable {
    let dataResponse: DataResponse
    let stat: String
    
    private enum CodingKeys : String, CodingKey {
        case dataResponse = "photos", stat
    }
}

// MARK: - Photos
struct DataResponse: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoResponse]
}

// MARK: - Photo
struct PhotoResponse: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}

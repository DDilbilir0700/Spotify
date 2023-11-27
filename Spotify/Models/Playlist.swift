//
//  Playlist.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import Foundation

struct Playlist: Codable {
    let description: String
    let id: String
    let external_urls: [String: String]
    let images: [Image]
    let name: String
    let owner: UserFeatures
}

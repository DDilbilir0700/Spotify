//
//  fetchReleasesResponder.swift
//
//  Created by Deniz Dilbilir on 04/12/2023.
//

import Foundation

struct FetchReleasesResponder: Codable {
    let albums: AlbumsResponder
}

struct AlbumsResponder: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let id: String
    var images: [Image]
    let name: String
    let release_date: String
    let type: String
    let total_tracks: Int
    let artists: [Artist]
}

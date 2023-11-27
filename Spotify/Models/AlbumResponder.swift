//
//  AlbumResponder.swift
//
//  Created by Deniz Dilbilir on 13/12/2023.
//

import Foundation

struct AlbumResponder: Codable {
    let album_type: String
    let artists: [Artist]
    let available_markets: [String]
    let external_urls: [String: String]
    let id: String
    let images: [Image]
    let label: String
    let name: String
    let tracks: TracksResponse
}

struct TracksResponse: Codable {
    let items: [Tracks]
}



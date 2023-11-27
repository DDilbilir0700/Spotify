//
//  PlaylistResponder.swift
//
//  Created by Deniz Dilbilir on 14/12/2023.
//

import Foundation

struct PlaylistResponder: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [Image]
    let name: String
    let tracks: PlaylistTracksResponse
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItems]
}

struct PlaylistItems: Codable {
    let track: Tracks
}

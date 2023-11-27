//
//  GetFeaturedPlaylistsResponder.swift
//
//  Created by Deniz Dilbilir on 04/12/2023.
//

import Foundation

struct GetFeaturedPlaylistsResponder: Codable {
    let playlists: PlaylistResponse
}

struct CategoryPlaylistResponse: Codable {
    let playlists: PlaylistResponse
}


struct PlaylistResponse: Codable {
    let items: [Playlist]
}



struct UserFeatures: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}



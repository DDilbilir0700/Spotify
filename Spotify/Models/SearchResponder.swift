//
//  SearchResponder.swift
//
//  Created by Deniz Dilbilir on 26/12/2023.
//

import Foundation

struct SearchResponder: Codable {
    let albums: SeachAlbumResponder
    let artists: SearchArtistResponder
    let playlists: SearchPlaylistResponder
    let tracks: SearchTracksResponder
}

struct SeachAlbumResponder: Codable {
    let items: [Album]
}

struct SearchArtistResponder: Codable {
    let items: [Artist]
}

struct SearchPlaylistResponder: Codable {
    let items: [Playlist]
}

struct SearchTracksResponder: Codable {
    let items: [Tracks]
}

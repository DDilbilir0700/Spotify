//
//  LibraryAlbumResponder.swift
//
//  Created by Deniz Dilbilir on 18/01/2024.
//

import Foundation


struct LibraryAlbumResponder: Codable {
    let items: [AddedToLibraryAlbum]
}

struct AddedToLibraryAlbum: Codable {
    let added_at: String
    let album: Album
}

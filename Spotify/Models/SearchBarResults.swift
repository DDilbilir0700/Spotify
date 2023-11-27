//
//  SearchBarResults.swift
//
//  Created by Deniz Dilbilir on 27/12/2023.
//

import Foundation

enum SearchBarResults {
    case artist(model: Artist)
    case track(model: Tracks)
    case playlist(model: Playlist)
    case album(model: Album)
}

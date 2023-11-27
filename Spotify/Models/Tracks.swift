//
//  Tracks.swift
//
//  Created by Deniz Dilbilir on 05/12/2023.
//

import Foundation


struct Tracks: Codable {
    var album: Album?
    let artists: [Artist]
    let available_markets: [String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String: String]
    let id: String
    let name: String
    let preview_url: String?

}



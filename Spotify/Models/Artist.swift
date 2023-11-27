//
//  Artist.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import Foundation


struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [Image]?
    let external_urls: [String: String]
}

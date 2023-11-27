//
//  User.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import Foundation

struct User: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let images: [Image]
}
     


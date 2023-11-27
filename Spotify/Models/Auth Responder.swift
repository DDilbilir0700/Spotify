//
//  Auth Responder.swift
//
//  Created by Deniz Dilbilir on 24/11/2023.
//

import Foundation

struct AuthResponder: Codable {
    let access_token: String
    let refresh_token: String?
    let expires_in: Int
    let scope: String
    let token_type: String
}

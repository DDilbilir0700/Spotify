//
//  Constants .swift
//
//  Created by Deniz Dilbilir on 22/11/2023.
//

import Foundation

struct Constants {
    static var clientID: String {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let keys = NSDictionary(contentsOfFile: path),
              let clientID = keys["clientID"] as? String else {
            fatalError("Unable to load client ID from Keys.plist")
        }
        return clientID
    }

    static var clientSecret: String {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let keys = NSDictionary(contentsOfFile: path),
              let clientSecret = keys["clientSecret"] as? String else {
            fatalError("Unable to load client secret from Keys.plist")
        }
        return clientSecret
    }
    static let tokenURL = "https://accounts.spotify.com/api/token"
    static let redirectURI = "https://ddenizdilbilir.wordpress.com/"
    static let scopes = "user-read-private%20playlist-modify-public%20playlist-modify-private%20playlist-read-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
   static let baseURL = "https://api.spotify.com/v1"
}

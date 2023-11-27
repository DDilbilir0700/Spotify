//
//  AuthManager.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import Foundation


final class AuthManager {
    
    static let shared = AuthManager()
    
    private var refreshingToken = false
    
    private init() {}
    
    public var signInURL: URL? {
        
       
        let base = "https://accounts.spotify.com/authorize"
        
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID.trimmingCharacters(in: .whitespacesAndNewlines))&scope=\(Constants.scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        
        return URL(string: string)
    }
    
    var registered: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationTime: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var mustRefreshToken: Bool {
        guard let expirationTime = tokenExpirationTime else {
            return false
        }
        
        let currentDate = Date()
        let refreshThreshold: TimeInterval = 300
        
        return currentDate.addingTimeInterval(refreshThreshold) >= expirationTime
    }
    
    func exchangeForToken(code: String, completion: @escaping ((Bool) -> Void)) {
        guard let url = URL(string: Constants.tokenURL) else {
            completion(false)
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = components.query?.data(using: .utf8)
        
        let token = Constants.clientID + ":" + Constants.clientSecret
        let data = token.data(using: .utf8)
        guard let base64 = data?.base64EncodedString() else {
            print("base64 error")
            completion(false)
            return
        }
        
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                print("Error during token exchange: \(String(describing: error))")
                completion(false)
                return
            }
            print("Raw response data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            do {
                let result = try JSONDecoder().decode(AuthResponder.self, from: data)
                self?.cacheToken(result: result)
                print("Token exchange successful: \(result)")
                completion(true)
            } catch {
                print("Error decoding token: \(error)")
                completion(false)
            }
        }
        
        task.resume()
    }
    
    private var onRefresh = [((String) -> Void)]()
    
    func withAuthenticatedToken(completion: @escaping (String) -> Void) {
        guard !refreshingToken else {
            onRefresh.append(completion)
            return
        }
        if mustRefreshToken {
            refreshInNeed { [weak self] success in
                if let token = self?.accessToken,success {
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }
    
    func refreshInNeed(completion: ((Bool) -> Void)?) {
        guard !refreshingToken else {
            return
        }
        
        guard  mustRefreshToken else {
            completion?(true)
            return
        }
        guard let refreshToken = self.refreshToken else {
            return
        }
        guard let url = URL(string: Constants.tokenURL) else {
            return
        }
        
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = components.query?.data(using: .utf8)
        
        let token = Constants.clientID + ":" + Constants.clientSecret
        let data = token.data(using: .utf8)
        guard let base64 = data?.base64EncodedString() else {
            print("base64 error")
            completion?(false)
            return
        }
        
        urlRequest.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Error during token exchange: \(String(describing: error))")
                completion?(false)
                return
            }
            print("Raw response data: \(String(data: data, encoding: .utf8) ?? "No data")")
            
            do {
                let result = try JSONDecoder().decode(AuthResponder.self, from: data)
                self?.onRefresh.forEach { $0(result.access_token)
                    self?.onRefresh.removeAll()
                    
                }
                self?.cacheToken(result: result)
                print("Token exchange successful: \(result)")
                completion?(true)
            } catch {
                print("Error decoding token: \(error)")
                completion?(false)
            }
        }
        
        task.resume()
    }
    
    

    

    private func cacheToken(result: AuthResponder) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
    }
        
       
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    
    func logOut(completion: (Bool) -> Void) {
        
        
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expirationDate")
        completion(true)
    }
}

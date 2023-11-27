//
//  APIManager.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    private init() {
    }
    
    enum APIRequestError: Error {
        case couldntReceiveData
    }
    
    // MARK: Albums
    
    func getAlbum(for album: Album, completion: @escaping (Result<AlbumResponder, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/albums/" + album.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                do {
                    let json = try JSONDecoder().decode(AlbumResponder.self, from: data)
//                    JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    
                    completion(.success(json))
                }
                catch {
                   
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getUserAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/me/albums"), type: .GET) { userAlbumRequest in
            print("getting albums")
            let task = URLSession.shared.dataTask(with: userAlbumRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                do {
                    let json = try JSONDecoder().decode(LibraryAlbumResponder.self, from: data)
                    
                    completion(.success(json.items.compactMap({ $0.album})))
                    
                }
                catch {
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        
        }
    }
    
    func saveAlbumsToLibrary(album: Album, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/me/albums?ids=\(album.id)"), type: .PUT) { baseRequest in
            
            var request = baseRequest
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, error == nil else {
                    completion(false)
                    return
                }
                    print(statusCode)
                    completion(statusCode == 200)
                }
            task.resume()
            
        }
    }
    
    
    
    // MARK: Playlists
    
    func getPlaylist(for playlist: Playlist, completion: @escaping (Result<PlaylistResponder, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/playlists/" + playlist.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                do {
                    let json = try JSONDecoder().decode(PlaylistResponder.self, from: data)
//                    JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    print(json)
                    completion(.success(json))
                }
                catch {
//                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    public func getUserPlaylists(completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/me/playlists/?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                
                do {
                    let json = try JSONDecoder().decode(LibraryPlaylistResponder.self, from: data)
                    completion(.success(json.items))
                }
                catch {
                  
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
    }
     func createPlaylists(with name: String, completion: @escaping (Bool) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
                
            case .success(let success):
                let urlString = Constants.baseURL + "/users/\(success.id)/playlists"
                print(urlString)
                self?.createRequest(with: URL(string: urlString), type: .POST) { baseRequest in
                    
            
                    var request = baseRequest
                   let json = ["name": name]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    print("creating...")
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            if let response = result as? [String: Any], response["id"] as? String != nil {
                                print("created")
                                completion(true)
                            }
                            else {
                                print("failed to create.")
                                completion(false)
                            }
                        }
                        catch {
                            print(error.localizedDescription)
                            completion(false)
                        }
                    }
                    task.resume()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    public func addsongsToPlaylists(track: Tracks, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/playlists/\(playlist.id)/tracks"), type: .POST) { urlRequest in
            var request = urlRequest
            let json = ["uris": ["spotify:track:\(track.id)"]]
            print(json)
            request.httpBody  = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            print("adding to the playlist")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print(result)
                    if let response = result as? [String: Any], response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
                catch {
                    completion(false)
                }
            }
            task.resume()
        }
    
    }
    public func removeSongFromPlaylist(
        track: Tracks,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void
    ) {
        createRequest(
            with: URL(string: Constants.baseURL + "/playlists/\(playlist.id)/tracks"),
            type: .DELETE
        ) { baseRequest in
            var request = baseRequest
            let json: [String: Any] = [
                "tracks": [
                    [
                        "uri": "spotify:track:\(track.id)"
                    ]
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(false)
                    return
                }

                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
                }
                catch {
                    completion(false)
                }
            }
            task.resume()
        }
    }

    
    
    // MARK: - profile
    
    func getCurrentUserProfile(completion: @escaping (Result<User, Error>) -> Void) {
          createRequest(with: URL(string: Constants.baseURL + "/me"), type: .GET) { request in
              let task = URLSession.shared.dataTask(with: request) { data, response, error in
                  guard let data = data, error == nil else {
                      print("API Error: \(error?.localizedDescription ?? "Unknown error")")
                      completion(.failure(APIRequestError.couldntReceiveData))
                      return
                  }
               
                  print(String(data: data, encoding: .utf8) ?? "No raw data")

                  do {
                      let result = try JSONDecoder().decode(User.self, from: data)
                      completion(.success(result))
                  } catch {
                      print("Decoding Error: \(error.localizedDescription)")
                      completion(.failure(error))
                  }
              }
              task.resume()
          }
      }
    
    // MARK: - Search

    func fetchReleases(completion: @escaping ((Result<FetchReleasesResponder, Error>))  -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/new-releases?limit=50"), type: .GET) { request in


            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    print("getNewRelease API error \(String(describing: error?.localizedDescription))")
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                do {
                    let json = try JSONDecoder().decode(FetchReleasesResponder.self, from: data)
                    print("JSON: \(json)")
                       completion(.success(json))
                }
                catch {
                    print("JSON error: \(error.localizedDescription)")
                       completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getFeaturedPlaylists(completion: @escaping ((Result<GetFeaturedPlaylistsResponder, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/featured-playlists?limit=20"), type: .GET) { request in
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    print("getNewRelease API error \(String(describing: error?.localizedDescription))")
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                do {
                    let json = try JSONDecoder().decode(GetFeaturedPlaylistsResponder.self, from: data)
                    
                     completion(.success(json))
                }
                catch {
                    print("JSON GetFeaturedPlaylistResponse error: \(error.localizedDescription)")
                       completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponder, Error>) -> Void)) {
        let seeds = genres.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        print("Fetching recommendations for genres: \(seeds)")

        createRequest(with: URL(string: Constants.baseURL + "/recommendations?limit=10&seed_genres=\(seeds)"), type: .GET) { request in
            print("URL Request: \(request)")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error in recommendations API call: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

              
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("HTTP Error: Status code \(httpResponse.statusCode)")
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                
                guard let data = data else {
                               print("No data received from recommendations API")
                               completion(.failure(APIRequestError.couldntReceiveData))
                               return
                           }

                           if let dataString = String(data: data, encoding: .utf8) {
                               print("Raw response data: \(dataString)")
                           }

                           do {
                               let json = try JSONDecoder().decode(RecommendationsResponder.self, from: data)
                               completion(.success(json))
                           } catch {
                               print("JSON decoding error: \(error.localizedDescription)")
                               completion(.failure(error))
                           }
                       }
                       task.resume()
        }
    }

        
    func getRecommendedGenres(completion: @escaping ((Result<GenresRecommendedResponder, Error>) -> Void)) {
           createRequest(with: URL(string: Constants.baseURL + "/recommendations/available-genre-seeds"), type: .GET) { request in
               print("Recommendations api call start")
   
               let task = URLSession.shared.dataTask(with: request) { data, _, error in
                   guard let data = data, error == nil else {
   
                       completion(.failure(APIRequestError.couldntReceiveData))
                       return
                   }
                   do {
                       let json = try JSONDecoder().decode(GenresRecommendedResponder.self, from: data)
                    
                    completion(.success(json))
                   }
                   catch {
                      
                       completion(.failure(error))
                   }
               }
               task.resume()
           }
       }
    // MARK: - Category
    
    public func getCategoriesForSearchVC(completion: @escaping (Result<[Items], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/categories?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                
                do {
                    
                    let json = try JSONDecoder().decode(CategoriesResponder.self, from: data)
                    print(json.categories.items)
                    completion(.success(json.categories.items))

                }
                catch {
                    completion(.failure(error))
                    print(error.localizedDescription)
                }
            }
            task.resume()
        }
    }
    
  
    
    public func getPlaylistCategoryForSearchVC(category: Items, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/categories/\(category.id)/playlists?limit=20"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIRequestError.couldntReceiveData))
                    return
                }
                
                do {
                    
                    let json = try JSONDecoder().decode(CategoryPlaylistResponse.self, from: data)
                    let playlists = json.playlists.items
                    
                    completion(.success(playlists))
                    
                    
                }
                catch {
                    completion(.failure(error))
                   
                }
            }
            task.resume()
        }
    }
    
    // MARK: Search Results
   
            public func search(with query: String, completion: @escaping (Result<[SearchBarResults], Error>) -> Void) {
                createRequest(with: URL(string: Constants.baseURL + "/search?limit=10&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { request in
                    print(request.url?.absoluteString ?? "none")
                    let task = URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(.failure(APIRequestError.couldntReceiveData))
                            return
                        }
        
                        do {
        
                            let json = try  JSONDecoder().decode(SearchResponder.self, from: data)
                            var searchBarResults: [SearchBarResults] = []
                            searchBarResults.append(contentsOf: json.tracks.items.compactMap({ SearchBarResults.track(model: $0) }))
                            searchBarResults.append(contentsOf: json.albums.items.compactMap({ SearchBarResults.album(model: $0) }))
                            searchBarResults.append(contentsOf: json.artists.items.compactMap({ SearchBarResults.artist(model: $0) }))
                            searchBarResults.append(contentsOf: json.playlists.items.compactMap({ SearchBarResults.playlist(model: $0) }))
                            completion(.success(searchBarResults))
                        }
                        catch {
                            print(error.localizedDescription)
                            completion(.failure(error))
        
                        }
                    }
                    task.resume()
                }
            }
        
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        
        AuthManager.shared.withAuthenticatedToken { accessToken in
            guard let URL = url else {
                return
            }
            var uRLRequest = URLRequest(url: URL)
            uRLRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            uRLRequest.httpMethod = type.rawValue
            uRLRequest.timeoutInterval = 30
            completion(uRLRequest)
        }
        
    }
        
    }
    
    
    
    

    



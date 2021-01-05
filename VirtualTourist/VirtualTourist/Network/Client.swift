//
//  Client.swift
//  VirtualTourist
//
//  Created by Giovanni Luidi Bruno on 03/01/21.
//  Copyright © 2021 Giovanni Luigi Bruno. All rights reserved.
//

import Foundation

class Client {
    
    static let shared = Client()
    
    private init() {}
    
    struct Auth {
        static let apiKey = "fb5f4cbfc4aabe1c0eab73a4b9201c1c"
    }
    
    enum ClientError: Error, LocalizedError {
        case parsingError
        case invalidCredentials
        case networkError
        
        var errorDescription: String? {
            switch self {
            case .parsingError:
                return "Invalid data. Parsing error."
            case .invalidCredentials:
                return "Account not found or invalid credentials."
            case .networkError:
                return "An network error was found."
            }
        }
    }
    
    enum HttpMethod: String {
        case GET, POST, PUT, DELETE
    }
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/"
        
        case search(lat: Double, lon: Double, accuracy: Int = 11, contentType: Int = 1, perPage: Int, page: Int)
        case image(server: String, id: String, secret: String, size: String = "m")
        
        var stringValue: String {
            switch self {
            case .search(let lat, let lon, let accuracy, let contentType, let perPage, let page):
                return Endpoints.base + "?method=flickr.photos.search&api_key=\(Auth.apiKey)&lat=\(lat)&lon=\(lon)&accuracy=\(accuracy)&content_type\(contentType)&per_page=\(perPage)&page=\(page)&format=json&nojsoncallback=1"
            case .image(let server, let id, let secret, let size):
                return "https://live.staticflickr.com/\(server)/\(id)_\(secret)_\(size).jpg"
            }
        }
        
        var url: URL {
            return URL(string: self.stringValue)!
        }
        
        var urlComponents: URLComponents {
            return URLComponents(string: self.stringValue)!
        }
    }
    
    func getImage(from photo: PhotoResponse, completion: @escaping (_ imageData: Data?)->Void) {
        let url = Endpoints.image(server: photo.server, id: photo.id, secret: photo.secret).url
        DispatchQueue.global(qos: .userInitiated).async {
            let data = try? Data(contentsOf: url)
            completion(data)
        }
    }
    
    func getPhotosFrom(lat: Double, lon: Double, completion: @escaping (Result<SearchResponse, Error>)->Void) {
        var request = URLRequest(url: Endpoints.search(lat: lat, lon: lon, perPage: 15, page: 1).url, timeoutInterval: 30)
        request.httpMethod = HttpMethod.GET.rawValue
        doHttpRequest(request, modelType: SearchResponse.self) { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    completion(.success(response))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func doHttpRequest<S: Codable>(_ request: URLRequest, modelType: S.Type, completion: @escaping (Result<S, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
                return
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 403 {
                DispatchQueue.main.async {
                    completion(.failure(ClientError.invalidCredentials))
                }
                return
            }
            
            do {
                let obj = try JSONDecoder().decode(modelType, from: data)
                DispatchQueue.main.async {
                    completion(.success(obj))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    
}

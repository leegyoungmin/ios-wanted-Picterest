//
//  Network.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/28.
//

import Foundation
import UIKit

enum NetWorkError: Error {
    case unknown
}

protocol NetWorkAble {
    var baseURL: String { get }
    var pageNumber: Int { get set }
    var apiKey: String { get }
    var query: [String: String]? { get }
    
    func configureURL() -> URL?
    func toQueryItem() -> [URLQueryItem]
    func requestNetwork(completion: @escaping (Result<Any, NetWorkError>) -> Void)
}

extension NetWorkAble {
    func toQueryItem() -> [URLQueryItem] {
        if let query = query {
            return query.configureQuerys()
        } else {
            let queryItem = [
                "client_id": apiKey,
                "page": "\(pageNumber)",
                "per_page": "15"
            ]
            return queryItem.configureQuerys()
        }
    }

    func configureURL() -> URL? {
        guard var components = URLComponents(string: baseURL) else {
            return nil
        }
        
        components.queryItems = toQueryItem()

        guard let url = components.url else {
            return nil
        }
        
        return url
    }
}

class ImageLoader: NetWorkAble {
    var baseURL: String
    var query: [String : String]?
    var pageNumber: Int
    
    var apiKey: String
    var task: URLSessionDataTask?
    
    init(baseURL: String, pageNumber: Int = 0, apiKey: String = "", query: [String:String]?) {
        self.baseURL = baseURL
        self.pageNumber = pageNumber
        self.apiKey = apiKey
        self.query = query
    }
    
    func requestNetwork(completion: @escaping (Result<Any, NetWorkError>) -> Void) {
        
        if let imageLoadURL = configureURL() {
            task = URLSession.shared.dataTask(with: imageLoadURL) { data, response, error in
                guard error == nil else {
                    completion(.failure(.unknown))
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    completion(.failure(.unknown))
                    
                    return
                }
                
                guard let data = data,
                      let image = UIImage(data: data) else {
                    completion(.failure(.unknown))
                    return
                }
                
                completion(.success(image))
            }
        }
    }
}

class ImageDataLoader: NetWorkAble {
    var baseURL: String
    var pageNumber: Int
    var apiKey: String
    var query: [String : String]?
    
    init(
        baseURL: String = "https://api.unsplash.com/photos/",
        pageNumber: Int = 1,
        apiKey: String,
        query: [String: String]? = nil
    ) {
        self.baseURL = baseURL
        self.pageNumber = pageNumber
        self.apiKey = apiKey
    }
    
    func requestNetwork(completion: @escaping (Result<Any, NetWorkError>) -> Void) {
        
        if let imageDataLoadURL = configureURL() {
            URLSession.shared.dataTask(with: imageDataLoadURL) { data, response, error in
                guard error == nil else {
                    print("Error in data add")
                    completion(.failure(.unknown))
                    return
                }
                
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    print(response)
                    completion(.failure(.unknown))
                    print("Error in status code")
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.unknown))
                    return
                }
                
                do {
                    let datas = try JSONDecoder().decode(Photo.self, from: data)
                    completion(.success(datas))
                    self.pageNumber += 1
                } catch {
                    print("Error in decode data")
                }
            }
            .resume()
        }
    }
    
}

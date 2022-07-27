//
//  FeedViewModel.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import Combine
import UIKit

class FeedViewModel {
    let key = KeyChainService.shared.key
    var isUpdating: Bool = false
    private let caches = CacheService.shared
    @Published var imageDatas: Photo = []
    var cancellable = Set<AnyCancellable>()

    init() {
        loadImageData()
    }
    
    func loadImageData() {
        isUpdating = true
        let urlString = "https://api.unsplash.com/photos/random"
        guard var components = URLComponents(string: urlString) else {
            return
        }
        
        let query = [
            "client_id":key,
            "count":"15"
        ]
        
        let queryItems = query.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        components.queryItems = queryItems
        guard let requestURL = components.url else {
            return
        }
        
        URLSession.shared
            .dataTaskPublisher(for: requestURL)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: Photo.self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .assign(to: \.imageDatas, on: self)
            .store(in: &cancellable)
        isUpdating = false
    }
}

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
    var isLoading: Bool = false
    var pageNumber: Int = 1
    var imageDatas: [PhotoElement] = []
    
    func loadImageData(completion: @escaping () -> Void) {
        isLoading = true
        
        let urlString = "https://api.unsplash.com/photos/"
        guard var components = URLComponents(string: urlString) else {
            return
        }
        
        let query = [
            "client_id":key,
            "page":"\(pageNumber)",
            "per_page":"15"
        ]
        
        let queryItems = query.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        components.queryItems = queryItems
        guard let componentURL = components.url else {
            return
        }
        URLSession.shared.dataTask(with: componentURL) { data, response, error in
            guard error == nil else {
                print("Error in data add")
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("Error in status code")

                return
            }
            
            guard let data = data else {
                print("Error in decode data")

                return
            }

            do {
                let datas = try JSONDecoder().decode(Photo.self, from: data)

                self.imageDatas.append(contentsOf: datas)

                self.isLoading = false
                self.pageNumber += 1
                completion()
            } catch {
                print("Error in decode data")
            }
        }
        .resume()
    }
}

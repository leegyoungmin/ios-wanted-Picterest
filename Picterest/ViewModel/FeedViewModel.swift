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
    var isLoading: Bool = false
    var pageNumber: Int = 1
    private let caches = CacheService.shared
    private var nextURL: String?
    var imageDatas: [PhotoElement] = []
//    @Published var imageDatas: Photo = []
    var cancellable = Set<AnyCancellable>()

//    init() {
//        loadImageData(isPaging: false) {
//            print("Init")
//        }
//    }
    
    func loadImageData(isPaging: Bool = false, completion: @escaping () -> Void) {
        isUpdating = true
        isLoading = true
        
        var requestURL: URL?
        
        if let nextURL = nextURL {
            requestURL = URL(string: nextURL)

        } else {
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
            requestURL = componentURL
        }
        
        guard let url = requestURL else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("Error in data add")
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("Error in status code")

                return
            }
            
            let links = response.value(forHTTPHeaderField: "Link")?.split(separator: ",")
            if let nextURL = self.parseNextURL(links) {
                print(nextURL)
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
    
    private func parseNextURL(_ links: [Substring]?) -> String? {
        
        guard let value = links?.first(where: { $0.contains("next") }) else {
            return nil
        }
        let pageValue = value.split(separator: ";").first
        var nextPageURL = pageValue?.replacingOccurrences(of: "<", with: "")
        nextPageURL = nextPageURL?.replacingOccurrences(of: ">", with: "")
        
        return nextPageURL
//        let linkList = response.value(forHTTPHeaderField: "Link")?.split(separator: ",")
//        print(linkList)
//        guard let value = linkList?.first(where: {$0.contains("next")}) else {
//            return
//        }
//
//        print(value)
//        print(value.split(separator: ";").first?.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: ""))
    }
}

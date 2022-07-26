//
//  FeedCellViewModel.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit
import Combine

class FeedCellViewModel: ObservableObject {
    @Published var image: UIImage = UIImage()
    var imageLoadTask: URLSessionDataTask?
    
    func loadImage(_ imageURL: String, width: CGFloat) {
        var component = URLComponents(string: imageURL)
        
        let widthQuery = URLQueryItem(name: "w", value: "\(width)")
        
        component?.queryItems?.append(widthQuery)
        
        guard let requestURL = component?.url else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: requestURL) { data, response, error in
            guard error == nil else {
                print("Error in data task \(error?.localizedDescription)")
                return
            }
            
            guard let data = data,
                  let receiveImage = UIImage(data: data) else {
                print("Error in convert Image")
                return
            }
            print(receiveImage)
            self.image = receiveImage
        }
        
        self.imageLoadTask = task
    }
    
    func fetchImage() {
        imageLoadTask?.resume()
    }
    
    func cancelImage(){
        imageLoadTask?.cancel()
    }
}

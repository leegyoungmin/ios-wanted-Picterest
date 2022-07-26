//
//  FeedCellViewModel.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit
import Combine

class FeedCellViewModel: ObservableObject {
    let imageURL: String
    @Published var image: UIImage?
    
    init(imageURL: String) {
        self.imageURL = imageURL
        loadImage()
    }
    
    func loadImage() {
        guard let requestURL = URL(string: imageURL) else {
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { data, response, error in
            guard error == nil else {
                print("Error in data task")
                return
            }
            
            guard let data = data,
                  let receiveImage = UIImage(data: data) else {
                print("Error in convert Image")
                return
            }
            self.image = receiveImage
        }.resume()
    }
}

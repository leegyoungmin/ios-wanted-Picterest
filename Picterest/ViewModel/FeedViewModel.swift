//
//  FeedViewModel.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import Combine
import UIKit

protocol FeedViewModelObservable: AnyObject {
    var isLoading: Bool { get set }
    var pageNumber: Int { get set }
    var imageDataLoader: ImageDataLoader { get }
    var cancellable: Set<AnyCancellable> { get set }
}

class FeedViewModel: FeedViewModelObservable {
    var isLoading: Bool = false
    var pageNumber: Int = 1
    @Published var imageDatas: Photo = []
    var imageDataLoader: ImageDataLoader
    var cancellable = Set<AnyCancellable>()
    
    init(imageDataLoader: ImageDataLoader) {
        self.imageDataLoader = imageDataLoader
    }
    
    func loadImageData() {
        isLoading = true
        
        imageDataLoader.requestNetwork(query: nil) { result in
            switch result {
            case .success(let datas):
                if let photos = datas as? Photo {
                    self.imageDatas.append(contentsOf: photos)
                }
                self.isLoading = false
            case .failure(let error):
                print("Error in decode photo \(error)")
            }
        }
    }
}

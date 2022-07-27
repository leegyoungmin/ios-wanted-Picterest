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
    
    
}

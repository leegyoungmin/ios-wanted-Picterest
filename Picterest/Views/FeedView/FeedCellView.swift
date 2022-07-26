//
//  FeedCellView.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit
import Combine

class FeedCellView: UICollectionViewCell {
    static let identifier = "FeedCellView"
    
    var viewModel: FeedCellViewModel = FeedCellViewModel()
    private var cancellable = Set<AnyCancellable>()
    @Published var imageURL: String?
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.autoresizesSubviews = true
        
        imageView.frame = self.bounds
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        setImageView()
        self.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        $imageURL.sink { urlString in
            if let urlString = urlString {
                self.viewModel.loadImage(urlString, width: frame.size.width)
                self.viewModel.fetchImage()
            }

        }
        .store(in: &cancellable)
        
        viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { image in
                self.imageView.image = image
            }
            .store(in: &cancellable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImageView() {
        contentView.layer.cornerRadius = 15
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.backgroundColor = .gray
        contentView.clipsToBounds = false
    }
    
    override func prepareForReuse() {
        self.imageURL = nil
        viewModel.cancelImage()
        viewModel.image = UIImage()
        imageView.image = nil
        super.prepareForReuse()
    }
    
//    func bindImage() {
//        viewModel?.$image
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { image in
//                self.imageView.image = image
//            })
//            .store(in: &cancellable)
//    }
}

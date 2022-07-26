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
    
    var viewModel: FeedCellViewModel?
    private var cancellable = Set<AnyCancellable>()
    @Published var index: Int = 0
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.autoresizesSubviews = true
        
        label.frame = self.bounds
        label.clipsToBounds = true
        setImageView()
        self.addSubview(label)
        
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
        $index.sink { value in
            self.label.text = value.description
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
        contentView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel?.image = nil
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

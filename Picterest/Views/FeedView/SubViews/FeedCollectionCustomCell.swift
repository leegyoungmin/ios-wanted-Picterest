//
//  FeedCellView.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit

protocol ImageDrawAble: AnyObject {
    var imageLoader: ImageLoader? { get }
    var blurColor: UIColor? { get }
    func setUpTask()
}

class FeedCollectionCustomCell: UICollectionViewCell, ImageDrawAble {
    var blurColor: UIColor?
    var imageLoader: ImageLoader?
    private let cache = CacheService.shared
    static let identifier = "FeedCollectionCustomCell"
    private var dataTask: URLSessionDataTask?
    let blurEffect = UIBlurEffect(style: .regular)
    
    lazy var visualEffectView = UIVisualEffectView(effect: blurEffect)
    
    var topButtonView: CellTopButtonView = {
        let CellTopButtonView = CellTopButtonView()
        return CellTopButtonView
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        
        visualEffectView.alpha = 1.0

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        cancelLoad()
    }
    
    func configureUI() {
        self.autoresizesSubviews = false
        
        [
            imageView,
            topButtonView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.layer.cornerRadius = 15
            $0.clipsToBounds = true
            
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            
            topButtonView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topButtonView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topButtonView.topAnchor.constraint(equalTo: self.topAnchor),
            topButtonView.heightAnchor.constraint(equalToConstant: 35),
        ])
        
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        topButtonView.backgroundColor = .black.withAlphaComponent(0.2)
        topButtonView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        imageView.backgroundColor = blurColor
    }
    
}

extension FeedCollectionCustomCell {
    func setUpTask() {
        
        let query = [
            "w": self.bounds.size.width.description,
            "h": self.bounds.size.height.description
        ]
        
        imageLoader?.requestNetwork(query: query, completion: { result in
            switch result {
            case .success(let data):
                if let image = data as? UIImage {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            case .failure(let error):
                print("Error in download mage \(error)")
            }
        })
        
        imageLoader?.task?.resume()
    }
    
    func cancelLoad() {
        imageLoader?.task?.cancel()
        imageLoader?.task = nil
        imageView.image = nil
    }
}

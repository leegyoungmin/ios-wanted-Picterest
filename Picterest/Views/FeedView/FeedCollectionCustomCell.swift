//
//  FeedCellView.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit

protocol ImageDrawAble: AnyObject {
    var blurEffect: UIBlurEffect { get }
    var visualEffectView: UIVisualEffectView { get }
}

class FeedCollectionCustomCell: UICollectionViewCell, ImageDrawAble {
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDataTask()
        imageView.image = nil
    }
    
    func configureImage(url: String, hexString: String) {
        configureBackground(hexString: hexString)
        setAnimation()
        loadImage(url)
    }
    
    func configureUI() {
        self.autoresizesSubviews = true

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
    }

}

private extension FeedCollectionCustomCell {
    func setUpImageURL(_ url: String) -> URLComponents? {
        var components = URLComponents(string: url)
        let queryItem = URLQueryItem(name: "w", value: self.bounds.size.width.description)
        let heightItem = URLQueryItem(name: "h", value: self.bounds.size.height.description)
        components?.queryItems?.append(queryItem)
        components?.queryItems?.append(heightItem)
        
        return components
    }
    
    func configureBackground(hexString: String) {
        let backgroundColor = UIColor(hexString: hexString)?.withAlphaComponent(0.5)
        self.contentView.backgroundColor = backgroundColor
        self.contentView.layer.cornerRadius = 15
    }
    
    func setAnimation() {
        visualEffectView.alpha = 1
        visualEffectView.frame = self.contentView.frame
        imageView.addSubview(visualEffectView)
    }
    
    func loadCacheImage(path: String) -> Bool {
        if let data = cache.fetchData(path) {
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 1.0) {
                    self.contentView.backgroundColor = .clear
                    self.visualEffectView.alpha = 0
                }
                self.imageView.image = UIImage(data: data)
            }
            return true
        } else {
            return false
        }
    }
    
    func loadImage(_ url: String) {
        
        guard let component = setUpImageURL(url),
              let imageURL = component.url else {
            return
        }
        
        if !loadCacheImage(path: imageURL.absoluteString) {
            dataTask = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
                guard error == nil else {
                    print("Error in data task \(error?.localizedDescription)")
                    return
                }
                
                guard let data = data,
                      let receiveImage = UIImage(data: data) else {
                    print("Error in convert Image")
                    return
                }
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1.0) {
                        self?.contentView.backgroundColor = .clear
                        self?.visualEffectView.alpha = 0
                    }
                    self?.imageView.image = receiveImage
                    self?.cache.uploadData(key: imageURL.absoluteString, data: data)
                }
            }
            
            dataTask?.resume()
        }
    }
    
    func cancelDataTask() {
        dataTask?.cancel()
        dataTask = nil
    }
}

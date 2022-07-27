//
//  FeedCellView.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit

class FeedCellView: UICollectionViewCell {
    private let cache = CacheService.shared
    static let identifier = "FeedCellView"
    private var dataTask: URLSessionDataTask?
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.frame = self.bounds
        self.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelDataTask()
        imageView.image = nil
    }
    
    func configureBackground(hexString: String) {
        let backgroundColor = UIColor(hexString: hexString)?.withAlphaComponent(0.5)
        self.contentView.backgroundColor = backgroundColor
        self.contentView.layer.cornerRadius = 15
        self.contentView.clipsToBounds = true
    }
    
    func configureImage(url: String, hexString: String) {
        var components = URLComponents(string: url)
        let queryItem = URLQueryItem(name: "w", value: self.bounds.size.width.description)
        let heightItem = URLQueryItem(name: "h", value: self.bounds.size.height.description)
        components?.queryItems?.append(queryItem)
        components?.queryItems?.append(heightItem)
        
        guard let imageURL = components?.url else {
            return
        }
        
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.alpha = 1
        visualEffectView.frame = self.contentView.frame
        imageView.addSubview(visualEffectView)
        
        
        if let data = cache.fetchData(imageURL.absoluteString) {
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 1.0) {
                    visualEffectView.alpha = 0
                }
                self.imageView.image = UIImage(data: data)
            }
            return
        }
        
        
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
                    visualEffectView.alpha = 0
                }
                self?.imageView.image = receiveImage
                self?.cache.uploadData(key: imageURL.absoluteString, data: data)
            }
        }
        
        dataTask?.resume()
    }
    
    private func cancelDataTask() {
        dataTask?.cancel()
        dataTask = nil
    }
}

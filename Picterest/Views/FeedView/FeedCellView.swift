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

class FeedCellView: UICollectionViewCell, ImageDrawAble {
    private let cache = CacheService.shared
    static let identifier = "FeedCellView"
    private var dataTask: URLSessionDataTask?
    let blurEffect = UIBlurEffect(style: .regular)
    lazy var visualEffectView = UIVisualEffectView(effect: blurEffect)
    
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
    }
    
    private func setUpImageURL(_ url: String) -> URLComponents? {
        var components = URLComponents(string: url)
        let queryItem = URLQueryItem(name: "w", value: self.bounds.size.width.description)
        let heightItem = URLQueryItem(name: "h", value: self.bounds.size.height.description)
        components?.queryItems?.append(queryItem)
        components?.queryItems?.append(heightItem)
        
        return components
    }
    
    private func setAnimation() {
        visualEffectView.alpha = 1
        visualEffectView.frame = self.contentView.frame
        imageView.addSubview(visualEffectView)
    }
    
    func configureImage(url: String, hexString: String) {
        setAnimation()
        guard let component = setUpImageURL(url),
              let imageURL = component.url else {
            return
        }
        
        if let data = cache.fetchData(imageURL.absoluteString) {
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 1.0) {
                    self.contentView.backgroundColor = .clear
                    self.visualEffectView.alpha = 0
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
                    self?.contentView.backgroundColor = .clear
                    self?.visualEffectView.alpha = 0
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

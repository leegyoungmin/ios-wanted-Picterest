//
//  SavedCollectionCustomCell.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/28.
//

import UIKit

class SavedCollectionCustomCell: UICollectionViewCell {
    static let identifier = "SavedCollectionCustomCell"
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    let topView = CellTopButtonView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.autoresizesSubviews = true
        self.layer.cornerRadius = 15
        [
            imageView,
            topView
        ].forEach {
            $0.layer.cornerRadius = 15
            $0.clipsToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            
            topView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topView.topAnchor.constraint(equalTo: self.topAnchor),
            topView.heightAnchor.constraint(equalToConstant: 35),
            
        ])
        
        imageView.frame = self.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        topView.backgroundColor = .black.withAlphaComponent(0.5)
        topView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        super.prepareForReuse()
    }
}

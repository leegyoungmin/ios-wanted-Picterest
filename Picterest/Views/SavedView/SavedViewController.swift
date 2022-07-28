//
//  SavedViewController.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit

class SavedViewController: UIViewController {
    let coreDataService = CoreDataService.shared
    
    lazy var collectionView: UICollectionView = {
        let layout = SavedCollectionViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            SavedCollectionCustomCell.self,
            forCellWithReuseIdentifier: SavedCollectionCustomCell.identifier
        )
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureUI()
    }
    
    func configureUI() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

extension SavedViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 20
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SavedCollectionCustomCell.identifier,
            for: indexPath
        ) as? SavedCollectionCustomCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
}


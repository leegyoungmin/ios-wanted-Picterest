//
//  SavedViewController.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit
import CoreData

class SavedViewController: UIViewController {
    let coreDataService = CoreDataService.shared
    private var imageDatas: [savedModel] = []
    private let imageDownLoader = DownLoadManager()
    
    lazy var collectionView: UICollectionView = {
        let layout = SavedCollectionViewLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            SavedCollectionCustomCell.self,
            forCellWithReuseIdentifier: SavedCollectionCustomCell.identifier
        )
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        coreDataService.deleteAll() // 전체 삭제 메서드
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        super.viewWillAppear(animated)
    }
    
    func fetchData() {
        if let datas = coreDataService.fetch() as? [SavedModel] {
            datas.forEach { model in
                let savedModel = savedModel(id: model.id,
                                            meme: model.memo,
                                            file: model.fileURL,
                                            raw: model.rawURL)

                self.imageDatas.append(savedModel)
                print(savedModel.image?.size)
            }
        }
    }
    
    func configureUI() {
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
// MARK: - CollectionView DataSource
extension SavedViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return imageDatas.count
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
        guard let image = imageDatas[indexPath.row].image else {
            return UICollectionViewCell()
        }
        cell.imageView.image = image.resizeImageTo(newWidth: cell.bounds.width)
        
        cell.topView.delegate = self
        cell.tag = indexPath.row
        return cell
    }
}

extension SavedViewController: SaveCollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath: IndexPath
    ) -> CGFloat {
        let inset = collectionView.contentInset
        let insetSize = inset.left + inset.right
        let contentWidth = collectionView.frame.width
        guard let image = imageDatas[heightForPhotoAtIndexPath.row].image else {
            return 0
        }
        return (contentWidth - insetSize) * (image.size.height / image.size.width)
    }
}

extension SavedViewController: CellTopButtonDelegate {
    func CellTopButton(to starButton: UIButton) {
        print(starButton.tag)
    }
    
    
}

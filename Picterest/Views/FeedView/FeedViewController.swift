//
//  FeedViewController.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit
import Combine

class FeedViewController: UIViewController {
    let viewModel: FeedViewModel
    private var bag: [UUID: AnyCancellable] = [:]
    
    lazy var collectionView: UICollectionView = {
        let layout = FeedCollectionLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
        collectionView.register(FeedCollectionCustomCell.self, forCellWithReuseIdentifier: FeedCollectionCustomCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return collectionView
    }()
    
    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = FeedViewModel()
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        configView()
        bindImageData()
    }
}

extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if collectionView.contentOffset.y > (collectionView.contentSize.height - self.collectionView.bounds.size.height) {
//            print("do updating")
//            if !viewModel.isUpdating {
//                viewModel.addImageDatas()
//
//                collectionView.reloadData()
//            }
//        }
    }
}

extension FeedViewController: UICollectionViewDelegate {
    
}


extension FeedViewController: CellTopButtonDelegate {
    func CellTopButton(to didTapStarButton: UIButton) {
        let isSelected = didTapStarButton.isSelected
        didTapStarButton.isSelected = !isSelected
        if didTapStarButton.isSelected {
            didTapStarButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            didTapStarButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
}

// MARK: - UICollectionView DataSource Prefetching
extension FeedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        indexPaths.forEach { indexPath in
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? FeedCollectionCustomCell else {
                return
            }
            
            let imageData = viewModel.imageDatas[indexPath.row]
            cell.configureImage(url: imageData.urls.raw, hexString: imageData.color)
        }
    }
}

// MARK: - CollectionView DataSource
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return viewModel.imageDatas.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeedCollectionCustomCell.identifier,
            for: indexPath
        ) as? FeedCollectionCustomCell else {
            return UICollectionViewCell()
        }
        let imageData = viewModel.imageDatas[indexPath.row]
        cell.topButtonView.delegate = self
        cell.configureImage(url: imageData.urls.raw, hexString: imageData.color)
        cell.topButtonView.indexLabel.text = indexPath.row.description + "번째 사진입니다."
        return cell
    }
}

// MARK: - FeedCollectionLayout Delegate
extension FeedViewController: FeedCollectionLayoutDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        heightRateForPhotoAtIndexPath indexPath: IndexPath
    ) -> CGFloat {
        let item = viewModel.imageDatas[indexPath.item]
        return item.ratio
    }
}


// MARK: - Binding Methods
private extension FeedViewController {
    func bindImageData() {
        viewModel.$imageDatas
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &viewModel.cancellable)
    }
}

// MARK: - UI Configure Methods
private extension FeedViewController {
    func setUpNavBar() {
        navigationItem.title = "피드"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    func configView() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }
}

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
    
    lazy var collectionView: UICollectionView = {
        let layout = FeedCollectionLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FeedCellView.self, forCellWithReuseIdentifier: FeedCellView.identifier)
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
        view.backgroundColor = .lightGray
        bindImageData()
    }
}

// MARK: - CollectionView DataSource
extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.imageDatas.isEmpty ? 0 : viewModel.imageDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedCellView.identifier, for: indexPath) as? FeedCellView else {
            return UICollectionViewCell()
        }
        return cell
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let itemSize = (collectionView.frame.width - (collectionView.contentInset.left + collectionView.contentInset.right + 10)) / 2
      return CGSize(width: itemSize, height: itemSize)
    }
}

extension FeedViewController: FeedCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightRateForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let item = viewModel.imageDatas[indexPath.item]
        return CGFloat(item.height) / CGFloat(item.width)
    }
}


// MARK: - Binding Methods
private extension FeedViewController {
    func bindImageData() {
        viewModel.$imageDatas
            .receive(on: DispatchQueue.main)
            .sink { images in
                if !images.isEmpty {
                    self.collectionView.invalidateIntrinsicContentSize()
                    self.collectionView.reloadData()
                }
                print(images)
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
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//
//  FeedViewController.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/25.
//

import UIKit
import Combine
import CoreData

class FeedViewController: UIViewController {
    let coreDataService = CoreDataService.shared
    let viewModel: FeedViewModel
    private var isLoading: Bool = false
    
    lazy var collectionView: UICollectionView = {
        let layout = FeedCollectionLayout()
        layout.delegate = self
        let collectionView = UICollectionView(frame: .zero,collectionViewLayout: layout)
        collectionView.register(FeedCollectionCustomCell.self, forCellWithReuseIdentifier: FeedCollectionCustomCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return collectionView
    }()
    
    init(observable: FeedViewModelObservable) {
        self.viewModel = FeedViewModel(imageDataLoader: observable.imageDataLoader)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = FeedViewModel(imageDataLoader: ImageDataLoader(apiKey: KeyChainService.shared.key))
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        configView()
        bindImageData()
    }
    
}

private extension CoreDataService {
    func save(pictureId: String, memo: String, rawURL: String, fileLocation: String) -> Bool {
        let context = self.persistentContrainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "SavedModel", into: context)
        
        object.setValue(pictureId, forKey: "id")
        object.setValue(memo, forKey: "memo")
        object.setValue(rawURL, forKey: "rawURL")
        object.setValue(fileLocation, forKey: "fileURL")
        print(object)
        do {
            self.saveContext()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
}

// MARK: - ScrollView Delegate
extension FeedViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
        
        if position > collectionView.contentSize.height - 100 - scrollView.frame.size.height {
            guard !viewModel.isLoading else {
                return
            }
            
            viewModel.loadImageData()
        }
    }
}



// MARK: - Cell Top Button Delegate
extension FeedViewController: CellTopButtonDelegate {
    func CellTopButton(to didTapStarButton: UIButton) {
        if didTapStarButton.isSelected {
            presentErrorAlert()
        } else {
            presentWriteAlert(sender: didTapStarButton)
        }
    }
}
// MARK: - CollectionView Delegate
extension FeedViewController: UICollectionViewDelegate {}

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
        cell.imageLoader = ImageLoader(baseURL: imageData.urls.raw)
        cell.setUpTask()
        cell.topButtonView.delegate = self
        cell.topButtonView.starButton.tag = indexPath.row
        cell.blurColor = UIColor(hexString: imageData.color)
//        print(indexPath.row, imageData.urls.raw)
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
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] images in
                
                UIViewPropertyAnimator(duration: 2, curve: .easeInOut) {
                    self?.collectionView.reloadData()
                    self?.collectionView.collectionViewLayout.invalidateLayout()
                }
                .startAnimation()
                
            }
            .store(in: &viewModel.cancellable)
    }
}

// MARK: - UI Configure Methods
private extension FeedViewController {
    
    func presentErrorAlert() {
        let alertController = UIAlertController(
            title: "저장오류",
            message: "이미 저장된 사진입니다.",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "확인", style: .default)
        alertController.addAction(confirmAction)
        present(alertController, animated: true)
    }
    
    func presentWriteAlert(sender: UIButton) {
        let alertController = UIAlertController(
            title: "사진저장",
            message: "사진과 함께 남길 메모를 작성해주세요.",
            preferredStyle: .alert
        )
        
        let confirmAction = UIAlertAction(title: "저장", style: .default) { action in
            if let writtenText = alertController.textFields?.first?.text {
                sender.isSelected = true
                sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
                
                if self.viewModel.imageDatas.count > sender.tag {
                    let item = self.viewModel.imageDatas[sender.tag]
                    
                    let saveResult = self.coreDataService.save(pictureId: item.id, memo: writtenText, rawURL: item.urls.raw, fileLocation: item.urls.raw)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .destructive) { action in
            sender.isSelected = false
            sender.setImage(UIImage(systemName: "star"), for: .normal)
        }
        [cancelAction,confirmAction].forEach {
            alertController.addAction($0)
        }
        
        alertController.addTextField()
        
        self.present(alertController, animated: true)
    }
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

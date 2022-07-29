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
    private let coreDataService = CoreDataService.shared
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
        
        let imageSizeQuery = [
            "w": cell.frame.size.width.description,
            "h": cell.frame.size.height.description
        ]
        
        cell.imageLoader = ImageLoader(baseURL: imageData.urls.raw, query: imageSizeQuery)
        cell.setUpTask()
        cell.topButtonView.delegate = self
        cell.topButtonView.starButton.tag = indexPath.row
        cell.blurColor = UIColor(hexString: imageData.color)
        
        if let fetchedData = coreDataService.fetch() as? [SavedModel] {
            let fetchIDs = fetchedData.compactMap {
                $0.id
            }
            print(fetchIDs)
            print(imageData.id)
            if fetchIDs.contains(imageData.id) {
                cell.topButtonView.starButton.isSelected = true
                cell.topButtonView.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
        }
        
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
        let alertController = AlertViewController(
            titleText: "저장오류",
            messageText: "이미 저장된 사진입니다."
        ) { _ in }
        present(alertController, animated: false)
    }
    
    func presentWriteAlert(sender: UIButton) {
        
        let alertController = AlertViewController(
            titleText: "저장 안내",
            messageText: "사진과 함께 남길 메모를 작성해주세요.",
            alertType: .confirmTextField
        ) { [weak self] inputValue in
            self?.confirmAction(sender: sender, inputValue: inputValue ?? "")
        }
        self.present(alertController, animated: false)
    }
    
    func confirmAction(sender: UIButton, inputValue: String) {
        sender.isSelected = true
        sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
        
        let data = self.viewModel.imageDatas[sender.tag]
        let width = self.collectionView.frame.size.width
        let imageLoader = ImageLoader(baseURL: data.urls.regular, query: ["w":width.description])
        
        imageLoader.requestNetwork { result in
            switch result {
            case .success(let image):
                if let image = image as? UIImage, let imageData = image.pngData() {
                    let imageKey = data.id.description + ".png"
                    if DownLoadManager().uploadData(imageKey, data: imageData) {
                        let _ = self.coreDataService.save(
                            pictureId: data.id,
                            memo: inputValue,
                            rawURL: data.urls.raw,
                            fileLocation: imageKey
                        )
                    }
                }
            case .failure(_):
                print("Error in download image")
            }
        }
        
        imageLoader.task?.resume()
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

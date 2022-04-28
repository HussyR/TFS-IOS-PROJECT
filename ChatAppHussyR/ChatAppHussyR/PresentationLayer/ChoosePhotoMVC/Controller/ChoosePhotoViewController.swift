//
//  ChoosePhotoViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 26.04.2022.
//

import UIKit

protocol ChoosePhotoViewControllerDelegate: AnyObject {
    func choosePhotoViewControllerDelegate(image: UIImage)
    func choosePhotoViewControllerDelegate(url: String)
}

class ChoosePhotoViewController: UIViewController {

    var networkService: NetworkServiceProtocol?
    var isLoaded = false
    var currentPage = 1
    weak var delegate: ChoosePhotoViewControllerDelegate?
    
    var photosURL = [Photo]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                print(self.photosURL.count)
                self.collectionView.reloadData()
            }
        }
    }
    
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let inset: CGFloat = 6
        let cellWidth = (view.frame.width - inset * 4) / 3
        layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        layout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        layout.minimumLineSpacing = inset
        layout.minimumInteritemSpacing = inset
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        setupUI()
        loadPhotosUrls()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - LOGIC
    
    private func loadPhotosUrls() {
        networkService?.getPictures(numberOfPhotos: 50, topic: "dog", page: 1) { [weak self] result in
            guard let self = self else { return }
            self.currentPage += 1
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let photos):
                self.photosURL = photos
            }
        }
    }
    
    private func fillCellWithImage(indexPath: IndexPath, url: String) {
        DispatchQueue.global().async {
            self.networkService?.loadPicture(url: url) { result in
                switch result {
                case .success(let imageData):
                    DispatchQueue.main.async {
                        let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCell
                        guard let image = UIImage(data: imageData) else { return }
                        cell?.configure(image: image)
                        cell?.changeActivity(isActive: false)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension ChoosePhotoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.identifier,
            for: indexPath) as? PhotoCell else {
            fatalError("")
        }
        cell.changeActivity(isActive: true)
        fillCellWithImage(indexPath: indexPath, url: photosURL[indexPath.row].previewUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = photosURL[indexPath.item].largeImageURL
        DispatchQueue.global().async {
            self.networkService?.loadPicture(url: url) { result in
                switch result {
                case .success(let imageData):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self,
                              let image = UIImage(data: imageData)
                        else { return }
                        self.delegate?.choosePhotoViewControllerDelegate(image: image)
                        self.delegate?.choosePhotoViewControllerDelegate(url: url)
                        self.dismiss(animated: true)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
    }
    
}

extension ChoosePhotoViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y + scrollView.frame.size.height
        if !isLoaded {
            if position > scrollView.contentSize.height - 20 {
                isLoaded = true
                networkService?.getPictures(numberOfPhotos: 50, topic: "dog", page: currentPage) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let photos):
                        self.photosURL.append(contentsOf: photos)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                    self.isLoaded = false
                    self.currentPage += 1
                }
            }
        }
    }
    
}

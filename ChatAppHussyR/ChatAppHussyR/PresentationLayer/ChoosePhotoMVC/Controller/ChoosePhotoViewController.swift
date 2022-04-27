//
//  ChoosePhotoViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 26.04.2022.
//

import UIKit

class ChoosePhotoViewController: UIViewController {

    var networkService = NetworkService()
    
    var photos = [Photo]() {
        didSet {
            
        }
    }
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkService.getPictures(numberOfPhotos: 200, topic: "avatar", complitionHandler: { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let photos):
                self.photos = photos
            }
        }, on: DispatchQueue.main)
    }
}



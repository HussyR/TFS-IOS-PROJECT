//
//  ViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.02.2022.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print(saveButton.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Actions
    
    @objc private func editTapped() {
        print("Выбери изображение профиля")
        let alert = UIAlertController(title: "Изображение профиля", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: {[weak self] _ in
            guard let self = self else {return}
            self.showImagePickerController(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: {[weak self] _ in
            guard let self = self else {return}
            self.showImagePickerController(sourceType: UIImagePickerController.SourceType.camera)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.mediaTypes = ["public.image"]
        vc.allowsEditing = true
        vc.delegate = self
        print(AVCaptureDevice.authorizationStatus(for: .video).rawValue)
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {return}
        if sourceType == .photoLibrary {
            vc.sourceType = sourceType
            self.present(vc, animated: true)
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized ||
                  AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined
        {
            vc.sourceType = sourceType
            self.present(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Разрешите доступ", message: "Выбранный вами способ недоступен", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .cancel))
            self.show(alert, sender: self)
        }
    }
    
    //MARK: Setup UI Layout
    
    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(myProfileLabel)
        navigationView.addSubview(closeButton)
        
        view.addSubview(avatarImageView)
        view.addSubview(editButton)
        
        view.addSubview(nameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(saveButton)
        
        // Чтобы настроить адаптацию под маленькие устройства
        let avatarWidthConstraint = avatarImageView.widthAnchor.constraint(equalToConstant: 240)
        avatarWidthConstraint.priority = UILayoutPriority(999)

        
        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationView.heightAnchor.constraint(equalToConstant: 96),
            
            myProfileLabel.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            myProfileLabel.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor, constant: 16),
            
            closeButton.centerYAnchor.constraint(equalTo: navigationView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor, constant: -16),
            
            avatarImageView.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 7),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarWidthConstraint,
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            avatarImageView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 68),
            avatarImageView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -68),
            
            editButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            editButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 22),
            
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 10),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 32),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 78),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -78),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
    }
    
    //MARK: UIElements
    
    let navigationView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        return view
    }()
    
    let myProfileLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "My Profile"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 26)
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let avatarImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black.withAlphaComponent(0.04)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Danila Ryabikov"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 24)
        return label
    }()
    
    let descriptionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UX/UI designer, web-designer Moscow, Russia"
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
}

//MARK: Lifecycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        setupLayout()
        print(saveButton.frame) // Здесь еще не известны резмеры UI элементов
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(saveButton.frame) \(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(saveButton.frame) // В данном методе уже известны размеры ui элементов
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("\(saveButton.frame) \(#function)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
        print("\(saveButton.frame) \(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

}
//MARK: UINavigationControllerDelegate, UIImagePickerControllerDelegate
extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            avatarImageView.image = image
        } else if let image = info[.editedImage] as? UIImage {
            avatarImageView.image = image
        }
    }
}

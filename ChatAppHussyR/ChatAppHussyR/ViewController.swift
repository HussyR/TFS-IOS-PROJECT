//
//  ViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.02.2022.
//

import UIKit

class ViewController: UIViewController {

    
    //MARK: Actions
    
    @objc private func editTapped() {
        print("Выбери изображение профиля")
        let alert = UIAlertController(title: "Изображение профиля", message: "awd", preferredStyle: .actionSheet)
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
        view.backgroundColor = UIColor.black.withAlphaComponent(0.02)
        return view
    }()
    
    let myProfileLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "My Profile"
        label.textColor = .black
        return label
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    let avatarImageView : UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let nameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Danila Ryabikov"
        label.textColor = .black
        return label
    }()
    
    let descriptionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UX/UI designer, web-designer Moscow, Russia"
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black.withAlphaComponent(0.02)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2

    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

}

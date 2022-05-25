//
//  ViewController.swift
//  ChatAppHussyR
//
//  Created by Данил on 18.02.2022.
//

import UIKit
import Foundation
import AVFoundation

enum SaveMethod {
    case GCD
    case operation
}

class ProfileViewController: UIViewController {

    var theme: Theme = .classic
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var networkService: NetworkServiceProtocol?
    var oldSavedName: String?
    var oldSavedDescription: String?
    var oldImage: UIImage?
    var oldImageFlag = false
    
    // MARK: - Actions
    
    @objc private func editImageTapped() {
        print("Выбери изображение профиля")
        let alert = UIAlertController(title: "Изображение профиля", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Установить из галереи", style: .default, handler: {[weak self] _ in
            guard let self = self else { return }
            self.showImagePickerController(sourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: {[weak self] _ in
            guard let self = self else { return }
            self.showImagePickerController(sourceType: UIImagePickerController.SourceType.camera)
        }))
        alert.addAction(UIAlertAction(title: "Загрузить", style: .default, handler: {[weak self] _ in
            guard let self = self else { return }
            let vc = ChoosePhotoViewController()
            vc.networkService = self.networkService
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func closeAction() {
        self.dismiss(animated: true)
    }
    
    @objc private func editTextTapped() {
        nameTextField.becomeFirstResponder()
        showButtons(show: false)
        isEdit(isEdit: true)
        updateSavedUI()
    }
    
    @objc private func cancelEditing() {
        isEdit(isEdit: false)
        if hasChanges() {
            nameTextField.text = oldSavedName
            descriptionTextView.text = oldSavedDescription
            avatarImageView.image = oldImage
        }
    }
    
    @objc private func saveGCD() {
        showButtons(show: false)
        activityIndicator.startAnimating()
        let profileData = self.makeProfileModel()
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let success = DataManagerGCDService.shared.writeProfileData(model: profileData)
            print("data saved")
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.showAlertWhenSuccessOrFailSave(isSuccess: success, method: .GCD)
            }
        }
    }
    
    // MARK: - Logic
    
    private func makeProfileModel() -> ProfileModel {
        let name = nameTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        let imageData = avatarImageView.image?.pngData()
        let profileData = ProfileModel(name: name, description: description, image: imageData)
        return profileData
    }
    
    // Метод показывает алерты и в случае нажатия повторения вызывает соотв. методы сохранения
    private func showAlertWhenSuccessOrFailSave(isSuccess: Bool, method: SaveMethod) {
        if isSuccess {
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.showButtons(show: true)
                    self.isEdit(isEdit: false)
                }))
                self.updateSavedUI()
                self.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Ошибка", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.showButtons(show: true)
            }))
            alert.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                switch method {
                case .GCD:
                    self.saveGCD()
                case .operation:
                    print("Раньше здесь было сохранение через Operations))")
                }
            }))
            self.present(alert, animated: true)
        }
    }
    
    private func readProfileData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let result = DataManagerGCDService.shared.readProfileData()
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    let description = (model.description.isEmpty ? "description": model.description)
                    self.nameTextField.text = model.name
                    self.descriptionTextView.text = description
                    if let data = model.image,
                       let image = UIImage(data: data) {
                        self.avatarImageView.image = image
                    }
                    self.updateSavedUI()
                }
            case .failure(let error):
                print("Данные профиля не прочитаны")
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateSavedUI() {
        oldSavedName = nameTextField.text
        oldSavedDescription = descriptionTextView.text
        oldImage = avatarImageView.image
        oldImageFlag = false
    }
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let vc = UIImagePickerController()
        vc.mediaTypes = ["public.image"]
        vc.allowsEditing = true
        vc.delegate = self
        print(AVCaptureDevice.authorizationStatus(for: .video).rawValue)
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        if sourceType == .photoLibrary {
            vc.sourceType = sourceType
            self.present(vc, animated: true)
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized ||
                  AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            vc.sourceType = sourceType
            self.present(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Разрешите доступ", message: "Выбранный вами способ недоступен", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .cancel))
            self.show(alert, sender: self)
        }
    }
    
    private func isEdit(isEdit: Bool) {
        if isEdit {
            animateCancelButton()
        } else {
            cancelButton.layer.removeAllAnimations()
        }
        
        editTextButton.isHidden = isEdit
        cancelButton.isHidden = !isEdit
        saveButton.isHidden = !isEdit
        nameTextField.isUserInteractionEnabled = isEdit
        descriptionTextView.isUserInteractionEnabled = isEdit
    }
    
    private func animateCancelButton() {
        let width = cancelButton.frame.midX
        let height = cancelButton.frame.midY
        let animationMove = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        // Сделал только на 5 градусов, так как на 18 слишком сильно ее крутит))
        animationMove.values = [0, -(Float.pi / 180) * 5, 0, +(Float.pi / 180) * 5, 0]

        let animationMoveXY = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animationMoveXY.values = [
            CGPoint(x: width, y: height),
            CGPoint(x: width + 5, y: height),
            CGPoint(x: width, y: height),
            CGPoint(x: width - 5, y: height),
            CGPoint(x: width, y: height),
            CGPoint(x: width, y: height + 5),
            CGPoint(x: width, y: height),
            CGPoint(x: width, y: height - 5),
            CGPoint(x: width, y: height)
        ]

        let group = CAAnimationGroup()
        group.duration = 0.3
        group.repeatCount = .infinity
        group.animations = [animationMove, animationMoveXY]

        cancelButton.layer.add(group, forKey: "key")
    }
    
    private func hasChanges() -> Bool {
        if nameTextField.text != oldSavedName ||
            descriptionTextView.text != oldSavedDescription ||
            oldImageFlag {
            return true
        }
        return false
    }
    
    private func showButtons(show: Bool) {
        saveButton.isEnabled = show
        if show {
            saveButton.alpha = 1
        } else {
            saveButton.alpha = 0.5
        }
        
    }
    
    // MARK: - Theme
    
    private func setupTheme() {
        switch theme {
        case .night:
            view.backgroundColor = .black
            myProfileLabel.textColor = .white
            navigationView.backgroundColor = .clear
            nameTextField.textColor = .white
            descriptionTextView.textColor = .white
        default:
            view.backgroundColor = .white
            myProfileLabel.textColor = .black
            navigationView.backgroundColor = .black.withAlphaComponent(0.04)
            nameTextField.textColor = .black
            descriptionTextView.textColor = .black
        }
    }
    
    // MARK: - Hide keyboard
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Setup UI Actions
    
    private func setupUIActions() {
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        editAvatarButton.addTarget(self, action: #selector(editImageTapped), for: .touchUpInside)
        editTextButton.addTarget(self, action: #selector(editTextTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelEditing), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveGCD), for: .touchUpInside)
    }
    
    // MARK: - Setup UI Layout
    
    private func setupLayout() {
        view.addSubview(navigationView)
        navigationView.addSubview(myProfileLabel)
        navigationView.addSubview(closeButton)
        
        view.addSubview(avatarImageView)
        view.addSubview(editAvatarButton)
        
        view.addSubview(nameTextField)
        view.addSubview(descriptionTextView)
        view.addSubview(saveButton)
        view.addSubview(cancelButton)
        view.addSubview(editTextButton)
        view.addSubview(activityIndicator)
        
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
            
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 22),
            
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.topAnchor.constraint(equalTo: editAvatarButton.bottomAnchor, constant: 10),
            
            descriptionTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 10),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -100),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            saveButton.heightAnchor.constraint(equalToConstant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
            
            editTextButton.heightAnchor.constraint(equalToConstant: 40),
            editTextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            editTextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            editTextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: editTextButton.topAnchor, constant: -20)
        ])
        
    }
    
    // MARK: - UIElements
    
    let navigationView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.04)
        return view
    }()
    
    let myProfileLabel: UILabel = {
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
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .black.withAlphaComponent(0.04)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let editAvatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.accessibilityIdentifier = "editProfile"
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        textField.placeholder = "Full name"
        textField.textAlignment = .center
        textField.textColor = .black
        textField.font = UIFont.boldSystemFont(ofSize: 24)
        return textField
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isUserInteractionEnabled = false
        textView.text = "Description"
        textView.isScrollEnabled = false
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }()
    
    let editTextButton: UIButton = {
        let button = UIButton()
        button.accessibilityIdentifier = "editText"
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.alpha = 0.5
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black.withAlphaComponent(0.04)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

// MARK: - Lifecycle

extension ProfileViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupUIActions()
        setupTheme()
        isEdit(isEdit: false)
        
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        
        readProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.width / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

}

// MARK: - UINavigationControllerDelegate, UIImagePickerControllerDelegate

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            oldImage = avatarImageView.image
            isEdit(isEdit: true)
            avatarImageView.image = image
            oldImageFlag = true
            showButtons(show: true)
        } else if let image = info[.editedImage] as? UIImage {
            oldImage = avatarImageView.image
            isEdit(isEdit: true)
            avatarImageView.image = image
            oldImageFlag = true
            showButtons(show: true)
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if hasChanges() {
            print(#function)
            showButtons(show: true)
        } else {
            showButtons(show: false)
        }
    }
}

extension ProfileViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        if hasChanges() {
            print(#function)
            showButtons(show: true)
        } else {
            showButtons(show: false)
        }
    }
}

extension ProfileViewController: ChoosePhotoViewControllerDelegate {
    func choosePhotoViewControllerDelegate(image: UIImage) {
        oldImage = avatarImageView.image
        isEdit(isEdit: true)
        avatarImageView.image = image
        oldImageFlag = true
        showButtons(show: true)
    }
    
    func choosePhotoViewControllerDelegate(url: String) {
        print(url)
    }
}
